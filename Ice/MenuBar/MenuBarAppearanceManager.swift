//
//  MenuBarAppearanceManager.swift
//  Ice
//

import Combine
import OSLog
import ScreenCaptureKit
import SwiftUI

/// A type that manages the appearance of the menu bar.
final class MenuBarAppearanceManager: ObservableObject {
    /// A Boolean value that indicates whether the menu bar
    /// should have a shadow.
    @Published var hasShadow: Bool = false

    /// A Boolean value that indicates whether the menu bar
    /// should have a border.
    @Published var hasBorder: Bool = false

    /// The color of the menu bar's border.
    @Published var borderColor: CGColor = .black

    /// The width of the menu bar's border.
    @Published var borderWidth: Double = 1

    /// The shape of the menu bar.
    @Published var shapeKind: MenuBarShapeKind = .none

    /// Information for the menu bar's shape when it is in
    /// the ``MenuBarShapeKind/full`` state.
    @Published var fullShapeInfo: MenuBarFullShapeInfo = .default

    /// Information for the menu bar's shape when it is in
    /// the ``MenuBarShapeKind/split`` state.
    @Published var splitShapeInfo: MenuBarSplitShapeInfo = .default

    /// The tint kind currently in use.
    @Published var tintKind: MenuBarTintKind = .none

    /// The user's currently chosen tint color.
    @Published var tintColor: CGColor = .black

    /// The user's currently chosen tint gradient.
    @Published var tintGradient: CustomGradient = .defaultMenuBarTint

    /// The current desktop wallpaper, clipped to the bounds
    /// of the menu bar.
    @Published var desktopWallpaper: CGImage?

    /// The average color of the menu bar.
    @Published var averageColor: CGColor?

    /// A Boolean value that indicates whether the screen
    /// is currently locked.
    @Published private(set) var screenIsLocked = false

    /// A Boolean value that indicates whether the screen
    /// saver is currently active.
    @Published private(set) var screenSaverIsActive = false

    private var cancellables = Set<AnyCancellable>()

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let defaults: UserDefaults

    private(set) weak var menuBarManager: MenuBarManager?

    private lazy var backingPanel = MenuBarBackingPanel(appearanceManager: self)
    private lazy var overlayPanel = MenuBarOverlayPanel(appearanceManager: self)

    init(
        menuBarManager: MenuBarManager,
        encoder: JSONEncoder,
        decoder: JSONDecoder,
        defaults: UserDefaults
    ) {
        self.menuBarManager = menuBarManager
        self.encoder = encoder
        self.decoder = decoder
        self.defaults = defaults
    }

    func performSetup() {
        loadInitialState()
        configureCancellables()
        Task.detached { @MainActor [self] in
            try await Task.sleep(for: .milliseconds(500))
            backingPanel.configureCancellables()
            overlayPanel.configureCancellables()
        }
    }

    /// Loads data from storage and sets the initial state
    /// of the manager from that data.
    private func loadInitialState() {
        hasShadow = defaults.bool(forKey: Defaults.menuBarHasShadow)
        hasBorder = defaults.bool(forKey: Defaults.menuBarHasBorder)
        borderWidth = defaults.object(forKey: Defaults.menuBarBorderWidth) as? Double ?? 1
        tintKind = MenuBarTintKind(rawValue: defaults.integer(forKey: Defaults.menuBarTintKind)) ?? .none

        do {
            if let borderColorData = defaults.data(forKey: Defaults.menuBarBorderColor) {
                borderColor = try decoder.decode(CodableColor.self, from: borderColorData).cgColor
            }
            if let tintColorData = defaults.data(forKey: Defaults.menuBarTintColor) {
                tintColor = try decoder.decode(CodableColor.self, from: tintColorData).cgColor
            }
            if let tintGradientData = defaults.data(forKey: Defaults.menuBarTintGradient) {
                tintGradient = try decoder.decode(CustomGradient.self, from: tintGradientData)
            }
            if let shapeKindData = defaults.data(forKey: Defaults.menuBarShapeKind) {
                shapeKind = try decoder.decode(MenuBarShapeKind.self, from: shapeKindData)
            }
            if let fullShapeData = defaults.data(forKey: Defaults.menuBarFullShapeInfo) {
                fullShapeInfo = try decoder.decode(MenuBarFullShapeInfo.self, from: fullShapeData)
            }
            if let splitShapeData = defaults.data(forKey: Defaults.menuBarSplitShapeInfo) {
                splitShapeInfo = try decoder.decode(MenuBarSplitShapeInfo.self, from: splitShapeData)
            }
        } catch {
            Logger.appearanceManager.error("Error decoding value: \(error)")
        }
    }

