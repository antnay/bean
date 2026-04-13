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

enum Mode {
    case container
    case brew
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
    @Published var timerDisplay: String = "00.00"
    @Published var isConnected: Bool = false
    @Published var mode: Mode = .brew
    @Published var discoveredScales: [AcaiaScale] = []

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
            self.stopAutoScan()
            self.isConnected = true
            if let scale = AcaiaManager.shared().connectedScale {
                self.lastScaleID = scale.name
            }
        }
    }

    @objc private func didDisconnect(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.disconnectRoutine()
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
        DispatchQueue.main.async {
            self.weight =
                notif.userInfo?[AcaiaScaleUserInfoKeyWeight] as? Float ?? 0.0
        }
    }

    @objc private func onTimer(_ notif: NSNotification) {
        guard
            let time: Int = notif.userInfo?[AcaiaScaleUserInfoKeyTimer] as? Int
        else { return }
        print("timer notification")
        DispatchQueue.main.async {
            if !self.isTimerStarted {
                self.isTimerStarted = true
            }
            self.timerDisplay = String(
                format: "%02d:%02d",
                time / 60,
                time % 60
            )
            self.timerSeconds = time
            AcaiaManager.shared().connectedScale?.startTimer()
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
                isTimerPaused = false
                timerDisplay = "00:00"
                timerSeconds = 0
                scale.stopTimer()
            } else {
                isTimerStarted = true
                scale.startTimer()
            }
        }
    }

    // scale did not pause in testing
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
        self.mode = .container
    }

    func brewMode() {
        self.mode = .brew
        //        clearContainer()
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

    private func clearContainer() {
        self.containerOffset = 0.0
    }

    // Scale will autostart automatically when weight increase.
    // App just needs to know when it started for logging and graphing
    // maybe unnecessary
    func autoStartTimer() {
    }

    func stopAutoScan() {
        scanTimer?.invalidate()
        scanTimer = nil
    }

    private func disconnectRoutine() {
        self.isConnected = false
        self.mode = .brew
        self.timerSeconds = 0
        self.timerDisplay = "00.00"
        self.weight = 0.0
    }

    private func startAutoScan() {
        guard scanTimer == nil else { return }
        scanForScales()
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
        AcaiaManager.shared().startScan(0.5)
    }
}
