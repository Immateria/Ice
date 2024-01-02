//
//  MenuBarItemManager.swift
//  Ice
//

import Combine
import OSLog
import ScreenCaptureKit

class MenuBarItemManager: ObservableObject {
    /// An error that can occur during the retrieval of shareable content.
    enum ShareableContentError: Error {
        /// No menu bar window exists.
        case noMenuBarWindow
    }

    /// An error that can be thrown during menu bar item movement.
    enum MoveError: Error {
        case eventFailure
        case noScreen
        case macOSProhibited(MenuBarItem)
        case noCurrentWindow(MenuBarItem)
    }

    /// All items in the menu bar.
    @Published private(set) var items = [MenuBarItem]()

    /// The items in the "Visible" section in the menu bar.
    @Published private(set) var visibleItems = [MenuBarItem]()

    /// The items in the "Hidden" section in the menu bar.
    @Published private(set) var hiddenItems = [MenuBarItem]()

    /// The items in the "Always Hidden" section in the menu bar.
    @Published private(set) var alwaysHiddenItems = [MenuBarItem]()

    private(set) weak var menuBarManager: MenuBarManager?

    private var timer: AnyCancellable?
    private var previousWindowCount = 0

    private var cancellables = Set<AnyCancellable>()

    init(menuBarManager: MenuBarManager) {
        self.menuBarManager = menuBarManager
        configureCancellables()
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        $items
            .sink { [weak self] items in
                guard
                    let self,
                    let menuBarManager,
                    let hiddenSection = menuBarManager.section(withName: .hidden),
                    let alwaysHiddenSection = menuBarManager.section(withName: .alwaysHidden)
                else {
                    return
                }

                visibleItems = items.filter { item in
                    item.window.frame.midX > (hiddenSection.controlItem.windowFrame?.midX ?? 0)
                }
                if alwaysHiddenSection.isEnabled {
                    hiddenItems = items.filter { item in
                        item.window.frame.midX < (hiddenSection.controlItem.windowFrame?.midX ?? 0) &&
                        item.window.frame.midX > (alwaysHiddenSection.controlItem.windowFrame?.midX ?? 0)
                    }
                    alwaysHiddenItems = items.filter { item in
                        item.window.frame.midX < (alwaysHiddenSection.controlItem.windowFrame?.midX ?? 0)
                    }
                } else {
                    hiddenItems = items.filter { item in
                        item.window.frame.midX < (hiddenSection.controlItem.windowFrame?.midX ?? 0)
                    }
                    alwaysHiddenItems = []
                }
            }
            .store(in: &c)

        cancellables = c
    }

