//
//  gdmApp.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import SwiftUI
import VisionKit

//@main
//struct gdmApp: App {
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(DataStoreFactory.createDataStore())
////                .environment(\.locale, Locale(identifier: "en_US"))
//        }
//    }
//    
//    private func createDataStore() -> DataStore {
//        let dataStore = DataStore()
//        
//        // Проверяем launch arguments для тестов
//        if CommandLine.arguments.contains("-resetData") {
//            print("DataStore: Сброс данных для тестирования")
//            dataStore.clearAllData()
//        }
//        
//        return dataStore
//    }
//}

//@main
//struct gdmApp: App {
//    
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//                .environmentObject(createDataStore())
////                .environment(\.locale, Locale(identifier: "en_US"))
//        }
//    }
//    
//    private func createDataStore() -> DataStore {
//        let dataStore = DataStore()
//        
//        // Проверяем launch arguments для тестов
//        if CommandLine.arguments.contains("-resetData") {
//            print("DataStore: Сброс данных для тестирования")
//            dataStore.clearAllData()
//        }
//        
//        return dataStore
//    }
//}


import Foundation

// MARK: - DataStore Factory

struct DataStoreFactory {
    
    /// Создает DataStore для продакшена
    static func createProductionDataStore() -> DataStore {
        return DataStore(loadSampleData: true, userDefaults: .standard)
    }
    
    /// Создает DataStore для тестов с изолированным UserDefaults
    static func createTestDataStore(suiteName: String, loadSampleData: Bool = false) -> DataStore {
        let testDefaults = UserDefaults(suiteName: suiteName) ?? .standard
        return DataStore(loadSampleData: loadSampleData, userDefaults: testDefaults)
    }
    
    /// Создает DataStore на основе launch arguments
    static func createDataStore() -> DataStore {
//        if let testSuiteName = getTestSuiteName() {
//            // Режим тестирования
//            let loadSampleData = CommandLine.arguments.contains("-loadSampleData")
//            return createTestDataStore(suiteName: testSuiteName, loadSampleData: loadSampleData)
//        } else {
            // Продакшен режим
            return createProductionDataStore()
//        }
    }
    
    private static func getTestSuiteName() -> String? {
        for argument in CommandLine.arguments {
            if argument.hasPrefix("-testSuite=") {
                let suiteName = String(argument.dropFirst("-testSuite=".count))
                return suiteName.isEmpty ? nil : suiteName
            }
        }
        return nil
    }
}

// MARK: - Обновленная версия App

@main
struct gdmApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(createDataStore())
        }
    }
    
    private func createDataStore() -> DataStore {
        let dataStore = DataStoreFactory.createDataStore()
        
        // Обработка дополнительных команд
        handleLaunchArguments(dataStore: dataStore)
        
        return dataStore
    }
    
    private func handleLaunchArguments(dataStore: DataStore) {
        if CommandLine.arguments.contains("-resetData") {
            print("🔄 Сброс данных для тестирования")
            dataStore.clearAllData()
        }
        
        if CommandLine.arguments.contains("-loadSampleData") {
            print("📊 Загрузка образцов данных для тестирования")
            dataStore.resetToSampleData()
        }
        
        if CommandLine.arguments.contains("-debugUserDefaults") {
            // TestUserDefaultsManager.debugActiveSuites()
            print("🔍 DataStore Debug Info:")
            print("  Records count: \(dataStore.records.count)")
            print("  UserDefaults suite: \(getTestSuiteName() ?? "standard")")
            print("  Launch arguments: \(CommandLine.arguments)")
        }
        
//        if CommandLine.arguments.contains("-cleanupTestSuites") {
//            TestUserDefaultsManager.cleanupAllTestSuites()
//        }
    }
    
    private func getTestSuiteName() -> String? {
        // Ищем аргумент с префиксом "-testSuite="
        for argument in CommandLine.arguments {
            if argument.hasPrefix("-testSuite=") {
                let suiteName = String(argument.dropFirst("-testSuite=".count))
                return suiteName.isEmpty ? nil : suiteName
            }
        }
        return nil
    }
}

// MARK: - Extension для DataStore с дополнительными методами тестирования

extension DataStore {
    
    /// Проверяет в каком UserDefaults сохраняются данные
    func debugUserDefaultsInfo() -> String {
        let keys = userDefaults.dictionaryRepresentation().keys
        let recordsData = userDefaults.data(forKey: "GDM_Records")
        let recordsSize = recordsData?.count ?? 0
        
        return """
        UserDefaults Info:
        - Total keys: \(keys.count)
        - Records data size: \(recordsSize) bytes
        - Records count: \(records.count)
        - Sample keys: \(Array(keys.prefix(3)).joined(separator: ", "))
        """
    }
    
    /// Добавляет тестовую запись с указанным ID для проверки изоляции
    func addTestRecord(withId id: String) throws {
        let testRecord = Record(
            id: UUID(uuidString: id) ?? UUID(),
            date: Date(),
            sugarLevel: 6.2,
            insulinType: .levemir,
            food: "Тестовая еда",
            breadUnits: 2.5
        )
        try addRecord(testRecord)
    }
    
    /// Проверяет наличие тестовой записи
    func hasTestRecord(withId id: String) -> Bool {
        guard let uuid = UUID(uuidString: id) else { return false }
        return records.contains { $0.id == uuid }
    }
}
