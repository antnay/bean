//
//  BrewView.swift
//  bean
//
//  Created by Anthony on 4/12/26.
//

import SwiftUI

struct BrewView: View {
    @EnvironmentObject private var scaleMan: ScaleManager

    var body: some View {
        VStack {
            ChartView(
                flow: scaleMan.flowSamples,
                mass: scaleMan.weightSamples
            )
            TimerDisplay()
            WeightDisplay()
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
    }
}
