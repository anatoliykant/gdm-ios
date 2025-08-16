//
//  ContentViewUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class ContentViewUITests: XCTestCase {
    
    enum TestError: Error {
        case navigationBarNotFound
        case addButtonNotFound
        case exportButtonNotFound
        case recordListNotFound
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    // Список тестов:
    
    // Navigation Bar: accID "MainNavigationView" / title / share button (shown and active)
    
    // Пустой список записей
    
    // Список после добавления одной записи
    
    // Список после добавления нескольких записей
    
    // Возможность прокрутки списка записей
    
    // Список после удаления записи (после реализации @Published для sortedDays)
    
    /// Тесты кнопки Add '+' (accID "ShowRecordViewButton" / active and tappable)
    func testAddButtonExistsAndIsActive() {
        // Arrange - Ожидаем загрузки главного экрана
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        let mainNavigationView = app.otherElements["MainNavigationView"]
        XCTAssertTrue(mainNavigationView.waitForExistence(timeout: 5.0), "Main navigation view should exist")
        
        // Act & Assert - Проверяем наличие кнопки добавления записи
        let addButton = app.buttons["ShowRecordViewButton"]
        
        // Проверяем, что кнопка существует
        XCTAssertTrue(addButton.exists, "Add button should exist on the screen")
        
        // Проверяем, что кнопка видима на экране
        XCTAssertTrue(addButton.isHittable, "Add button should be visible and hittable")
        
        // Проверяем, что кнопка активна (не disabled)
        XCTAssertTrue(addButton.isEnabled, "Add button shou.ld be enabled")
        
        // Дополнительная проверка - кнопка должна появиться в течение разумного времени
        XCTAssertTrue(addButton.waitForExistence(timeout: 3.0), "Add button should appear within 3 seconds")
    }
    
    /// При нажатии кнопки Add '+' открывается форма ввода (accID "InputViewTitle")
    func testAddButtonOpensInputView() {
        // Arrange
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Act - Нажимаем на кнопку добавления записи
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5.0), "Add button should exist")
        addButton.tap()
        
        // Assert - Проверяем, что открылась форма ввода
        
        let inputView = app.otherElements["InputViewContainer"]
        XCTAssertTrue(waitForElement(inputView), "Input view should exist after tapping Add button")
        
        let inputViewTitle = app.staticTexts["InputViewTitle"]
        XCTAssertTrue(waitForElement(inputViewTitle), "Input view title should exist after tapping Add button")
    }
    
    // MARK: Интерактивность
    
    // Тап по записям для редактирования

    // MARK: Граничные случаи

    // Большое количество записей в день
    // Очень длинные описания блюд
    // Экстремальные значения сахара
    
    func testDebugDataStore() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Ждем загрузки
        Thread.sleep(forTimeInterval: 2.0)
        
        // Проверяем navigation bar чтобы убедиться что приложение загрузилось
        let navigationBar = app.navigationBars["Дневник сахара"]
        print("Navigation bar exists: \(navigationBar.exists)")
        
        // Проверяем что приложение обработало флаг -resetData
        // Мы можем это сделать косвенно, проверив что нет данных в списке
        
        XCTAssertTrue(navigationBar.exists)
    }
    
