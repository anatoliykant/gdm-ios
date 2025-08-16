//  RecordListView1.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 05.06.2025.
//

import SwiftUI

struct RecordListView1: View {
    @EnvironmentObject var dataStore: DataStore

    private var groupedRecords: [Date: [Record]] {
        Dictionary(grouping: dataStore.records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
    }

    // FIXME: use @Published and dynamic load
    private var sortedDays: [Date] {
        groupedRecords.keys.sorted(by: >)
    }

    var body: some View {
        List {
            ForEach(sortedDays, id: \.self) { day in
                Section(
                    header: dayHeaderView(for: day)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .accessibilityIdentifier("DayHeader-\(day.timeIntervalSince1970)"),
                    footer: dayResultFooterViewFor(day: day)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .accessibilityIdentifier("DayFooter-\(day.timeIntervalSince1970)")
                ) {
                    ForEach(sessions(for: day)) { session in
                        SessionRowView(session: session)
                             .listRowInsets(EdgeInsets())
                             .padding(.horizontal, 6)
                             .listRowSeparator(.hidden)
                             .accessibilityIdentifier("SessionRow-\(session.id)")
                    }
                    .padding(.top, 5)
                    .padding(.bottom, 6)
                }
                .accessibilityIdentifier("DaySection-\(day.timeIntervalSince1970)")
            }
        }
        .accessibilityIdentifier("RecordsList")
    }
    
    private func dayHeaderView(for day: Date) -> some View {
        HStack {
            Image(systemName: "calendar")
            dayHeaderText(for: day)
                .accessibilityIdentifier("DayHeaderText-\(day.timeIntervalSince1970)")
        }
    }
    
    // dayRecordsViewFor(day:) is no longer needed after refactor.
    
    private func dayResultFooterViewFor(day: Date) -> some View {
        Group {
            if let recordsForDay = groupedRecords[day], !recordsForDay.isEmpty {
                HStack(spacing: 10) {
                    
                    Spacer()
                    Text("Всего")
                    Image(systemName: "syringe.fill")
                    Text("**\(recordsForDay.compactMap { $0.insulinUnits }.reduce(0, +))** ед.")
                    
                    Image(systemName: "fork.knife")
                    Text("**\(formatBreadUnits(recordsForDay.compactMap { $0.breadUnits }.reduce(0, +)))** ХЕ")
                }
                .font(.callout)
            }
        }
    }

    private func dayHeaderText(for date: Date) -> Text {
        let formatter = DateFormatter()
        formatter.locale = Locale.autoupdatingCurrent // Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        
        if Calendar.current.isDateInToday(date) {
            return Text("Сегодня, \(formatter.string(from: date))")
            // FIXME: localization
        } else if Calendar.current.isDateInYesterday(date) {
            return Text("Вчера, \(formatter.string(from: date))") // FIXME: localization
        }
        return Text(formatter.string(from: date))
    }
    
    private func sessions(for day: Date) -> [SugarSession] {
        let dayRecords = groupedRecords[day]?.sorted(by: { $0.date < $1.date }) ?? []
        var sessions: [SugarSession] = []
        var current: [Record] = []

        for rec in dayRecords {
            if current.isEmpty || (current.first?.food == nil && rec.food == nil) {
                current.append(rec)
                    } else if rec.food != nil {
            if let firstRecord = current.first {
                sessions.append(SugarSession(date: firstRecord.date, records: current))
            }
            current = [rec]
        } else {
            current.append(rec)
        }
    }
    if !current.isEmpty {
        if let firstRecord = current.first {
            sessions.append(SugarSession(date: firstRecord.date, records: current))
        }
    }
        return sessions
    }
    
    private func formatBreadUnits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
    RecordListView1()
        .environmentObject(DataStore())
}

#Preview("RecordListView1 with mock data") {
    
    let day = Date()
    let sugarSession = [SugarSession(date: day, records: Record.mockArray), SugarSession(date: day, records: Record.mockArray)]
    
    ScrollView {
        VStack(spacing: 0) {
            ForEach(sugarSession) { session in
                SessionRowView(session: session)
            }
        }
    }
//    .padding(.horizontal, 16)
}

//private var groupedRecords: [Date: [Record]] {
//    Dictionary(grouping: dataStore.records) { record in
//        Calendar.current.startOfDay(for: record.date)
//    }
//}
//
//private func sessions(for day: Date) -> [SugarSession] {
//    let dayRecords = groupedRecords[day]?.sorted(by: { $0.date < $1.date }) ?? []
//    var sessions: [SugarSession] = []
//    var current: [Record] = []
//
//    for rec in dayRecords {
//        if current.isEmpty || (current.first?.food == nil && rec.food == nil) {
//            current.append(rec)
//        } else if rec.food != nil {
//            sessions.append(SugarSession(date: current.first!.date, records: current))
//            current = [rec]
//        } else {
//            current.append(rec)
//        }
//    }
//    if !current.isEmpty {
//        sessions.append(SugarSession(date: current.first!.date, records: current))
//    }
//    return sessions
//}
