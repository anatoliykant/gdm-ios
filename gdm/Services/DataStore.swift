//
//  DataStore.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 08.06.2025.
//

import Foundation

final class DataStore: ObservableObject {
    @Published var records: [Record] = []

    init() {
        // Load initial sample data or data from storage
        loadRecords()
        if records.isEmpty { // Add sample data if no records are loaded
            addSampleData()
        }
    }

    // Adds a new record and sorts the records by date
    func addRecord(_ record: Record) {
        records.append(record)
        records.sort { $0.date > $1.date } // Sort descending (newest first)
        saveRecords()
    }

    // Placeholder for loading records from persistence
    func loadRecords() {
        // In a real app, load from UserDefaults, CoreData, Realm, or a server
        // For now, we might load some sample data or start fresh
        print("DataStore: Load records (placeholder)")
        // Example: self.records = loadedRecords
    }

    // Placeholder for saving records to persistence
    func saveRecords() {
        // In a real app, save to UserDefaults, CoreData, Realm, or a server
        print("DataStore: Save records (placeholder)")
        // Example: save(self.records)
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
        records = Record.mockArray.sorted(by: { $0.date < $1.date }) // Ensure sample data is also sorted
    }
}
