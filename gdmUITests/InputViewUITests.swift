//
//  InputViewUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class InputViewUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func openInputView() -> XCUIApplication {
        let app = XCUIApplication()
        app.launch()
        
        // Открываем форму добавления
        let addButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Добавить запись'")).firstMatch
        addButton.tap()
        
        // Ждем открытия формы
        let inputForm = app.staticTexts["Добавить запись"]
        _ = inputForm.waitForExistence(timeout: 3)
        
        return app
    }
    
    func testInputViewTitle() {
        let app = openInputView()
        
        // Проверяем заголовок формы
        let title = app.staticTexts["Добавить запись"]
        XCTAssertTrue(title.exists)
    }
    
    func testSugarInputField() {
        let app = openInputView()
        
        // Проверяем поле для ввода сахара
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        XCTAssertTrue(sugarField.exists)
        
        // Вводим значение
        sugarField.tap()
        sugarField.typeText("6.5")
        
        XCTAssertTrue(sugarField.value as? String == "6,5" || sugarField.value as? String == "6.5")
    }
    
    func testDatePickerExists() {
        let app = openInputView()
        
        // Проверяем наличие date picker (ищем любые date picker элементы)
        let datePickers = app.datePickers
        XCTAssertGreaterThan(datePickers.count, 0)
    }
    
    func testTimePickerExists() {
        let app = openInputView()
        
        // Проверяем наличие time picker (ищем любые date picker элементы, включая time)
        let datePickers = app.datePickers
        XCTAssertGreaterThan(datePickers.count, 0)
    }
    
    func testInsulinPickerExists() {
        let app = openInputView()
        
        // Проверяем наличие insulin picker (ищем по иконке шприца)
        let syringeIcon = app.images["syringe"]
        XCTAssertTrue(syringeIcon.exists)
        
        // Проверяем наличие picker для типа инсулина
        let insulinPicker = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Новорапид'")).firstMatch
        XCTAssertTrue(insulinPicker.exists)
    }
    
    func testFoodDescriptionField() {
        let app = openInputView()
        
        // Проверяем text editor для описания еды
        let foodField = app.textViews.firstMatch
        XCTAssertTrue(foodField.exists)
        
        // Вводим текст
        foodField.tap()
        foodField.typeText("Завтрак")
        
        // Проверяем, что текст был введен (более гибкая проверка)
        let fieldValue = foodField.value as? String
        XCTAssertTrue(fieldValue?.contains("Завтрак") == true || fieldValue == "Завтрак")
    }
    
    func testAddRecordButtonState() {
        let app = openInputView()
        
        // Находим кнопку "Добавить"
        let addButton = app.buttons["Добавить"]
        XCTAssertTrue(addButton.exists)
        
        // Кнопка должна быть неактивна до ввода сахара
        XCTAssertFalse(addButton.isEnabled)
        
        // Вводим значение сахара
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Кнопка должна стать активной
        XCTAssertTrue(addButton.isEnabled)
    }
    
    func testBreadUnitsFieldAppearsWithFood() {
        let app = openInputView()
        
        // Сначала проверяем, что поле ХЕ скрыто
        let breadUnitsLabel = app.staticTexts["ХЕ"]
        XCTAssertFalse(breadUnitsLabel.exists)
        
        // Вводим описание еды
        let foodField = app.textViews.firstMatch
        foodField.tap()
        foodField.typeText("Завтрак")
        
        // Теперь поле ХЕ должно появиться
        XCTAssertTrue(breadUnitsLabel.waitForExistence(timeout: 2))
    }
    
    func testFormSubmission() {
        let app = openInputView()
        
        // Заполняем форму
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        sugarField.tap()
        sugarField.typeText("7.2")
        
        // Нажимаем кнопку добавления
        let addButton = app.buttons["Добавить"]
        XCTAssertTrue(addButton.isEnabled)
        addButton.tap()
        
        // Проверяем, что вернулись на главный экран
        let navigationTitle = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(navigationTitle.waitForExistence(timeout: 3))
    }
    
    func testKeyboardDismissal() {
        let app = openInputView()
        
        // Активируем поле ввода
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        sugarField.tap()
        
        // Проверяем, что кнопка "Готово" появилась
        let doneButton = app.buttons["Готово"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 2))
        
        doneButton.tap()
        
        // Клавиатура должна исчезнуть (проверяем, что кнопка "Готово" больше не видна)
        XCTAssertFalse(doneButton.exists)
    }
    
    func testSugarInputWithDecimalSeparator() {
        let app = openInputView()
        
        let sugarField = app.textFields.containing(NSPredicate(format: "placeholderValue CONTAINS 'Сахар'")).firstMatch
        sugarField.tap()
        
        // Вводим значение с запятой
        sugarField.typeText("5,8")
        
        // Проверяем, что значение корректно обрабатывается
        let addButton = app.buttons["Добавить"]
        XCTAssertTrue(addButton.isEnabled)
    }
}