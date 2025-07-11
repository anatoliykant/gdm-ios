//
//  RecordRowView.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 05.06.2025.
//

import SwiftUI

struct RecordRowView: View {
    let record: Record
    let previousRecord: Record?
    let isFirstSugarOfDay: Bool
    let isFirstInSession: Bool
    let isLastInSession: Bool
    
    private var sugarDisplayColor: Color {
        SugarColorLogic.color(for: record, previousRecord: previousRecord, isFirstSugarOfDay: isFirstSugarOfDay)
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 2) {
            
            timerIconAndRectangleView
//                .background(Color.blue)
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack(alignment: .top, spacing: 8) {
                    
                    Text(record.date, style: .time)
                    // Text(record.date.stringTime/*, style: .time*/)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(minWidth: isLongTimeFormat ? 55 : 35, alignment: .leading)
                    // .frame(width: 55, alignment: .leading)
                        .padding(.top, 4)
//                             .background(Color.yellow)
                    
                    if let sugar = record.sugarLevel {
                        HStack(spacing: 4) {
                            
                            Image(systemName: "drop.fill")
                                .foregroundColor(sugarDisplayColor.opacity(0.9))
                            
                            Text(String(format: "%.1f", sugar).replacingOccurrences(of: ".", with: ","))
                                .fontWeight(.bold)
                                .foregroundColor(sugarDisplayColor.opacity(0.9))
                            
                            //                            Spacer()
                        }
                        .frame(width: 50, alignment: .leading)
                        //                        .background(Color.orange)
                    } else {
                        Text("")
                            .frame(width: 50)
                    }
                    
                    if record.didTakeInsulin {
                        HStack(spacing: 4) {
                            Image(systemName: "syringe.fill")
                                .font(.caption)
                            Text(record.insulinType.rawValue) +
                            Text(" \(record.insulinUnits ?? 0) ед.").fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                        .padding(4)
                        .frame(width: 155, height: 24, alignment: .center)
                        .background(record.insulinType.color)
                        .cornerRadius(4)
                    }
                    
                    if let breadUnits = record.breadUnits, breadUnits > 0 {
                        HStack(spacing: 4) {
                            Text("\(Text(formatBreadUnits(breadUnits)).fontWeight(.bold)) ХЕ")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(4)
                        .frame(width: 50, height: 24, alignment: .center)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                    }
                    
                    Spacer()
                }
                // .padding(.bottom, 6)
                
                if let food = record.food {
                    Text(food)
                        .font(.subheadline)
                        .padding(.top, 4)
                    //                            .frame(maxWidth: .infinity, alignment: .leading)
//                                            .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
//                                            .layoutPriority(1)
                }
                //                .background(Color.yellow)
                
                //            if !session.records.compactMap({ $0.food }).isEmpty {
                //                Text(session.records.compactMap { $0.food }.joined(separator: ", "))
                //                    .font(.subheadline)
                //                    .padding(.top, 4)
                //            }
            }
//            .background(Color.red)
            .padding(.vertical, 2)
//            .background(Color.green)
            //            .background(Color.blue)
            
//             Spacer()
        }
        .frame(maxHeight: 130)
        .onAppear {
            debugPrint("isLongTimeFormat: \(isLongTimeFormat)")
        }
    }
    
    private var timerIconAndRectangleView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if isFirstInSession || isLastInSession {
                VStack(spacing: 0) {
                    
                    Image(systemName: "timer")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    //                            .background(Color.red)
                    
                    if record.food != nil {
                        Rectangle()
//                            .frame(maxHeight: .infinity)
                            .frame(width: 1)
                            // .foregroundColor(Color.red.opacity(0.5))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                }
//                .frame(maxHeight: .infinity)
                
            }
            //            if isFirstInSession || isLastInSession {
            //                VStack(spacing: 0) {
            //                    Image(systemName: "timer")
            //                        .font(.caption)
            //                        .foregroundColor(.gray)
            //                        .padding(.top, 8)
            //                    // Рисуем полосу во всех случаях
            //                    Rectangle()
            //                        .frame(width: 1)
            //                        .foregroundColor(Color.gray.opacity(0.5))
            //                        .frame(maxHeight: .infinity)
            //                }
            //            }
            else {
                Rectangle()
//                 .frame(maxHeight: .infinity)
                    .frame(width: 1)
                    // .foregroundColor(Color.orange.opacity(0.5))
                    .foregroundColor(Color.gray.opacity(0.5))
            }
        }
        .frame(width: 15)
    }
    
