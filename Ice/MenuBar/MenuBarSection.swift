//
//  MenuBarSection.swift
//  Ice
//

import Combine
import Foundation
import HotKeys
import OSLog

/// A representation of a section in a menu bar.
final class MenuBarSection: ObservableObject {
    /// User-visible name that describes a menu bar section.
    enum Name: String, Codable, Hashable {
        case visible = "Visible"
        case hidden = "Hidden"
        case alwaysHidden = "Always Hidden"
    }

    /// The control item that manages the visibility of the section.
    @Published var controlItem: ControlItem {
        didSet {
            controlItem.updateStatusItem(with: controlItem.state)
            configureCancellables()
        }
    }

    /// The hot key associated with the section.
    @Published var hotKey: HotKey? {
        didSet {
            if registration != nil {
                enableHotKey()
            }
            menuBarManager?.needsSave = true
        }
    }

    private var registration: HotKeyRegistration?
    private var cancellables = Set<AnyCancellable>()

    /// User-visible name that describes the section.
    let name: Name

    /// The menu bar associated with the section.
    weak var menuBarManager: MenuBarManager? {
        didSet {
            controlItem.menuBarManager = menuBarManager
        }
    }

    /// A Boolean value that indicates whether the section is enabled.
    var isEnabled: Bool {
        get {
            controlItem.isVisible
        }
        set {
            controlItem.isVisible = newValue
            if newValue {
                enableHotKey()
            } else {
                disableHotKey()
            }
        }
    }

    /// A Boolean value that indicates whether the section is hidden.
    var isHidden: Bool {
        switch controlItem.state {
        case .hideItems: true
        case .showItems: false
        }
    }

    /// A Boolean value that indicates whether the section's hot key is
    /// enabled.
    var hotKeyIsEnabled: Bool {
        registration != nil
    }

    /// The max X coordinate of the section on screen.
    var maxX: CGFloat {
        switch name {
        case .visible:
            if let screen = controlItem.screen {
                screen.frame.maxX
            } else {
                0
            }
        case .hidden, .alwaysHidden:
            controlItem.windowFrame?.minX ?? 0
        }
    }

    /// Creates a menu bar section with the given name, control item,
    /// hot key, and unique identifier.
    init(name: Name, controlItem: ControlItem, hotKey: HotKey? = nil) {
        self.name = name
        self.controlItem = controlItem
        self.hotKey = hotKey
        enableHotKey()
        configureCancellables()
    }

    /// Creates a menu bar section with the given name.
    convenience init(name: Name) {
        let autosaveName: String
        let position: CGFloat?
        let state: ControlItem.HidingState?

        switch name {
        case .visible:
            autosaveName = "Item-1"
            position = 0
            state = nil
        case .hidden:
            autosaveName = "Item-2"
            position = 1
            state = nil
        case .alwaysHidden:
            autosaveName = "Item-3"
            position = nil
            state = .hideItems
        }

        self.init(
            name: name,
            controlItem: ControlItem(
                autosaveName: autosaveName,
                position: position,
                state: state
            ),
            hotKey: nil
        )
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        // propagate changes from the section's control item
        controlItem.objectWillChange
            .sink { [weak self] in
                self?.objectWillChange.send()
            }
            .store(in: &c)

        cancellables = c
    }

    /// Enables the hot key associated with the section.
    func enableHotKey() {
        guard let hotKey else {
            disableHotKey()
            return
        }
        registration = try? HotKeyRegistry.shared.register(
            hotKey: hotKey,
            eventKind: .pressed,
            handler: { [weak self] _ in
                self?.toggle()
            }
        )
    }

    /// Disables the hot key associated with the section.
    func disableHotKey() {
        if let registration {
            try? HotKeyRegistry.shared.unregister(registration)
        }
        registration = nil
    }

    /// Shows the status items in the section.
    func show() {
        guard let menuBarManager else {
            return
        }
        switch name {
        case .visible, .hidden:
            guard
                let section1 = menuBarManager.section(withName: .visible),
                let section2 = menuBarManager.section(withName: .hidden)
            else {
                return
            }
            section1.controlItem.state = .showItems
            section2.controlItem.state = .showItems
        case .alwaysHidden:
            guard
                let section1 = menuBarManager.section(withName: .hidden),
                let section2 = menuBarManager.section(withName: .alwaysHidden)
            else {
                return
            }
            section1.show() // uses other branch
            section2.controlItem.state = .showItems
        }
    }

    /// Hides the status items in the section.
    func hide() {
        guard let menuBarManager else {
            return
        }
        switch name {
        case .visible, .hidden:
            guard
                let section1 = menuBarManager.section(withName: .visible),
                let section2 = menuBarManager.section(withName: .hidden),
                let section3 = menuBarManager.section(withName: .alwaysHidden)
            else {
                return
            }
            section1.controlItem.state = .hideItems
            section2.controlItem.state = .hideItems
            section3.hide() // uses other branch
        case .alwaysHidden:
            guard let section = menuBarManager.section(withName: .alwaysHidden) else {
                return
            }
            section.controlItem.state = .hideItems
        }
        menuBarManager.showOnHoverPreventedByUserInteraction = false
    }

    /// Toggles the visibility of the status items in the section.
    func toggle() {
        switch controlItem.state {
        case .hideItems: show()
        case .showItems: hide()
        }
    }
}

// MARK: MenuBarSection: Codable
extension MenuBarSection: Codable {
    private enum CodingKeys: String, CodingKey {
        case name
        case controlItem
        case hotKey
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            name: container.decode(Name.self, forKey: .name),
            controlItem: container.decode(ControlItem.self, forKey: .controlItem),
            hotKey: container.decodeIfPresent(HotKey.self, forKey: .hotKey)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(controlItem, forKey: .controlItem)
        try container.encodeIfPresent(hotKey, forKey: .hotKey)
    }
}

// MARK: MenuBarSection: Equatable
extension MenuBarSection: Equatable {
    static func == (lhs: MenuBarSection, rhs: MenuBarSection) -> Bool {
        lhs.name == rhs.name &&
        lhs.controlItem == rhs.controlItem &&
        lhs.hotKey == rhs.hotKey
    }
}

// MARK: MenuBarSection: Hashable
extension MenuBarSection: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(controlItem)
        hasher.combine(hotKey)
    }
}

// MARK: MenuBarSection: BindingExposable
extension MenuBarSection: BindingExposable { }
