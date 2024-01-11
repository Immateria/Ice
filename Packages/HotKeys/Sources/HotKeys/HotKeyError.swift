//
//  HotKeyError.swift
//  Ice
//

/// An error that can occur during hot key operations.
public enum HotKeyError: Error {
    /// Indicates that a registration with the same identifier
    /// has already been created.
    case alreadyRegistered

    /// Indicates that a registration is not registered with a
    /// given hot key registry.
    case notRegistered

    /// Indicates that another process has already exclusively
    /// registered a hot key.
    case exclusiveHotKey

    /// Indicates a failure to register a hot key.
    case registrationFailed

    /// Indicates a failure to unregister a hot key.
    case unregistrationFailed

    /// Indicates an invalid hot key reference.
    case invalidHotKeyRef

    /// Indicates a failure to install an event handler.
    case installationFailed
}
