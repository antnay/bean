//
//  Settings.swift
//  bean
//
//  Created by Anthony on 4/11/26.
//

import AcaiaSDK
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var scaleMan: ScaleManager

    var body: some View {
        if !scaleMan.isBluetoothOn {
            Text("Enable bluetooth in your device settings")
        } else {
            VStack {
                //                if scaleMan.isConnected {
                //                    // display name
                //                }

                Button(action: scaleMan.scan) {
                    Text("Scan")
                }

                Text("Found Scales")
                List {
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
        }
    }
}