    private func configureCancellables() {
        var c = Set<AnyCancellable>()

        DistributedNotificationCenter.default()
            .publisher(for: Notification.Name("com.apple.screenIsLocked"))
            .sink { [weak self] _ in
                self?.screenIsLocked = true
            }
            .store(in: &c)

        DistributedNotificationCenter.default()
            .publisher(for: Notification.Name("com.apple.screenIsUnlocked"))
            .sink { [weak self] _ in
                self?.screenIsLocked = false
            }
            .store(in: &c)

        DistributedNotificationCenter.default()
            .publisher(for: Notification.Name("com.apple.screensaver.didstart"))
            .sink { [weak self] _ in
                self?.screenSaverIsActive = true
            }
            .store(in: &c)

        DistributedNotificationCenter.default()
            .publisher(for: Notification.Name("com.apple.screensaver.didstop"))
            .sink { [weak self] _ in
                self?.screenSaverIsActive = false
            }
            .store(in: &c)

        NSWorkspace.shared.notificationCenter
            .publisher(for: NSWorkspace.activeSpaceDidChangeNotification)
            .sink { [weak self] _ in
                self?.updateDesktopWallpaper()
            }
            .store(in: &c)

        Timer.publish(every: 3, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDesktopWallpaper()
            }
            .store(in: &c)

        $hasShadow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasShadow in
                self?.handleHasShadow(hasShadow)
            }
            .store(in: &c)

