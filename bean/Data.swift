//
//  Item.swift
//  bean
//
//  Created by Anthony on 4/10/26.
//

import Combine
import Foundation
import SwiftData

@Model
final class Brew {
    var id: UUID = UUID()
    var displayName: String
    var profile: Profile
    var grinder: Grinder?
    var equipment: Equipment?
    var basket: Basket?
    var bean: Bean?
    var grinderSetting: Double?
    var rating: Int?
    var notes: String?
    var timestamp: Date

    init(
        displayName: String?,
        profile: Profile,
        grinder: Grinder? = nil,
        equipment: Equipment? = nil,
        basket: Basket? = nil,
        bean: Bean? = nil,
        grinderSetting: Double? = nil,
        rating: Int? = nil,
        notes: String? = nil,
        timestamp: Date
    ) {
        self.displayName =
            displayName
            ?? Brew.createDisplayName(
                equipment: equipment,
                profile: profile,
                grinder: grinder
            )
        self.profile = profile
        self.grinder = grinder
        self.equipment = equipment
        self.basket = basket
        self.bean = bean
        self.grinderSetting = grinderSetting
        self.rating = rating
        self.notes = notes
        self.timestamp = timestamp
    }

    static func createDisplayName(
        equipment: Equipment? = nil,
        profile: Profile,
        grinder: Grinder? = nil
    ) -> String {
        let parts = [
            equipment?.name,
            "\(Int(profile.massIn))g → \(Int(profile.massOut))g",
            grinder?.name,
        ].compactMap { $0 }

        return parts.isEmpty ? "Untitled Brew" : parts.joined(separator: " · ")
    }
}

@Model
final class Grinder: Identifiable {
    var id: UUID = UUID()
    @Attribute(.unique) var name: String?
    var brand: String?
    var model: String?

    init(name: String? = nil, brand: String? = nil, model: String? = nil) {
        self.name = name
        self.brand = brand
        self.model = model
    }
}

@Model
final class Basket: Identifiable {
    var id: UUID = UUID()
    @Attribute(.unique) var name: String?

    init(name: String? = nil) {
        self.name = name
    }
}

@Model
final class Equipment: Identifiable {
    var id: UUID = UUID()
    @Attribute(.unique) var name: String?
    var brand: String?
    var model: String?

    init(name: String? = nil, brand: String? = nil, model: String? = nil) {
        self.name = name
        self.brand = brand
        self.model = model
    }
}

@Model
final class Bean: Identifiable {
    var id: UUID = UUID()
    var roaster: String?
    var name: String?
    var origin: String?
    var process: String?
    var roastDate: Date?

    init(
        roaster: String? = nil,
        name: String? = nil,
        origin: String? = nil,
        process: String? = nil,
        roastDate: Date? = nil
    ) {
        self.roaster = roaster
        self.name = name
        self.origin = origin
        self.process = process
        self.roastDate = roastDate
    }
}

@Model
final class Profile: Identifiable {
    var id: UUID = UUID()
    @Attribute(.unique) var name: String?
    var massIn: Double
    var massOut: Double
    var ratio: Double {
        massOut / massIn
    }
    var preinfusion: Double?
    var time: Double?  // maybe another type
    var temp: Double?
    var pressure: Double?

    init(
        name: String? = nil,
        massIn: Double,
        massOut: Double,
        preinfusion: Double? = nil,
        time: Double? = nil,
        temp: Double? = nil,
        pressure: Double? = nil
    ) {
        self.name = name
        self.massIn = massIn
        self.massOut = massOut
        self.preinfusion = preinfusion
        self.time = time
        self.temp = temp
        self.pressure = pressure
    }
}

@Model
final class ScaleContainer: Identifiable {
    var id: UUID = UUID()
    var name: String
    var weight: Float

    init(name: String, weight: Float) {
        self.name = name
        self.weight = weight
    }
}

