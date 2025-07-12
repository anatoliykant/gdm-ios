//
//  ContentViewUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class ContentViewUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testNavigationTitleExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем наличие заголовка навигации
        let navigationTitle = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationTitle.exists)
    }
    
    func testAddButtonExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Ищем кнопку добавления по accessibilityLabel
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        XCTAssertTrue(addButton.exists)
    }
    
    func testAddButtonFunctionality() {
        let app = XCUIApplication()
        app.launch()
        
        // Нажимаем на кнопку добавления
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        XCTAssertTrue(addButton.exists)
        
        addButton.tap()
        
        // Проверяем, что открылся InputView (ищем заголовок формы)
        let inputViewTitle = app.staticTexts["Добавить запись"]
        XCTAssertTrue(inputViewTitle.waitForExistence(timeout: 3))
    }
    
    func testExportButtonExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем наличие кнопки экспорта в toolbar
        let exportButton = app.buttons["Share"]
        XCTAssertTrue(exportButton.exists)
    }
    
    func testRecordListViewExists() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем наличие списка записей в любом формате
        let recordsList = app.tables.firstMatch
        let collectionView = app.collectionViews.firstMatch
        let scrollView = app.scrollViews.firstMatch
        
        XCTAssertTrue(recordsList.exists || collectionView.exists || scrollView.exists)
    }
    
    func testMainScreenLayout() {
        let app = XCUIApplication()
        app.launch()
        
        // Проверяем основные элементы экрана
        let navigationBar = app.navigationBars["Дневник сахара"]
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        let exportButton = app.buttons["Share"]
        
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(addButton.exists)
        XCTAssertTrue(exportButton.exists)
    }
    
    func testNavigationToInputView() {
        let app = XCUIApplication()
        app.launch()
        
        // Открываем форму добавления
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        addButton.tap()
        
        // Проверяем, что форма открылась
        let inputForm = app.staticTexts["Добавить запись"]
        XCTAssertTrue(inputForm.waitForExistence(timeout: 3))
        
        // Проверяем основные поля формы
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        XCTAssertTrue(sugarField.exists)
    }
    
    func testCloseInputViewWithSwipeDown() {
        let app = XCUIApplication()
        app.launch()
        
        // Открываем форму
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        addButton.tap()
        
        // Ждем открытия формы
        let inputForm = app.staticTexts["Добавить запись"]
        XCTAssertTrue(inputForm.waitForExistence(timeout: 3))
        
        // Свайп вниз для закрытия
        inputForm.swipeDown()
        
        // Проверяем, что вернулись на главный экран
        let navigationTitle = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 2))
    }
}