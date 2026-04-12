//
//  Acacia.swift
//  bean
//
//  Created by Anthony on 4/10/26.
//

import AcaiaSDK
import Combine
import Foundation
import CoreBluetooth

class ScaleManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var weight: Float = 0.0
    @Published var unit: AcaiaScaleWeightUnit = .gram
    @Published var timerSeconds: Int = 0
    @Published var timerDisplay: String = ""
    @Published var isConnected: Bool = false
    @Published var discoveredScales: [AcaiaScale] = []
    @Published var isBluetoothOn: Bool = false
    private var btMan: CBCentralManager!

    override init() {
        super.init()
        btMan = CBCentralManager.init(delegate: self, queue: nil)

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

    }
    
    @objc func centralManagerDidUpdateState(_ central: CBCentralManager) {
           DispatchQueue.main.async {
               self.isBluetoothOn = central.state == .poweredOn
           }
       }

    @objc private func didConnect(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.isConnected = true
        }
    }

    @objc private func didDisconnect(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.isConnected = false
        }
    }

    @objc private func didFinishScan(_ notif: NSNotification) {
        DispatchQueue.main.async {
            self.discoveredScales = AcaiaManager.shared().scaleList
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
        DispatchQueue.main.async {
            self.timerSeconds = time
            AcaiaManager.shared().connectedScale?.startTimer()
        }
    }

    func scan() {
        guard isBluetoothOn else { return }
        AcaiaManager.shared().startScan(0.5)
    }

    func connect(to scale: AcaiaScale) {
        scale.connect()
    }

    func disconnect() {
        AcaiaManager.shared().connectedScale?.disconnect()
    }

    func tare() {
        AcaiaManager.shared().connectedScale?.tare()
    }

    func timerButton() {
        AcaiaManager.shared().connectedScale?.startTimer()
    }
    
    func pauseTimer() {
        AcaiaManager.shared().connectedScale?.pauseTimer()
    }
}
