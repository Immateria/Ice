//
//  HotKeyRecorderModel.swift
//  Ice
//

import Cocoa
import Combine
import HotKeys

/// Model for a hot key recorder's state.
class HotKeyRecorderModel: ObservableObject {
    @Published private(set) var isRecording = false
    @Published private(set) var pressedModifierStrings = [String]()
    @Published var failure: RecordingFailure?

    let section: MenuBarSection?

    private let handleFailure: (HotKeyRecorderModel, RecordingFailure) -> Void
    private var monitor: LocalEventMonitor?

    private var cancellables = Set<AnyCancellable>()

    /// A Boolean value that indicates whether the hot key is
    /// currently enabled.
    var isEnabled: Bool {
        section?.hotKeyIsEnabled ?? false
    }

    /// Creates a model for a hot key recorder that records key
    /// combinations for the given section's hot key.
    init(section: MenuBarSection?) {
        defer {
            configureCancellables()
        }
        self.section = section
        self.handleFailure = { model, failure in
            // remove the modifier strings so the pressed modifiers
            // aren't being displayed at the same time as a failure
            model.pressedModifierStrings.removeAll()
            model.failure = failure
        }
        guard !AppState.shared.isPreview else {
            return
        }
        self.monitor = LocalEventMonitor(mask: [.keyDown, .flagsChanged]) { [weak self] event in
            guard let self else {
                return event
            }
            switch event.type {
            case .keyDown:
                handleKeyDown(event: event)
            case .flagsChanged:
                handleFlagsChanged(event: event)
            default:
                return event
            }
            return nil
        }
    }

    deinit {
        stopRecording()
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        if let section {
            section.$hotKey
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &c)
        }

        cancellables = c
    }

    /// Disables the hot key and starts monitoring for events.
    func startRecording() {
        guard !isRecording else {
            return
        }
        isRecording = true
        section?.disableHotKey()
        monitor?.start()
        pressedModifierStrings = []
    }

    /// Enables the hot key and stops monitoring for events.
    func stopRecording() {
        guard isRecording else {
            return
        }
        isRecording = false
        monitor?.stop()
        section?.enableHotKey()
        pressedModifierStrings = []
        failure = nil
    }

    /// Handles local key down events when the hot key recorder
    /// is recording.
    private func handleKeyDown(event: NSEvent) {
        guard let hotKey = HotKey(nsEvent: event) else {
            return
        }
        if hotKey.modifiers.isEmpty {
            if hotKey.key == .escape {
                // escape was pressed with no modifiers
                stopRecording()
            } else {
                handleFailure(self, .noModifiers)
            }
            return
        }
        if hotKey.modifiers == .shift {
            handleFailure(self, .onlyShift)
            return
        }
        if hotKey.isReservedBySystem {
            handleFailure(self, .reserved(hotKey))
            return
        }
        // if we made it this far, all checks passed; assign the
        // new hot key and stop recording
        section?.hotKey = hotKey
        stopRecording()
    }

    /// Handles modifier flag changes when the hot key recorder
    /// is recording.
    private func handleFlagsChanged(event: NSEvent) {
        pressedModifierStrings = HotKey.Modifiers.canonicalOrder.compactMap {
            event.modifierFlags.contains($0.nsEventFlags) ? $0.stringValue : nil
        }
    }
}
