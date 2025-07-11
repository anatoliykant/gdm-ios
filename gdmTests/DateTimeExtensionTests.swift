//
//  DateTimeExtensionTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 11.07.2025.
//

import Testing
import Foundation
@testable import gdm

/// Тесты для Date extensions
@Suite("DateTime Extension Tests")
struct DateTimeExtensionTests {
    
    // MARK: - Helper Methods
    
    /// Создает дату с заданными параметрами
    private func createDate(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? Date()
    }
    
    // MARK: - stringDate Tests
    
    @Test("Date stringDate returns formatted date")
    func date_StringDate_ReturnsFormattedDate() throws {
        let date = createDate(year: 2025, month: 7, day: 11)
        let dateString = date.stringDate
        
        // Проверяем что строка не пустая и содержит элементы даты
        #expect(!dateString.isEmpty)
        
        // Проверяем что в строке есть числа (день, год)
        #expect(dateString.contains("11") || dateString.contains("2025"))
    }
    
    @Test("Date stringDate uses medium style")
    func date_StringDate_UsesMediumStyle() throws {
        let date = createDate(year: 2025, month: 1, day: 15)
        let dateString = date.stringDate
        
        // Создаем ожидаемый формат вручную для сравнения
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let expectedString = formatter.string(from: date)
        
        #expect(dateString == expectedString)
    }
    
    @Test("Date stringDate with different dates")
    func date_StringDate_WithDifferentDates_FormatsCorrectly() throws {
        let dates = [
            createDate(year: 2025, month: 1, day: 1),    // Новый год
            createDate(year: 2025, month: 7, day: 4),    // Середина года
            createDate(year: 2025, month: 12, day: 31),  // Конец года
            createDate(year: 2024, month: 2, day: 29),   // Високосный год
        ]
        
        for date in dates {
            let dateString = date.stringDate
            #expect(!dateString.isEmpty)
            #expect(dateString.count > 3) // Минимальная длина разумной даты
        }
    }
    
    @Test("Date stringDate with past and future dates")
    func date_StringDate_WithPastAndFutureDates_FormatsCorrectly() throws {
        let pastDate = createDate(year: 1990, month: 5, day: 20)
        let futureDate = createDate(year: 2030, month: 8, day: 15)
        
        let pastString = pastDate.stringDate
        let futureString = futureDate.stringDate
        
        #expect(!pastString.isEmpty)
        #expect(!futureString.isEmpty)
        #expect(pastString != futureString)
    }
    
    // MARK: - stringTime Tests
    
    @Test("Date stringTime returns formatted time")
    func date_StringTime_ReturnsFormattedTime() throws {
        let date = createDate(year: 2025, month: 7, day: 11, hour: 14, minute: 30)
        let timeString = date.stringTime
        
        // Проверяем что строка не пустая и содержит время
        #expect(!timeString.isEmpty)
        
        // Проверяем что содержит двоеточие (разделитель времени)
        #expect(timeString.contains(":"))
        
        // Проверяем что содержит часы или минуты
        #expect(timeString.contains("14") || timeString.contains("30"))
    }
    
    @Test("Date stringTime uses short style")
    func date_StringTime_UsesShortStyle() throws {
        let date = createDate(year: 2025, month: 7, day: 11, hour: 15, minute: 45)
        let timeString = date.stringTime
        
        // Создаем ожидаемый формат вручную для сравнения
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let expectedString = formatter.string(from: date)
        
        #expect(timeString == expectedString)
    }
    
    @Test("Date stringTime with different times")
    func date_StringTime_WithDifferentTimes_FormatsCorrectly() throws {
        let times = [
            createDate(year: 2025, month: 1, day: 1, hour: 0, minute: 0),   // Полночь
            createDate(year: 2025, month: 1, day: 1, hour: 6, minute: 30),  // Утро
            createDate(year: 2025, month: 1, day: 1, hour: 12, minute: 0),  // Полдень
            createDate(year: 2025, month: 1, day: 1, hour: 18, minute: 45), // Вечер
            createDate(year: 2025, month: 1, day: 1, hour: 23, minute: 59), // Почти полночь
        ]
        
        for time in times {
            let timeString = time.stringTime
            #expect(!timeString.isEmpty)
            #expect(timeString.contains(":"))
        }
    }
    
    @Test("Date stringTime with same time different dates")
    func date_StringTime_WithSameTimeDifferentDates_ReturnsSameTime() throws {
        let date1 = createDate(year: 2025, month: 1, day: 1, hour: 10, minute: 30)
        let date2 = createDate(year: 2025, month: 12, day: 31, hour: 10, minute: 30)
        
        let timeString1 = date1.stringTime
        let timeString2 = date2.stringTime
        
        // Время должно быть одинаковым независимо от даты
        #expect(timeString1 == timeString2)
    }
    
