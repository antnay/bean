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
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            BrewView()
                .tabItem {
                    Label("Brew", systemImage: "cup.and.saucer.fill")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            SettingsView()
                .tabItem {
                    Label("Setup", systemImage: "book.closed.fill")
                }
        }
        //        NavigationSplitView {
        //            List {
        //                ForEach(items) { item in
        //                    NavigationLink {
        //                        Text(
        //                            "Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))"
        //                        )
        //                    } label: {
        //                        Text(
        //                            item.timestamp,
        //                            format: Date.FormatStyle(
        //                                date: .numeric,
        //                                time: .standard
        //                            )
        //                        )
        //                    }
        //                }
        //                .onDelete(perform: deleteItems)
        //            }
        //            .toolbar {
        //                ToolbarItem(placement: .navigationBarTrailing) {
        //                    EditButton()
        //                }
        //                ToolbarItem {
        //                    Button(action: addItem) {
        //                        Label("Add Item", systemImage: "plus")
        //                    }
        //                }
        //            }
        //        } detail: {
        //            Text("Select an item")
        //        }
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
