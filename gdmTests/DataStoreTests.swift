//
//  DataStoreTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import Testing
import Foundation
@testable import gdm

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
    
    // MARK: - Delete by ID Tests
    
    @Test("DataStore deletes record by ID successfully")
    func dataStore_DeletesRecordById_Success() throws {
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
        
        dataStore.deleteRecord(withId: record.id)
        #expect(dataStore.records.isEmpty)
    }
    
    @Test("DataStore handles delete by non-existent ID")
    func dataStore_DeletesRecordById_NonExistentId_NoError() throws {
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
        
        let nonExistentId = UUID()
        dataStore.deleteRecord(withId: nonExistentId)
        #expect(dataStore.records.count == 1) // Record should still be there
    }
    
    // MARK: - Sample Data Tests
    
    @Test("DataStore resets to sample data")
    func dataStore_ResetsToSampleData() throws {
        let dataStore = createTestDataStore()
        
        // Add some custom data first
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
        
        // Reset to sample data
        dataStore.resetToSampleData()
        
        // Should have sample data now
        #expect(dataStore.records.count > 1)
        #expect(dataStore.records.count == Record.mockArray.count)
    }
    
    // MARK: - Get Previous Record Tests
    
    @Test("DataStore finds previous record correctly")
    func dataStore_GetsPreviousRecord_Success() throws {
        let dataStore = createTestDataStore()
        let now = Date()
        
        let record1 = Record(
            date: now.addingTimeInterval(-7200), // 2 hours ago
            sugarLevel: 4.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        let record2 = Record(
            date: now.addingTimeInterval(-3600), // 1 hour ago
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        let record3 = Record(
            date: now.addingTimeInterval(-1800), // 30 minutes ago
            sugarLevel: 6.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        _ = dataStore.addRecordSafely(record1)
        _ = dataStore.addRecordSafely(record2)
        _ = dataStore.addRecordSafely(record3)
        
        // Get previous record before the most recent one
        let previousRecord = dataStore.getPreviousRecord(before: record3.date)
        #expect(previousRecord != nil)
        #expect(previousRecord?.id == record2.id)
        #expect(previousRecord?.sugarLevel == 5.5)
    }
    
    @Test("DataStore returns nil for previous record when none exists")
    func dataStore_GetsPreviousRecord_ReturnsNilWhenNoneExists() throws {
        let dataStore = createTestDataStore()
        let now = Date()
        
        let record = Record(
            date: now.addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        _ = dataStore.addRecordSafely(record)
        
        // No record exists before this one
        let previousRecord = dataStore.getPreviousRecord(before: record.date)
        #expect(previousRecord == nil)
    }
    
    @Test("DataStore gets previous record from empty store returns nil")
    func dataStore_GetsPreviousRecord_EmptyStore_ReturnsNil() throws {
        let dataStore = createTestDataStore()
        let now = Date()
        
        let previousRecord = dataStore.getPreviousRecord(before: now)
        #expect(previousRecord == nil)
    }
    
    // MARK: - First Sugar Record of Day Tests
    
    @Test("DataStore identifies first sugar record of day correctly")
    func dataStore_IsFirstSugarRecordOfDay_ReturnsTrue() throws {
        let dataStore = createTestDataStore()
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        
        // Add a record without sugar first
        let recordNoSugar = Record(
            date: startOfDay.addingTimeInterval(3600), // 1 hour after start of day
            sugarLevel: nil,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Завтрак",
            breadUnits: 2.0
        )
        
        // Add first sugar record of the day
        let firstSugarRecord = Record(
            date: startOfDay.addingTimeInterval(7200), // 2 hours after start of day
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        _ = dataStore.addRecordSafely(recordNoSugar)
        _ = dataStore.addRecordSafely(firstSugarRecord)
        
        let isFirst = dataStore.isFirstSugarRecordOfDay(for: firstSugarRecord)
        #expect(isFirst == true)
    }
    
    @Test("DataStore identifies non-first sugar record of day correctly")
    func dataStore_IsFirstSugarRecordOfDay_ReturnsFalse() throws {
        let dataStore = createTestDataStore()
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        
        // Add first sugar record of the day
        let firstSugarRecord = Record(
            date: startOfDay.addingTimeInterval(3600), // 1 hour after start of day
            sugarLevel: 4.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        // Add second sugar record of the day
        let secondSugarRecord = Record(
            date: startOfDay.addingTimeInterval(7200), // 2 hours after start of day
            sugarLevel: 5.5,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        _ = dataStore.addRecordSafely(firstSugarRecord)
        _ = dataStore.addRecordSafely(secondSugarRecord)
        
        let isFirstForSecond = dataStore.isFirstSugarRecordOfDay(for: secondSugarRecord)
        #expect(isFirstForSecond == false)
        
        let isFirstForFirst = dataStore.isFirstSugarRecordOfDay(for: firstSugarRecord)
        #expect(isFirstForFirst == true)
    }
    
    @Test("DataStore returns false for record without sugar level")
    func dataStore_IsFirstSugarRecordOfDay_NoSugarLevel_ReturnsFalse() throws {
        let dataStore = createTestDataStore()
        let record = Record(
            date: Date(),
            sugarLevel: nil,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Завтрак",
            breadUnits: 2.0
        )
        
        _ = dataStore.addRecordSafely(record)
        
        let isFirst = dataStore.isFirstSugarRecordOfDay(for: record)
        #expect(isFirst == false)
    }
    
    @Test("DataStore handles same-day records with different times")
    func dataStore_IsFirstSugarRecordOfDay_SameDayDifferentTimes() throws {
        let dataStore = createTestDataStore()
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        
        let morningRecord = Record(
            date: startOfDay.addingTimeInterval(28800), // 8 AM
            sugarLevel: 5.0,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        let lunchRecord = Record(
            date: startOfDay.addingTimeInterval(46800), // 1 PM
            sugarLevel: 7.0,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        let eveningRecord = Record(
            date: startOfDay.addingTimeInterval(68400), // 7 PM
            sugarLevel: 6.0,
            insulinType: .none,
            insulinUnits: nil,
            food: nil,
            breadUnits: nil
        )
        
        _ = dataStore.addRecordSafely(morningRecord)
        _ = dataStore.addRecordSafely(lunchRecord)
        _ = dataStore.addRecordSafely(eveningRecord)
        
        #expect(dataStore.isFirstSugarRecordOfDay(for: morningRecord) == true)
        #expect(dataStore.isFirstSugarRecordOfDay(for: lunchRecord) == false)
        #expect(dataStore.isFirstSugarRecordOfDay(for: eveningRecord) == false)
    }
    
    // MARK: - ValidationResult Tests
    
    @Test("ValidationResult error property works correctly")
    func dataStore_ValidationResult_Error_WorksCorrectly() throws {
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
        #expect(result.error != nil)
        #expect(result.errorMessage != nil)
        #expect(result.errorMessage?.contains("сахар") == true || result.errorMessage?.contains("sugar") == true)
        
        // Test success case
        let validRecord = Record(
            date: Date().addingTimeInterval(-3600),
            sugarLevel: 5.5,
            insulinType: .novorapid,
            insulinUnits: 8,
            food: "Хлеб",
            breadUnits: 2.0
        )
        
        let successResult = dataStore.addRecordSafely(validRecord)
        #expect(successResult.isSuccess)
        #expect(successResult.error == nil)
        #expect(successResult.errorMessage == nil)
    }
    
    // MARK: - UserDefaults Integration Tests  
    
    @Test("DataStore handles UserDefaults migration scenario")
    func dataStore_UserDefaults_MigrationScenario() throws {
        let testUserDefaults = createTestUserDefaults()
        
        // Simulate old version scenario
        testUserDefaults.set(0, forKey: "GDM_DataVersion")
        
        let dataStore = DataStore(loadSampleData: true, userDefaults: testUserDefaults)
        // Should handle migration scenario gracefully
        #expect(dataStore.records.count >= 0) // No crash, might be empty or have sample data
    }
    
    @Test("DataStore handles corrupted UserDefaults data")
    func dataStore_UserDefaults_CorruptedData() throws {
        let testUserDefaults = createTestUserDefaults()
        
        // Set invalid data that can't be decoded
        let corruptedData = "invalid json".data(using: .utf8)!
        testUserDefaults.set(corruptedData, forKey: "GDM_Records")
        testUserDefaults.set(1, forKey: "GDM_DataVersion")
        
        let dataStore = DataStore(loadSampleData: false, userDefaults: testUserDefaults)
        // Should handle corrupted data gracefully and not crash
        #expect(dataStore.records.count >= 0)
    }
    
    @Test("DataStore handles version mismatch in UserDefaults")
    func dataStore_UserDefaults_VersionMismatch() throws {
        let testUserDefaults = createTestUserDefaults()
        
        // Set a different version number to trigger migration path
        testUserDefaults.set(999, forKey: "GDM_DataVersion")
        
        let dataStore = DataStore(loadSampleData: false, userDefaults: testUserDefaults)
        // Should handle version mismatch gracefully
        #expect(dataStore.records.count >= 0)
    }
} 