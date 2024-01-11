//
//  RecordingFailure.swift
//  Ice
//

import Foundation
import HotKeys

/// An error type that describes a recording failure.
enum RecordingFailure: LocalizedError, Hashable {
    /// No modifiers were pressed.
    case noModifiers
    /// Shift was the only modifier being pressed.
    case onlyShift
    /// The given hot key is reserved by macOS.
    case reserved(HotKey)

    /// Description of the failure.
    var errorDescription: String? {
        switch self {
        case .noModifiers:
            return "Hot key should include at least one modifier"
        case .onlyShift:
            return "Shift (⇧) cannot be a hot key's only modifier"
        case .reserved(let hotKey):
            return "Hot key \(hotKey.stringValue) is reserved by macOS"
        }
    }
}