        $hasBorder
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasBorder in
                self?.handleHasBorder(hasBorder)
            }
            .store(in: &c)

        $borderColor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] borderColor in
                self?.handleBorderColor(borderColor)
            }
            .store(in: &c)

        $borderWidth
            .receive(on: DispatchQueue.main)
            .sink { [weak self] borderWidth in
                self?.handleBorderWidth(borderWidth)
            }
            .store(in: &c)

        $tintKind
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tintKind in
                self?.handleTintKind(tintKind)
            }
            .store(in: &c)

        $tintColor
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tintColor in
                self?.handleTintColor(tintColor)
            }
            .store(in: &c)

        $tintGradient
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tintGradient in
                self?.handleTintGradient(tintGradient)
            }
            .store(in: &c)

        $shapeKind
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shapeKind in
                self?.handleShapeKind(shapeKind)
            }
            .store(in: &c)

        $fullShapeInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fullShapeInfo in
                self?.handleFullShapeInfo(fullShapeInfo)
            }
            .store(in: &c)

        $splitShapeInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] splitShapeInfo in
                self?.handleSplitShapeInfo(splitShapeInfo)
            }
            .store(in: &c)

        $desktopWallpaper
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAverageColor()
            }
            .store(in: &c)

        cancellables = c
    }

    /// Handles changes to the ``hasShadow`` property.
    ///
    /// - Parameter hasShadow: The new value of the property.
    private func handleHasShadow(_ hasShadow: Bool) {
        defaults.set(hasShadow, forKey: Defaults.menuBarHasShadow)
    }

    /// Handles changes to the ``hasBorder`` property.
    ///
    /// - Parameter hasBorder: The new value of the property.
    private func handleHasBorder(_ hasBorder: Bool) {
        defaults.set(hasBorder, forKey: Defaults.menuBarHasBorder)
    }

    /// Handles changes to the ``borderColor`` property.
    ///
    /// - Parameter borderColor: The new value of the property.
    private func handleBorderColor(_ borderColor: CGColor) {
        do {
            let data = try encoder.encode(CodableColor(cgColor: borderColor))
            defaults.set(data, forKey: Defaults.menuBarBorderColor)
        } catch {
            Logger.appearanceManager.error("Error encoding border color: \(error)")
        }
    }

    /// Handles changes to the ``borderWidth`` property.
    ///
    /// - Parameter borderWidth: The new value of the property.
    private func handleBorderWidth(_ borderWidth: Double) {
        defaults.set(borderWidth, forKey: Defaults.menuBarBorderWidth)
    }

    /// Handles changes to the ``tintKind`` property.
    ///
    /// - Parameter tintKind: The new value of the property.
    private func handleTintKind(_ tintKind: MenuBarTintKind) {
        defaults.set(tintKind.rawValue, forKey: Defaults.menuBarTintKind)
    }

    /// Handles changes to the ``tintColor`` property.
    ///
    /// - Parameter tintColor: The new value of the property.
    private func handleTintColor(_ tintColor: CGColor) {
        do {
            let data = try encoder.encode(CodableColor(cgColor: tintColor))
            defaults.set(data, forKey: Defaults.menuBarTintColor)
        } catch {
            Logger.appearanceManager.error("Error encoding tint color: \(error)")
        }
    }

    /// Handles changes to the ``tintGradient`` property.
    ///
    /// - Parameter tintGradient: The new value of the property.
    private func handleTintGradient(_ tintGradient: CustomGradient) {
        do {
            let data = try encoder.encode(tintGradient)
            defaults.set(data, forKey: Defaults.menuBarTintGradient)
        } catch {
            Logger.appearanceManager.error("Error encoding tint gradient: \(error)")
        }
    }

    /// Handles changes to the ``shapeKind`` property.
    ///
    /// - Parameter shapeKind: The new value of the property.
    private func handleShapeKind(_ shapeKind: MenuBarShapeKind) {
        do {
            let data = try encoder.encode(shapeKind)
            updateDesktopWallpaper()
            defaults.set(data, forKey: Defaults.menuBarShapeKind)
        } catch {
            Logger.appearanceManager.error("Error encoding shape kind: \(error)")
        }
    }

    /// Handles changes to the ``fullShapeInfo`` property.
    ///
    /// - Parameter fullShapeInfo: The new value of the property.
    private func handleFullShapeInfo(_ fullShapeInfo: MenuBarFullShapeInfo) {
        do {
            let data = try encoder.encode(fullShapeInfo)
            defaults.set(data, forKey: Defaults.menuBarFullShapeInfo)
        } catch {
            Logger.appearanceManager.error("Error encoding full shape info: \(error)")
        }
    }

    /// Handles changes to the ``splitShapeInfo`` property.
    ///
    /// - Parameter splitShapeInfo: The new value of the property.
    private func handleSplitShapeInfo(_ splitShapeInfo: MenuBarSplitShapeInfo) {
        do {
            let data = try encoder.encode(splitShapeInfo)
            defaults.set(data, forKey: Defaults.menuBarSplitShapeInfo)
        } catch {
            Logger.appearanceManager.error("Error encoding split shape info: \(error)")
        }
    }

    /// Captures and stores a current image of the desktop
    /// wallpaper, clipped to the bounds of the menu bar.
    private func updateDesktopWallpaper() {
        guard shapeKind != .none else {
            desktopWallpaper = nil
            return
        }

        guard !screenIsLocked else {
            Logger.appearanceManager.debug("Screen is locked")
            return
        }

        guard !screenSaverIsActive else {
            Logger.appearanceManager.debug("Screen saver is active")
            return
        }

        guard
            let appState = menuBarManager?.appState,
            appState.permissionsManager.screenRecordingPermission.hasPermission
        else {
            Logger.appearanceManager.notice("Missing screen capture permissions")
            return
        }

        Task { @MainActor in
            do {
                let content = try await SCShareableContent.current

                let wallpaperWindowPredicate: (SCWindow) -> Bool = { window in
                    // wallpaper window belongs to the Dock process
                    window.owningApplication?.bundleIdentifier == "com.apple.dock" &&
                    window.isOnScreen &&
                    window.title?.hasPrefix("Wallpaper-") == true
                }
                let menuBarWindowPredicate: (SCWindow) -> Bool = { window in
                    // menu bar window belongs to the WindowServer process
                    // (identified by an empty string)
                    window.owningApplication?.bundleIdentifier == "" &&
                    window.windowLayer == kCGMainMenuWindowLevel &&
                    window.title == "Menubar"
                }

                guard
                    let wallpaperWindow = content.windows.first(where: wallpaperWindowPredicate),
                    let menuBarWindow = content.windows.first(where: menuBarWindowPredicate)
                else {
                    return
                }

                let image = try await ScreenshotManager.captureImage(
                    withTimeout: .milliseconds(500),
                    window: wallpaperWindow,
                    captureRect: menuBarWindow.frame,
                    options: .ignoreFraming
                )

                if desktopWallpaper?.dataProvider?.data != image.dataProvider?.data {
                    desktopWallpaper = image
                }
            } catch {
                Logger.appearanceManager.error("Error updating desktop wallpaper: \(error)")
            }
        }
    }

    /// Calculates and stores the average color of the area
    /// of the desktop wallpaper behind the menu bar.
    private func updateAverageColor() {
        guard let color = desktopWallpaper?.averageColor(
            accuracy: .low,
            algorithm: .simple,
            options: .ignoreAlpha
        ) else {
            return
        }

        if averageColor != color {
            averageColor = color
        }
    }
}

// MARK: MenuBarAppearanceManager: BindingExposable
extension MenuBarAppearanceManager: BindingExposable { }

// MARK: - Logger
private extension Logger {
    static let appearanceManager = Logger(category: "MenuBarAppearanceManager")
}