    //    var body: some View {
    //        HStack(alignment: .top, spacing: 10) {
    //
    //            VStack(alignment: .leading/*, spacing: 4*/) {
    //
    //                Image(systemName: "timer")
    //                    .font(.caption)
    //                    .foregroundColor(.gray)
    //
    //                Spacer()
    //
    //                Image(systemName: "timer")
    //                    .font(.caption)
    //                    .foregroundColor(.gray)
    //
    //            }
    //            .padding(.top, 5)
    //
    //            VStack(alignment: .leading) {
    //                HStack(alignment: .top) {
    //
    //                    Text(record.date, style: .time)
    //                        .font(.caption)
    //                        .foregroundColor(.gray)
    //
    //                    if let sugar = record.sugarLevel {
    //                        HStack(spacing: 4) {
    //                            Circle()
    //                                .fill(sugarDisplayColor)
    //                                .frame(width: 10, height: 10)
    //                            Text(String(format: "%.1f", sugar).replacingOccurrences(of: ".", with: ","))
    //                                .fontWeight(.bold)
    //                                .foregroundColor(sugarDisplayColor)
    //                        }
    //                    } else {
    //                        Text("-")
    //                            .foregroundColor(.gray)
    //                            .padding(.leading, 14)
    //                    }
    //
    //                    //                VStack(alignment: .leading, spacing: 4) {
    //                    if record.didTakeInsulin {
    //                        HStack(spacing: 4) {
    //                            Image(systemName: "syringe.fill")
    //                                .font(.caption)
    //                            Text(record.insulinType.rawValue) + Text(" \(record.insulinUnits ?? 0) ед.").fontWeight(.bold)
    //                            //                            .font(.caption)
    //                        }
    //                        .font(.system(size: 14))
    //                        .padding(4)
    //                        .background(Color.yellow.opacity(0.1))
    //                        .cornerRadius(4)
    //                    }
    //
    //                    if let breadUnits = record.breadUnits, breadUnits > 0 {
    //                        HStack(spacing: 4) {
    //                            //                        Image(systemName: "cube.fill") // FIXME: change icon
    //                            //                            .font(.caption)
    //                            //                            .foregroundColor(.brown.opacity(0.7))
    //                            Text("\(formatBreadUnits(breadUnits)) ХЕ")
    //                                .font(.system(size: 10, weight: .medium))
    //                            //                            .foregroundColor(.secondary)
    //                        }
    //                        .padding(4)
    //                        .background(Color.blue.opacity(0.1))
    //                        .cornerRadius(4)
    //                    }
    //                    //                }
    //                }
    //
    //
    //                if let food = record.food, !food.isEmpty {
    //                    HStack {
    //                        Text(food)
    //                            .font(.subheadline)
    //                    }
    //                }
    //
    //                HStack(spacing: 0) {
    //
    //                    Text(record.date, style: .time)
    //                        .font(.caption)
    //                        .foregroundColor(.gray)
    //
    //                    Spacer()
    //                }
    //                .padding(.top, 10)
    //
    //            }
    //
    //            Spacer()
    //        }
    //        .background(.red.opacity(0.8))
    //    }
    
    private func formatBreadUnits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
    RecordRowView(
        record: Record.mockArray[14],
        previousRecord: nil,
        isFirstSugarOfDay: true,
        isFirstInSession: true,
        isLastInSession: false
    )
    .padding(.horizontal, 16)
}

#Preview {

    let dataStore = DataStore()

    var sortedDays: [Date] {
        groupedRecords.keys.sorted(by: >)
    }
    
    var groupedRecords: [Date: [Record]] {
        Dictionary(grouping: dataStore.records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
    }
    
    ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
            
            ForEach(sortedDays, id: \.self) { day in
//                Section {
                    let sortedRecords = (groupedRecords[day] ?? []).sorted { $0.date < $1.date }
                    let firstSugarIndex = sortedRecords.firstIndex(where: { $0.sugarLevel != nil }) ?? 0
                    ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                        RecordRowView(
                            record: record,
                            previousRecord: nil,
                            // previousRecord: dataStore.getPreviousRecord(before: record.date),
                            // isFirstSugarOfDay: dataStore.isFirstSugarRecordOfDay(for: record),
                            isFirstSugarOfDay: index == firstSugarIndex, // dataStore.isFirstSugarRecordOfDay(for: record),
                            isFirstInSession: index == 0,
                            isLastInSession: sortedRecords.count == 1 || index == sortedRecords.count - 1
                        )
                    }
//                }
            }
        }
    }
    .padding(.horizontal)
    .environmentObject(dataStore)
    // выставляем американскую локаль
