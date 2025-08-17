//
//  InsulinType.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import SwiftUI

enum FoodOrNotFoodTime: String, CaseIterable, Identifiable, Hashable, Codable {
    case empty = "Натощак"
    case breakfast = "Завтрак"
    case lunch = "Обед"
    case afternoonSnack = "Полдник"
    case dinner = "Ужин"
    case snack = "Перекус"
    case beforeSleep = "Перед сном"
    
    var id: String { self.rawValue }
}


///  Типы инсулина, которые используются в приложении.
enum InsulinType: String, CaseIterable, Identifiable, Hashable, Codable {
    case none = "Нет"
    case novorapid = "Новорапид"
    case levemir = "Левемир"
    // TODO: добавить другие типы инсулина

    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .none:
            return .gray
        case .novorapid:
            return .orange.opacity(0.1)
        case .levemir:
            return .blue.opacity(0.1)
        }
    }
}

enum Reminder: String, CaseIterable, Identifiable, Hashable {
    case afterOneHour = "Через час"
    case afterTwoHours = "Через два часа"
    case afterThreeHours = "Через три часа"
    
    var id: String { self.rawValue }
}
