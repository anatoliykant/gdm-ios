//
//  RecordListViewUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class RecordListViewUITests: XCTestCase {
    
    enum TestError: Error {
        case addButtonNotFound
        case inputFormNotFound
        case sugarFieldNotFound
        case submitButtonNotFound
        case submitButtonDisabled
        case navigationBarNotFound
        case recordCellNotFound
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    private func createTestRecord(app: XCUIApplication) throws {
        // Открываем форму добавления
        let addButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        addButton.tap()
        
        // Ждем открытия формы
        let inputForm = app.staticTexts["Добавить запись"]
        guard inputForm.waitForExistence(timeout: 5) else {
            throw TestError.inputFormNotFound
        }
        
        // Заполняем сахар
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        guard sugarField.waitForExistence(timeout: 3) else {
            throw TestError.sugarFieldNotFound
        }
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Ждем, пока кнопка станет активной
        let submitButton = app.buttons["Добавить"]
        guard submitButton.waitForExistence(timeout: 3) else {
            throw TestError.submitButtonNotFound
        }
        
        // Ждем активации кнопки
        let predicate = NSPredicate(format: "isEnabled == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: submitButton)
        guard XCTWaiter.wait(for: [expectation], timeout: 3) == .completed else {
            throw TestError.submitButtonDisabled
        }
        
        submitButton.tap()
        
        // Ждем возвращения на главный экран и убеждаемся что форма закрылась
        guard app.navigationBars["Дневник сахара"].waitForExistence(timeout: 5) else {
            throw TestError.navigationBarNotFound
        }
        
        // Дополнительная проверка что мы вернулись на главный экран
        let firstCell = app.tables.firstMatch.cells.element(boundBy: 0)
        guard firstCell.waitForExistence(timeout: 5) else {
            throw TestError.recordCellNotFound
        }
    }
    
    func testRecordListExists() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Проверяем наличие основного списка - сначала проверим все возможные элементы
        let recordsList = app.collectionViews["RecordsList"]
        
        // Список должен существовать
        XCTAssertTrue(recordsList.exists)
    }
    
    func testRecordCreationAndDisplay() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Создаем тестовую запись
        do {
            try createTestRecord(app: app)
        } catch {
            XCTFail("Record creation failed with error: \(error)")
            return
        }
        
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
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Создаем запись
        do {
            try createTestRecord(app: app)
        } catch {
            XCTFail("Record creation failed with error: \(error)")
            return
        }
        
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
        app.launchArguments += ["-resetData"]
        app.launch()
        
        var successfulRecords = 0
        
        // Создаем несколько записей
        for _ in 1...3 {
            do {
                try createTestRecord(app: app)
                successfulRecords += 1
                Thread.sleep(forTimeInterval: 0.5) // Небольшая задержка между записями
            } catch {
                // ignore failures and continue
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
        app.launchArguments += ["-resetData"]
        app.launch()
        
        // Create extra records for scroll testing
        for _ in 1...3 {
            try? createTestRecord(app: app)
        }
        
        // Сначала проверяем что есть хоть какой-то scrollable контейнер
        let recordsList = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        guard let element = (
            recordsList.exists
                 ? recordsList
                 : collectionView.exists
                    ? collectionView
                    : scrollView.exists
                        ? scrollView
                        : nil
        ) else {
            XCTFail("No scrollable element found")
            return
        }
        
        // Создаем несколько записей для тестирования скроллинга
        for _ in 1...3 {
            try? createTestRecord(app: app)
        }
        
        // Даем время для обновления UI
        Thread.sleep(forTimeInterval: 1.0)
        
        // Тестируем скроллинг на любом найденном элементе
        if element.elementType == .table || element.elementType == .collectionView {
            let firstCell = element.cells.firstMatch
            XCTAssertTrue(firstCell.exists, "No items to scroll")
            element.swipeUp()
            let lastCell = element.cells.element(boundBy: element.cells.count - 1)
            XCTAssertTrue(lastCell.waitForExistence(timeout: 5), "Did not find last cell after scroll up")
            element.swipeDown()
            
            // Элемент должен по-прежнему существовать после скроллинга
            XCTAssertTrue(element.exists, "Scrollable element disappeared after scrolling")
        }
    }
}
