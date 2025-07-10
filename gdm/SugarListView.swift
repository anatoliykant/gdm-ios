//
//  SugarListView.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import SwiftUI

// MARK: - Models
struct DiaryEntry: Equatable, Identifiable {
    let id = UUID()
    let time: String
    let bloodSugar: Double?
    let insulin: InsulinInfo?
    let breadUnits: Double?
    let description: String?
    let bloodSugarColor: Color
}

struct InsulinInfo: Equatable {
    let type: String // "Новорапид" или "Левемир"
    let units: Int
}

struct DayEntry: Equatable {
    let date: String
    let entries: [DiaryEntry]
    let totalBreadUnits: Double
    let totalInsulinUnits: Int
}

// MARK: - Main View
struct DiabetesDiaryView: View {
    let days: [DayEntry] = [
        DayEntry(
            date: "6 мая 2025",
            entries: [
                DiaryEntry(
                    time: "15:00",
                    bloodSugar: 6.3,
                    insulin: nil,
                    breadUnits: nil,
                    description: "(кабачок, огурец, авокадо, маш, зеленый салат)",
                    bloodSugarColor: .green
                ),
                DiaryEntry(
                    time: "16:40",
                    bloodSugar: nil,
                    insulin: nil,
                    breadUnits: 1,
                    description: "Хлеб житный из вв 1 кусок, масло, сыр, вареное яйцо, зеленый салат",
                    bloodSugarColor: .green
                ),
                DiaryEntry(
                    time: "17:40",
                    bloodSugar: 5.6,
                    insulin: nil,
                    breadUnits: nil,
                    description: nil,
                    bloodSugarColor: .green
                ),
                DiaryEntry(
                    time: "20:00",
                    bloodSugar: 5.3,
                    insulin: InsulinInfo(type: "Новорапид", units: 8),
                    breadUnits: 3.5,
                    description: "Киноа 100г, тушенная говядина, вафля (льняная мука, кефир, яйцо), сулини из вв, огурец, помидоры черри, зеленый салат",
                    bloodSugarColor: .green
                ),
                DiaryEntry(
                    time: "21:00",
                    bloodSugar: 6.2,
                    insulin: nil,
                    breadUnits: nil,
                    description: nil,
                    bloodSugarColor: .green
                ),
                DiaryEntry(
                    time: "22:00",
                    bloodSugar: nil,
                    insulin: nil,
                    breadUnits: 1,
                    description: "ряженка 1 стакан",
                    bloodSugarColor: .green
                ),
                DiaryEntry(
                    time: "23:59",
                    bloodSugar: 6,
                    insulin: InsulinInfo(type: "Левемир", units: 16),
                    breadUnits: nil,
                    description: nil,
                    bloodSugarColor: .green
                )
            ],
            totalBreadUnits: 12,
            totalInsulinUnits: 40
        ),
        DayEntry(
            date: "6 мая 2025",
            entries: [
                DiaryEntry(
                    time: "09:20",
                    bloodSugar: 5.2,
                    insulin: InsulinInfo(type: "Новорапид", units: 8),
                    breadUnits: 2.5,
                    description: "Хлеб житный из вв 1.5 куска, ветчина из вв, огурец, салат ромэн, кофе со сливками",
                    bloodSugarColor: .red
                ),
                DiaryEntry(
                    time: "10:20",
                    bloodSugar: 7.8,
                    insulin: InsulinInfo(type: "Новорапид", units: 1),
                    breadUnits: nil,
                    description: nil,
                    bloodSugarColor: .red
                ),
                DiaryEntry(
                    time: "11:20",
                    bloodSugar: 6.2,
                    insulin: nil,
                    breadUnits: nil,
                    description: nil,
                    bloodSugarColor: .green
                )
            ],
            totalBreadUnits: 2.5,
            totalInsulinUnits: 9
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(days.indices, id: \.self) { dayIndex in
                        DaySection(days: days, dayIndex: dayIndex)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// MARK: - Day Section
struct DaySection: View {
    let days: [DayEntry]
    let dayIndex: Int
    private var day: DayEntry {
        days[dayIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Entries
            VStack(spacing: 0) {
                ForEach(day.entries.indices, id: \.self) { index in
                    EntryRow(entry: day.entries[index])
                    
                    if index < day.entries.count - 1 {
                        Divider()
                            .padding(.leading, 16)
                    }
                }
            }
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            
            // Summary
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                    Text("Всего \(Int(day.totalBreadUnits))XE")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    Text("Всего \(day.totalInsulinUnits) ед.")
                        .font(.footnote)
                        .fontWeight(.medium)
                }
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 32)
            .padding(.vertical, 12)
            
            // Date header for next day
            if day == days.last {
                DateHeaderView(date: day.date)
                    .padding(.top, 20)
            }
        }
    }
}

// MARK: - Entry Row
struct EntryRow: View {
    let entry: DiaryEntry
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Time
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(entry.time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Blood sugar indicator
                if let bloodSugar = entry.bloodSugar {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(entry.bloodSugarColor)
                            .frame(width: 8, height: 8)
                        
                        Text("\(bloodSugar, specifier: "%.1f")")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
            }
            .frame(width: 50, alignment: .leading)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Insulin info
                    if let insulin = entry.insulin {
                        HStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text("\(insulin.type) \(insulin.units) ед.")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Bread units
                    if let breadUnits = entry.breadUnits {
                        Text("\(breadUnits, specifier: "%.1f") XE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    // Menu button
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Description
                if let description = entry.description {
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Date Header
struct DateHeaderView: View {
    let date: String
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                
                Text(date)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal, 16)
    }
}

// MARK: - Preview
struct DiabetesDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiabetesDiaryView()
    }
}
