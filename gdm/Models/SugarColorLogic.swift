//
//  SugarColorLogic.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-07.
//

import SwiftUI

struct SugarColorLogic {
    static func color(for record: Record, previousRecord: Record?, isFirstSugarOfDay: Bool) -> Color {
        guard let sugar = record.sugarLevel else { return .gray } // No sugar, no color indication

        // Logic from screenshot 3
        // 1. Первый сахар за день (натощак)
        if isFirstSugarOfDay {
            return sugar <= 5.0 ? .green : .red
        }

        // 2. Сахар после еды
        if let prevRecord = previousRecord, 
           let prevFood = prevRecord.food, 
           !prevFood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let timeDifferenceInHours = record.date.timeIntervalSince(prevRecord.date) / 3600

            if timeDifferenceInHours >= 0.8, timeDifferenceInHours < 1.8 { // Примерно 1 час
                return sugar <= 7.0 ? .green : .red
            } else if timeDifferenceInHours >= 1.8, timeDifferenceInHours < 2.8 { // Примерно 2 часа
                return sugar <= 6.7 ? .green : .red
            } else if timeDifferenceInHours >= 2.8 { // 3 часа и более
                return sugar <= 5.8 ? .green : .red
            }
        }
        
        // Fallback
        return sugar <= 5.0 ? .green : .red
    }
}
