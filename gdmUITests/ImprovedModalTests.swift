//
//  ImprovedModalTests.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-13.
//


import XCTest

extension FullyIsolatedUITestCase {
    
    /// Отладочный метод для поиска модального экрана
    func debugModalScreen() {
        print("\n=== DEBUGGING MODAL SCREEN ===")
        
        // Проверяем разные типы элементов для модального экрана
        print("Sheets count: \(app.sheets.count)")
        print("Other elements count: \(app.otherElements.count)")
        print("ScrollViews count: \(app.scrollViews.count)")
        print("Groups count: \(app.groups.count)")
        print("Tables count: \(app.tables.count)")
        print("CollectionViews count: \(app.collectionViews.count)")
        print("Windows count: \(app.windows.count)")
        
        // Выводим иерархию после нажатия кнопки
        print("\n=== UI HIERARCHY AFTER BUTTON TAP ===")
        print(app.debugDescription)
        
        // Ищем элементы по частичному содержимому
        print("\n=== SEARCHING FOR MODAL ELEMENTS ===")
        
        // Поиск элементов которые могут быть модальным экраном
        let possibleModals = [
            app.sheets.firstMatch,
            app.otherElements.containing(.any, identifier: "InputViewContainer").firstMatch,
            app.scrollViews.firstMatch,
            app.groups.firstMatch,
            app.otherElements.element(boundBy: app.otherElements.count - 1), // Последний other element
            app.windows.element(boundBy: app.windows.count - 1) // Последнее окно
        ]
        
        for (index, element) in possibleModals.enumerated() {
            if element.exists {
                print("✅ Possible modal \(index): \(element.elementType.readableName) - exists: \(element.exists), hittable: \(element.isHittable)")
                
                // Если есть identifier
                if !element.identifier.isEmpty {
                    print("   Identifier: '\(element.identifier)'")
                }
                
                // Если есть label
                if !element.label.isEmpty {
                    print("   Label: '\(element.label)'")
                }
                
                // Проверяем frame
                let frame = element.frame
                print("   Frame: \(frame)")
            } else {
                print("❌ Possible modal \(index): not found")
            }
        }
        
        // Ищем по ключевым словам
        searchModalByContent()
    }
    
    private func searchModalByContent() {
        print("\n=== SEARCHING BY CONTENT ===")
        
        // Поиск элементов содержащих ключевые слова
        let keywords = ["Input", "Add", "Record", "Save", "Cancel", "Done", "Close"]
        
        for keyword in keywords {
            let elements = app.descendants(matching: .any).containing(.any, identifier: keyword)
            if elements.count > 0 {
                print("Found \(elements.count) elements containing '\(keyword)'")
                
                for i in 0..<min(elements.count, 3) { // Показываем только первые 3
                    let element = elements.element(boundBy: i)
                    if element.exists {
                        print("  - \(element.elementType.readableName): '\(element.identifier)' '\(element.label)'")
                    }
                }
            }
        }
        
        // Поиск по типу элементов с текстом
        let textElements = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS[c] 'sugar' OR label CONTAINS[c] 'glucose' OR label CONTAINS[c] 'insulin'"))
        print("Found \(textElements.count) elements with diabetes-related text")
        
        // Поиск новых элементов (появившихся после нажатия кнопки)
        findNewlyAppearedElements()
    }
    
    private func findNewlyAppearedElements() {
        print("\n=== FINDING NEWLY APPEARED ELEMENTS ===")
        
        // Получаем все элементы и ищем те, что недавно появились
        let allElements = app.descendants(matching: .any)
        var newElements: [XCUIElement] = []
        
        for i in 0..<min(allElements.count, 50) { // Ограничиваем поиск
            let element = allElements.element(boundBy: i)
            
            // Проверяем элементы которые находятся в верхней части экрана (модальные обычно там)
            if element.exists && element.frame.minY < 200 && element.frame.height > 100 {
                newElements.append(element)
            }
        }
        
        print("Found \(newElements.count) elements in modal area")
        for (index, element) in newElements.enumerated() {
            print("  \(index): \(element.elementType.readableName) - '\(element.identifier)' - frame: \(element.frame)")
        }
    }
}

// MARK: - Улучшенный тест с отладкой

class ImprovedModalTests: FullyIsolatedUITestCase {
    
    func testFindModalScreen() {
        // Arrange
        launchApp()
        
        // Запоминаем состояние ДО нажатия кнопки
        let elementCountBefore = app.descendants(matching: .any).count
        let sheetCountBefore = app.sheets.count
        
        print("🔍 Before button tap:")
        print("  Total elements: \(elementCountBefore)")
        print("  Sheets: \(sheetCountBefore)")
        
        // Act - нажимаем кнопку
        let addButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        
        addButton.tap()
        
        // Ждем немного для загрузки модального экрана
        Thread.sleep(forTimeInterval: 1.0)
        
        // Проверяем состояние ПОСЛЕ нажатия
        let elementCountAfter = app.descendants(matching: .any).count
        let sheetCountAfter = app.sheets.count
        
        print("🔍 After button tap:")
        print("  Total elements: \(elementCountAfter)")
        print("  Sheets: \(sheetCountAfter)")
        print("  New elements appeared: \(elementCountAfter - elementCountBefore)")
        
        // Запускаем отладку для поиска модального экрана
        debugModalScreen()
        
        // Пробуем разные способы найти модальный экран
        let modal = findModalScreenByAnyMeans()
        
        if let modal {
            print("✅ Modal screen found: \(modal.elementType.readableName)")
            XCTAssertTrue(modal.exists, "Modal should exist")
            
            // Закрываем модальное окно
            closeModal(modal)
        } else {
            XCTFail("Could not find modal screen")
        }
    }
    
