//
//  SugarSession.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 6/10/25.
//

import Foundation

struct SugarSession: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    let records: [Record]

    var totalCarbs: Double {
        records.compactMap { $0.breadUnits }.reduce(0, +)
    }

    var totalInsulin: Int {
        records.compactMap { $0.insulinUnits }.reduce(0, +)
    }
}

extension SugarSession {
    static let mockArray: [SugarSession] = [
        .init(date: Date(), records: Record.mockArray),
        .init(date: Date().addingTimeInterval(-86400), records: Record.mockArray2),
    ]
}

// import Playgrounds

//#Playground {
//    let record1 = Record(insulinUnits: 4, breadUnits: 2.5)
//    let record2 = Record(insulinUnits: 2, breadUnits: 1.0)
//    let session = SugarSession(date: Date(), records: [record1, record2])
//    let carbs = session.totalCarbs
//    let insulin = session.totalInsulin
//}
