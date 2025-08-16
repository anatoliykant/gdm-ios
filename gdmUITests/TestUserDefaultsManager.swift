//
//  TestUserDefaultsManager.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-13.
//

import Foundation

final class TestUserDefaultsManager {
    
    private static var activeSuites: Set<String> = []
    
    /// Создает уникальный suite name и регистрирует его для очистки
    static func createTestSuite(for testName: String) -> String {
        let cleanTestName = testName.replacingOccurrences(of: "[", with: "")
                                   .replacingOccurrences(of: "]", with: "")
                                   .replacingOccurrences(of: " ", with: "_")
        let timestamp = Int(Date().timeIntervalSince1970)
        let random = Int.random(in: 1000...9999)
        let suiteName = "test.gdm.\(cleanTestName).\(timestamp).\(random)"
        
        activeSuites.insert(suiteName)
        
        print("📝 Создан тестовый UserDefaults: \(suiteName)")
        return suiteName
    }
    
    /// Очищает конкретный test suite
    static func cleanupTestSuite(_ suiteName: String) {
        if let testDefaults = UserDefaults(suiteName: suiteName) {
            // Получаем все ключи перед удалением для логирования
            let keys = testDefaults.dictionaryRepresentation().keys
            
            // Удаляем домен
            testDefaults.removePersistentDomain(forName: suiteName)
            
            activeSuites.remove(suiteName)
            
            print("🧽 Очищен UserDefaults: \(suiteName) (\(keys.count) ключей)")
        }
    }
    
    /// Очищает все активные test suites
    static func cleanupAllTestSuites() {
        let suitesToCleanup = Array(activeSuites)
        
        for suiteName in suitesToCleanup {
            cleanupTestSuite(suiteName)
        }
        
        print("🧽 Очищено \(suitesToCleanup.count) тестовых UserDefaults")
    }
    
    /// Выводит информацию о всех активных test suites
    static func debugActiveSuites() {
        print("\n=== АКТИВНЫЕ ТЕСТОВЫЕ USERDEFAULTS ===")
        
        if activeSuites.isEmpty {
            print("Нет активных тестовых UserDefaults")
            return
        }
        
        for suiteName in activeSuites {
            if let testDefaults = UserDefaults(suiteName: suiteName) {
                let keys = testDefaults.dictionaryRepresentation().keys
                print("📦 \(suiteName): \(keys.count) ключей")
                
                // Показываем содержимое если ключей немного
                if keys.count <= 5 {
                    for key in keys.sorted() {
                        let value = testDefaults.object(forKey: key)
                        print("   \(key): \(type(of: value))")
                    }
                }
            }
        }
    }
}
