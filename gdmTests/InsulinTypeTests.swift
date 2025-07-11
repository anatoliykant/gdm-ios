//
//  InsulinTypeTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 11.07.2025.
//

import Testing
import Foundation
import SwiftUI
@testable import gdm

/// Тесты для enum InsulinType
@Suite("InsulinType Tests")
struct InsulinTypeTests {
    
    // MARK: - Basic Properties Tests
    
    @Test("InsulinType none properties")
    func insulinType_None_HasCorrectProperties() throws {
        let insulin = InsulinType.none
        
        #expect(insulin.rawValue == "Нет")
        #expect(insulin.id == "Нет")
        #expect(insulin.color == .gray)
    }
    
    @Test("InsulinType novorapid properties")
    func insulinType_Novorapid_HasCorrectProperties() throws {
        let insulin = InsulinType.novorapid
        
        #expect(insulin.rawValue == "Новорапид")
        #expect(insulin.id == "Новорапид")
        #expect(insulin.color == .orange.opacity(0.1))
    }
    
    @Test("InsulinType levemir properties")
    func insulinType_Levemir_HasCorrectProperties() throws {
        let insulin = InsulinType.levemir
        
        #expect(insulin.rawValue == "Левемир")
        #expect(insulin.id == "Левемир")
        #expect(insulin.color == .blue.opacity(0.1))
    }
    
    // MARK: - CaseIterable Tests
    
    @Test("InsulinType allCases contains all types")
    func insulinType_AllCases_ContainsAllTypes() throws {
        let allCases = InsulinType.allCases
        
        #expect(allCases.count == 3)
        #expect(allCases.contains(.none))
        #expect(allCases.contains(.novorapid))
        #expect(allCases.contains(.levemir))
    }
    
    @Test("InsulinType allCases order")
    func insulinType_AllCases_HasCorrectOrder() throws {
        let allCases = InsulinType.allCases
        
        #expect(allCases[0] == .none)
        #expect(allCases[1] == .novorapid)
        #expect(allCases[2] == .levemir)
    }
    
    // MARK: - Identifiable Tests
    
    @Test("InsulinType id property equals rawValue")
    func insulinType_IdProperty_EqualsRawValue() throws {
        for insulinType in InsulinType.allCases {
            #expect(insulinType.id == insulinType.rawValue)
        }
    }
    
    @Test("InsulinType id property uniqueness")
    func insulinType_IdProperty_IsUnique() throws {
        let allIds = InsulinType.allCases.map { $0.id }
        let uniqueIds = Set(allIds)
        
        #expect(allIds.count == uniqueIds.count)
    }
    
    // MARK: - Hashable Tests
    
    @Test("InsulinType hashable works correctly")
    func insulinType_Hashable_WorksCorrectly() throws {
        let insulin1 = InsulinType.novorapid
        let insulin2 = InsulinType.novorapid
        let insulin3 = InsulinType.levemir
        
        #expect(insulin1.hashValue == insulin2.hashValue)
        #expect(insulin1.hashValue != insulin3.hashValue)
        
        // Тестируем использование в Set
        let insulinSet: Set<InsulinType> = [insulin1, insulin2, insulin3]
        #expect(insulinSet.count == 2) // insulin1 и insulin2 это один и тот же элемент
    }
    
    // MARK: - Codable Tests
    
    @Test("InsulinType codable encoding")
    func insulinType_Codable_EncodesCorrectly() throws {
        let insulin = InsulinType.novorapid
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(insulin)
        let jsonString = String(data: data, encoding: .utf8)
        
        #expect(jsonString?.contains("Новорапид") == true)
    }
    
    @Test("InsulinType codable decoding")
    func insulinType_Codable_DecodesCorrectly() throws {
        let jsonData = "\"Левемир\"".data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let insulin = try decoder.decode(InsulinType.self, from: jsonData)
        
        #expect(insulin == .levemir)
    }
    
