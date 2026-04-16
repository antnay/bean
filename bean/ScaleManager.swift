//
//  ScaleManager.swift
//  bean
//
//  Created by Anthony on 4/10/26.
//

import AcaiaSDK
import Combine
import CoreBluetooth
import Foundation
import SwiftData

struct FlowData: Identifiable {
    let id = UUID()
    let time: Double
    let flowRate: Double
}

struct MassData: Identifiable {
    let id = UUID()
    let time: Double
    let weight: Float
}

enum Mode {
    case brew
    case container
    case scale
}

enum BrewMode {
    case none
    case autoTimer
}

class ScaleManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    var modelContext: ModelContext
    @Published var autoScan: Bool = true
    private var scanTimer: Timer?
    private var btMan: CBCentralManager!
    private let lastScaleKey = "lastConnectedScaleID"

    var lastScaleID: String? {
        get { UserDefaults.standard.string(forKey: lastScaleKey) }
        set { UserDefaults.standard.set(newValue, forKey: lastScaleKey) }
    }
    @Published var isBluetoothOn: Bool = false

    var netWeight: Float {
        weight - containerOffset
    }
    @Published var containerOffset: Float = 0.0
    @Published var isTimerPaused: Bool = false
    @Published var isTimerStarted: Bool = false
    @Published var weight: Float = 0.0
    @Published var unit: AcaiaScaleWeightUnit = .gram
    @Published var timerSeconds: Int = 0
    @Published var timerDisplay: String = "00:00"
    @Published var isConnected: Bool = false
    @Published var mode: Mode = .scale
    @Published var discoveredScales: [AcaiaScale] = []
    private var lastWeight: Float = 0.0
    private var lastWeightTime: Date = .now
    private var lastWeightUpdate: Date = Date.distantPast
    private var lastTimerUpdate: Date = .distantPast
    private var displayTimer: Timer?
    @Published var flowSamples: [FlowData] = []
    @Published var weightSamples: [MassData] = []
    private var flowHistory: [Double] = []
    private var brewStartTime: Date?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        btMan = CBCentralManager(delegate: self, queue: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didConnect),
            name: .init(AcaiaScaleDidConnected),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didDisconnect),
            name: .init(AcaiaScaleDidDisconnected),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishScan),
            name: .init(rawValue: AcaiaScaleDidFinishScan),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onWeight),
            name: .init(rawValue: AcaiaScaleWeight),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTimer),
            name: .init(rawValue: AcaiaScaleTimer),
            object: nil
        )
        refreshContainerOffset()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothOn = central.state == .poweredOn
            if self.isBluetoothOn {
                self.scan()
            }
        }
    }

    @objc private func didConnect(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.stopAutoScan()
            if let scale = AcaiaManager.shared().connectedScale {
                self.lastScaleID = scale.name
            }
            AcaiaManager.shared().enableBackgroundRecovery = true
        }
    }

    @objc private func didDisconnect(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.disconnectRoutine()
            AcaiaManager.shared().enableBackgroundRecovery = false
            self.scan()
        }
    }

    @objc private func didFinishScan(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.discoveredScales = AcaiaManager.shared().scaleList
            if let lastID = self.lastScaleID,
                let scale = self.discoveredScales.first(where: {
                    $0.name == lastID
                })
            {
                self.connect(to: scale)
            }
        }
    }

    @objc private func onTare(_ notif: NSNotification) {
        DispatchQueue.main.async {
            AcaiaManager.shared().connectedScale?.tare()
        }
    }

    @objc private func onWeight(_ notif: NSNotification) {
        let now = Date()
        guard now.timeIntervalSince(lastWeightUpdate) > 0.1 else { return }
        lastWeightUpdate = now

        let weight =
            notif.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float ?? 0.0
        if self.mode == .scale && weight == self.weight { return }

        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.weight = weight

            if self.mode == .brew && self.isTimerStarted {
                let deltaT = now.timeIntervalSince(self.lastWeightTime)
                if deltaT > 0.25 {
                    let rawFlow = Double(self.weight - self.lastWeight) / deltaT
                    let clampedFlow = max(0, min(rawFlow, 10))
                    self.flowHistory.append(clampedFlow)
                    if self.flowHistory.count > 3 {
                        self.flowHistory.removeFirst()
                    }
                    let smoothedFlow =
                        self.flowHistory.reduce(0, +)
                        / Double(self.flowHistory.count)

                    let elapsed = now.timeIntervalSince(
                        self.brewStartTime ?? now
                    )

                    self.flowSamples.append(
                        FlowData(time: elapsed, flowRate: smoothedFlow)
                    )
                    self.weightSamples.append(
                        MassData(time: elapsed, weight: max(0, self.weight))
                    )

                    self.lastWeight = self.weight
                    self.lastWeightTime = now
                }
            } else {
                self.lastWeight = self.weight
                self.lastWeightTime = now
            }
        }
    }
    @objc private func onTimer(_ notif: NSNotification) {
        let now = Date()
        guard now.timeIntervalSince(lastTimerUpdate) > 0.3 else { return }
        lastTimerUpdate = now

        guard
            let time: Int = notif.userInfo?[AcaiaScaleUserInfoKeyTimer] as? Int
        else {
            print("returning from onTimer (guard failed")
            return
        }
        guard time != self.timerSeconds else { return }
        DispatchQueue.main.async {
            print("timer: \(time)")
            print("mode: \(self.mode)")
            if !self.isTimerStarted {
                self.isTimerStarted = true
            }
            self.timerSeconds = time
            self.timerDisplay = String(
                format: "%02d:%02d",
                time / 60,
                time % 60
            )
        }
    }

    func refreshContainerOffset() {
        containerOffset =
            ModelDefaults.shared.lastContainer(in: modelContext)?.weight ?? 0.0
        print(containerOffset)
    }

    func scan() {
        guard isBluetoothOn else { return }
        if autoScan {
            startAutoScan()
        } else {
            scanForScales()
        }
    }

    func connect(to scale: AcaiaScale) {
        scale.connect()
    }

    func disconnect() {
        disconnectRoutine()
        AcaiaManager.shared().connectedScale?.disconnect()
    }

    func tare() {
        AcaiaManager.shared().connectedScale?.tare()
    }

    func timerButton() {
        if let scale = AcaiaManager.shared().connectedScale {
            if isTimerStarted {
                isTimerStarted = false
                // FIXME: pressing stop timer resets timer, it should instead just stop it and not reset
                //                isTimerPaused = false
                //                timerDisplay = "00:00"
                //                timerSeconds = 0
                scale.pauseTimer()
            } else {
                scale.stopTimer()
                isTimerStarted = true
                if self.mode == .brew {
                    print("starting brew timer")
                    startBrew()
                } else {
                    print("starting scale timer")
                }
                scale.startTimer()
                //                timerSeconds = 0
                //                displayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                //                    guard let self else { return }
                //                    self.timerSeconds += 1
                //                    self.timerDisplay = String(format: "%02d:%02d", self.timerSeconds / 60, self.timerSeconds % 60)
                //                }
            }
        }
    }

    func pauseTimer() {
        if let scale = AcaiaManager.shared().connectedScale {
            if isTimerPaused {
                isTimerPaused = false
                scale.startTimer()
            } else {
                isTimerPaused = true
                scale.pauseTimer()
            }
        }
    }

    func containerMode() {
        print("container mode")
        self.mode = .container
    }

    func brewMode() {
        print("brew mode")
        clearTimer()
        self.mode = .brew
        clearContainer()
    }

    func scaleMode() {
        print("scale mode")
        clearTimer()
        self.mode = .scale
    }

    // Starts the brew process.
    // TODO: case when user does not have auto timer on scale sofrware and presses start brew in app
    // TODO: case when user has auto timer on scale software and wants to start brew from app
    func startBrew() {
        flowSamples = [FlowData(time: 0, flowRate: 0)]
        weightSamples = [MassData(time: 0, weight: weight)]
        flowHistory = []
        print("flowsamples count: \(flowSamples.count)")
        print("weightsamples count: \(weightSamples.count)")
        lastWeight = weight
        lastWeightTime = Date()
        brewStartTime = Date()
        clearTimer()
    }

    // If you have a frequently used container in your weighing workflow, you can save the weight of the
    // container using the Tare Save function. This will allow you to weigh the container with contents,
    // then trigger Tare Save to deduct the container weight and obtain the net weight.
    func saveContainer(container: ScaleContainer) {
        modelContext.insert(container)
        try? modelContext.save()
        ModelDefaults.shared.lastContainerID = container.id
    }

    func loadContainer(container: ScaleContainer) {
        self.containerOffset = container.weight
        ModelDefaults.shared.lastContainerID = container.id
    }

    func stopAutoScan() {
        print("stopping autoscan")
        scanTimer?.invalidate()
        scanTimer = nil
    }

    private func clearContainer() {
        self.containerOffset = 0.0
    }

    private func clearTimer() {
        self.timerDisplay = "00:00"
        self.isTimerStarted = false
        self.isTimerPaused = false
        print("cleared timer")
    }

    private func disconnectRoutine() {
        self.isConnected = false
        self.timerDisplay = "disconnected"
        self.weight = 0.0
        print("disconnected from scale")
    }

    private func startAutoScan() {
        print("starting autoscan")
        guard scanTimer == nil else { return }
        scanTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) {
            [weak self] _ in
            guard let self, !self.isConnected else {
                self?.stopAutoScan()
                return
            }
            self.scanForScales()
        }
    }

    private func scanForScales() {
        print("scanning for scales")
        AcaiaManager.shared().startScan(0.5)
    }
}
