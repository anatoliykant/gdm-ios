import Foundation
import SwiftUI

/// Сервис валидации входных данных
struct ValidationService {
    
    // MARK: - Validation Errors
    
    enum ValidationError: Error, LocalizedError, Equatable {
        case sugarLevelOutOfRange(Double)
        case sugarLevelTooLow(Double)
        case sugarLevelTooHigh(Double)
        case insulinUnitsOutOfRange(Int)
        case insulinUnitsTooLow(Int)
        case insulinUnitsTooHigh(Int)
        case breadUnitsOutOfRange(Double)
        case breadUnitsTooLow(Double)
        case breadUnitsTooHigh(Double)
        case dateInFuture(Date)
        case foodDescriptionTooLong(String)
        case foodDescriptionEmpty
        
        var errorDescription: String? {
            switch self {
            case .sugarLevelOutOfRange(let value):
                return "Уровень сахара \(value) ммоль/л вне допустимого диапазона (0.1-30.0)"
            case .sugarLevelTooLow(let value):
                return "Уровень сахара \(value) ммоль/л слишком низкий (минимум 0.1)"
            case .sugarLevelTooHigh(let value):
                return "Уровень сахара \(value) ммоль/л слишком высокий (максимум 30.0)"
            case .insulinUnitsOutOfRange(let value):
                return "Доза инсулина \(value) ед. вне допустимого диапазона (1-100)"
            case .insulinUnitsTooLow(let value):
                return "Доза инсулина \(value) ед. слишком низкая (минимум 1)"
            case .insulinUnitsTooHigh(let value):
                return "Доза инсулина \(value) ед. слишком высокая (максимум 100)"
            case .breadUnitsOutOfRange(let value):
                return "Хлебные единицы \(value) вне допустимого диапазона (0.1-50.0)"
            case .breadUnitsTooLow(let value):
                return "Хлебные единицы \(value) слишком низкие (минимум 0.1)"
            case .breadUnitsTooHigh(let value):
                return "Хлебные единицы \(value) слишком высокие (максимум 50.0)"
            case .dateInFuture(let date):
                return "Дата \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)) не может быть в будущем"
            case .foodDescriptionTooLong(let description):
                return "Описание еды слишком длинное (\(description.count) символов, максимум 500)"
            case .foodDescriptionEmpty:
                return "Описание еды не может быть пустым при указании ХЕ"
            }
        }
    }
    
    // MARK: - Validation Constants
    
    /// Минимальный уровень сахара в крови (ммоль/л)
    static let minSugarLevel: Double = 0.1
    
    /// Максимальный уровень сахара в крови (ммоль/л)
    static let maxSugarLevel: Double = 30.0
    
    /// Минимальная доза инсулина (единицы)
    static let minInsulinUnits: Int = 1
    
    /// Максимальная доза инсулина (единицы)
    static let maxInsulinUnits: Int = 100
    
    /// Минимальное количество хлебных единиц
    static let minBreadUnits: Double = 0.1
    
    /// Максимальное количество хлебных единиц
    static let maxBreadUnits: Double = 50.0
    
    /// Максимальная длина описания еды
    static let maxFoodDescriptionLength: Int = 500
    
    // MARK: - Validation Methods
    
    /// Валидирует запись полностью
    static func validateRecord(_ record: Record) throws {
        // Проверяем дату
        try validateDate(record.date)
        
        // Проверяем уровень сахара если указан
        if let sugarLevel = record.sugarLevel {
            try validateSugarLevel(sugarLevel)
        }
        
        // Проверяем инсулин если указан
        if let insulinUnits = record.insulinUnits, record.insulinType != .none {
            try validateInsulinUnits(insulinUnits)
        }
        
        // Проверяем хлебные единицы если указаны
        if let breadUnits = record.breadUnits {
            try validateBreadUnits(breadUnits)
        }
        
        // Проверяем еду
        if let food = record.food {
            try validateFoodDescription(food)
        }
        
        // Проверяем логическую связность
        try validateRecordLogic(record)
    }
    
