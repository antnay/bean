//
//  SettingsView.swift
//  bean
//
//  Created by Anthony on 4/11/26.
//

import AcaiaSDK
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var scaleMan: ScaleManager

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Scales", destination: ScaleSettingsView())
                NavigationLink("Baskets", destination: BasketSettingsView())
                NavigationLink(
                    "Equipment",
                    destination: EquipmentSettingsView()
                )
                NavigationLink("Beans", destination: BeanSettingsView())
            }
        }
        .navigationTitle("Settings")
    }
}

struct ScaleSettingsView: View {
    @EnvironmentObject private var scaleMan: ScaleManager

    var body: some View {
        if !scaleMan.isBluetoothOn {
            Text("Enable bluetooth in your device settings")
                .frame(alignment: .center)
        } else {
            Form {
                Section {
                    Toggle(
                        "Auto scan",
                        systemImage:
                            "arrow.trianglehead.2.clockwise.rotate.90.circle.fill",
                        isOn: $scaleMan.autoScan
                    )
                    Button(action: scaleMan.scan) {
                        Label(
                            "Scan",
                            systemImage: "arrow.2.circlepath.circle"
                        )
                    }
                } header: {
                    Text("settings")
                }
                Section {
                    List {
                        if scaleMan.discoveredScales.isEmpty {
                        } else {
                            ForEach(
                                Array(scaleMan.discoveredScales.enumerated()),
                                id: \.offset
                            ) { _, scale in
                                Button(action: { scaleMan.connect(to: scale) }) {
                                    Text(scale.name)
                                }
                            }
                        }
                    }
                } header: {
                    Text("scales found")
                }
            }
            .navigationTitle("Scales")
            .padding(.all, 10)
        }
    }
}

struct BasketSettingsView: View {

    var body: some View {
    }
}

struct EquipmentSettingsView: View {

    var body: some View {
    }
}

struct BeanSettingsView: View {

    var body: some View {
    }
}

struct GrinderSettingsView: View {

    var body: some View {
    }
}

struct ContainersSettingsView: View {

    var body: some View {
    }
}
