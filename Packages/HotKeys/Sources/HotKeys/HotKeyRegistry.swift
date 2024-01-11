//
//  HotKeyRegistry.swift
//  Ice
//

import Carbon.HIToolbox

/// A type that registers hot keys to the event system.
open class HotKeyRegistry {
    /// The shared hot key registry.
    public static let shared = HotKeyRegistry()

    private let signature = OSType(1229146187) // OSType for ICHK (Ice HotKey)
    private var eventHandlerRef: EventHandlerRef?
    private var registrations = [UInt32: HotKeyRegistration]()

    private func installIfNeeded() throws {
        guard eventHandlerRef == nil else {
            return
        }
        let handler: EventHandlerUPP = { _, event, userData in
            guard
                let event,
                let userData
            else {
                return OSStatus(eventNotHandledErr)
            }
            let registry = Unmanaged<HotKeyRegistry>.fromOpaque(userData).takeUnretainedValue()
            return registry.performEventHandler(for: event)
        }
        let eventTypes = [
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed)),
            EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased)),
        ]
        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            handler,
            eventTypes.count,
            eventTypes,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandlerRef
        )
        guard status == noErr else {
            throw HotKeyError.installationFailed
        }
    }

    private func performEventHandler(for event: EventRef) -> OSStatus {
        // create a hot key id from the event
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )

        // make sure creation was successful
        guard status == noErr else {
            return status
        }

        // make sure the event signature matches our signature and
        // that a valid event handler is registered for the event
        guard
            hotKeyID.signature == signature,
            let registration = registrations[hotKeyID.id],
            registration.isValid,
            registration.eventKind == HotKey.EventKind(event: event)
        else {
            return OSStatus(eventNotHandledErr)
        }

        // all checks passed; perform the event handler
        registration.handler(registration)

        return noErr
    }

    /// Registers the given hot key for the given event kind and
    /// returns the registration on success.
    ///
    /// The returned registration can be used to unregister the
    /// hot key using the ``unregister(_:)`` function.
    ///
    /// - Parameters:
    ///   - hotKey: The hot key to register.
    ///   - eventKind: The event kind to register the hot key for.
    ///   - handler: The handler to perform when `hotKey` is
    ///     triggered with the event kind specified by `eventKind`.
    ///
    /// - Returns: A hot key registration.
    public func register(
        hotKey: HotKey,
        eventKind: HotKey.EventKind,
        handler: @escaping (HotKeyRegistration) -> Void
    ) throws -> HotKeyRegistration {
        enum Context {
            static var currentID: UInt32 = 0
        }

        try installIfNeeded()

        defer {
            Context.currentID += 1
        }

        let id = Context.currentID

        guard registrations[id] == nil else {
            throw HotKeyError.alreadyRegistered
        }

        let hotKeyID = EventHotKeyID(signature: signature, id: id)
        var hotKeyRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            UInt32(hotKey.key.rawValue),
            UInt32(hotKey.modifiers.carbonFlags),
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )

        switch status {
        case noErr:
            break
        case OSStatus(eventHotKeyExistsErr):
            throw HotKeyError.exclusiveHotKey
        default:
            throw HotKeyError.registrationFailed
        }

        guard let hotKeyRef else {
            throw HotKeyError.invalidHotKeyRef
        }

        let registration = HotKeyRegistration(
            eventKind: eventKind,
            hotKey: hotKey,
            registry: self,
            hotKeyRef: hotKeyRef,
            hotKeyID: hotKeyID,
            handler: handler
        )
        registrations[id] = registration

        return registration
    }

    /// Unregisters the hot key associated with the given registration.
    public func unregister(_ registration: HotKeyRegistration) throws {
        guard registrations.removeValue(forKey: registration.hotKeyID.id) === registration else {
            throw HotKeyError.notRegistered
        }
        try registration.invalidate()
    }

    /// Returns a Boolean value that indicates whether the given
    /// registration is managed by this registry.
    public func isRegistered(_ registration: HotKeyRegistration) -> Bool {
        registrations[registration.hotKeyID.id] === registration
    }
}
