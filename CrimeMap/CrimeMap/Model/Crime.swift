//
//  Crime.swift
//  CrimeMap
//

import Foundation

struct Crime {
    let rangeDate: RangeDate
    let lat, lon: Double
    let event: [String]?
    let qualification: [String]?
    let objectStatus: [String]?
    let affectedType: [String]?
    let affectedNumber: String
}

struct RangeDate {
    let from, till: Date

    init(from: Date, till: Date) {
        self.from = from
        self.till = till
    }
}

extension RangeDate: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.from == rhs.from &&
        lhs.till == rhs.till
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(from)
        hasher.combine(till)
    }
}
