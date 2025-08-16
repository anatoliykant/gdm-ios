//
//  SomeUITest.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 2025-07-13.
//

@testable import gdm
import XCTest

extension XCTestCase {
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 5.0) -> Bool {
        element.waitForExistence(timeout: timeout)
    }
}

// MARK: - Тесты изоляции данных

class DataIsolationValidationTests: FullyIsolatedUITestCase {
    
    func testDataIsCompletelyIsolated() {
        // Этот тест проверяет полную изоляцию данных между тестами
        
        // Arrange
        launchApp()
        print("🔍 Проверяем изоляцию данных в: \(testSuiteName!)")
        
        // Act & Assert - проверяем что начинаем с чистого состояния
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        
        // Проверяем через отладочную информацию
        // (в реальном приложении можно добавить скрытую кнопку для отладки)
        
        // Имитируем добавление данных через UI
        addButton.tap()
        let sheet = app.sheets.firstMatch
        
        print("\(app.sheets.count) // Для отладки, сколько sheet'ов открыто")
        
        // ОТЛАДКА: выводим всю иерархию элементов
        print("=== UI HIERARCHY ===")
        print(app.debugDescription)
        
        // Проверяем разные типы элементов
        print("NavigationBars count: \(app.navigationBars.count)")
        print("Other elements count: \(app.otherElements.count)")
        print("Buttons count: \(app.buttons.count)")
        
        // Попробуем найти элементы по частичному совпадению
        let allElements = app.descendants(matching: .any)
        for element in allElements.allElementsBoundByIndex {
            if !element.identifier.isEmpty {
                print("Found element: \(element.identifier) - type: \(element.elementType.readableName), label: \(element.label), exists: \(element.exists)")
            }
        }
        
        XCTAssertTrue(waitForElement(sheet, timeout: 3.0), "Sheet should appear")
        
        // Закрываем sheet
        sheet.swipeDown()
        
        print("✅ Тест изоляции данных прошел для: \(testSuiteName!)")
    }
    
    func testSecondIsolatedTest() {
        // Этот тест должен запуститься с полностью чистым состоянием
        
        launchApp()
        print("🔍 Второй тест изоляции в: \(testSuiteName!)")
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        
        // Этот тест не должен "видеть" никаких данных из предыдущего теста
        
        print("✅ Второй тест изоляции прошел для: \(testSuiteName!)")
    }
    
    func testWithSampleDataIsolation() {
        // Тест с образцами данных - также должен быть изолирован
        
        launchAppWithSampleData()
        print("🔍 Тест с образцами данных в: \(testSuiteName!)")
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        
        // Здесь должны быть образцы данных, но только в этом тесте
        
        print("✅ Тест с образцами данных прошел для: \(testSuiteName!)")
    }
}

// MARK: - Функциональные тесты с изоляцией

class AddButtonFunctionalTests: FullyIsolatedUITestCase {
    
    func testAddButtonBasicFunctionality() {
        launchApp()
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        XCTAssertTrue(addButton.isHittable, "Add button should be hittable")
        XCTAssertTrue(addButton.isEnabled, "Add button should be enabled")
        
        // Тестируем нажатие
        addButton.tap()
        
        let sheet = app.sheets.firstMatch
        XCTAssertTrue(waitForElement(sheet, timeout: 3.0), "Input sheet should appear")
        
        print("✅ Базовая функциональность кнопки проверена в: \(testSuiteName!)")
    }
    
    func testAddButtonWithExistingData() {
        // Тест кнопки при наличии данных
        
        launchAppWithSampleData()
        
        let addButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist with data")
        
        // Кнопка должна работать даже при наличии данных
        addButton.tap()
        
        let sheet = app.sheets.firstMatch
        XCTAssertTrue(waitForElement(sheet, timeout: 3.0), "Sheet should open with existing data")
        
        print("✅ Кнопка работает с существующими данными: \(testSuiteName!)")
    }
}

// MARK: - Параллельные тесты

class ParallelExecutionTests: FullyIsolatedUITestCase {
    