    /// Валидирует уровень сахара
    static func validateSugarLevel(_ sugarLevel: Double) throws {
        guard sugarLevel >= minSugarLevel else {
            throw ValidationError.sugarLevelTooLow(sugarLevel)
        }
        
        guard sugarLevel <= maxSugarLevel else {
            throw ValidationError.sugarLevelTooHigh(sugarLevel)
        }
    }
    
    /// Валидирует дозу инсулина
    static func validateInsulinUnits(_ insulinUnits: Int) throws {
        guard insulinUnits >= minInsulinUnits else {
            throw ValidationError.insulinUnitsTooLow(insulinUnits)
        }
        
        guard insulinUnits <= maxInsulinUnits else {
            throw ValidationError.insulinUnitsTooHigh(insulinUnits)
        }
    }
    
    /// Валидирует хлебные единицы
    static func validateBreadUnits(_ breadUnits: Double) throws {
        guard breadUnits >= minBreadUnits else {
            throw ValidationError.breadUnitsTooLow(breadUnits)
        }
        
        guard breadUnits <= maxBreadUnits else {
            throw ValidationError.breadUnitsTooHigh(breadUnits)
        }
    }
    
    /// Валидирует дату
    static func validateDate(_ date: Date) throws {
        let now = Date()
        
        // Даем небольшую погрешность на несколько минут в будущем
        let allowedFutureTimeInterval: TimeInterval = 5 * 60 // 5 минут
        
        guard date.timeIntervalSince(now) <= allowedFutureTimeInterval else {
            throw ValidationError.dateInFuture(date)
        }
    }
    
    /// Валидирует описание еды
    static func validateFoodDescription(_ food: String) throws {
        let trimmedFood = food.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedFood.isEmpty else {
            throw ValidationError.foodDescriptionEmpty
        }
        
        guard trimmedFood.count <= maxFoodDescriptionLength else {
            throw ValidationError.foodDescriptionTooLong(trimmedFood)
        }
    }
    
    /// Валидирует логическую связность записи
    static func validateRecordLogic(_ record: Record) throws {
        // Если указаны хлебные единицы, должно быть описание еды
        if let breadUnits = record.breadUnits, breadUnits > 0 {
            guard let food = record.food, !food.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ValidationError.foodDescriptionEmpty
            }
        }
        
        // Если указан инсулин (кроме "нет"), должна быть доза
        if record.insulinType != .none {
            guard let insulinUnits = record.insulinUnits, insulinUnits > 0 else {
                throw ValidationError.insulinUnitsTooLow(0)
            }
        }
    }
    
    // MARK: - Validation Helpers
    
    /// Проверяет, валидна ли запись
    static func isValid(_ record: Record) -> Bool {
        do {
            try validateRecord(record)
            return true
        } catch {
            return false
        }
    }
    
    /// Получает все ошибки валидации для записи
    static func getValidationErrors(_ record: Record) -> [ValidationError] {
        var errors: [ValidationError] = []
        
        // Проверяем каждый компонент отдельно
        do {
            try validateDate(record.date)
        } catch let error as ValidationError {
            errors.append(error)
        } catch {}
        
        if let sugarLevel = record.sugarLevel {
            do {
                try validateSugarLevel(sugarLevel)
            } catch let error as ValidationError {
                errors.append(error)
            } catch {}
        }
        
        if let insulinUnits = record.insulinUnits, record.insulinType != .none {
            do {
                try validateInsulinUnits(insulinUnits)
            } catch let error as ValidationError {
                errors.append(error)
            } catch {}
        }
        
        if let breadUnits = record.breadUnits {
            do {
                try validateBreadUnits(breadUnits)
            } catch let error as ValidationError {
                errors.append(error)
            } catch {}
        }
        
        if let food = record.food {
            do {
                try validateFoodDescription(food)
            } catch let error as ValidationError {
                errors.append(error)
            } catch {}
        }
        
        do {
            try validateRecordLogic(record)
        } catch let error as ValidationError {
            errors.append(error)
        } catch {}
        
        return errors
    }
} 