////
////  RecordListView.swift
////  gdm
////
////  Created by Anatoliy Podkladov on 2025-06-19.
////
//
//
//import SwiftUI
//
//struct RecordListView: View {
//    // var groupedRecords: [Date: [Record]] = [:] // Example placeholder
//    var groupedRecords: [SugarSession] = [] // Example placeholder
//    
//    /*
//    func sessions(for day: Date) -> SugarSession? {
//        // Example placeholder
//        groupedRecords.first(where: { $0.date == day })
//    }
//    */
//    
//    var body: some View {
//        List {
//            ForEach(groupedRecords, id: \.id) { session in
//                let day = session.date
//                Section {
//                    
//                    ForEach(sessions(for: day)) { session in
//                        SessionRowView(session: session)
//                    }
//                    
//                    HStack {
//                        if !session.records.isEmpty {
//                            DailySummaryRow(records: session.records)
//                        }
//                        Spacer()
//                    }
//                } header: {
//                    HStack {
//                        Image(systemName: "calendar")
//                        dayHeader(for: day)
//                            .font(.system(size: 20, weight: .bold))
//                    }
//                    .foregroundColor(.primary)
//                }
//            }
//        }
//    }
//    
//    private func sessions(for day: Date) -> [SugarSession] {
//        let dayRecords = groupedRecords.first(where: { $0.date == day })?.records.sorted(by: { $0.date < $1.date }) ?? []
//        var sessions: [SugarSession] = []
//        var current: [Record] = []
//
//        for rec in dayRecords {
//            if current.isEmpty || (current.first?.food == nil && rec.food == nil) {
//                current.append(rec)
//            } else if rec.food != nil {
//                sessions.append(SugarSession(date: current.first!.date, records: current))
//                current = [rec]
//            } else {
//                current.append(rec)
//            }
//        }
//        if !current.isEmpty {
//            sessions.append(SugarSession(date: current.first!.date, records: current))
//        }
//        return sessions
//    }
//    
//    private func formatBreadUnits(_ value: Double) -> String {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 1
//        formatter.decimalSeparator = ","
//        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
//    }
//    
//    private func dayHeader(for date: Date) -> Text {
//        let formatter = DateFormatter()
////        formatter.locale = Locale(identifier: "ru_RU")
//        formatter.dateFormat = "d MMMM yyyy"
//        
//        if Calendar.current.isDateInToday(date) {
//            return Text("Сегодня, \(formatter.string(from: date))")
//        } else if Calendar.current.isDateInYesterday(date) {
//            return Text("Вчера, \(formatter.string(from: date))")
//        }
//        return Text(formatter.string(from: date))
//    }
//}
//
//#Preview {
//    RecordListView(groupedRecords: [
//        SugarSession(date: Date(), records: Record.mockArray)
//    ])
//}
//
////struct RecordListView: View {
////    @EnvironmentObject var dataStore: DataStore
////
////    @State private var groupedRecords: [Date: [Record]] = [:]
////
////    var body: some View {
////        List {
////            ForEach(groupedRecords.keys.sorted(by: >), id: \.self) { day in
////                Section(header: Text(day, style: .date)) {
////                    let sessions = sessions(for: groupedRecords[day] ?? [])
////                    ForEach(sessions, id: \.id) { session in
////                        SessionRowView(session: session)
////                    }
////
////                    if let recordsForDay = groupedRecords[day], !recordsForDay.isEmpty {
////                        HStack {
////                            Image(systemName: "croissant")
////                            Text("Всего \(formatBreadUnits(recordsForDay.compactMap { $0.breadUnits }.reduce(0, +))) ХЕ")
////                            Spacer()
////                            Image(systemName: "syringe.fill")
////                            Text("Всего \(recordsForDay.compactMap { $0.insulinUnits }.reduce(0, +)) ед.")
////                        }
////                        .font(.footnote)
////                        .padding(.vertical, 8)
////                    }
////                }
////            }
////        }
////        .onAppear(perform: groupRecords)
////        .onChange(of: dataStore.records) { _ in
////            groupRecords()
////        }
////    }
////
////    private func groupRecords() {
////        groupedRecords = Dictionary(grouping: dataStore.records) { record in
////            Calendar.current.startOfDay(for: record.date)
////        }
////    }
////
////    private func sessions(for records: [Record]) -> [Session] {
////        var sessions: [Session] = []
////        var currentSessionRecords: [Record] = []
////
////        for record in records.sorted(by: { $0.date < $1.date }) {
////            if let last = currentSessionRecords.last {
////                let diff = record.date.timeIntervalSince(last.date)
////                if diff > 2 * 3600 {
////                    sessions.append(Session(records: currentSessionRecords))
////                    currentSessionRecords = []
////                }
////            }
////            currentSessionRecords.append(record)
////        }
////
////        if !currentSessionRecords.isEmpty {
////            sessions.append(Session(records: currentSessionRecords))
////        }
////
////        return sessions
////    }
////
////    private func formatBreadUnits(_ value: Double) -> String {
////        let formatter = NumberFormatter()
////        formatter.minimumFractionDigits = 0
////        formatter.maximumFractionDigits = 1
////        formatter.decimalSeparator = ","
////        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
////    }
////}
