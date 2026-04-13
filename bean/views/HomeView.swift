//
//  HomeView.swift
//  bean
//
//  Created by Anthony on 4/11/26.
//

import AcaiaSDK
import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var scaleMan: ScaleManager
    @Query private var containers: [ScaleContainer]

    @State private var showContainers = false
    @State private var showNewContainer = false
    @State private var containerName = ""
    @State private var capturedWeight: Float = 0.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 8) {
                if scaleMan.mode == .container {
                    Text("\(scaleMan.netWeight, specifier: "%.1f")")
                        .font(
                            .system(size: 72, weight: .bold, design: .rounded)
                        )
                        .monospacedDigit()
                } else {
                    Text("\(scaleMan.weight, specifier: "%.1f")")
                        .font(
                            .system(size: 72, weight: .bold, design: .rounded)
                        )
                        .monospacedDigit()
                }
                Text("grams")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(scaleMan.timerDisplay)
                    .font(
                        .system(
                            size: 36,
                            weight: .semibold,
                            design: .monospaced
                        )
                    )
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Spacer()
            HStack {
                Button(action: {
                    switch scaleMan.mode {
                    case .container: scaleMan.brewMode()
                    case .brew: scaleMan.containerMode()
                    }
                }) {
                    Image(systemName: "archivebox.fill")
                }
                .buttonStyle(
                    ToggleButtonStyle(isActive: scaleMan.mode == .container)
                )
            }
            Spacer()
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button(action: scaleMan.tare) {
                        Label("Tare", systemImage: "scalemass")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)

                    Button(action: scaleMan.timerButton) {
                        Label(
                            scaleMan.isTimerStarted
                                ? "Stop timer" : "Start timer",
                            systemImage: scaleMan.isTimerStarted
                                ? "stop.fill" : "play.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                Button(action: {
                    capturedWeight = scaleMan.weight
                    containerName = ""
                    showContainers = true
                }) {
                    Label("Containers", systemImage: "archivebox")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding()
        }
        .sheet(isPresented: $showContainers) {
            NavigationStack {
                List {
                    ForEach(containers) { container in
                        HStack {
                            Text(container.name)
                            Spacer()
                            Text("\(container.weight, specifier: "%.1f") g")
                                .foregroundStyle(.secondary)
                        }
                        .onTapGesture {
                            scaleMan.loadContainer(container: container)
                            showContainers = false
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            modelContext.delete(containers[index])
                        }
                    }
                }
                .navigationTitle("Containers")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        // edit should be able to edit name
                        EditButton()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { showNewContainer = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showNewContainer) {
                    NavigationStack {
                        Form {
                            Text("\(capturedWeight, specifier: "%.1f") g")
                                .font(.title2)
                            TextField("Container name", text: $containerName)
                        }
                        .navigationTitle("New Container")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { showNewContainer = false }
                            }
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Save") {
                                    let container = ScaleContainer(
                                        name: containerName,
                                        weight: capturedWeight
                                    )
                                    modelContext.insert(container)
                                    showNewContainer = false
                                }
                                .disabled(containerName.isEmpty)
                            }
                        }
                    }
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

struct ToggleButtonStyle: ButtonStyle {
    var isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .background(isActive ? Color.accentColor : Color.clear)
            .foregroundStyle(isActive ? .white : .accentColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor, lineWidth: 1.5)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
