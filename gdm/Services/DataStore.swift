//
//  DataStore.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import Foundation

final class DataStore: ObservableObject {
    @Published var records: [Record] = []
    
    /// Ключ для хранения данных в UserDefaults
    private let storageKey = "GDM_Records"
    
    /// Версия данных для возможной миграции
    private let dataVersion = 1
    
    /// Версия ключа для хранения версии данных
    private let versionKey = "GDM_DataVersion"
    
    /// UserDefaults для хранения данных (можно инжектить для тестов)
    let userDefaults: UserDefaults

    init(loadSampleData: Bool = true, userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        // Load initial sample data or data from storage
        loadRecords()
        if loadSampleData, records.isEmpty { // Add sample data if no records are loaded
            addSampleData()
        }
    }

    // Adds a new record and sorts the records by date
    func addRecord(_ record: Record) throws {
        // Валидируем запись перед добавлением
        try ValidationService.validateRecord(record)
        
        records.append(record)
        records.sort { $0.date > $1.date } // Sort descending (newest first)
        saveRecords()
    }
    
    /// Обновляет существующую запись
    func updateRecord(_ record: Record) throws {
        // Валидируем запись перед обновлением
        try ValidationService.validateRecord(record)
        
        if let index = records.firstIndex(where: { $0.id == record.id }) {
            records[index] = record
            records.sort { $0.date > $1.date }
            saveRecords()
        }
    }
    
    /// Удаляет запись
    func deleteRecord(_ record: Record) {
        records.removeAll { $0.id == record.id }
        saveRecords()
    }
    
    /// Удаляет запись по ID
    func deleteRecord(withId id: UUID) {
        records.removeAll { $0.id == id }
        saveRecords()
    }

    // Загружает записи из UserDefaults
    func loadRecords() {
        do {
            // Проверяем версию данных
            let savedVersion = userDefaults.integer(forKey: versionKey)
            
            if savedVersion == 0 {
                // Первый запуск - версия данных не сохранена
                print("DataStore: Первый запуск, используем образцы данных")
                return
            }
            
            if savedVersion != dataVersion {
                // Потребуется миграция данных в будущем
                print("DataStore: Обнаружена старая версия данных, требуется миграция")
                // В будущем здесь будет логика миграции
            }
            
            // Загружаем данные из UserDefaults
            if let data = userDefaults.data(forKey: storageKey) {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                let loadedRecords = try decoder.decode([Record].self, from: data)
                self.records = loadedRecords.sorted { $0.date > $1.date }
                
                print("DataStore: Загружено \(records.count) записей из UserDefaults")
            } else {
                print("DataStore: Данные в UserDefaults не найдены")
            }
        } catch {
            print("DataStore: Ошибка при загрузке данных - \(error)")
            // При ошибке загрузки используем образцы данных
        }
    }

    // Сохраняет записи в UserDefaults
    func saveRecords() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(records)
            userDefaults.set(data, forKey: storageKey)
            userDefaults.set(dataVersion, forKey: versionKey)
            
            print("DataStore: Сохранено \(records.count) записей в UserDefaults")
        } catch {
            print("DataStore: Ошибка при сохранении данных - \(error)")
        }
    }
    
    /// Очищает все данные (для тестирования)
    func clearAllData() {
        records.removeAll()
        userDefaults.removeObject(forKey: storageKey)
        userDefaults.removeObject(forKey: versionKey)
        print("DataStore: Все данные очищены")
    }
    
    /// Сброс к образцам данных
    func resetToSampleData() {
        clearAllData()
        addSampleData()
        saveRecords()
    }
    
    // MARK: - Safe Operations with Validation
    
    /// Безопасно добавляет запись с обработкой ошибок валидации
    func addRecordSafely(_ record: Record) -> ValidationResult {
        do {
            try addRecord(record)
            return .success
        } catch let error as ValidationService.ValidationError {
            return .failure(error)
        } catch {
            return .failure(ValidationService.ValidationError.dateInFuture(record.date))
        }
    }
    
    /// Безопасно обновляет запись с обработкой ошибок валидации
    func updateRecordSafely(_ record: Record) -> ValidationResult {
        do {
            try updateRecord(record)
            return .success
        } catch let error as ValidationService.ValidationError {
            return .failure(error)
        } catch {
            return .failure(ValidationService.ValidationError.dateInFuture(record.date))
        }
    }
    
    /// Результат валидации
    enum ValidationResult {
        case success
        case failure(ValidationService.ValidationError)
        
        var isSuccess: Bool {
            switch self {
            case .success:
                return true
            case .failure:
                return false
            }
        }
        
        var error: ValidationService.ValidationError? {
            switch self {
            case .success:
                return nil
            case .failure(let error):
                return error
            }
        }
        
        var errorMessage: String? {
            return error?.localizedDescription
        }
    }
    
    // Retrieves the record immediately preceding the given date
    func getPreviousRecord(before date: Date) -> Record? {
        // Ensure records are sorted chronologically (oldest first for this logic)
        let sortedRecords = records.sorted { $0.date < $1.date }
        // Find the index of the current record's date or where it would be inserted
        // This logic needs to find the record strictly *before* the given record's date.
        let recordDate = date
        if let currentIndex = sortedRecords.lastIndex(where: { $0.date < recordDate }) {
            return sortedRecords[currentIndex]
        }
        return nil
    }

    // Determines if a record is the first sugar reading of its day
    func isFirstSugarRecordOfDay(for record: Record) -> Bool {
        guard record.sugarLevel != nil else { return false }
        let calendar = Calendar.current
        // Get all records from the same day as the current record that have a sugar level and are earlier
        let earlierRecordsTodayWithSugar = records.filter {
            calendar.isDate($0.date, inSameDayAs: record.date) &&
            $0.date < record.date && // Strictly earlier
            $0.id != record.id && // Exclude the record itself if dates were identical (unlikely with UUIDs but good practice)
            $0.sugarLevel != nil
        }
        return earlierRecordsTodayWithSugar.isEmpty
    }
    
    // Adds some sample data for demonstration
    private func addSampleData() {
        records = Record.mockArray.sorted(by: { $0.date > $1.date }) // Ensure sample data is also sorted
        saveRecords()
    }
}
