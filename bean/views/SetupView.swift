//
//  SettingsView.swift
//  bean
//
//  Created by Anthony on 4/11/26.
//

import AcaiaSDK
import SwiftData
import SwiftUI

struct SetupView: View {
    @EnvironmentObject private var scaleMan: ScaleManager

    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Baskets", destination: BasketSettingsView())
                NavigationLink("Beans", destination: BeanSettingsView())
                NavigationLink(
                    "Equipment",
                    destination: EquipmentSettingsView()
                )
                NavigationLink("Scales", destination: ScaleSettingsView())
            }
        }
        .scrollDisabled(true)
        .background { Color.appBackground.ignoresSafeArea() }
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
                                Button(action: { scaleMan.connect(to: scale) })
                                {
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
    @Environment(\.modelContext) private var modelContext
    @Query private var baskets: [Basket]
    @State private var editingBasketID: UUID?
    @FocusState private var focusedBasketID: UUID?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(baskets) { basket in
                    if basket.id == editingBasketID {
                        TextField(
                            "Basket name",
                            text: Binding(
                                get: { basket.name },
                                set: { basket.name = $0 }
                            )
                        )
                        .focused($focusedBasketID, equals: basket.id)
                        .onSubmit {
                            editingBasketID = nil
                        }
                    } else {
                        NavigationLink {
                            Text(basket.name)
                        } label: {
                            Text(basket.name)
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        modelContext.delete(baskets[index])
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {
                        let basket = Basket(name: "")
                        modelContext.insert(basket)
                        editingBasketID = basket.id
                        focusedBasketID = basket.id
                    }) {
                        Label("Add Basket", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Baskets")
        }
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
