//
//  ContentView.swift
//  bean
//
//  Created by Anthony on 4/10/26.
//

import AcaiaSDK
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var scaleMan: ScaleManager
    @Query private var items: [Brew]

    var body: some View {
        TabView {
            BrewView()
                .tabItem {
                    Label("Brew", systemImage: "house")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }

    private func addItem() {
        withAnimation {
            //            let newBrew = Brew(
            //                displayName: nil,
            //                profile: Profile(massIn: <#T##Double#>, massOut: <#T##Double#>),
            //                timestamp: Date.now
            //            )
            //            modelContext.insert(newBrew)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}
