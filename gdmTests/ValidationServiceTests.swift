//
//  ValidationServiceTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import Testing
import Foundation
@testable import gdm

/// Тесты для ValidationService
@Suite("ValidationService Tests")
struct ValidationServiceTests {
    
    // MARK: - Sugar Level Validation Tests
    
    @Test("ValidationService validates correct sugar levels")
    func validationService_ValidatesSugarLevels_Success() throws {
        // Граничные валидные значения
        try ValidationService.validateSugarLevel(0.1) // минимум
        try ValidationService.validateSugarLevel(30.0) // максимум
        
        // Типичные валидные значения
        try ValidationService.validateSugarLevel(5.5)
        try ValidationService.validateSugarLevel(12.3)
        try ValidationService.validateSugarLevel(8.0)
    }
    
    @Test("ValidationService rejects sugar levels too low")
    func validationService_RejectsSugarLevels_TooLow() throws {
        // Проверяем значения ниже минимума
        #expect(throws: (any Error).self) {
            try ValidationService.validateSugarLevel(0.0)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateSugarLevel(-1.0)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateSugarLevel(0.05)
        }
    }
    
    @Test("ValidationService rejects sugar levels too high")
    func validationService_RejectsSugarLevels_TooHigh() throws {
        // Проверяем значения выше максимума
        #expect(throws: (any Error).self) {
            try ValidationService.validateSugarLevel(30.1)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateSugarLevel(50.0)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateSugarLevel(100.0)
        }
    }
    
    // MARK: - Insulin Units Validation Tests
    
    @Test("ValidationService validates correct insulin units")
    func validationService_ValidatesInsulinUnits_Success() throws {
        // Граничные валидные значения
        try ValidationService.validateInsulinUnits(1) // минимум
        try ValidationService.validateInsulinUnits(100) // максимум
        
        // Типичные валидные значения
        try ValidationService.validateInsulinUnits(8)
        try ValidationService.validateInsulinUnits(15)
        try ValidationService.validateInsulinUnits(50)
    }
    
    @Test("ValidationService rejects insulin units too low")
    func validationService_RejectsInsulinUnits_TooLow() throws {
        #expect(throws: (any Error).self) {
            try ValidationService.validateInsulinUnits(0)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateInsulinUnits(-5)
        }
    }
    
    @Test("ValidationService rejects insulin units too high")
    func validationService_RejectsInsulinUnits_TooHigh() throws {
        #expect(throws: (any Error).self) {
            try ValidationService.validateInsulinUnits(101)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateInsulinUnits(500)
        }
    }
    
    // MARK: - Bread Units Validation Tests
    
    @Test("ValidationService validates correct bread units")
    func validationService_ValidatesBreadUnits_Success() throws {
        // Граничные валидные значения
        try ValidationService.validateBreadUnits(0.1) // минимум
        try ValidationService.validateBreadUnits(50.0) // максимум
        
        // Типичные валидные значения
        try ValidationService.validateBreadUnits(2.0)
        try ValidationService.validateBreadUnits(8.5)
        try ValidationService.validateBreadUnits(25.0)
    }
    
    @Test("ValidationService rejects bread units too low")
    func validationService_RejectsBreadUnits_TooLow() throws {
        #expect(throws: (any Error).self) {
            try ValidationService.validateBreadUnits(0.0)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateBreadUnits(-1.0)
        }
    }
    
    @Test("ValidationService rejects bread units too high")
    func validationService_RejectsBreadUnits_TooHigh() throws {
        #expect(throws: (any Error).self) {
            try ValidationService.validateBreadUnits(50.1)
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateBreadUnits(100.0)
        }
    }
    
    // MARK: - Date Validation Tests
    
    @Test("ValidationService validates correct dates")
    func validationService_ValidatesDates_Success() throws {
        let now = Date()
        
        // Текущее время
        try ValidationService.validateDate(now)
        
        // Прошлые даты
        try ValidationService.validateDate(now.addingTimeInterval(-3600)) // 1 час назад
        try ValidationService.validateDate(now.addingTimeInterval(-86400)) // 1 день назад
        
        // Небольшое время в будущем (в пределах допустимого)
        try ValidationService.validateDate(now.addingTimeInterval(300)) // 5 минут в будущем
    }
    
    @Test("ValidationService rejects future dates")
    func validationService_RejectsFutureDates() throws {
        let now = Date()
        
        // Даты слишком далеко в будущем
        let futureDate1 = now.addingTimeInterval(600) // 10 минут в будущем
        #expect(throws: (any Error).self) {
            try ValidationService.validateDate(futureDate1)
        }
        
        let futureDate2 = now.addingTimeInterval(86400) // 1 день в будущем
        #expect(throws: (any Error).self) {
            try ValidationService.validateDate(futureDate2)
        }
    }
    
    // MARK: - Food Description Validation Tests
    
    @Test("ValidationService validates correct food descriptions")
    func validationService_ValidatesFoodDescriptions_Success() throws {
        // Нормальные описания
        try ValidationService.validateFoodDescription("Хлеб")
        try ValidationService.validateFoodDescription("Овсянка с молоком")
        try ValidationService.validateFoodDescription("Хлебцы без глютена 2 куска, масло")
        
        // Описание с пробелами по краям
        try ValidationService.validateFoodDescription("  Яблоко  ")
        
        // Длинное но валидное описание
        let longButValidDescription = String(repeating: "a", count: 500)
        try ValidationService.validateFoodDescription(longButValidDescription)
    }
    
    @Test("ValidationService rejects empty food descriptions")
    func validationService_RejectsEmptyFoodDescriptions() throws {
        #expect(throws: (any Error).self) {
            try ValidationService.validateFoodDescription("")
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateFoodDescription("   ") // только пробелы
        }
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateFoodDescription("\n\t") // только whitespace
        }
    }
    
    @Test("ValidationService rejects too long food descriptions")
    func validationService_RejectsTooLongFoodDescriptions() throws {
        let tooLongDescription = String(repeating: "a", count: 501)
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateFoodDescription(tooLongDescription)
        }
    }
    
    // MARK: - Record Logic Validation Tests
    
    @Test("ValidationService validates correct record logic")
    func validationService_ValidatesRecordLogic_Success() throws {
        // Запись с едой и ХЕ
        let recordWithFood = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        try ValidationService.validateRecordLogic(recordWithFood)
        
        // Запись с инсулином и дозой
        let recordWithInsulin = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: nil,
            breadUnits: nil
        )
        try ValidationService.validateRecordLogic(recordWithInsulin)
        
        // Запись без инсулина
        let recordNoInsulin = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        try ValidationService.validateRecordLogic(recordNoInsulin)
    }
    
    @Test("ValidationService rejects invalid record logic")
    func validationService_RejectsInvalidRecordLogic() throws {
        // ХЕ без описания еды
        let recordBreadUnitsNoFood = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: 2.0
        )
        #expect(throws: (any Error).self) {
            try ValidationService.validateRecordLogic(recordBreadUnitsNoFood)
        }
        
        // ХЕ с пустым описанием еды
        let recordBreadUnitsEmptyFood = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: "   ", // только пробелы
            breadUnits: 2.0
        )
        #expect(throws: (any Error).self) {
            try ValidationService.validateRecordLogic(recordBreadUnitsEmptyFood)
        }
        
        // Инсулин без дозы
        let recordInsulinNoUnits = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        #expect(throws: (any Error).self) {
            try ValidationService.validateRecordLogic(recordInsulinNoUnits)
        }
        
        // Инсулин с нулевой дозой
        let recordInsulinZeroUnits = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 0,
            food: nil,
            breadUnits: nil
        )
        #expect(throws: (any Error).self) {
            try ValidationService.validateRecordLogic(recordInsulinZeroUnits)
        }
    }
    
    // MARK: - Complete Record Validation Tests
    
    @Test("ValidationService validates complete valid record")
    func validationService_ValidatesCompleteRecord_Success() throws {
        let validRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка с молоком",
            breadUnits: 2.0
        )
        
        try ValidationService.validateRecord(validRecord)
    }
    
    @Test("ValidationService rejects invalid complete record")
    func validationService_RejectsInvalidCompleteRecord() throws {
        let invalidRecord = Record(
            date: Date().addingTimeInterval(3600), // будущее время
            sugarLevel: 35.0, // слишком высокий сахар
            insulinType: .novorapid,
            insulinUnits: 150, // слишком много инсулина
            food: "Хлеб",
            breadUnits: 100.0 // слишком много ХЕ
        )
        
        #expect(throws: (any Error).self) {
            try ValidationService.validateRecord(invalidRecord)
        }
    }
    
    // MARK: - Helper Methods Tests
    
    @Test("ValidationService isValid returns correct results")
    func validationService_IsValid_ReturnsCorrectResults() throws {
        // Валидная запись
        let validRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        #expect(ValidationService.isValid(validRecord) == true)
        
        // Невалидная запись
        let invalidRecord = Record(
            date: Date().addingTimeInterval(3600), // будущее время
            sugarLevel: 35.0, // слишком высокий сахар
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        #expect(ValidationService.isValid(invalidRecord) == false)
    }
    
    @Test("ValidationService getValidationErrors returns correct errors")
    func validationService_GetValidationErrors_ReturnsCorrectErrors() throws {
        // Валидная запись - должна вернуть пустой массив
        let validRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        let validErrors = ValidationService.getValidationErrors(validRecord)
        #expect(validErrors.isEmpty)
        
        // Невалидная запись - должна вернуть несколько ошибок
        let invalidRecord = Record(
            date: Date().addingTimeInterval(3600), // будущее время
            sugarLevel: 35.0, // слишком высокий сахар
            insulinType: .novorapid,
            insulinUnits: 150, // слишком много инсулина
            food: "Хлеб",
            breadUnits: 100.0 // слишком много ХЕ
        )
        let invalidErrors = ValidationService.getValidationErrors(invalidRecord)
        #expect(invalidErrors.count > 0)
        
        // Проверим что есть ошибки разных типов
        let errorMessages = invalidErrors.map { $0.localizedDescription }
        #expect(errorMessages.contains { $0.contains("будущее время") || $0.contains("сахар") || $0.contains("инсулин") || $0.contains("ХЕ") })
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("ValidationService handles boundary values correctly")
    func validationService_HandlesBoundaryValues_Correctly() throws {
        // Граничные значения должны проходить валидацию
        let boundaryRecord = Record(
            date: Date().addingTimeInterval(-1), // 1 секунда назад
            sugarLevel: 0.1, // минимальный сахар
            insulinType: .novorapid,
            insulinUnits: 1, // минимальный инсулин
            food: "a", // минимальное описание
            breadUnits: 0.1 // минимальные ХЕ
        )
        
        try ValidationService.validateRecord(boundaryRecord)
        #expect(ValidationService.isValid(boundaryRecord) == true)
        
        // Максимальные граничные значения
        let maxBoundaryRecord = Record(
            date: Date().addingTimeInterval(299), // максимально допустимое будущее время
            sugarLevel: 30.0, // максимальный сахар
            insulinType: .novorapid,
            insulinUnits: 100, // максимальный инсулин
            food: String(repeating: "a", count: 500), // максимальное описание
            breadUnits: 50.0 // максимальные ХЕ
        )
        
        try ValidationService.validateRecord(maxBoundaryRecord)
        #expect(ValidationService.isValid(maxBoundaryRecord) == true)
    }
} 