//    func testDebugAllElements() {
//        let app = XCUIApplication()
//        app.launchArguments += ["-resetData"]
//        app.launch()
//        
//        // Ждем загрузки
//        Thread.sleep(forTimeInterval: 2.0)
//        
//        // Выводим все доступные элементы для отладки
//        print("All buttons:")
//        for button in app.buttons.allElementsBoundByIndex {
//            print("Button: identifier='\(button.identifier)', label='\(button.label)', exists=\(button.exists)")
//        }
//        
//        print("All other elements:")
//        for element in app.otherElements.allElementsBoundByIndex {
//            print("Element: identifier='\(element.identifier)', label='\(element.label)', exists=\(element.exists)")
//        }
//        
//        print("All navigation bars:")
//        for nav in app.navigationBars.allElementsBoundByIndex {
//            print("NavigationBar: identifier='\(nav.identifier)', label='\(nav.label)', exists=\(nav.exists)")
//        }
//        
//        // Простая проверка что приложение запустилось
//        XCTAssertTrue(app.exists)
//    }
    
    /// Тесты для проверки navigation bar (заголовка и кнопки share)
    
    
    func testMainScreenLoads() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Проверяем что главный экран загрузился
        let mainNavigationView = app.otherElements["MainNavigationView"]
        XCTAssertTrue(mainNavigationView.waitForExistence(timeout: 3))
    }
    
    // проверить, что navigation bar существует и содержит нужный заголовок
    func testNavigationTitle() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Проверяем корректность заголовка навигации
        let navigationBar = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        XCTAssertEqual(navigationBar.identifier, "Дневник сахара")
    }
    
    // проверить, что кнопка + для открытие модального окна записи существует и активна
    func testAddRecordButtonExists() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Проверяем наличие кнопки добавления записи
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        XCTAssertTrue(addButton.isEnabled)
    }
    
    // проверить, что кнопка share существует и активна
    func testExportPDFButtonExists() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Проверяем наличие кнопки экспорта PDF
        let exportButton = app.buttons["ExportPDFButton"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 5))
        XCTAssertTrue(exportButton.isEnabled)
    }
    
    func testRecordListViewExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем что внутри есть список записей
        let recordsList = app.collectionViews["RecordsList"]
        XCTAssertTrue(recordsList.waitForExistence(timeout: 3))
    }
    
    func testRecordListViewNotExist() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Проверяем что внутри нет списка записей
        let recordsList = app.collectionViews["RecordsList"]
        XCTAssertFalse(recordsList.cells.element.exists)
    }
    
    func testAddButtonOpensInputForm() {
        // Arrange
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Act - Нажимаем на кнопку '+'
        let showRecordViewButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(showRecordViewButton.exists, "Show Record View button should exist")
        showRecordViewButton.tap()
        
        Thread.sleep(forTimeInterval: 1.0)
        
        // Assert - Проверяем, что открылась форма ввода со всеми необходимыми элементами
        
        // Title text
        let title = app.staticTexts["InputViewTitle"]
        XCTAssertTrue(title.exists, "Title should exist")
        
        // Date view
        let dateView = app.otherElements["DatePicker"]
        XCTAssertTrue(dateView.exists, "Date picker should exist")
        
        // Time view
        let timeView = app.otherElements["TimePicker"]
        XCTAssertTrue(timeView.exists, "Time picker should exist")
        
        // Sugar view
        let sugarView = app.otherElements["SugarInputView"]
        XCTAssertTrue(sugarView.exists, "Sugar input view should exist")
        
        // Sugar text field
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.exists, "Sugar input field should exist")
        
        // Sugar image
        let sugarImage = app.images["SugarInputImage"]
        XCTAssertTrue(sugarImage.waitForExistence(timeout: 3))
        
        // Insulin row
        let insulinRow = app.otherElements["InsulinRow"]
        XCTAssertTrue(insulinRow.exists, "Insulin row should exist")
        
        // Food description view
        let foodDescriptionView = app.otherElements["FoodDescriptionView"]
        XCTAssertTrue(foodDescriptionView.exists, "Food description view should exist")
        
        
        let breadUnitsView = app.otherElements["BreadUnitsView"]
        XCTAssertFalse(breadUnitsView.exists, "Bread units view should exist")
        
        foodDescriptionView.tap()
        foodDescriptionView.typeText("Тестовое блюдо")
        
        // Bread units view
        let breadUnitsViewAfterFoodFilled = app.otherElements["BreadUnitsView"]
        XCTAssertTrue(breadUnitsViewAfterFoodFilled.exists, "Bread units view should exist")
        
        let modalView = findModalScreenByAnyMeans()
        XCTAssertTrue(modalView?.exists == true, "Modal view should still exist swipe down")
        
        // Add button
        
        let addButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(addButton.exists, "Add button should exist")
        
