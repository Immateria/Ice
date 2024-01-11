//
//  HotKey+Modifiers.swift
//  Ice
//

import Carbon.HIToolbox
import SwiftUI

extension HotKey {
    /// A representation of the modifier keys in a hot key.
    public struct Modifiers: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        /// The Control key.
        public static let control = Modifiers(rawValue: 1 << 0)
        /// The Option key.
        public static let option = Modifiers(rawValue: 1 << 1)
        /// The Shift key.
        public static let shift = Modifiers(rawValue: 1 << 2)
        /// The Command key.
        public static let command = Modifiers(rawValue: 1 << 3)

        /// All modifiers in the order displayed by the system, according
        /// to Apple's style guide.
        public static let canonicalOrder: [Modifiers] = [.control, .option, .shift, .command]
    }
}

extension HotKey.Modifiers {

    // MARK: Conversion Properties

    /// The equivalent string representation of the modifiers.
    public var stringValue: String {
        var result = ""
        if contains(.control) {
            result.append("⌃")
        }
        if contains(.option) {
            result.append("⌥")
        }
        if contains(.shift) {
            result.append("⇧")
        }
        if contains(.command) {
            result.append("⌘")
        }
        return result
    }

    /// A label for the modifiers.
    public var label: String {
        var result = [String]()
        if contains(.control) {
            result.append("Control")
        }
        if contains(.option) {
            result.append("Option")
        }
        if contains(.shift) {
            result.append("Shift")
        }
        if contains(.command) {
            result.append("Command")
        }
        return result.joined(separator: " + ")
    }

    /// The equivalent `NSEvent` flags of the modifiers.
    public var nsEventFlags: NSEvent.ModifierFlags {
        var result: NSEvent.ModifierFlags = []
        if contains(.control) {
            result.insert(.control)
        }
        if contains(.option) {
            result.insert(.option)
        }
        if contains(.shift) {
            result.insert(.shift)
        }
        if contains(.command) {
            result.insert(.command)
        }
        return result
    }

    /// The equivalent `CoreGraphics` event flags of the modifiers.
    public var cgEventFlags: CGEventFlags {
        var result: CGEventFlags = []
        if contains(.control) {
            result.insert(.maskControl)
        }
        if contains(.option) {
            result.insert(.maskAlternate)
        }
        if contains(.shift) {
            result.insert(.maskShift)
        }
        if contains(.command) {
            result.insert(.maskCommand)
        }
        return result
    }

    /// The equivalent `Carbon` event flags of the modifiers.
    public var carbonFlags: Int {
        var result = 0
        if contains(.control) {
            result |= controlKey
        }
        if contains(.option) {
            result |= optionKey
        }
        if contains(.shift) {
            result |= shiftKey
        }
        if contains(.command) {
            result |= cmdKey
        }
        return result
    }

    // MARK: Conversion Initializers

    /// Creates modifiers with the given string representation.
    public init(stringValue: String) {
        self.init()
        if stringValue.contains("⌃") {
            insert(.control)
        }
        if stringValue.contains("⌥") {
            insert(.option)
        }
        if stringValue.contains("⇧") {
            insert(.shift)
        }
        if stringValue.contains("⌘") {
            insert(.command)
        }
    }

    /// Creates modifiers with the given `NSEvent` flags.
    public init(nsEventFlags: NSEvent.ModifierFlags) {
        self.init()
        if nsEventFlags.contains(.control) {
            insert(.control)
        }
        if nsEventFlags.contains(.option) {
            insert(.option)
        }
        if nsEventFlags.contains(.shift) {
            insert(.shift)
        }
        if nsEventFlags.contains(.command) {
            insert(.command)
        }
    }

    /// Creates modifiers with the given `CoreGraphics` event flags.
    public init(cgEventFlags: CGEventFlags) {
        self.init()
        if cgEventFlags.contains(.maskControl) {
            insert(.control)
        }
        if cgEventFlags.contains(.maskAlternate) {
            insert(.option)
        }
        if cgEventFlags.contains(.maskShift) {
            insert(.shift)
        }
        if cgEventFlags.contains(.maskCommand) {
            insert(.command)
        }
    }

    /// Creates modifiers with the given `Carbon` event flags.
    public init(carbonFlags: Int) {
        self.init()
        if carbonFlags & controlKey == controlKey {
            insert(.control)
        }
        if carbonFlags & optionKey == optionKey {
            insert(.option)
        }
        if carbonFlags & shiftKey == shiftKey {
            insert(.shift)
        }
        if carbonFlags & cmdKey == cmdKey {
            insert(.command)
        }
    }
}

// MARK: Modifiers: Codable
extension HotKey.Modifiers: Codable { }

// MARK: Modifiers: Equatable
extension HotKey.Modifiers: Equatable { }

// MARK: Modifiers: Hashable
extension HotKey.Modifiers: Hashable { }