    @Test("InsulinType codable round trip")
    func insulinType_Codable_RoundTripWorks() throws {
        for originalInsulin in InsulinType.allCases {
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            
            let data = try encoder.encode(originalInsulin)
            let decodedInsulin = try decoder.decode(InsulinType.self, from: data)
            
            #expect(decodedInsulin == originalInsulin)
        }
    }
    
    // MARK: - Color Tests
    
    @Test("InsulinType colors are different")
    func insulinType_Colors_AreDifferent() throws {
        let noneColor = InsulinType.none.color
        let novorapidColor = InsulinType.novorapid.color
        let levemirColor = InsulinType.levemir.color
        
        // Проверяем что цвета различаются (базовые цвета)
        // Сравниваем описания цветов, так как Color не implements Equatable напрямую
        #expect(noneColor.description != novorapidColor.description)
        #expect(noneColor.description != levemirColor.description) 
        #expect(novorapidColor.description != levemirColor.description)
    }
    
    @Test("InsulinType none color is gray")
    func insulinType_NoneColor_IsGray() throws {
        let color = InsulinType.none.color
        let grayColor = Color.gray
        
        #expect(color.description == grayColor.description)
    }
    
    @Test("InsulinType color opacity values")
    func insulinType_ColorOpacity_IsCorrect() throws {
        // Проверяем что novorapid и levemir имеют opacity 0.1
        let novorapidColor = InsulinType.novorapid.color
        let levemirColor = InsulinType.levemir.color
        
        let expectedNovorapidColor = Color.orange.opacity(0.1)
        let expectedLevemirColor = Color.blue.opacity(0.1)
        
        #expect(novorapidColor.description == expectedNovorapidColor.description)
        #expect(levemirColor.description == expectedLevemirColor.description)
    }
    
    // MARK: - Initialization Tests
    
    @Test("InsulinType initialization from rawValue")
    func insulinType_InitializationFromRawValue_WorksCorrectly() throws {
        #expect(InsulinType(rawValue: "Нет") == InsulinType.none)
        #expect(InsulinType(rawValue: "Новорапид") == InsulinType.novorapid)
        #expect(InsulinType(rawValue: "Левемир") == InsulinType.levemir)
        #expect(InsulinType(rawValue: "Несуществующий") == nil)
    }
    
    // MARK: - String Representation Tests
    
    @Test("InsulinType rawValue localization")
    func insulinType_RawValue_IsLocalized() throws {
        // Проверяем что raw values на русском языке
        #expect(InsulinType.none.rawValue == "Нет")
        #expect(InsulinType.novorapid.rawValue == "Новорапид")
        #expect(InsulinType.levemir.rawValue == "Левемир")
    }
    
    // MARK: - Realistic Usage Tests
    
    @Test("InsulinType in Record context")
    func insulinType_InRecordContext_WorksCorrectly() throws {
        let record1 = Record(
            insulinType: .novorapid,
            insulinUnits: 5
        )
        let record2 = Record(
            insulinType: .levemir,
            insulinUnits: 15
        )
        let record3 = Record(
            insulinType: .none,
            insulinUnits: nil
        )
        
        #expect(record1.insulinType == .novorapid)
        #expect(record2.insulinType == .levemir)
        #expect(record3.insulinType == .none)
        
        // Проверяем цвета
        #expect(record1.insulinType.color == .orange.opacity(0.1))
        #expect(record2.insulinType.color == .blue.opacity(0.1))
        #expect(record3.insulinType.color == .gray)
    }
    
    @Test("InsulinType switch statement coverage")
    func insulinType_SwitchStatement_CoversAllCases() throws {
        for insulinType in InsulinType.allCases {
            let description: String
            
            switch insulinType {
            case .none:
                description = "Инсулин не вводился"
            case .novorapid:
                description = "Быстрый инсулин"
            case .levemir:
                description = "Длинный инсулин"
            }
            
            #expect(!description.isEmpty)
        }
    }
} 