    func testDataIsCompletelyIsolatedFixed() {
        // Исправленная версия оригинального теста
        
        launchApp()
        print("🔍 Проверяем изоляцию данных в: \(testSuiteName!)")
        
        let addButton = app.buttons["AddRecordButton"]
        XCTAssertTrue(waitForElement(addButton), "Add button should exist")
        
        // Нажимаем кнопку
        addButton.tap()
        
        // Ждем появления модального экрана
        Thread.sleep(forTimeInterval: 1.0)
        
        // Ищем модальный экран разными способами
        let modal = findModalScreenByAnyMeans()
        
        XCTAssertNotNil(modal, "Modal screen should appear")
        
        if let modal {
            print("✅ Modal found: \(modal.elementType.readableName)")
            
            // Закрываем модальное окно
            closeModal(modal)
            
            // Проверяем что модальный экран закрылся
            // Thread.sleep(forTimeInterval: 0.5)
            XCTAssertFalse(modal.exists, "Modal should be dismissed")
        }
        
        print("✅ Тест изоляции данных прошел для: \(testSuiteName!)")
    }
    
    // MARK: - Helper Methods
    
//    private func findModalScreenByAnyMeans() -> XCUIElement? {
//        print("\n🔍 Trying to find modal screen...")
//        
//        // Способ 1: Классический sheet
//        let sheet = app.sheets.firstMatch
//        if sheet.exists {
//            print("✅ Found as sheet")
//            return sheet
//        }
//        
//        // Способ 2: Поиск по identifier InputView
//        let inputView = app.otherElements["InputViewContainer"]
//        if inputView.exists {
//            print("✅ Found by InputView identifier")
//            return inputView
//        }
//        
//        // Способ 3: Последний добавленный other element
//        if app.otherElements.count > 0 {
//            let lastOther = app.otherElements.element(boundBy: app.otherElements.count - 1)
//            if lastOther.exists && lastOther.frame.height > 200 {
//                print("✅ Found as last other element")
//                return lastOther
//            }
//        }
//        
//        // Способ 4: Поиск по координатам (центр экрана, верхняя половина)
//        let centerTopCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
//        let elementAtCenter = centerTopCoordinate.referencedElement
//        if elementAtCenter.exists && elementAtCenter.elementType != .application {
//            print("✅ Found by center coordinate")
//            return elementAtCenter
//        }
//        
//        // Способ 5: Ищем среди ScrollViews
//        for i in 0..<app.scrollViews.count {
//            let scrollView = app.scrollViews.element(boundBy: i)
//            if scrollView.exists && scrollView.frame.height > 300 {
//                print("✅ Found as scroll view")
//                return scrollView
//            }
//        }
//        
//        // Способ 6: Ищем среди Groups
//        for i in 0..<app.groups.count {
//            let group = app.groups.element(boundBy: i)
//            if group.exists && group.frame.height > 200 {
//                print("✅ Found as group")
//                return group
//            }
//        }
//        
//        // Способ 7: фильтрация по фрейму через Swift
//        let allElements = app.descendants(matching: .any).allElementsBoundByIndex
//        let largeElements = allElements.filter {
//            $0.frame.height > 200 && $0.frame.width > 200
//        }
//        if let element = largeElements.last {
//            print("✅ Found by frame size: \(element.frame)")
//            return element
//        }
//        
//        print("❌ Modal not found by any method")
//        return nil
//    }
    
    private func closeModal(_ modal: XCUIElement) {
        print("🔄 Trying to close modal...")
        
        // Способ 1: Swipe down
        modal.swipeDown(velocity: .fast)
        // Thread.sleep(forTimeInterval: 0.5)
        
        if !modal.exists {
            print("✅ Closed by swipe down")
            return
        }
        
        // Способ 2: Ищем кнопку Cancel/Close
        let cancelButton = modal.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'cancel' OR label CONTAINS[c] 'close' OR label CONTAINS[c] 'done'")).firstMatch
        if cancelButton.exists {
            cancelButton.tap()
            print("✅ Closed by cancel button")
            return
        }
        
        // Способ 3: Тап вне модального окна
        let outsideCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
        outsideCoordinate.tap()
        Thread.sleep(forTimeInterval: 0.5)
        
        if !modal.exists {
            print("✅ Closed by tapping outside")
            return
        }
        
        // Способ 4: Escape key (на симуляторе) или свайп вниз как fallback
        let escapeKey = app.keys["Escape"].firstMatch
        if escapeKey.exists {
            escapeKey.tap()
            print("✅ Closed by Escape key")
            return
        }
    }
}
