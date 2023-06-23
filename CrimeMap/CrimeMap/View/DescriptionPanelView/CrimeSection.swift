//
//  CrimeSection.swift
//  CrimeMap
//

import Foundation

enum CrimeSection: Int, CaseIterable {
    case event
    case affectedType
    case status
    case qualification
    case affectedNumber

    var localizedString: String {
        switch self {
        case .affectedType:
            return "Тип потерпілих:"
        case .status:
            return "Тип об'єкта:"
        case .qualification:
            return "Правова кваліфікація:"
        case .affectedNumber:
            return "Кількість постраждалих:"
        case .event:
            return "Подія:"
        }
    }
}

struct CrimeEvent {
    let title: String
}

extension CrimeEvent: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
