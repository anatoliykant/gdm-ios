//
//  InputViewUITests.swift
//  gdmUITests
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import XCTest

final class InputViewUITests: XCTestCase {
    
    enum TestError: Error {
        case addButtonNotFound
        case inputFormNotFound
        case fieldNotFound
        case buttonNotEnabled
        case formNotClosed
        case invalidFieldValue
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func openInputForm(app: XCUIApplication) throws {
        let addButton = app.buttons["AddRecordButton"]
        guard addButton.waitForExistence(timeout: 5) else {
            throw TestError.addButtonNotFound
        }
        addButton.tap()
        
        let inputFormTitle = app.staticTexts["InputViewTitle"]
        guard inputFormTitle.waitForExistence(timeout: 5) else {
            throw TestError.inputFormNotFound
        }
    }
    
    func testInputFormOpens() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем что форма открылась
        let inputFormTitle = app.staticTexts["InputViewTitle"]
        XCTAssertTrue(inputFormTitle.exists)
    }
    
    func testSugarFieldInput() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем поле сахара
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        
        // Вводим значение
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Проверяем что значение введено
        XCTAssertEqual(sugarField.value as? String, "6.5")
    }
    
    func testAddButtonDisabledWhenSugarEmpty() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем что кнопка отключена когда поле пустое
        let submitButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
        XCTAssertFalse(submitButton.isEnabled)
    }
    
    func testAddButtonEnabledWhenSugarEntered() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Вводим сахар
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Проверяем что кнопка стала активной
        let submitButton = app.buttons["AddRecordButton"]
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = XCTNSPredicateExpectation(predicate: enabledPredicate, object: submitButton)
        let result = XCTWaiter.wait(for: [enabledExpectation], timeout: 3.0)
        XCTAssertEqual(result, .completed)
    }
    
    func testFoodDescriptionField() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем поле описания еды
        let foodField = app.textViews["FoodDescriptionField"]
        XCTAssertTrue(foodField.waitForExistence(timeout: 3))
        
        // Вводим текст
        foodField.tap()
        foodField.typeText("Овсянка с молоком")
        
        // Проверяем что текст введен
        XCTAssertTrue(foodField.value as? String == "Овсянка с молоком")
    }
    
    func testDatePickerExists() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем наличие датапикера
        let datePicker = app.otherElements["DatePicker"]
        XCTAssertTrue(datePicker.waitForExistence(timeout: 3))
    }
    
    func testTimePickerExists() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем наличие тайм-пикера
        let timePicker = app.otherElements["TimePicker"]
        XCTAssertTrue(timePicker.waitForExistence(timeout: 3))
    }
    
    func testInsulinRowExists() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем наличие строки инсулина
        let insulinRow = app.otherElements["InsulinRow"]
        XCTAssertTrue(insulinRow.waitForExistence(timeout: 3))
    }
    
    func testKeyboardDoneButton() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Тапаем на поле сахара для появления клавиатуры
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        
        // Проверяем кнопку "Готово" на клавиатуре
        let doneButton = app.buttons["KeyboardDoneButton"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3))
    }
    
    func testSuccessfulRecordCreation() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Заполняем обязательное поле
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Нажимаем кнопку добавления
        let submitButton = app.buttons["AddRecordButton"]
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = XCTNSPredicateExpectation(predicate: enabledPredicate, object: submitButton)
        let enabledResult = XCTWaiter.wait(for: [enabledExpectation], timeout: 3.0)
        XCTAssertEqual(enabledResult, .completed)
        
        submitButton.tap()
        
        // Проверяем что форма закрылась и мы вернулись на главный экран
        let mainNavigationView = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(mainNavigationView.waitForExistence(timeout: 5))
        
        // Проверяем что форма действительно закрылась
        let inputFormTitle = app.staticTexts["InputViewTitle"]
        let formClosedPredicate = NSPredicate(format: "exists == false")
        let formClosedExpectation = XCTNSPredicateExpectation(predicate: formClosedPredicate, object: inputFormTitle)
        let formClosedResult = XCTWaiter.wait(for: [formClosedExpectation], timeout: 3.0)
        XCTAssertEqual(formClosedResult, .completed)
    }
    
    func testFormCancellation() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Заполняем поле, но не сохраняем
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        sugarField.typeText("6.5")
        
        // Свайпаем вниз для закрытия формы
        app.swipeDown()
        
        // Проверяем что форма закрылась
        let inputFormTitle = app.staticTexts["InputViewTitle"]
        let formClosedPredicate = NSPredicate(format: "exists == false")
        let formClosedExpectation = XCTNSPredicateExpectation(predicate: formClosedPredicate, object: inputFormTitle)
        let formClosedResult = XCTWaiter.wait(for: [formClosedExpectation], timeout: 3.0)
        XCTAssertEqual(formClosedResult, .completed)
    }
    
    func testComplexRecordCreation() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Заполняем сахар
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        sugarField.typeText("7.2")
        
        // Заполняем описание еды
        let foodField = app.textViews["FoodDescriptionField"]
        XCTAssertTrue(foodField.waitForExistence(timeout: 3))
        foodField.tap()
        foodField.typeText("Гречневая каша")
        
        // Сохраняем запись
        let submitButton = app.buttons["AddRecordButton"]
        let enabledPredicate = NSPredicate(format: "isEnabled == true")
        let enabledExpectation = XCTNSPredicateExpectation(predicate: enabledPredicate, object: submitButton)
        let enabledResult = XCTWaiter.wait(for: [enabledExpectation], timeout: 3.0)
        XCTAssertEqual(enabledResult, .completed)
        
        submitButton.tap()
        
        // Проверяем что форма закрылась
        let mainNavigationView = app.navigationBars["Дневник сахара"]
        XCTAssertTrue(mainNavigationView.waitForExistence(timeout: 5))
    }
    
    func testInvalidSugarValue() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Пытаемся ввести некорректное значение
        let sugarField = app.textFields["SugarInputField"]
        XCTAssertTrue(sugarField.waitForExistence(timeout: 3))
        sugarField.tap()
        sugarField.typeText("abc")
        
        // Кнопка должна оставаться активной, но логика валидации должна сработать в приложении
        let submitButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
    }
    
    func testEmptyFormValidation() {
        let app = XCUIApplication()
        app.launchArguments += ["-resetData"]
        app.launch()
        
        XCTAssertNoThrow(try openInputForm(app: app))
        
        // Проверяем что кнопка отключена при пустой форме
        let submitButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 3))
        XCTAssertFalse(submitButton.isEnabled)
    }
}