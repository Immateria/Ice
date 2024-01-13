//
//  LayoutBarCocoaView.swift
//  Ice
//

import Cocoa
import Combine
import ScreenCaptureKit

/// A Cocoa view that manages the menu bar layout interface.
class LayoutBarCocoaView: NSView {
    private let container: LayoutBarContainer

    /// The section whose items are represented.
    var section: MenuBarSection {
        container.section
    }

    /// The amount of space between each arranged view.
    var spacing: CGFloat {
        get { container.spacing }
        set { container.spacing = newValue }
    }

    /// The layout view's arranged views.
    ///
    /// The views are laid out from left to right in the order that they
    /// appear in the array. The ``spacing`` property determines the amount
    /// of space between each view.
    var arrangedViews: [LayoutBarItemView] {
        get { container.arrangedViews }
        set { container.arrangedViews = newValue }
    }

    /// Creates a layout bar view with the given menu bar manager,
    /// section, and spacing.
    ///
    /// - Parameters:
    ///   - menuBarManager: The shared menu bar manager instance.
    ///   - section: The section whose items are represented.
    ///   - spacing: The amount of space between each arranged view.
    init(menuBarManager: MenuBarManager, section: MenuBarSection, spacing: CGFloat) {
        self.container = LayoutBarContainer(
            menuBarManager: menuBarManager,
            section: section,
            spacing: spacing
        )

        super.init(frame: .zero)
        addSubview(self.container)

        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // center the container along the y axis
            self.container.centerYAnchor.constraint(
                equalTo: self.centerYAnchor
            ),

            // give the container a few points of trailing space
            self.trailingAnchor.constraint(
                equalTo: self.container.trailingAnchor,
                constant: 7.5
            ),

            // allow variable spacing between leading anchors to let the view stretch
            // to fit whatever size is required; container should remain aligned toward
            // the trailing edge; this view is itself nested in a scroll view, so if it
            // has to expand to a larger size, it can be clipped
            self.leadingAnchor.constraint(
                lessThanOrEqualTo: self.container.leadingAnchor,
                constant: -7.5
            ),
        ])

        registerForDraggedTypes([.layoutBarItem])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        container.updateArrangedViewsForDrag(with: sender, phase: .entered)
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        if let sender {
            container.updateArrangedViewsForDrag(with: sender, phase: .exited)
        }
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        container.updateArrangedViewsForDrag(with: sender, phase: .updated)
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        container.updateArrangedViewsForDrag(with: sender, phase: .ended)
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard
            let sourceView = sender.draggingSource as? LayoutBarItemView,
            sender.draggingSourceOperationMask == .move
        else {
            return false
        }
        return moveItem(for: sourceView)
    }

    /// Moves the item belonging to the given source view.
    private func moveItem(for sourceView: LayoutBarItemView) -> Bool {
        guard let sourceIndex = container.index(of: sourceView) else {
            return false
        }

        // wait for the control item to resize
        let semaphore = DispatchSemaphore(value: 0)

        let box = BoxObject<AnyCancellable?>()
        box.base = NotificationCenter.default.publisher(for: ControlItem.didResizeNotification)
            .filter { [weak self] notification in
                guard
                    let self,
                    let controlItem = notification.object as? ControlItem
                else {
                    return false
                }
                switch section.name {
                case .visible:
                    guard let section = container.menuBarManager.section(withName: .hidden) else {
                        return false
                    }
                    return controlItem === section.controlItem
                case .hidden:
                    guard let section = container.menuBarManager.section(withName: .alwaysHidden) else {
                        return false
                    }
                    return controlItem === section.controlItem
                case .alwaysHidden:
                    return false
                }
            }
            .sink { [weak box, weak semaphore] _ in
                box?.base?.cancel()
                box?.base = nil
                semaphore?.signal()
            }

        container.menuBarManager.section(withName: .hidden)?.show()
        container.menuBarManager.section(withName: .alwaysHidden)?.show()

        let result = semaphore.wait(timeout: .now() + 0.5)

        switch result {
        case .success:
            Task {
                do {
                    try await Task.sleep(for: .seconds(0.001))
                    let content = try await SCShareableContent.current
                    if
                        let destinationView = container.arrangedView(atIndex: sourceIndex - 1),
                        let destinationWindow = content.windows.first(where: { window in
                            window.windowID == destinationView.item.window.windowID
                        })
                    {
                        try await container.menuBarManager.itemManager.move(
                            sourceView.item,
                            toXPosition: destinationWindow.frame.midX + 1
                        )
                    } else if
                        let destinationView = container.arrangedView(atIndex: sourceIndex + 1),
                        let destinationWindow = content.windows.first(where: { window in
                            window.windowID == destinationView.item.window.windowID
                        })
                    {
                        try await container.menuBarManager.itemManager.move(
                            sourceView.item,
                            toXPosition: destinationWindow.frame.midX - 1
                        )
                    }
                } catch {
                    NSAlert(error: error).runModal()
                }
                container.menuBarManager.section(withName: .hidden)?.hide()
                container.menuBarManager.section(withName: .alwaysHidden)?.hide()
            }
            return true
        case .timedOut:
            return false
        }
    }
}