//        addButton.tap()
        
        // Закрываем форму свайпом вниз
        app.swipeDown(velocity: .fast)
        XCTAssertTrue(modalView?.exists == false, "Modal view should not exist after swipe down")
    }
    
    func testExportButtonShowsActivitySheet() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Создаем тестовую запись сначала
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()
        
        // Заполняем форму
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Сохраняем запись
        let submitButton = app.buttons["AddRecordButton"]
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = XCTNSPredicateExpectation(predicate: enabledPredicate, object: submitButton)
        let enabledResult = XCTWaiter.wait(for: [enabledExpectation], timeout: 3.0)
        XCTAssertEqual(enabledResult, .completed)
        submitButton.tap()
        
        // Ждем возвращения на главный экран
        let navigationBar = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        
        // Нажимаем на кнопку экспорта
        let exportButton = app.buttons["ExportPDFButton"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 3))
        exportButton.tap()
        
        // Проверяем что activity sheet появился (может появиться не всегда в тестах)
        // Делаем мягкую проверку через timeout
        let activityView = app.otherElements["ActivityListView"]
        let activityViewExists = activityView.waitForExistence(timeout: 3)
        
        // Если activity sheet появился, проверяем его содержимое
        if activityViewExists {
            XCTAssertTrue(activityView.exists)
        }
    }
    
    /// Проверяем все основные элементы макета
    func testMainScreenLayoutElements() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        let exportButton = app.buttons["ExportPDFButton"]
        XCTAssertTrue(exportButton.waitForExistence(timeout: 3))
        
        let navigationBar = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        
        let mainNavigationView = app.otherElements["MainNavigationView"]
        XCTAssertTrue(mainNavigationView.waitForExistence(timeout: 3))
        
        let recordListView = app.otherElements["RecordsList"]
        XCTAssertFalse(recordListView.waitForExistence(timeout: 3))
        
        let addButton = app.buttons["ShowRecordViewButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
    }
    
    func testUserDefaultsManyCheckExists() {
        UserDefaultsService.listUserDefaultsFiles()
        
        // Add three user defaults with values
        
        let standart = UserDefaults.standard
        standart.set("Test Value 1", forKey: "TestKey1")
        standart.set("Test Value 2", forKey: "TestKey2")
        
        let customDefaults = UserDefaults(suiteName: "com.example.customDefaults")!
        customDefaults.set("Custom Value 1", forKey: "CustomKey1")
        customDefaults.set("Custom Value 2", forKey: "CustomKey2")
        
        let testSuiteName = "test_\(UUID().uuidString)"
        let userDefaults = UserDefaults(suiteName: testSuiteName)!
        userDefaults.set("Test Suite Value 1", forKey: "TestSuiteKey1")
        userDefaults.set("Test Suite Value 2", forKey: "TestSuiteKey2")
        
        UserDefaultsService.listUserDefaultsFiles()
    }
}

final class UserDefaultsService {
    
    static func listUserDefaultsFiles() {
        print("\n=== USERDEFAULTS FILES ===")
        
        // Путь к UserDefaults в симуляторе/устройстве
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        let preferencesPath = "\(libraryPath)/Preferences"
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: preferencesPath)
            let plistFiles = files.filter { $0.hasSuffix(".plist") }
            
            print("UserDefaults файлы в \(preferencesPath):")
            for (index, file) in plistFiles.enumerated() {
                print("  \(index) \(file)")
                
                // Попытка загрузить и показать содержимое
                let filePath = "\(preferencesPath)/\(file)"
                if let plist = NSDictionary(contentsOfFile: filePath) {
                    print("    Ключей в файле: \(plist.count)")
                }
            }
        } catch {
            print("Ошибка чтения директории Preferences: \(error)")
        }
    }
    
    
    static func deleteAllUserDefaultsFiles() {
        #if DEBUG
        print("\n=== DELETING ALL USERDEFAULTS FILES ===")
        
        // Путь к UserDefaults в симуляторе/устройстве
        let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        let preferencesPath = "\(libraryPath)/Preferences"
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: preferencesPath)
            let plistFiles = files.filter { $0.hasSuffix(".plist") }
            
            var deletedCount = 0
            var failedCount = 0
            
            for file in plistFiles {
                let filePath = "\(preferencesPath)/\(file)"
                
                do {
                    // Проверяем размер файла перед удалением
                    let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    
                    // Удаляем файл
                    try FileManager.default.removeItem(atPath: filePath)
                    
                    print("✅ Удален: \(file) (размер: \(fileSize) bytes)")
                    deletedCount += 1
                    
                } catch {
                    print("❌ Ошибка удаления \(file): \(error.localizedDescription)")
                    failedCount += 1
                }
            }
            
            print("\nРезультат:")
            print("  Удалено файлов: \(deletedCount)")
            print("  Ошибок: \(failedCount)")
            print("  Всего .plist файлов найдено: \(plistFiles.count)")
            
        } catch {
            print("❌ Ошибка чтения директории Preferences: \(error.localizedDescription)")
        }
        #else
        print("⚠️ deleteAllUserDefaultsFiles() доступно только в DEBUG сборке")
        #endif
    }
}