//    .environment(\.locale, Locale(identifier: "en_US"))
}

#Preview("RecordRowView") {
    let previewDataStore = DataStore()
    previewDataStore.records = []
    
    let calendar = Calendar.current
    let now = Date()
    
    let record1_first_of_day_fasting = Record(
        date: calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))!.addingTimeInterval(9*3600),
        sugarLevel: 4.8
    )
    
    let record2_food_insulin = Record(
        date: calendar.date(byAdding: .hour, value: -4, to: now)!,
        sugarLevel: 6.5,
        insulinType: .novorapid,
        insulinUnits: 4,
        food: "Завтрак: каша и фрукт. Это довольно длинное описание еды, чтобы проверить, как TextEditor будет обрабатывать несколько строк и перенос текста.",
        breadUnits: 3.0
    )
    previewDataStore.records.append(record2_food_insulin)
    
    let record3_sugar_after_1h_meal = Record(
        date: calendar.date(byAdding: .hour, value: -2, to: now)!,
        sugarLevel: 7.5
    )
    
    let record4_sugar_after_2h_meal = Record(
        date: calendar.date(byAdding: .hour, value: -1, to: now)!,
        sugarLevel: 5.5
    )
    
    // TODO:
    // 1. add records in data store
    // 2. add 2 more records to previewDataStore
    
    return VStack(alignment: .leading, spacing: 0) {
        
        // Натощак (первый за день)
        RecordRowView(
            record: record1_first_of_day_fasting,
            previousRecord: previewDataStore.getPreviousRecord(before: record1_first_of_day_fasting.date),
            isFirstSugarOfDay: previewDataStore.isFirstSugarRecordOfDay(for: record1_first_of_day_fasting),
            isFirstInSession: true,
            isLastInSession: true
        )
        .frame(maxHeight: 30)
        //        .background(Color(UIColor.blue.withAlphaComponent(0.1)))
        
        // Запись с едой (длинная)
        RecordRowView(
            record: record2_food_insulin,
            previousRecord: previewDataStore.getPreviousRecord(before: record2_food_insulin.date),
            isFirstSugarOfDay: previewDataStore.isFirstSugarRecordOfDay(for: record2_food_insulin),
            isFirstInSession: true,
            isLastInSession: false
        )
        // .frame(maxHeight: 130) // Ограничиваем высоту для длинного текста
        //        .background(Color(UIColor.gray.withAlphaComponent(0.1)))
        
        // Через 1 час после еды
        RecordRowView(
            record: record3_sugar_after_1h_meal,
            previousRecord: previewDataStore.getPreviousRecord(before: record3_sugar_after_1h_meal.date),
            isFirstSugarOfDay: previewDataStore.isFirstSugarRecordOfDay(for: record3_sugar_after_1h_meal),
            isFirstInSession: false,
            isLastInSession: false
        )
        .frame(maxHeight: 30)
        //        .background(Color(UIColor.green.withAlphaComponent(0.1)))
        
        // Через 2 часа после еды
        RecordRowView(
            record: record4_sugar_after_2h_meal,
            previousRecord: previewDataStore.getPreviousRecord(before: record4_sugar_after_2h_meal.date),
            isFirstSugarOfDay: previewDataStore.isFirstSugarRecordOfDay(for: record4_sugar_after_2h_meal),
            isFirstInSession: false,
            isLastInSession: true
        )
        .frame(maxHeight: 30)
        //        .background(Color(UIColor.red.withAlphaComponent(0.1)))
        
        Spacer()
        
    }
    .padding()
    .environmentObject(previewDataStore)
//    .environment(\.locale, Locale(identifier: "ru_RU"))
}

//struct RecordRowView: View {
//    let record: Record
//    let previousRecord: Record?
//    let isFirstSugarOfDay: Bool
//    let isFirstInSession: Bool = false
//
//    var body: some View {
//        HStack {
//            if isFirstInSession {
//                Image(systemName: "timer")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            } else {
//                Rectangle()
//                    .frame(width: 1, height: 24)
//                    .foregroundColor(Color.gray.opacity(0.5))
//            }
//
//            Text(record.date, style: .time)
//                .font(.caption)
//                .foregroundColor(.gray)
//                .frame(width: 40)
//
//            // ... other UI elements
//        }
//    }
//}
