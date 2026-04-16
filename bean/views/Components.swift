//
//  Components.swift
//  bean
//
//  Created by Anthony on 4/15/26.
//

import Charts
import SwiftUI

struct WeightDisplay: View {
    @EnvironmentObject var scaleMan: ScaleManager

    var body: some View {
        Text("\(scaleMan.weight, specifier: "%.1f")")
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .monospacedDigit()
    }
}

struct NetWeightDisplay: View {
    @EnvironmentObject var scaleMan: ScaleManager

    var body: some View {
        Text("\(scaleMan.netWeight, specifier: "%.1f")")
            .font(.system(size: 72, weight: .bold, design: .rounded))
            .monospacedDigit()
    }
}

struct TimerDisplay: View {
    @EnvironmentObject var scaleMan: ScaleManager

    var body: some View {
        Text(scaleMan.timerDisplay)
            .font(.system(size: 36, weight: .semibold, design: .monospaced))
    }
}

struct ChartView: View {
    var flow: [FlowData]
    var mass: [MassData]

    var body: some View {
        VStack(spacing: 4) {
            Chart(flow) { sample in
                LineMark(
                    x: .value("time", sample.time),
                    y: .value("flow", sample.flowRate)
                )
                .interpolationMethod(.catmullRom)
                AreaMark(
                    x: .value("Time", sample.time),
                    y: .value("Flow", sample.flowRate)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            Color.accentColor.opacity(0.3),
                            Color.accentColor.opacity(0.0),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .foregroundStyle(Color.orange)
            .chartYAxisLabel(
                "flow (g/s)",
                position: .trailing,
                alignment: .center
            )
            .chartXScale(domain: xDomainFlow)
            .chartYScale(domain: yDomainFlow)
            .frame(height: 200)

            Chart(mass) { sample in
                LineMark(
                    x: .value("time", sample.time),
                    y: .value("mass", sample.weight)
                )
                .interpolationMethod(.catmullRom)
            }
            .chartXScale(domain: xDomainMass)
            .chartYScale(domain: yDomainMass)
            .chartXAxisLabel("time (s)")
            .chartYAxisLabel(
                "mass (g)",
                position: .trailing,
                alignment: .center
            )
            .frame(height: 200)
        }
    }
    var xDomainFlow: ClosedRange<Double> {
        guard let max = flow.last?.time, max > 30 else { return 0...30 }
        return 0...max
    }

    var yDomainFlow: ClosedRange<Double> {
        guard let max = flow.map(\.flowRate).max(), max > 5 else {
            return 0...5
        }
        return 0...(max * 1.2)
    }

    var xDomainMass: ClosedRange<Double> {
        guard let max = mass.last?.time, max > 30 else { return 0...30 }
        return 0...max
    }

    var yDomainMass: ClosedRange<Float> {
        guard let max = mass.map(\.weight).max(), max > 5 else {
            return 0...40
        }
        return 0...(max * 1.2)
    }
}
