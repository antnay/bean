//
//  beanApp.swift
//  bean
//
//  Created by Anthony on 4/10/26.
//

import SwiftData
import SwiftUI

@main
struct beanApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Brew.self,
            Basket.self,
            Profile.self,
            Grinder.self,
            Equipment.self,
            Bean.self,
            ScaleContainer.self,

        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var scaleMan: ScaleManager

    init() {
        let context = sharedModelContainer.mainContext
        _scaleMan = StateObject(
            wrappedValue: ScaleManager(modelContext: context)
        )
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(scaleMan)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                scaleMan.disconnect()
                scaleMan.stopAutoScan()
                break
            case .active:
                scaleMan.scan()
                break
            case .inactive:
                scaleMan.disconnect()
                scaleMan.stopAutoScan()
                break
            @unknown default:
                break
            }
        }
    }
}
