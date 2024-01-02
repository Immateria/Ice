//
//  MenuBarSettingsPane.swift
//  Ice
//

import SwiftUI

struct MenuBarSettingsPane: View {
    @AppStorage(Defaults.menuBarSettingsPaneSelectedTab) var selection: Int = 0

    var body: some View {
        CustomTabView(selection: $selection) {
            CustomTab {
                Text("Layout")
            } content: {
                MenuBarLayoutTab()
            }
            CustomTab {
                Text("Appearance")
            } content: {
                MenuBarAppearanceTab()
            }
        }
        .bottomBar {
            HStack {
                Spacer()
                Button("Quit \(Constants.appName)") {
                    NSApp.terminate(nil)
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuBarSettingsPane()
        .environmentObject(AppState.shared)
        .frame(width: 500, height: 300)
}
