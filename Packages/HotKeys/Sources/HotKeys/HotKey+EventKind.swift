//
//  HotKey+EventKind.swift
//  Ice
//

import Carbon.HIToolbox

extension HotKey {
    /// Constants representing the possible event kinds that
    /// a hot key can be registered for.
    public enum EventKind {
        /// The hot key is pressed.
        case pressed
        /// The hot key is released.
        case released

        init?(event: EventRef) {
            switch Int(GetEventKind(event)) {
            case kEventHotKeyPressed:
                self = .pressed
            case kEventHotKeyReleased:
                self = .released
            default:
                return nil
            }
        }
    }
}
