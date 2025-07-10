//
//  DailySummaryRow.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 07.06.2025.
//

import SwiftUI

//struct DailySummaryRow: View {
//    let records: [Record]
//
//    private var totalBreadUnits: Double {
//        records.reduce(0) { $0 + ($1.breadUnits ?? 0) }
//    }
//
//    private var totalInsulinUnits: Int {
//        records.reduce(0) { $0 + ($1.insulinType != .none ? ($1.insulinUnits ?? 0) : 0) }
//    }
//
//    var body: some View {
//        HStack(spacing: 0) {
//            
//            Spacer()
//            
//            if totalInsulinUnits > 0 {
//                Image(systemName: "syringe.fill")
//                    // .padding(.leading, totalBreadUnits > 0 ? 20 : 0)
////                    .padding(.leading, 25)
//                    .padding(.trailing, 3)
//                Text("Всего \(totalInsulinUnits) ед.")
//                // .padding(.leading, totalBreadUnits > 0 ? 10 : 0)
//            }
//            
//            if totalBreadUnits > 0 {
//                Image(systemName: "fork.knife")
//                    .padding(.trailing, 5)
//                    .padding(.leading, 10)
//                Text("Всего \(formatBreadUnits(totalBreadUnits)) ХЕ")
//            }
//            
////            Spacer()
//        }
//        .foregroundColor(.black)
//        //        .padding(.vertical, 4)
//        //        .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
//        .frame(maxWidth: .infinity, alignment: .center)
//    }
//    
//    private func formatBreadUnits(_ value: Double) -> String {
//        let formatter = NumberFormatter()
//        formatter.minimumFractionDigits = 0
//        formatter.maximumFractionDigits = 1
//        formatter.decimalSeparator = ","
//        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
//    }
//}
//
//#Preview {
//    DailySummaryRow(records: [
//        Record(date: Date(), sugarLevel: 5.5, insulinType: .novorapid, insulinUnits: 2, food: "Яблоко", breadUnits: 1.5),
//        Record(date: Date(), sugarLevel: 6.0, insulinType: .levemir, insulinUnits: 3, food: "Груша", breadUnits: 2.0),
//        Record(date: Date(), sugarLevel: 7.0, insulinType: .none, insulinUnits: nil, food: "Хлеб", breadUnits: 3.0)
//    ])
//    .padding()
//}
