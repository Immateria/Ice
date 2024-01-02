//
//  MenuBarItem.swift
//  Ice
//

import ScreenCaptureKit

private func bestDisplayName(for window: SCWindow) -> String {
    guard let application = window.owningApplication else {
        return window.title ?? ""
    }
    guard let title = window.title else {
        return application.applicationName
    }
    // by default, use the application name, but handle some special cases
    return switch application.bundleIdentifier {
    case "com.apple.controlcenter":
        if title == "BentoBox" { // Control Center icon
            application.applicationName
        } else if title == "NowPlaying" {
            "Now Playing"
        } else {
            title
        }
    case "com.apple.systemuiserver":
        if title == "TimeMachine.TMMenuExtraHost" {
            "Time Machine"
        } else {
            title
        }
    default:
        application.applicationName
    }
}

struct MenuBarItem: Hashable {
    let displayName: String
    let window: SCWindow
    let image: CGImage
    let acceptsMouseEvents: Bool

    init(window: SCWindow, image: CGImage) {
        let disabledDisplayNames = [
            "Clock",
            "Siri",
            "Control Center",
        ]
        let displayName = bestDisplayName(for: window)
        self.displayName = displayName
        self.window = window
        self.image = image
        self.acceptsMouseEvents = !disabledDisplayNames.contains(displayName)
    }
}
