//
//  Brew.swift
//  bean
//
//  Created by Anthony on 4/11/26.
//

import AcaiaSDK
import SwiftData
import SwiftUI

struct BrewView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var scaleMan: ScaleManager
    @Query private var containers: [ScaleContainer]

    @State private var showSaveContainer: Bool = false
    @State private var containerName = ""
    @State private var capturedWeight: Double = 0.0

    var body: some View {
        VStack {
            VStack {
                Text("\(scaleMan.weight, specifier: "%.1f") g")
                    .font(Font.largeTitle.bold())
                Text("\(scaleMan.timerDisplay) s")
                    .font(Font.largeTitle.bold())
            }
            VStack {
                Button(
                    "Tare",
                    action: {
                        scaleMan.tare()
                    }
                )
                .buttonStyle(.automatic)
                Button(
                    "Timer \(scaleMan.isTimerStarted ? "Stop" : "Start")",
                    action: {
                        scaleMan.timerButton()
                    }
                )
                .buttonStyle(.bordered)
                Button("Save Container") {
                    capturedWeight = Double(scaleMan.weight)
                    containerName = ""
                    showSaveContainer = true
                }
                .buttonStyle(.bordered)
                List {
                    ForEach(containers) { container in
                        Text(
                            "\(container.name) - \(container.weight, specifier: "%.1f") g"
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showSaveContainer) {
            NavigationStack {
                Form {
                    Text("\(capturedWeight, specifier: "%.1f") g")
                        .font(.title2)
                    TextField("Container name", text: $containerName)
                }
                .navigationTitle("New Container")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showSaveContainer = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let container = ScaleContainer(
                                name: containerName,
                                weight: capturedWeight
                            )
                            modelContext.insert(container)
                            try? modelContext.save()
                            showSaveContainer = false
                        }
                        .disabled(containerName.isEmpty)
                    }
                }
            }
        }
    }
}
