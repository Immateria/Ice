//
//  HotKeyRegistration.swift
//  Ice
//

import Carbon.HIToolbox

/// A type that contains information for a registered hot key.
open class HotKeyRegistration {
    private var hotKeyRef: EventHotKeyRef?

    let hotKeyID: EventHotKeyID

    let handler: (HotKeyRegistration) -> Void

    /// The event kind associated with the registration.
    public let eventKind: HotKey.EventKind

    /// The hot key associated with the registration.
    public let hotKey: HotKey

    /// The registry that manages the registration.
    public private(set) weak var registry: HotKeyRegistry?

    /// A Boolean value that indicates whether the registration
    /// is valid.
    public var isValid: Bool { hotKeyRef != nil }

    init(
        eventKind: HotKey.EventKind,
        hotKey: HotKey,
        registry: HotKeyRegistry,
        hotKeyRef: EventHotKeyRef,
        hotKeyID: EventHotKeyID,
        handler: @escaping (HotKeyRegistration) -> Void
    ) {
        self.eventKind = eventKind
        self.hotKey = hotKey
        self.registry = registry
        self.hotKeyRef = hotKeyRef
        self.hotKeyID = hotKeyID
        self.handler = handler
    }

    deinit {
        do {
            if
                let registry,
                registry.isRegistered(self)
            {
                try registry.unregister(self)
            } else {
                try invalidate()
            }
        } catch {
            hk_log("Error: \(error)", category: .hotKeyRegistry, type: .error)
        }
    }

    /// Unregisters the hot key without removing it from the
    /// registry.
    func invalidate() throws {
        guard isValid else {
            return
        }
        let status = UnregisterEventHotKey(hotKeyRef)
        switch status {
        case noErr:
            break
        default:
            throw HotKeyError.unregistrationFailed
        }
        hotKeyRef = nil
    }
}
