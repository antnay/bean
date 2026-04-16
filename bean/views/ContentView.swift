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
    //    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var scaleMan: ScaleManager
    //    @Query private var items: [Brew]

    var body: some View {
        TabView {

            AppBackground { ScaleView() }
                .tabItem {
                    Label("Scale", systemImage: "house")
                }
                .task(priority: .utility) {
                    scaleMan.scaleMode()
                }
            AppBackground { BrewView() }
                .tabItem {
                    Label("Brew", systemImage: "cup.and.saucer.fill")
                }
                .task(priority: .utility) {
                    scaleMan.brewMode()
                }
            AppBackground { HistoryView() }
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            AppBackground { SetupView() }
                .tabItem {
                    Label("Setup", systemImage: "book.closed.fill")
                }
        }
        .scrollDisabled(true)
    }
}

struct AppBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            content
        }
    }
}
