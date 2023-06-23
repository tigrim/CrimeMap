//
//  DateFormatterExtension.swift
//  CrimeMap
//

import Foundation

extension DateFormatter {
    static let shotFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        return df
    }()
}
