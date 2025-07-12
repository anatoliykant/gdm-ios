//
//  RecordListViewUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class RecordListViewUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func createTestRecord(app: XCUIApplication) -> Bool {
        // Открываем форму добавления
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        guard addButton.waitForExistence(timeout: 5) else { return false }
        addButton.tap()
        
        // Ждем открытия формы
        let inputForm = app.staticTexts["Добавить запись"]
        guard inputForm.waitForExistence(timeout: 5) else { return false }
        
        // Заполняем сахар
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        guard sugarField.waitForExistence(timeout: 3) else { return false }
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Ждем, пока кнопка станет активной
        let submitButton = app.buttons["Добавить"]
        guard submitButton.waitForExistence(timeout: 3) else { return false }
        
        // Ждем активации кнопки
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: submitButton)
        let result = XCTWaiter.wait(for: [expectation], timeout: 3.0)
        guard result == .completed else { return false }
        
        submitButton.tap()
        
        // Ждем возвращения на главный экран и убеждаемся что форма закрылась
        guard app.navigationBars["Дневник сахара"].waitForExistence(timeout: 5) else { return false }
        
        // Дополнительная проверка что мы вернулись на главный экран
        let formDisappeared = !inputForm.exists
        return formDisappeared
    }
    
    func testRecordListExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем наличие основного списка - сначала проверим все возможные элементы
        let recordsList = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        // Список должен существовать в одном из форматов
        XCTAssertTrue(recordsList.exists || collectionView.exists || scrollView.exists)
    }
    
    func testRecordCreationAndDisplay() {
        let app = XCUIApplication()
        app.launch()
        
        // Создаем тестовую запись
        let recordCreated = createTestRecord(app: app)
        XCTAssertTrue(recordCreated, "Failed to create test record")
        
        // Даем время для обновления UI
        Thread.sleep(forTimeInterval: 1.0)
        
        // Проверяем, что запись появилась в списке
        let recordsList = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch  
        let scrollView = app.scrollViews.firstMatch
        
        // Проверяем что есть какой-то контейнер для списка
        XCTAssertTrue(recordsList.exists || collectionView.exists || scrollView.exists)
        
        // Если есть table, проверяем ячейки
        if recordsList.exists {
            let cells = recordsList.cells
            XCTAssertGreaterThan(cells.count, 0)
        }
    }
    
    func testTodayHeaderExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Создаем запись
        let recordCreated = createTestRecord(app: app)
        XCTAssertTrue(recordCreated, "Failed to create test record")
        
        // Даем время для обновления UI
        Thread.sleep(forTimeInterval: 1.0)
        
        // Ищем заголовок "Сегодня" - если записи нет, заголовка тоже не будет
        let todayHeader = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Сегодня'")).firstMatch
        let anyDateHeader = app.staticTexts.containing(NSPredicate(format: "label CONTAINS '2025' OR label CONTAINS 'января' OR label CONTAINS 'декабря'")).firstMatch
        
        // Проверяем что есть хотя бы какой-то заголовок даты
        XCTAssertTrue(todayHeader.waitForExistence(timeout: 3) || anyDateHeader.waitForExistence(timeout: 3))
    }
    
    func testMultipleRecordsGrouping() {
        let app = XCUIApplication()
        app.launch()
        
        var successfulRecords = 0
        
        // Создаем несколько записей
        for _ in 1...3 {
            let recordCreated = createTestRecord(app: app)
            if recordCreated {
                successfulRecords += 1
                Thread.sleep(forTimeInterval: 0.5) // Небольшая задержка между записями
            }
        }
        
        // Должна быть создана хотя бы одна запись
        XCTAssertGreaterThan(successfulRecords, 0, "No records were created successfully")
        
        // Даем время для обновления UI
        Thread.sleep(forTimeInterval: 1.0)
        
        // Проверяем, что записи отображаются
        let recordsList = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        if recordsList.exists {
            let cells = recordsList.cells
            XCTAssertGreaterThanOrEqual(cells.count, successfulRecords, "Expected at least \(successfulRecords) cells but got \(cells.count)")
        } else if collectionView.exists {
            let cells = collectionView.cells
            XCTAssertGreaterThanOrEqual(cells.count, successfulRecords)
        } else {
            // Проверяем что хотя бы какой-то контейнер существует
            XCTAssertTrue(scrollView.exists, "No list container found")
        }
    }
    
    func testScrolling() {
        let app = XCUIApplication()
        app.launch()
        
        // Сначала проверяем что есть хоть какой-то scrollable контейнер
        let recordsList = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        var scrollableElement: XCUIElement?
        
        if recordsList.exists {
            scrollableElement = recordsList
        } else if collectionView.exists {
            scrollableElement = collectionView
        } else if scrollView.exists {
            scrollableElement = scrollView
        }
        
        XCTAssertNotNil(scrollableElement, "No scrollable element found")
        
        // Создаем несколько записей для тестирования скроллинга
        var recordsCreated = 0
        for _ in 1...3 {
            if createTestRecord(app: app) {
                recordsCreated += 1
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        
        // Даем время для обновления UI
        Thread.sleep(forTimeInterval: 1.0)
        
        // Тестируем скроллинг на любом найденном элементе
        if let element = scrollableElement {
            element.swipeUp()
            element.swipeDown()
            
            // Элемент должен по-прежнему существовать после скроллинга
            XCTAssertTrue(element.exists, "Scrollable element disappeared after scrolling")
        }
    }
}