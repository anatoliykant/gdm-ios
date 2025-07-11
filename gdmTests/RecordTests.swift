//
//  RecordTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 11.07.2025.
//

import Testing
import Foundation
@testable import gdm

/// Тесты для модели Record
@Suite("Record Tests")
struct RecordTests {
    
    // MARK: - Helper Methods
    
    /// Создает базовую запись для тестов
    private func createRecord(
        sugarLevel: Double? = 5.0,
        insulinType: InsulinType = .novorapid,
        insulinUnits: Int? = 7,
        food: String? = nil,
        breadUnits: Double? = nil
    ) -> Record {
        return Record(
            date: Date(),
            sugarLevel: sugarLevel,
            insulinType: insulinType,
            insulinUnits: insulinUnits,
            food: food,
            breadUnits: breadUnits
        )
    }
    
    // MARK: - didTakeInsulin Tests
    
    @Test("Record didTakeInsulin with valid insulin")
    func record_DidTakeInsulin_WithValidInsulin_ReturnsTrue() throws {
        let record = createRecord(
            insulinType: .novorapid,
            insulinUnits: 5
        )
        
        #expect(record.didTakeInsulin == true)
    }
    
    @Test("Record didTakeInsulin with none insulin type")
    func record_DidTakeInsulin_WithNoneInsulinType_ReturnsFalse() throws {
        let record = createRecord(
            insulinType: .none,
            insulinUnits: 5
        )
        
        #expect(record.didTakeInsulin == false)
    }
    
    @Test("Record didTakeInsulin with nil insulin units")
    func record_DidTakeInsulin_WithNilInsulinUnits_ReturnsFalse() throws {
        let record = createRecord(
            insulinType: .novorapid,
            insulinUnits: nil
        )
        
        #expect(record.didTakeInsulin == false)
    }
    
    @Test("Record didTakeInsulin with zero insulin units")
    func record_DidTakeInsulin_WithZeroInsulinUnits_ReturnsFalse() throws {
        let record = createRecord(
            insulinType: .novorapid,
            insulinUnits: 0
        )
        
        #expect(record.didTakeInsulin == false)
    }
    
    @Test("Record didTakeInsulin with negative insulin units")
    func record_DidTakeInsulin_WithNegativeInsulinUnits_ReturnsFalse() throws {
        let record = createRecord(
            insulinType: .novorapid,
            insulinUnits: -5
        )
        
        #expect(record.didTakeInsulin == false)
    }
    
    @Test("Record didTakeInsulin with levemir insulin type")
    func record_DidTakeInsulin_WithLevemirInsulinType_ReturnsTrue() throws {
        let record = createRecord(
            insulinType: .levemir,
            insulinUnits: 15
        )
        
        #expect(record.didTakeInsulin == true)
    }
    
    @Test("Record didTakeInsulin with both none type and nil units")
    func record_DidTakeInsulin_WithNoneTypeAndNilUnits_ReturnsFalse() throws {
        let record = createRecord(
            insulinType: .none,
            insulinUnits: nil
        )
        
        #expect(record.didTakeInsulin == false)
    }
    
    // MARK: - hasMeal Tests
    
    @Test("Record hasMeal with valid food description")
    func record_HasMeal_WithValidFoodDescription_ReturnsTrue() throws {
        let record = createRecord(food: "Хлеб с маслом")
        
        #expect(record.hasMeal == true)
    }
    
    @Test("Record hasMeal with nil food")
    func record_HasMeal_WithNilFood_ReturnsFalse() throws {
        let record = createRecord(food: nil)
        
        #expect(record.hasMeal == false)
    }
    
    @Test("Record hasMeal with empty food string")
    func record_HasMeal_WithEmptyFoodString_ReturnsFalse() throws {
        let record = createRecord(food: "")
        
        #expect(record.hasMeal == false)
    }
    
    @Test("Record hasMeal with whitespace only food")
    func record_HasMeal_WithWhitespaceOnlyFood_ReturnsFalse() throws {
        let record = createRecord(food: "   ")
        
        #expect(record.hasMeal == false)
    }
    
    @Test("Record hasMeal with newlines and tabs food")
    func record_HasMeal_WithNewlinesAndTabsFood_ReturnsFalse() throws {
        let record = createRecord(food: "\n\t  \n")
        
        #expect(record.hasMeal == false)
    }
    
    @Test("Record hasMeal with food containing only whitespace and valid text")
    func record_HasMeal_WithFoodContainingWhitespaceAndValidText_ReturnsTrue() throws {
        let record = createRecord(food: "  Завтрак  ")
        
        #expect(record.hasMeal == true)
    }
    
