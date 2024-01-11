//
//  Logging.swift
//  Ice
//

import Foundation
import os

private let subsystem: String = {
    let packageName = "HotKeys"
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return packageName
    }
    return "\(bundleIdentifier).\(packageName)"
}()

/// A value that the logging system uses to filter log messages.
struct LogCategory: RawRepresentable {
    let rawValue: String
    let log: OSLog

    init(rawValue: String) {
        self.rawValue = rawValue
        self.log = OSLog(subsystem: subsystem, category: rawValue)
    }
}

extension LogCategory {
    /// The main log category.
    static let main = LogCategory(rawValue: "main")

    /// The log category to use for the `HotKeyRegistry` type.
    static let hotKeyRegistry = LogCategory(rawValue: "HotKeyRegistry")
}

/// Sends a message to the logging system using the given category and log level.
func hk_log(_ message: String, category: LogCategory = .main, type: OSLogType = .default) {
    os_log("%@", log: category.log, type: type, message)
}
