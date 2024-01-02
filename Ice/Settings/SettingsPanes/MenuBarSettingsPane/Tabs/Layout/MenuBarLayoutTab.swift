//
//  MenuBarLayoutTab.swift
//  Ice
//

import SwiftUI

struct MenuBarLayoutTab: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerText
                layoutViews
                Spacer()
            }
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .onAppear {
            // if observing starts too soon, some items are
            // not displayed; temporary workaround is to put
            // a slight delay before observing starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                appState.itemManager.startObserving()
            }
        }
        .onDisappear {
            appState.itemManager.stopObserving()
        }
    }

    @ViewBuilder
    private var headerText: some View {
        Text("Drag to arrange your menu bar items")
            .font(.title2)
            .annotation {
                Text("Tip: you can also arrange items by ⌘ (Command) + dragging them in the menu bar.")
            }
    }

    @ViewBuilder
    private var layoutViews: some View {
        Form {
            if let visibleSection = appState.menuBar.section(withName: .visible) {
                Section(visibleSection.name.rawValue) {
                    LayoutBar(section: visibleSection)
                        .annotation {
                            Text("Drag menu bar items to this section if you want them to always be visible.")
                        }
                }
            }

            if let hiddenSection = appState.menuBar.section(withName: .hidden) {
                Spacer()
                    .frame(maxHeight: 25)

                Section(hiddenSection.name.rawValue) {
                    LayoutBar(section: hiddenSection)
                        .annotation {
                            Text("Drag menu bar items to this section if you want to hide them.")
                        }
                }
            }

            if let alwaysHiddenSection = appState.menuBar.section(withName: .alwaysHidden) {
                Spacer()
                    .frame(maxHeight: 25)

                Section(alwaysHiddenSection.name.rawValue) {
                    LayoutBar(section: alwaysHiddenSection)
                        .annotation {
                            Text("Drag menu bar items to this section if you want them to always be hidden.")
                        }
                }
            }
        }
    }
}

#Preview {
    MenuBarLayoutTab()
        .fixedSize()
        .environmentObject(AppState.shared)
}
