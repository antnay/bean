//
//  Brew.swift
//  bean
//
//  Created by Anthony on 4/11/26.
//

import AcaiaSDK
import SwiftUI

struct BrewView: View {
    @EnvironmentObject private var scaleMan: ScaleManager

    var body: some View {
        VStack {
            Text("\(scaleMan.weight, specifier: "%.1f") g")
            Text("\(scaleMan.timerSeconds, specifier: "%.0f") s")
            HStack {
                Button("Tare", action: {
                    scaleMan.tare()
                })
                Button("Timer", action: {
                    if scaleMan.timerSeconds > 0 {
                        scaleMan.stopTimer()
                    }
                    scaleMan.startTimer()
                })

            }
        }
    }
}