    /// Starts observing the menu bar, updating the ``items``
    /// property whenever the number of menu bar items changes.
    func startObserving() {
        Task { @MainActor in
            try await self.updateItems()
        }
        timer = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                Task { @MainActor in
                    try await self.updateItems()
                }
            }
    }

    /// Stops observing the menu bar.
    func stopObserving() {
        timer?.cancel()
        timer = nil
    }

    /// Returns an array of the windows belonging to the items
    /// in the menu bar.
    private func getMenuBarItemWindows() async throws -> [SCWindow] {
        let menuBarWindowPredicate: (SCWindow) -> Bool = { window in
            // menu bar window belongs to the WindowServer process
            // (identified by an empty string)
            window.owningApplication?.bundleIdentifier == "" &&
            window.windowLayer == kCGMainMenuWindowLevel &&
            window.title == "Menubar"
        }

        let content = try await SCShareableContent.current

        guard let menuBarWindow = content.windows.first(where: menuBarWindowPredicate) else {
            throw ShareableContentError.noMenuBarWindow
        }

        return content.windows
            .filter { window in
                // must have status window level
                window.windowLayer == kCGStatusWindowLevel &&
                // must fit vertically inside menu bar window
                window.frame.minY == menuBarWindow.frame.minY &&
                window.frame.maxY == menuBarWindow.frame.maxY
            }
            .sorted { first, second in
                first.frame.minX < second.frame.minX
            }
    }

    /// Returns the current hiding states of all sections in
    /// the menu bar.
    private func getCurrentHidingStates() -> [MenuBarSection.Name: ControlItem.HidingState] {
        var states = [MenuBarSection.Name: ControlItem.HidingState]()
        if let menuBarManager {
            for section in menuBarManager.sections {
                states[section.name] = section.controlItem.state
            }
        }
        return states
    }

    /// Updates the ``items`` property, if the number of
    /// items in the menu bar has changed.
    @MainActor
    private func updateItems() async throws {
        guard let menuBarManager else {
            return
        }

        // store current hiding states of the sections
        let currentStates = getCurrentHidingStates()

        // can't capture off-screen items; iterate through
        // the sections and temporarily show all items
        for section in menuBarManager.sections {
            section.controlItem.state = .showItems
        }

        // need to wait for the change to take effect
        try await Task.sleep(for: .milliseconds(10))

        let windows = try await getMenuBarItemWindows()
        let newWindowCount = windows.count

        // only continue if the number of windows in the
        // menu bar has changed from last time
        if newWindowCount != previousWindowCount {
            let filteredWindows = windows.filter { window in
                window.isOnScreen &&
                // filter out our own items
                window.owningApplication?.processID != ProcessInfo.processInfo.processIdentifier
            }

            var newItems = [MenuBarItem]()

            for window in filteredWindows {
                do {
                    let image = try await ScreenshotManager.captureImage(
                        withTimeout: .milliseconds(100),
                        window: window
                    )
                    let item = MenuBarItem(window: window, image: image)
                    newItems.append(item)
                } catch {
                    Logger.itemManager.error("Error capturing menu bar item: \(error)")
                }
            }

            // sort the items by their order in the menu bar
            let sortedItems = newItems.sorted { first, second in
                first.window.frame.minX < second.window.frame.minX
            }

            items = sortedItems
            previousWindowCount = newWindowCount
        }

        // restore the hiding states of all sections to
        // their original values
        for section in menuBarManager.sections {
            if let state = currentStates[section.name] {
                section.controlItem.state = state
            }
        }
    }

    /// Moves the given menu bar item to the given X position
    /// in the menu bar.
    func move(_ item: MenuBarItem, toXPosition xPosition: CGFloat) async throws {
        guard item.acceptsMouseEvents else {
            throw MoveError.macOSProhibited(item)
        }

        // get the original mouse location
        let mouseLocation = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) else {
            throw MoveError.noScreen
        }
        // flip the mouse location along the y axis of its screen
        let originalMouseLocation = CGPoint(
            x: mouseLocation.x,
            y: screen.frame.maxY - mouseLocation.y
        )
        // get the frame of the menu bar
        let menuBarFrame = CGRect(
            x: screen.frame.minX,
            y: screen.visibleFrame.minY,
            width: screen.frame.width,
            height: screen.frame.height - screen.visibleFrame.height
        )

        let content = try await SCShareableContent.current

        // make sure we're working with the current window information
        guard let window = content.windows.first(where: { $0.windowID == item.window.windowID }) else {
            throw MoveError.noCurrentWindow(item)
        }

        // start at the center of the window
        let startPoint = CGPoint(x: window.frame.midX, y: window.frame.midY)
        // end at the provided X position, centered vertically
        // in the menu bar's frame
        let endPoint = CGPoint(x: xPosition, y: menuBarFrame.midY)

        // no need to move if we're already there
        guard startPoint != endPoint else {
            return
        }

        let source = CGEventSource(stateID: .hidSystemState)

        // to move the item, we must simulate a mouse drag from the
        // item's current location to the new location, while holding
        // down the command key; create the events that specify this,
        // and assign each one's `flags` parameter to the command key
        guard
            let mouseDownEvent = CGEvent(
                mouseEventSource: source,
                mouseType: .leftMouseDown,
                mouseCursorPosition: startPoint,
                mouseButton: .left
            ),
            let mouseDraggedEvent = CGEvent(
                mouseEventSource: source,
                mouseType: .leftMouseDragged,
                mouseCursorPosition: endPoint,
                mouseButton: .left
            ),
            let mouseUpEvent = CGEvent(
                mouseEventSource: source,
                mouseType: .leftMouseUp,
                mouseCursorPosition: endPoint,
                mouseButton: .left
            )
        else {
            throw MoveError.eventFailure
        }

        mouseDownEvent.flags = .maskCommand
        mouseDraggedEvent.flags = .maskCommand
        mouseUpEvent.flags = .maskCommand

        // hide the cursor and move it to the start position
        // CGDisplayHideCursor(CGMainDisplayID())
        CGWarpMouseCursorPosition(startPoint)

        defer {
            // move the cursor back to its original location and show it
            CGWarpMouseCursorPosition(originalMouseLocation)
            // CGDisplayShowCursor(CGMainDisplayID())
        }

        mouseDownEvent.post(tap: .cghidEventTap)
        try await Task.sleep(for: .seconds(0.25))

        mouseDraggedEvent.post(tap: .cghidEventTap)
        try await Task.sleep(for: .seconds(0.25))

        mouseUpEvent.post(tap: .cghidEventTap)
        try await Task.sleep(for: .seconds(0.25))
    }
}

// MARK: - Logger
private extension Logger {
    static let itemManager = Logger(category: "MenuBarItemManager")
}