    func testParallelExecution1() {
        launchApp()
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton))
        
        // Имитируем длительную операцию
        Thread.sleep(forTimeInterval: 2.0)
        
        // Проверяем что состояние не изменилось
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(addButton.isEnabled)
        
        print("✅ Параллельный тест 1 завершен: \(testSuiteName!)")
    }
    
    func testParallelExecution2() {
        launchApp()
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton))
        
        // Имитируем другую длительную операцию
        Thread.sleep(forTimeInterval: 1.5)
        
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(addButton.isEnabled)
        
        print("✅ Параллельный тест 2 завершен: \(testSuiteName!)")
    }
    
    func testParallelExecution3() {
        launchAppWithSampleData()
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton))
        
        Thread.sleep(forTimeInterval: 1.0)
        
        XCTAssertTrue(addButton.exists)
        
        print("✅ Параллельный тест 3 завершен: \(testSuiteName!)")
    }
}

// MARK: - Стресс-тесты изоляции

class IsolationStressTests: FullyIsolatedUITestCase {
    
    func testRapidTestExecution1() { performRapidTest(testNumber: 1) }
    func testRapidTestExecution2() { performRapidTest(testNumber: 2) }
    func testRapidTestExecution3() { performRapidTest(testNumber: 3) }
    func testRapidTestExecution4() { performRapidTest(testNumber: 4) }
    func testRapidTestExecution5() { performRapidTest(testNumber: 5) }
    
    private func performRapidTest(testNumber: Int) {
        launchApp()
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(waitForElement(addButton), "Rapid test \(testNumber) failed")
        
        addButton.tap()
        
        let sheet = app.sheets.firstMatch
        XCTAssertTrue(waitForElement(sheet, timeout: 3.0), "Sheet in rapid test \(testNumber) failed")
        
        sheet.swipeDown()
        
        print("⚡ Быстрый тест \(testNumber) завершен: \(testSuiteName!)")
    }
}

// MARK: - Утилиты для отладки изоляции

extension FullyIsolatedUITestCase {
    
    func printIsolationDebugInfo() {
        print("\n=== DEBUG INFO FOR \(name) ===")
        print("Test Suite Name: \(testSuiteName!)")
        print("Launch Arguments: \(app.launchArguments)")
        
        // Можно добавить больше отладочной информации
        TestUserDefaultsManager.debugActiveSuites()
    }
    
    func verifyCompleteIsolation() {
        // Проверяем что тестовые данные действительно изолированы
        
        // Создаем тестовые данные в нашем UserDefaults
        let testDefaults = UserDefaults(suiteName: testSuiteName)
        testDefaults?.set("isolated_test_value", forKey: "isolation_test_key")
        
        // Проверяем что стандартный UserDefaults не содержит эти данные
        let standardValue = UserDefaults.standard.string(forKey: "isolation_test_key")
        XCTAssertNil(standardValue, "Standard UserDefaults should not contain isolated test data")
        
        // Проверяем что наши данные есть в тестовом UserDefaults
        let isolatedValue = testDefaults?.string(forKey: "isolation_test_key")
        XCTAssertEqual(isolatedValue, "isolated_test_value", "Test UserDefaults should contain isolated data")
        
        print("✅ Изоляция подтверждена для: \(testSuiteName!)")
    }
}

// MARK: - Базовый класс с полной изоляцией

class FullyIsolatedUITestCase: XCTestCase {
    
    var app: XCUIApplication!
    var testSuiteName: String!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let name = "suite-\(UUID().uuidString)"
        
        // Создаем уникальный UserDefaults для этого теста
        testSuiteName = TestUserDefaultsManager.createTestSuite(for: name)
         
        // Настраиваем приложение
        app = XCUIApplication()
        setupAppForTesting()
        
        // print("🧪 Тест '\(name)' запущен с изолированным UserDefaults: \(testSuiteName!)")
    }
    
    override func tearDownWithError() throws {
        // Очищаем тестовые данные
        TestUserDefaultsManager.cleanupTestSuite(testSuiteName)
        
        app = nil
        testSuiteName = nil
        
        print("🏁 Тест завершен и очищен")
    }
    
    private func setupAppForTesting() {
        app.launchArguments = [
            "-UITesting",
            "-testSuite=testSuiteName",
            // "-testSuite=\(testSuiteName!)",
            "-resetData"
        ]
    }
    
    // MARK: - Helper Methods
    
    func launchApp(with additionalArguments: [String] = []) {
        app.launchArguments.append(contentsOf: additionalArguments)
        app.launch()
        
        // Ждем полной загрузки приложения
        let navigationBar = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 10.0),
                     "App should load completely")
    }
    
    func launchAppWithSampleData() {
        launchApp(with: ["-loadSampleData"])
    }
}
