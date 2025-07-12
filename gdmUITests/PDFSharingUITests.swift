//
//  PDFSharingUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class PDFSharingUITests: XCTestCase {
    
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
        
        // Ждем возвращения на главный экран
        guard app.navigationBars["Дневник сахара"].waitForExistence(timeout: 5) else { return false }
        
        return !inputForm.exists
    }
    
    func testExportButtonExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем наличие кнопки экспорта
        let exportButton = app.buttons["Share"]
        XCTAssertTrue(exportButton.exists)
        XCTAssertTrue(exportButton.isEnabled)
    }
    
    func testExportPDFWithEmptyData() {
        let app = XCUIApplication()
        app.launch()
        
        // Нажимаем кнопку экспорта даже с пустыми данными
        let exportButton = app.buttons["Share"]
        exportButton.tap()
        
        // PDF должен быть создан даже с пустыми данными
        // Проверяем, что операция не вызвала краш
    }
    
    func testExportPDFWithData() {
        let app = XCUIApplication()
        app.launch()
        
        // Создаем тестовую запись
        let recordCreated = createTestRecord(app: app)
        XCTAssertTrue(recordCreated, "Failed to create test record for PDF export")
        
        // Экспортируем PDF
        let exportButton = app.buttons["Share"]
        XCTAssertTrue(exportButton.exists)
        exportButton.tap()
        
        // Проверяем, что операция не вызвала краш
    }
    
    func testExportButtonAccessibility() {
        let app = XCUIApplication()
        app.launch()
        
        let exportButton = app.buttons["Share"]
        XCTAssertTrue(exportButton.exists)
        XCTAssertTrue(exportButton.isHittable)
        
        // Проверяем, что кнопка имеет accessibility label
        XCTAssertFalse(exportButton.label.isEmpty)
    }
}