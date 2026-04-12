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
    @StateObject private var scaleMan = ScaleManager()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Brew.self,
            Basket.self,
            Profile.self,
            Grinder.self,
            Equipment.self,
            Bean.self,

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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(scaleMan)
    }
}
