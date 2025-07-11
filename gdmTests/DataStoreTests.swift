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
} 