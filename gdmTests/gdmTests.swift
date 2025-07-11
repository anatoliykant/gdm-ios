//
//  gdmTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import Testing
import Foundation
@testable import gdm

/// Основные тесты для приложения GDM
@Suite("GDM Tests") 
struct gdmTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

/// Тесты для DataStore
@Suite("DataStore Tests")
struct DataStoreTests {
    
    /// Создает изолированный UserDefaults для тестов
    private func createTestUserDefaults() -> UserDefaults {
        let testSuiteName = "test_\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: testSuiteName)!
        // Очищаем все данные в этом UserDefaults
        userDefaults.removePersistentDomain(forName: testSuiteName)
        return userDefaults
    }
    
    /// Создает DataStore для тестов без sample data и с изолированным UserDefaults
    private func createTestDataStore() -> DataStore {
        let testUserDefaults = createTestUserDefaults()
        let dataStore = DataStore(loadSampleData: false, userDefaults: testUserDefaults)
        dataStore.clearAllData()
        return dataStore
    }
    
    // MARK: - Initialization Tests
    
    @Test("DataStore initializes with empty records")
    func dataStore_InitializesEmpty() throws {
        let dataStore = createTestDataStore()
        #expect(dataStore.records.isEmpty)
    }
    
    // MARK: - Add Record Tests
    
    @Test("DataStore adds valid record successfully")
    func dataStore_AddsValidRecord() throws {
        let dataStore = createTestDataStore()
        let record = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let result = dataStore.addRecordSafely(record)
        #expect(result.isSuccess)
        #expect(dataStore.records.count == 1)
        #expect(dataStore.records.first?.sugarLevel == 5.5)
    }
    
    @Test("DataStore rejects invalid record")
    func dataStore_RejectsInvalidRecord() throws {
        let dataStore = createTestDataStore()
        let invalidRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 35.0, // Invalid - too high
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        
        let result = dataStore.addRecordSafely(invalidRecord)
        #expect(!result.isSuccess)
        #expect(dataStore.records.isEmpty)
    }
    
    // MARK: - Update Record Tests
    
    @Test("DataStore updates existing record successfully")
    func dataStore_UpdatesExistingRecord() throws {
        let dataStore = createTestDataStore()
        let originalRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let addResult = dataStore.addRecordSafely(originalRecord)
        #expect(addResult.isSuccess)
        
        var updatedRecord = originalRecord
        updatedRecord.sugarLevel = 6.0
        
        let updateResult = dataStore.updateRecordSafely(updatedRecord)
        #expect(updateResult.isSuccess)
        #expect(dataStore.records.first?.sugarLevel == 6.0)
    }
    
    @Test("DataStore rejects invalid record update")
    func dataStore_RejectsInvalidUpdate() throws {
        let dataStore = createTestDataStore()
        let originalRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let addResult = dataStore.addRecordSafely(originalRecord)
        #expect(addResult.isSuccess)
        
        var invalidUpdate = originalRecord
        invalidUpdate.sugarLevel = 35.0 // Invalid - too high
        
        let updateResult = dataStore.updateRecordSafely(invalidUpdate)
        #expect(!updateResult.isSuccess)
        #expect(dataStore.records.first?.sugarLevel == 5.5) // Unchanged
    }
    
    // MARK: - Delete Record Tests
    
    @Test("DataStore deletes existing record successfully")
    func dataStore_DeletesExistingRecord() throws {
        let dataStore = createTestDataStore()
        let record = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let addResult = dataStore.addRecordSafely(record)
        #expect(addResult.isSuccess)
        #expect(dataStore.records.count == 1)
        
        dataStore.deleteRecord(record)
        #expect(dataStore.records.isEmpty)
    }
    
    // MARK: - Sorting Tests
    
    @Test("DataStore maintains records sorted by date")
    func dataStore_MaintainsSortedOrder() throws {
        let dataStore = createTestDataStore()
        let now = Date()
        
        let record1 = Record(
            date: now.addingTimeInterval(-7200), // 2 hours ago
            sugarLevel: 5.0,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        let record2 = Record(
            date: now.addingTimeInterval(-3600), // 1 hour ago
            sugarLevel: 6.0,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        let record3 = Record(
            date: now.addingTimeInterval(-1800), // 30 minutes ago
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        // Add records in random order
        _ = dataStore.addRecordSafely(record2)
        _ = dataStore.addRecordSafely(record1)
        _ = dataStore.addRecordSafely(record3)
        
        #expect(dataStore.records.count == 3)
        
        // Should be sorted newest first
        #expect(dataStore.records[0].date > dataStore.records[1].date)
        #expect(dataStore.records[1].date > dataStore.records[2].date)
        #expect(dataStore.records[0].sugarLevel == 5.5) // Most recent
        #expect(dataStore.records[2].sugarLevel == 5.0) // Oldest
    }
    
    // MARK: - Persistence Tests
    
    @Test("DataStore saves and loads records")
    func dataStore_SavesAndLoadsRecords() throws {
        // Создаем общий UserDefaults для этого теста
        let sharedUserDefaults = createTestUserDefaults()
        
        // Первый DataStore сохраняет данные
        let dataStore1 = DataStore(loadSampleData: false, userDefaults: sharedUserDefaults)
        dataStore1.clearAllData()
        
        let record = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let addResult = dataStore1.addRecordSafely(record)
        #expect(addResult.isSuccess)
        #expect(dataStore1.records.count == 1)
        
        // Второй DataStore с тем же UserDefaults должен загрузить сохраненные данные
        let dataStore2 = DataStore(loadSampleData: false, userDefaults: sharedUserDefaults)
        #expect(dataStore2.records.count == 1)
        #expect(dataStore2.records.first?.sugarLevel == 5.5)
        
        // Cleanup
        dataStore2.clearAllData()
    }
    
    // MARK: - Utility Tests
    
    @Test("DataStore clears all data")
    func dataStore_ClearsAllData() throws {
        let dataStore = createTestDataStore()
        let record = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let addResult = dataStore.addRecordSafely(record)
        #expect(addResult.isSuccess)
        #expect(dataStore.records.count == 1)
        
        dataStore.clearAllData()
        #expect(dataStore.records.isEmpty)
    }
    
    @Test("DataStore handles mixed record types")
    func dataStore_HandlesMixedRecordTypes() throws {
        let dataStore = createTestDataStore()
        let record1 = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Овсянка",
            breadUnits: 2.0
        )
        
        let record2 = Record(
            date: Date().addingTimeInterval(-1800),
            sugarLevel: nil, // No sugar level
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        
        _ = dataStore.addRecordSafely(record1)
        _ = dataStore.addRecordSafely(record2)
        
        #expect(dataStore.records.count == 2)
        #expect(dataStore.records.contains { $0.sugarLevel == 5.5 })
        #expect(dataStore.records.contains { $0.sugarLevel == nil })
    }
}

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
        
        // Проверим что среди ошибок есть ожидаемые типы
        #expect(invalidErrors.allSatisfy { $0 is ValidationService.ValidationError })
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
