//
//  XCTests+extensions.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-20.
//

import XCTest

extension XCUIElement.ElementType {
    var readableName: String {
        switch self {
        case .any: return "Any"
        case .other: return "Other"
        case .application: return "Application"
        case .group: return "Group"
        case .window: return "Window"
        case .sheet: return "Sheet"
        case .drawer: return "Drawer"
        case .alert: return "Alert"
        case .dialog: return "Dialog"
        case .button: return "Button"
        case .radioButton: return "RadioButton"
        case .radioGroup: return "RadioGroup"
        case .checkBox: return "CheckBox"
        case .disclosureTriangle: return "DisclosureTriangle"
        case .popUpButton: return "PopUpButton"
        case .comboBox: return "ComboBox"
        case .menuButton: return "MenuButton"
        case .toolbarButton: return "ToolbarButton"
        case .popover: return "Popover"
        case .keyboard: return "Keyboard"
        case .key: return "Key"
        case .navigationBar: return "NavigationBar"
        case .tabBar: return "TabBar"
        case .tabGroup: return "TabGroup"
        case .toolbar: return "Toolbar"
        case .statusBar: return "StatusBar"
        case .table: return "Table"
        case .tableRow: return "TableRow"
        case .tableColumn: return "TableColumn"
        case .outline: return "Outline"
        case .outlineRow: return "OutlineRow"
        case .browser: return "Browser"
        case .collectionView: return "CollectionView"
        case .slider: return "Slider"
        case .pageIndicator: return "PageIndicator"
        case .progressIndicator: return "ProgressIndicator"
        case .activityIndicator: return "ActivityIndicator"
        case .segmentedControl: return "SegmentedControl"
        case .picker: return "Picker"
        case .pickerWheel: return "PickerWheel"
        case .switch: return "Switch"
        case .toggle: return "Toggle"
        case .link: return "Link"
        case .image: return "Image"
        case .icon: return "Icon"
        case .searchField: return "SearchField"
        case .scrollView: return "ScrollView"
        case .scrollBar: return "ScrollBar"
        case .staticText: return "StaticText"
        case .textField: return "TextField"
        case .secureTextField: return "SecureTextField"
        case .datePicker: return "DatePicker"
        case .textView: return "TextView"
        case .menu: return "Menu"
        case .menuItem: return "MenuItem"
        case .menuBar: return "MenuBar"
        case .menuBarItem: return "MenuBarItem"
        case .map: return "Map"
        case .webView: return "WebView"
        case .incrementArrow: return "IncrementArrow"
        case .decrementArrow: return "DecrementArrow"
        case .timeline: return "Timeline"
        case .ratingIndicator: return "RatingIndicator"
        case .valueIndicator: return "ValueIndicator"
        case .splitGroup: return "SplitGroup"
        case .splitter: return "Splitter"
        case .relevanceIndicator: return "RelevanceIndicator"
        case .colorWell: return "ColorWell"
        case .helpTag: return "HelpTag"
        case .matte: return "Matte"
        case .dockItem: return "DockItem"
        case .ruler: return "Ruler"
        case .rulerMarker: return "RulerMarker"
        case .grid: return "Grid"
        case .levelIndicator: return "LevelIndicator"
        case .cell: return "Cell"
        case .layoutArea: return "LayoutArea"
        case .layoutItem: return "LayoutItem"
        case .handle: return "Handle"
        case .stepper: return "Stepper"
        case .tab: return "Tab"
        case .touchBar: return "TouchBar"
        case .statusItem: return "StatusItem"
        @unknown default: return "Unknown(\(self.rawValue))"
        }
    }
    
}

extension XCTestCase {
    
    // MARK: - Helper Methods
    
    func findModalScreenByAnyMeans() -> XCUIElement? {
        print("\n🔍 Trying to find modal screen...")
        
        let app = XCUIApplication()
        
        // Способ 1: Классический sheet
        let sheet = app.sheets.firstMatch
        if sheet.exists {
            print("✅ Found as sheet")
            return sheet
        }
        
        // Способ 2: Поиск по identifier InputView
        let inputView = app.otherElements["InputViewContainer"]
        if inputView.exists {
            print("✅ Found by InputView identifier")
            return inputView
        }
        
        // Способ 3: Последний добавленный other element
        if app.otherElements.count > 0 {
            let lastOther = app.otherElements.element(boundBy: app.otherElements.count - 1)
            if lastOther.exists && lastOther.frame.height > 200 {
                print("✅ Found as last other element")
                return lastOther
            }
        }
        
        // Способ 4: Поиск по координатам (центр экрана, верхняя половина)
        let centerTopCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.3))
        let elementAtCenter = centerTopCoordinate.referencedElement
        if elementAtCenter.exists && elementAtCenter.elementType != .application {
            print("✅ Found by center coordinate")
            return elementAtCenter
        }
        
        // Способ 5: Ищем среди ScrollViews
        for i in 0..<app.scrollViews.count {
            let scrollView = app.scrollViews.element(boundBy: i)
            if scrollView.exists && scrollView.frame.height > 300 {
                print("✅ Found as scroll view")
                return scrollView
            }
        }
        
        // Способ 6: Ищем среди Groups
        for i in 0..<app.groups.count {
            let group = app.groups.element(boundBy: i)
            if group.exists && group.frame.height > 200 {
                print("✅ Found as group")
                return group
            }
        }
        
        // Способ 7: фильтрация по фрейму через Swift
        let allElements = app.descendants(matching: .any).allElementsBoundByIndex
        let largeElements = allElements.filter {
            $0.frame.height > 200 && $0.frame.width > 200
        }
        if let element = largeElements.last {
            print("✅ Found by frame size: \(element.frame)")
            return element
        }
        
        print("❌ Modal not found by any method")
        return nil
    }
    
    func checkAllUIElements() {
        // Arrange
        let app = XCUIApplication()
        // app.launchArguments += ["-resetData"]
        app.launch()
        
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
        // XCTAssertTrue(true)
    }
}