    @Test("Record hasMeal with single character food")
    func record_HasMeal_WithSingleCharacterFood_ReturnsTrue() throws {
        let record = createRecord(food: "a")
        
        #expect(record.hasMeal == true)
    }
    
    @Test("Record hasMeal with very long food description")
    func record_HasMeal_WithVeryLongFoodDescription_ReturnsTrue() throws {
        let longDescription = String(repeating: "очень длинное описание еды ", count: 100)
        let record = createRecord(food: longDescription)
        
        #expect(record.hasMeal == true)
    }
    
    // MARK: - Combined Properties Tests
    
    @Test("Record with meal and insulin")
    func record_WithMealAndInsulin_BothPropertiesWork() throws {
        let record = createRecord(
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Обед с хлебом",
            breadUnits: 3.0
        )
        
        #expect(record.didTakeInsulin == true)
        #expect(record.hasMeal == true)
    }
    
    @Test("Record with meal but no insulin")
    func record_WithMealButNoInsulin_OnlyMealPropertyTrue() throws {
        let record = createRecord(
            insulinType: .none,
            insulinUnits: nil,
            food: "Перекус",
            breadUnits: 1.0
        )
        
        #expect(record.didTakeInsulin == false)
        #expect(record.hasMeal == true)
    }
    
    @Test("Record with insulin but no meal")
    func record_WithInsulinButNoMeal_OnlyInsulinPropertyTrue() throws {
        let record = createRecord(
            insulinType: .levemir,
            insulinUnits: 15,
            food: nil,
            breadUnits: nil
        )
        
        #expect(record.didTakeInsulin == true)
        #expect(record.hasMeal == false)
    }
    
    @Test("Record with neither meal nor insulin")
    func record_WithNeitherMealNorInsulin_BothPropertiesFalse() throws {
        let record = createRecord(
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        #expect(record.didTakeInsulin == false)
        #expect(record.hasMeal == false)
    }
    
    // MARK: - Realistic Scenarios Tests
    
    @Test("Record breakfast scenario")
    func record_BreakfastScenario_PropertiesCorrect() throws {
        let record = createRecord(
            sugarLevel: 5.2,
            insulinType: .novorapid,
            insulinUnits: 7,
            food: "Хлеб житный, масло, сыр, яйцо",
            breadUnits: 2.5
        )
        
        #expect(record.didTakeInsulin == true)
        #expect(record.hasMeal == true)
        #expect(record.sugarLevel == 5.2)
        #expect(record.breadUnits == 2.5)
    }
    
    @Test("Record control measurement scenario")
    func record_ControlMeasurementScenario_PropertiesCorrect() throws {
        let record = createRecord(
            sugarLevel: 6.1,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        #expect(record.didTakeInsulin == false)
        #expect(record.hasMeal == false)
        #expect(record.sugarLevel == 6.1)
        #expect(record.breadUnits == nil)
    }
    
    @Test("Record correction insulin scenario")
    func record_CorrectionInsulinScenario_PropertiesCorrect() throws {
        let record = createRecord(
            sugarLevel: 7.8,
            insulinType: .novorapid,
            insulinUnits: 2,
            food: nil,
            breadUnits: nil
        )
        
        #expect(record.didTakeInsulin == true)
        #expect(record.hasMeal == false)
        #expect(record.sugarLevel == 7.8)
    }
    
    @Test("Record night insulin scenario")
    func record_NightInsulinScenario_PropertiesCorrect() throws {
        let record = createRecord(
            sugarLevel: 5.5,
            insulinType: .levemir,
            insulinUnits: 14,
            food: nil,
            breadUnits: nil
        )
        
        #expect(record.didTakeInsulin == true)
        #expect(record.hasMeal == false)
        #expect(record.insulinType == .levemir)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Record with extreme values")
    func record_WithExtremeValues_HandlesCorrectly() throws {
        let record = createRecord(
            sugarLevel: 0.1,
            insulinType: .novorapid,
            insulinUnits: 100,
            food: "a",
            breadUnits: 50.0
        )
        
        #expect(record.didTakeInsulin == true)
        #expect(record.hasMeal == true)
    }
    
    @Test("Record initialization with all defaults")
    func record_InitializationWithDefaults_CreatesValidRecord() throws {
        let record = Record()
        
        // Проверяем значения по умолчанию
        #expect(record.sugarLevel == nil)
        #expect(record.insulinType == .novorapid)
        #expect(record.insulinUnits == 7)
        #expect(record.food == nil)
        #expect(record.breadUnits == nil)
        
        // Проверяем computed properties с значениями по умолчанию
        #expect(record.didTakeInsulin == true) // потому что insulinType = .novorapid и insulinUnits = 7
        #expect(record.hasMeal == false) // потому что food = nil
    }
} 