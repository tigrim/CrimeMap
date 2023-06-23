//
//  AnotationsService.swift
//  CrimeMap
//

import Foundation

final class AnnotationService {
    static let shared = AnnotationService()

    private init() { }

    private(set) var maxDateString: String?
    private(set) var minDateString: String?

    private var crimes: [Crime] = []

    func getAnnotation(fromDate: String, tillDate: String) -> [Annotation] {
        guard let from = DateFormatter.shotFormatter.date(from: fromDate),
              let till = DateFormatter.shotFormatter.date(from: tillDate) else {
            return []
        }
        if till >= from {
            let range = from...till
            let items = crimes.filter { range.contains($0.rangeDate.from) && range.contains($0.rangeDate.till) }
            return items.map { Annotation(crime: $0) }
        } else {
            return []
        }
    }

    func getAllPreparedAnnotations() -> [Annotation] {
        crimes.map { Annotation(crime: $0) }
    }

    func getAnotations() -> [Annotation] {
        let parser = Parser()
        let annotations = parser.getAnnotation()
        crimes = annotations.map { $0.crime }
        maxDateString = getMaxDateString()
        minDateString = getMinDateString()
        return annotations
    }

    func getMinDate() -> Date? {
        crimes.map { $0.rangeDate.from }.min()
    }

    func getMaxDate() -> Date? {
        crimes.map { $0.rangeDate.till }.max()
    }

    private func getMaxDateString() -> String {
        if let max = getMaxDate() {
            return DateFormatter.shotFormatter.string(from: max)
        } else {
            return ""
        }
    }

    private func getMinDateString() -> String {
        if let min = getMinDate() {
            return DateFormatter.shotFormatter.string(from: min)
        } else {
            return ""
        }
    }
}
