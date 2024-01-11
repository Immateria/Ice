//
//  HotKey.swift
//  Ice
//

import Carbon.HIToolbox
import SwiftUI

/// A key combination that can be used to trigger actions
/// on system-wide key-up or key-down events.
public struct HotKey {
    /// The key component of the hot key.
    public let key: Key

    /// The modifiers component of the hot key.
    public let modifiers: Modifiers

    /// The string representation of the hot key.
    public var stringValue: String {
        modifiers.stringValue + key.stringValue
    }

    /// Creates a hot key with the given key and modifiers.
    ///
    /// - Parameters:
    ///   - key: The key component of the hot key.
    ///   - modifiers: The modifiers component of the hot key.
    public init(key: Key, modifiers: Modifiers) {
        self.key = key
        self.modifiers = modifiers
    }

    /// Creates a hot key from the given `Cocoa` event.
    ///
    /// - Note: This initializer returns `nil` if the event's type
    ///   is not `keyDown` or `keyUp`.
    ///
    /// - Parameter nsEvent: The event to use to create the hot key.
    public init?(nsEvent: NSEvent) {
        guard nsEvent.type == .keyDown || nsEvent.type == .keyUp else {
            return nil
        }
        self.init(
            key: Key(rawValue: Int(nsEvent.keyCode)),
            modifiers: Modifiers(nsEventFlags: nsEvent.modifierFlags)
        )
    }

    /// Creates a hot key from the given `CoreGraphics` event.
    ///
    /// - Note: This initializer returns `nil` if the event's type
    ///   is not `keyDown` or `keyUp`.
    ///
    /// - Parameter cgEvent: The event to use to create the hot key.
    public init?(cgEvent: CGEvent) {
        guard cgEvent.type == .keyDown || cgEvent.type == .keyUp else {
            return nil
        }
        self.init(
            key: Key(rawValue: Int(cgEvent.getIntegerValueField(.keyboardEventKeycode))),
            modifiers: Modifiers(cgEventFlags: cgEvent.flags)
        )
    }
}

private var reservedHotkeys: [HotKey] {
    var symbolicHotKeys: Unmanaged<CFArray>?
    let status = CopySymbolicHotKeys(&symbolicHotKeys)
    guard
        status == noErr,
        let reservedHotKeys = symbolicHotKeys?.takeRetainedValue() as? [[String: Any]]
    else {
        return []
    }
    return reservedHotKeys.compactMap { hotKey in
        guard
            hotKey[kHISymbolicHotKeyEnabled] as? Bool == true,
            let carbonKeyCode = hotKey[kHISymbolicHotKeyCode] as? Int,
            let carbonModifiers = hotKey[kHISymbolicHotKeyModifiers] as? Int
        else {
            return nil
        }
        return HotKey(
            key: HotKey.Key(rawValue: carbonKeyCode),
            modifiers: HotKey.Modifiers(carbonFlags: carbonModifiers)
        )
    }
}

extension HotKey {
    /// Returns a Boolean value that indicates whether the
    /// hot key is reserved for system use.
    public var isReservedBySystem: Bool {
        reservedHotkeys.contains(self)
    }
}

// MARK: HotKey: Codable
extension HotKey: Codable { }

// MARK: HotKey: Equatable
extension HotKey: Equatable { }

// MARK: HotKey: Hashable
extension HotKey: Hashable { }
