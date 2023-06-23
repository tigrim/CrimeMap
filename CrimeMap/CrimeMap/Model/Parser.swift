//
//  Parser.swift
//  CrimeMap
//
//

import Foundation

// MARK: - ContentEvent
struct ContentEvent: Codable {
    let ua, de, en, fr, es, it, ru: Payload
}

// MARK: - Payload
struct Payload: Codable {
    let affectedType, objectStatus, event, qualification: [String: String]

    enum CodingKeys: String, CodingKey {
        case affectedType = "affected_type"
        case objectStatus = "object_status"
        case event, qualification
    }
}

enum ParsingEventType {
    case affectedType, objectStatus, event, qualification
}

final class Parser {
    var contentEvent: ContentEvent!

    func getAnnotation() -> [Annotation] {
        if let pathNames = Bundle.main.path(forResource: "names", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: pathNames), options: [])
                if let eventsJSON = try? JSONDecoder().decode(ContentEvent.self, from: data) {
                    contentEvent = eventsJSON
                } else {
                    return []
                }
            } catch {
                debugPrint("parseContent -> exception")
                return []
            }
        }
        if let pathEvent = Bundle.main.path(forResource: "event", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: pathEvent), options: .mappedIfSafe)
                let json = try? JSONSerialization.jsonObject(with: data)
                if let dic = json as? [String: [String: Any]] {
                    var crimes: [Crime] = []
                    let values = Array(dic.values)
                    for item in values {
                        guard
                            let from = item["from"] as? String,
                            let till = item["till"] as? String,
                            let fromDate = DateFormatter.shotFormatter.date(from: from),
                            let tillDate = DateFormatter.shotFormatter.date(from: till),
                            let lat = item["lat"] as? Double,
                            lat > 1.0,
                            let lon = item["lon"] as? Double
                        else {
                           continue
                        }
                        var affectedNumber = "0"
                        if let affectedN = item["affected_number"] {
                            if let affected = affectedN as? [String] {
                                affectedNumber = affected[0]
                            } else if let affected = affectedN as? [Int] {
                                affectedNumber = String(affected[0])
                            }
                        }
                        let objectStatus = getValuesFor(keys: (item["object_status"] as? [String]) ?? [], contentEvent: contentEvent, type: .objectStatus)
                        let event = getValuesFor(keys: (item["event"] as? [String]) ?? [], contentEvent: contentEvent, type: .event)
                        let qualification = getValuesFor(keys: (item["qualification"] as? [String]) ?? [], contentEvent: contentEvent, type: .qualification)
                        let affectedType = getValuesFor(keys: (item["affectedType"] as? [String]) ?? [], contentEvent: contentEvent, type: .affectedType)
                        let crime = Crime(rangeDate: RangeDate(from: fromDate, till: tillDate),
                                          lat: lat,
                                          lon: lon,
                                          event: event,
                                          qualification: qualification,
                                          objectStatus: objectStatus,
                                          affectedType: affectedType,
                                          affectedNumber: affectedNumber)
                        crimes.append(crime)
                    }
                    return crimes.map { Annotation(crime: $0) }
                } else {
                    return []
                }
            } catch {
                debugPrint("parseContent -> exception \(error)")
                return []
            }
        } else {
            return []
        }
    }

    func getValuesFor(keys: [String], contentEvent: ContentEvent, type: ParsingEventType) -> [String]? {
        var result = [String]()
        keys.forEach {
            switch type {
            case .event:
                if let value = contentEvent.ua.event[$0] {
                    result.append(value)
                }
            case .affectedType:
                if let value = contentEvent.ua.affectedType[$0] {
                    result.append(value)
                }
            case .objectStatus:
                if let value = contentEvent.ua.objectStatus[$0] {
                    result.append(value)
                }
            case .qualification:
                if let value = contentEvent.ua.qualification[$0] {
                    result.append(value)
                }
            }
        }
        return result.isEmpty ? nil : result
    }
}
