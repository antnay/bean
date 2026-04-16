//
//  BrewManager.swift
//  bean
//
//  Created by Anthony on 4/12/26.
//

import Foundation
import SwiftData

// Gets last used models (equipmentm, basket, etc)
class ModelDefaults {
    static let shared = ModelDefaults()
    private init() {}

    private let defaults = UserDefaults.standard
    var lastGrinderID: UUID? {
        get { defaults.string(forKey: "lastGrinder").flatMap(UUID.init) }
        set { defaults.set(newValue?.uuidString, forKey: "lastGrinder") }
    }

    var lastEquipmentID: UUID? {
        get { defaults.string(forKey: "lastEquipment").flatMap(UUID.init) }
        set { defaults.set(newValue?.uuidString, forKey: "lastEquipment") }
    }

    var lastBasketID: UUID? {
        get { defaults.string(forKey: "lastBasket").flatMap(UUID.init) }
        set { defaults.set(newValue?.uuidString, forKey: "lastBasket") }
    }

    var lastBeanID: UUID? {
        get { defaults.string(forKey: "lastBean").flatMap(UUID.init) }
        set { defaults.set(newValue?.uuidString, forKey: "lastBean") }
    }

    var lastContainerID: UUID? {
        get { defaults.string(forKey: "lastContainer").flatMap(UUID.init) }
        set { defaults.set(newValue?.uuidString, forKey: "lastContainer") }
    }

    func lastGrinder(in context: ModelContext) -> Grinder? {
        guard let id = lastGrinderID else { return nil }
        let descriptor = FetchDescriptor<Grinder>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }

    func lastEquipment(in context: ModelContext) -> Equipment? {
        guard let id = lastEquipmentID else { return nil }
        let descriptor = FetchDescriptor<Equipment>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }

    func lastBasket(in context: ModelContext) -> Basket? {
        guard let id = lastBasketID else { return nil }
        let descriptor = FetchDescriptor<Basket>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }

    func lastBean(in context: ModelContext) -> Bean? {
        guard let id = lastBeanID else { return nil }
        let descriptor = FetchDescriptor<Bean>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }

    func lastContainer(in context: ModelContext) -> ScaleContainer? {
        guard let id = lastContainerID else { return nil }
        let descriptor = FetchDescriptor<ScaleContainer>(
            predicate: #Predicate { $0.id == id }
        )
        return try? context.fetch(descriptor).first
    }
}
