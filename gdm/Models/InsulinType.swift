//
//  InsulinType.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import SwiftUI


///  Типы инсулина, которые используются в приложении.
enum InsulinType: String, CaseIterable, Identifiable, Hashable {
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