    // MARK: - Combined Tests
    
    @Test("Date stringDate and stringTime are different")
    func date_StringDateAndStringTime_AreDifferent() throws {
        let date = createDate(year: 2025, month: 7, day: 11, hour: 14, minute: 30)
        
        let dateString = date.stringDate
        let timeString = date.stringTime
        
        #expect(dateString != timeString)
        #expect(!dateString.isEmpty)
        #expect(!timeString.isEmpty)
    }
    
    @Test("Date formatting with current date")
    func date_Formatting_WithCurrentDate_WorksCorrectly() throws {
        let now = Date()
        
        let dateString = now.stringDate
        let timeString = now.stringTime
        
        #expect(!dateString.isEmpty)
        #expect(!timeString.isEmpty)
        #expect(dateString != timeString)
    }
    
    // MARK: - Realistic Usage Tests
    
    @Test("Date formatting in Record context")
    func date_Formatting_InRecordContext_WorksCorrectly() throws {
        let recordDate = createDate(year: 2025, month: 7, day: 11, hour: 9, minute: 15)
        let record = Record(date: recordDate, sugarLevel: 5.5)
        
        let dateString = record.date.stringDate
        let timeString = record.date.stringTime
        
        #expect(!dateString.isEmpty)
        #expect(!timeString.isEmpty)
        #expect(dateString.contains("11") || dateString.contains("2025"))
        #expect(timeString.contains("9") || timeString.contains("15"))
    }
    
    @Test("Date formatting consistency across multiple calls")
    func date_Formatting_ConsistencyAcrossMultipleCalls() throws {
        let date = createDate(year: 2025, month: 7, day: 11, hour: 14, minute: 30)
        
        // Вызываем форматирование несколько раз
        let dateString1 = date.stringDate
        let dateString2 = date.stringDate
        let timeString1 = date.stringTime
        let timeString2 = date.stringTime
        
        // Результаты должны быть одинаковыми
        #expect(dateString1 == dateString2)
        #expect(timeString1 == timeString2)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("Date formatting with very old dates")
    func date_Formatting_WithVeryOldDates_HandlesCorrectly() throws {
        let oldDate = createDate(year: 1900, month: 1, day: 1, hour: 0, minute: 0)
        
        let dateString = oldDate.stringDate
        let timeString = oldDate.stringTime
        
        #expect(!dateString.isEmpty)
        #expect(!timeString.isEmpty)
    }
    
    @Test("Date formatting with far future dates")
    func date_Formatting_WithFarFutureDates_HandlesCorrectly() throws {
        let futureDate = createDate(year: 2100, month: 12, day: 31, hour: 23, minute: 59)
        
        let dateString = futureDate.stringDate
        let timeString = futureDate.stringTime
        
        #expect(!dateString.isEmpty)
        #expect(!timeString.isEmpty)
    }
    
    @Test("Date formatting with leap year")
    func date_Formatting_WithLeapYear_HandlesCorrectly() throws {
        let leapDate = createDate(year: 2024, month: 2, day: 29, hour: 12, minute: 0)
        
        let dateString = leapDate.stringDate
        let timeString = leapDate.stringTime
        
        #expect(!dateString.isEmpty)
        #expect(!timeString.isEmpty)
        #expect(dateString.contains("29") || dateString.contains("2024"))
    }
    
    // MARK: - Global Variables Tests
    
    @Test("Global is12Hour variable accessibility")
    func global_Is12Hour_IsAccessible() throws {
        // Проверяем что глобальная переменная доступна
        let is12HourValue = is12Hour
        
        // Значение должно быть булевым
        #expect(is12HourValue == true || is12HourValue == false)
    }
    
    @Test("Global isLongTimeFormat variable accessibility")
    func global_IsLongTimeFormat_IsAccessible() throws {
        // Проверяем что глобальная переменная доступна
        let isLongTimeFormatValue = isLongTimeFormat
        
        // Значение должно быть булевым
        #expect(isLongTimeFormatValue == true || isLongTimeFormatValue == false)
        
        // Должно равняться is12Hour
        #expect(isLongTimeFormatValue == is12Hour)
    }
    
    // MARK: - Performance Tests
    
    @Test("Date formatting performance")
    func date_Formatting_Performance_IsReasonable() throws {
        let date = createDate(year: 2025, month: 7, day: 11, hour: 14, minute: 30)
        
        // Измеряем время выполнения форматирования
        let startTime = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            _ = date.stringDate
            _ = date.stringTime
        }
        
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        
        // Форматирование 100 дат должно занимать менее секунды
        #expect(timeElapsed < 1.0)
    }
} 