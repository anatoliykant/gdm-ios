//
//  SugarColorLogicTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import Testing
import Foundation
@testable import gdm

/// Тесты для SugarColorLogic
@Suite("SugarColorLogic Tests")
struct SugarColorLogicTests {
    
    // MARK: - Helper Methods
    
    /// Создает базовую запись для тестов
    private func createRecord(
        date: Date = Date(),
        sugarLevel: Double?,
        food: String? = nil
    ) -> Record {
        return Record(
            date: date,
            sugarLevel: sugarLevel,
            insulinType: .none,
            insulinUnits: nil,
            food: food,
            breadUnits: nil
        )
    }
    
    // MARK: - No Sugar Level Tests
    
    @Test("SugarColorLogic returns gray for nil sugar level")
    func sugarColorLogic_ReturnsGray_ForNilSugarLevel() throws {
        let record = createRecord(sugarLevel: nil)
        let color = SugarColorLogic.color(
            for: record,
            previousRecord: nil,
            isFirstSugarOfDay: false
        )
        
        #expect(color == .gray)
    }
    
    @Test("SugarColorLogic returns gray for nil sugar level regardless of context")
    func sugarColorLogic_ReturnsGray_ForNilSugarLevel_AllContexts() throws {
        let record = createRecord(sugarLevel: nil)
        let previousRecord = createRecord(sugarLevel: 5.0, food: "Хлеб")
        
        // Тест для всех возможных контекстов
        let contexts = [
            (isFirstSugarOfDay: true, previousRecord: nil as Record?),
            (isFirstSugarOfDay: false, previousRecord: nil as Record?),
            (isFirstSugarOfDay: false, previousRecord: previousRecord)
        ]
        
        for context in contexts {
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: context.previousRecord,
                isFirstSugarOfDay: context.isFirstSugarOfDay
            )
            #expect(color == .gray)
        }
    }
    
    // MARK: - First Sugar of Day Tests
    
    @Test("SugarColorLogic returns green for first sugar ≤ 5.0")
    func sugarColorLogic_ReturnsGreen_FirstSugarNormal() throws {
        let testCases: [Double] = [0.1, 3.0, 5.0] // граничные и типичные нормальные значения
        
        for sugarLevel in testCases {
            let record = createRecord(sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: nil,
                isFirstSugarOfDay: true
            )
            #expect(color == .green)
        }
    }
    
    @Test("SugarColorLogic returns red for first sugar > 5.0")
    func sugarColorLogic_ReturnsRed_FirstSugarHigh() throws {
        let testCases: [Double] = [5.1, 7.0, 15.0, 30.0] // граничные и высокие значения
        
        for sugarLevel in testCases {
            let record = createRecord(sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: nil,
                isFirstSugarOfDay: true
            )
            #expect(color == .red)
        }
    }
    
    // MARK: - After Food Tests (1 hour)
    
    @Test("SugarColorLogic returns green for sugar ≤ 7.0 after 1 hour")
    func sugarColorLogic_ReturnsGreen_After1Hour_Normal() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-3600), // 1 час назад
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let testCases: [Double] = [3.0, 6.0, 7.0] // нормальные значения
        
        for sugarLevel in testCases {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .green)
        }
    }
    
    @Test("SugarColorLogic returns red for sugar > 7.0 after 1 hour")
    func sugarColorLogic_ReturnsRed_After1Hour_High() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-3600), // 1 час назад
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let testCases: [Double] = [7.1, 10.0, 15.0] // высокие значения
        
        for sugarLevel in testCases {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .red)
        }
    }
    
    @Test("SugarColorLogic handles 1 hour time range boundaries")
    func sugarColorLogic_Handles1HourBoundaries() throws {
        let now = Date()
        let sugarLevel = 6.5 // нормальный для 1 часа
        
        // Тестируем граничные значения для 1-часового диапазона (0.8-1.8 часов)
        let timeDifferences: [TimeInterval] = [
            0.8 * 3600,  // 48 минут (нижняя граница)
            1.0 * 3600,  // 1 час (середина)
            1.7 * 3600   // 1.7 часа (почти верхняя граница)
        ]
        
        for timeDiff in timeDifferences {
            let previousRecord = createRecord(
                date: now.addingTimeInterval(-timeDiff),
                sugarLevel: 5.0,
                food: "Хлеб"
            )
            
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .green) // 6.5 ≤ 7.0 для 1 часа
        }
    }
    
    // MARK: - After Food Tests (2 hours)
    
    @Test("SugarColorLogic returns green for sugar ≤ 6.7 after 2 hours")
    func sugarColorLogic_ReturnsGreen_After2Hours_Normal() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-2 * 3600), // 2 часа назад
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let testCases: [Double] = [3.0, 6.0, 6.7] // нормальные значения для 2 часов
        
        for sugarLevel in testCases {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .green)
        }
    }
    
    @Test("SugarColorLogic returns red for sugar > 6.7 after 2 hours")
    func sugarColorLogic_ReturnsRed_After2Hours_High() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-2 * 3600), // 2 часа назад
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let testCases: [Double] = [6.8, 8.0, 12.0] // высокие значения для 2 часов
        
        for sugarLevel in testCases {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .red)
        }
    }
    
    @Test("SugarColorLogic handles 2 hour time range boundaries")
    func sugarColorLogic_Handles2HourBoundaries() throws {
        let now = Date()
        let sugarLevel = 6.5 // нормальный для 2 часов
        
        // Тестируем граничные значения для 2-часового диапазона (1.8-2.8 часов)
        let timeDifferences: [TimeInterval] = [
            1.8 * 3600,  // 1.8 часа (нижняя граница)
            2.0 * 3600,  // 2 часа (середина)
            2.7 * 3600   // 2.7 часа (почти верхняя граница)
        ]
        
        for timeDiff in timeDifferences {
            let previousRecord = createRecord(
                date: now.addingTimeInterval(-timeDiff),
                sugarLevel: 5.0,
                food: "Хлеб"
            )
            
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .green) // 6.5 ≤ 6.7 для 2 часов
        }
    }
    
    // MARK: - After Food Tests (3+ hours)
    
    @Test("SugarColorLogic returns green for sugar ≤ 5.8 after 3+ hours")
    func sugarColorLogic_ReturnsGreen_After3Hours_Normal() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-3 * 3600), // 3 часа назад
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let testCases: [Double] = [3.0, 5.0, 5.8] // нормальные значения для 3+ часов
        
        for sugarLevel in testCases {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .green)
        }
    }
    
    @Test("SugarColorLogic returns red for sugar > 5.8 after 3+ hours")
    func sugarColorLogic_ReturnsRed_After3Hours_High() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-3 * 3600), // 3 часа назад
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let testCases: [Double] = [5.9, 7.0, 10.0] // высокие значения для 3+ часов
        
        for sugarLevel in testCases {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .red)
        }
    }
    
    @Test("SugarColorLogic handles 3+ hour range correctly")
    func sugarColorLogic_Handles3PlusHourRange() throws {
        let now = Date()
        let sugarLevel = 5.5 // нормальный для 3+ часов
        
        // Тестируем различные времена ≥ 2.8 часов
        let timeDifferences: [TimeInterval] = [
            2.8 * 3600,  // 2.8 часа (нижняя граница)
            3.0 * 3600,  // 3 часа
            6.0 * 3600,  // 6 часов
            24.0 * 3600  // 24 часа
        ]
        
        for timeDiff in timeDifferences {
            let previousRecord = createRecord(
                date: now.addingTimeInterval(-timeDiff),
                sugarLevel: 5.0,
                food: "Хлеб"
            )
            
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(color == .green) // 5.5 ≤ 5.8 для 3+ часов
        }
    }
    
    // MARK: - Fallback Logic Tests
    
    @Test("SugarColorLogic uses fallback when no previous food")
    func sugarColorLogic_UsesFallback_NoPreviousFood() throws {
        let now = Date()
        
        // Предыдущая запись без еды
        let previousRecordNoFood = createRecord(
            date: now.addingTimeInterval(-3600),
            sugarLevel: 5.0,
            food: nil
        )
        
        // Предыдущая запись с пустой едой
        let previousRecordEmptyFood = createRecord(
            date: now.addingTimeInterval(-3600),
            sugarLevel: 5.0,
            food: "   " // только пробелы
        )
        
        let testCases = [
            (previousRecord: nil as Record?, name: "no previous record"),
            (previousRecord: previousRecordNoFood, name: "previous record without food"),
            (previousRecord: previousRecordEmptyFood, name: "previous record with empty food")
        ]
        
        for testCase in testCases {
            // Тест нормального значения (≤ 5.0)
            let normalRecord = createRecord(date: now, sugarLevel: 4.5)
            let normalColor = SugarColorLogic.color(
                for: normalRecord,
                previousRecord: testCase.previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(normalColor == .green)
            
            // Тест высокого значения (> 5.0)
            let highRecord = createRecord(date: now, sugarLevel: 6.0)
            let highColor = SugarColorLogic.color(
                for: highRecord,
                previousRecord: testCase.previousRecord,
                isFirstSugarOfDay: false
            )
            #expect(highColor == .red)
        }
    }
    
    @Test("SugarColorLogic uses fallback for time outside ranges")
    func sugarColorLogic_UsesFallback_TimeOutsideRanges() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-30 * 60), // 30 минут назад (< 0.8 часа)
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        // Тест нормального значения для fallback (≤ 5.0)
        let normalRecord = createRecord(date: now, sugarLevel: 4.5)
        let normalColor = SugarColorLogic.color(
            for: normalRecord,
            previousRecord: previousRecord,
            isFirstSugarOfDay: false
        )
        #expect(normalColor == .green)
        
        // Тест высокого значения для fallback (> 5.0)
        let highRecord = createRecord(date: now, sugarLevel: 6.0)
        let highColor = SugarColorLogic.color(
            for: highRecord,
            previousRecord: previousRecord,
            isFirstSugarOfDay: false
        )
        #expect(highColor == .red)
    }
    
    // MARK: - Edge Cases and Boundary Tests
    
    @Test("SugarColorLogic handles exact boundary values")
    func sugarColorLogic_HandlesExactBoundaryValues() throws {
        let now = Date()
        
        // Тест точных граничных значений сахара для каждого контекста
        let testCases = [
            (
                context: "First sugar of day",
                previousRecord: nil as Record?,
                isFirstSugarOfDay: true,
                boundary: 5.0,
                shouldBeGreen: true
            ),
            (
                context: "After 1 hour",
                previousRecord: createRecord(
                    date: now.addingTimeInterval(-3600),
                    sugarLevel: 5.0,
                    food: "Хлеб"
                ),
                isFirstSugarOfDay: false,
                boundary: 7.0,
                shouldBeGreen: true
            ),
            (
                context: "After 2 hours",
                previousRecord: createRecord(
                    date: now.addingTimeInterval(-2 * 3600),
                    sugarLevel: 5.0,
                    food: "Хлеб"
                ),
                isFirstSugarOfDay: false,
                boundary: 6.7,
                shouldBeGreen: true
            ),
            (
                context: "After 3+ hours",
                previousRecord: createRecord(
                    date: now.addingTimeInterval(-3 * 3600),
                    sugarLevel: 5.0,
                    food: "Хлеб"
                ),
                isFirstSugarOfDay: false,
                boundary: 5.8,
                shouldBeGreen: true
            )
        ]
        
        for testCase in testCases {
            // Тест граничного значения
            let boundaryRecord = createRecord(date: now, sugarLevel: testCase.boundary)
            let boundaryColor = SugarColorLogic.color(
                for: boundaryRecord,
                previousRecord: testCase.previousRecord,
                isFirstSugarOfDay: testCase.isFirstSugarOfDay
            )
            #expect(boundaryColor == .green)
            
            // Тест значения чуть выше границы
            let aboveBoundaryRecord = createRecord(date: now, sugarLevel: testCase.boundary + 0.1)
            let aboveBoundaryColor = SugarColorLogic.color(
                for: aboveBoundaryRecord,
                previousRecord: testCase.previousRecord,
                isFirstSugarOfDay: testCase.isFirstSugarOfDay
            )
            #expect(aboveBoundaryColor == .red)
        }
    }
    
    @Test("SugarColorLogic handles time boundary transitions")
    func sugarColorLogic_HandlesTimeBoundaryTransitions() throws {
        let now = Date()
        
        // Тест перехода от 1 часа к 2 часам с сахаром 6.8
        let sugarLevel = 6.8 // значение, которое нормально для 1 часа (≤ 7.0), но высоко для 2 часов (> 6.7)
        
        // Время чуть меньше 1.8 часа - должно использовать правило 1 часа (≤ 7.0)
        let just1Hour = createRecord(
            date: now.addingTimeInterval(-1.7 * 3600),
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        let color1Hour = SugarColorLogic.color(
            for: createRecord(date: now, sugarLevel: sugarLevel),
            previousRecord: just1Hour,
            isFirstSugarOfDay: false
        )
        #expect(color1Hour == .green) // 6.8 ≤ 7.0
        
        // Время чуть больше 1.8 часа - должно использовать правило 2 часов (≤ 6.7)
        let just2Hours = createRecord(
            date: now.addingTimeInterval(-1.9 * 3600),
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        let color2Hours = SugarColorLogic.color(
            for: createRecord(date: now, sugarLevel: sugarLevel),
            previousRecord: just2Hours,
            isFirstSugarOfDay: false
        )
        #expect(color2Hours == .red) // 6.8 > 6.7
        
        // Дополнительно протестируем переход от 2 часов к 3+ часам с сахаром 5.9
        let sugarLevel3Plus = 5.9 // нормально для 2 часов (≤ 6.7), но высоко для 3+ часов (> 5.8)
        
        // Время чуть меньше 2.8 часа - должно использовать правило 2 часов (≤ 6.7)
        let just2HoursEnd = createRecord(
            date: now.addingTimeInterval(-2.7 * 3600),
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        let color2HoursEnd = SugarColorLogic.color(
            for: createRecord(date: now, sugarLevel: sugarLevel3Plus),
            previousRecord: just2HoursEnd,
            isFirstSugarOfDay: false
        )
        #expect(color2HoursEnd == .green) // 5.9 ≤ 6.7
        
        // Время чуть больше 2.8 часа - должно использовать правило 3+ часов (≤ 5.8)
        let just3Hours = createRecord(
            date: now.addingTimeInterval(-2.9 * 3600),
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        let color3Hours = SugarColorLogic.color(
            for: createRecord(date: now, sugarLevel: sugarLevel3Plus),
            previousRecord: just3Hours,
            isFirstSugarOfDay: false
        )
        #expect(color3Hours == .red) // 5.9 > 5.8
    }
    
    // MARK: - Complex Scenarios Tests
    
    @Test("SugarColorLogic prioritizes isFirstSugarOfDay over previous record")
    func sugarColorLogic_PrioritizesFirstSugarOfDay() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-3600),
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        // Даже если есть предыдущая запись с едой, isFirstSugarOfDay должен иметь приоритет
        let record = createRecord(date: now, sugarLevel: 6.0)
        let color = SugarColorLogic.color(
            for: record,
            previousRecord: previousRecord,
            isFirstSugarOfDay: true
        )
        
        // Должно использовать правило первого сахара (> 5.0 = красный)
        // а не правило после еды (≤ 7.0 = зеленый)
        #expect(color == .red)
    }
    
    @Test("SugarColorLogic handles negative time differences")
    func sugarColorLogic_HandlesNegativeTimeDifferences() throws {
        let now = Date()
        
        // Предыдущая запись в будущем (отрицательная разница времени)
        let futureRecord = createRecord(
            date: now.addingTimeInterval(3600), // 1 час в будущем
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let record = createRecord(date: now, sugarLevel: 6.0)
        let color = SugarColorLogic.color(
            for: record,
            previousRecord: futureRecord,
            isFirstSugarOfDay: false
        )
        
        // Должно использовать fallback логику (≤ 5.0)
        #expect(color == .red) // 6.0 > 5.0
    }
    
    @Test("SugarColorLogic handles extreme sugar values")
    func sugarColorLogic_HandlesExtremeSugarValues() throws {
        let now = Date()
        let previousRecord = createRecord(
            date: now.addingTimeInterval(-3600),
            sugarLevel: 5.0,
            food: "Хлеб"
        )
        
        let extremeValues: [Double] = [0.1, 50.0, 100.0] // экстремально низкие и высокие значения
        
        for sugarLevel in extremeValues {
            let record = createRecord(date: now, sugarLevel: sugarLevel)
            let color = SugarColorLogic.color(
                for: record,
                previousRecord: previousRecord,
                isFirstSugarOfDay: false
            )
            
            // Проверяем что метод не крашится и возвращает валидный цвет
            #expect(color == .green || color == .red)
            
            // Для логики 1 часа после еды: ≤ 7.0 зеленый, > 7.0 красный
            if sugarLevel <= 7.0 {
                #expect(color == .green)
            } else {
                #expect(color == .red)
            }
        }
    }
} 