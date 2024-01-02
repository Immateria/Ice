//
//  LayoutBar.swift
//  Ice
//

import SwiftUI

struct LayoutBar: View {
    private struct Representable: NSViewRepresentable {
        let menuBarManager: MenuBarManager
        let section: MenuBarSection
        let spacing: CGFloat

        func makeNSView(context: Context) -> LayoutBarScrollView {
            LayoutBarScrollView(
                menuBarManager: menuBarManager,
                section: section,
                spacing: spacing
            )
        }

        func updateNSView(_ nsView: LayoutBarScrollView, context: Context) {
            nsView.spacing = spacing
        }
    }

    @EnvironmentObject var appState: AppState

    let section: MenuBarSection
    let spacing: CGFloat

    private var menuBarManager: MenuBarManager {
        appState.menuBarManager
    }

    private var appearanceManager: MenuBarAppearanceManager {
        menuBarManager.appearanceManager
    }

    init(section: MenuBarSection, spacing: CGFloat = 0) {
        self.section = section
        self.spacing = spacing
    }

    var body: some View {
        Representable(
            menuBarManager: menuBarManager,
            section: section,
            spacing: spacing
        )
        .background {
            backgroundView
        }
        .overlay {
            tintView
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 9)
        )
    }

    @ViewBuilder
    private var backgroundView: some View {
        if let averageColor = appearanceManager.averageColor {
            Color(cgColor: averageColor)
                .overlay(
                    Material.bar
                        .opacity(0.2)
                        .blendMode(.multiply)
                )
        } else {
            Color.defaultLayoutBar
        }
    }

    @ViewBuilder
    private var tintView: some View {
        switch appearanceManager.tintKind {
        case .none:
            EmptyView()
        case .solid:
            Color(cgColor: appearanceManager.tintColor)
                .opacity(0.2)
                .allowsHitTesting(false)
        case .gradient:
            appearanceManager.tintGradient
                .opacity(0.2)
                .allowsHitTesting(false)
        }
    }
}
