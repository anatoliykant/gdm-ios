//
//  SessionRowView.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-07.
//

import SwiftUI

struct SessionRowView: View {
    let session: SugarSession

    var body: some View {
//        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                let firstSugarIndex = session.records.firstIndex(where: { $0.sugarLevel != nil }) ?? 0
                ForEach(Array(session.records.enumerated()), id: \.element.id) { index, record in
                    RecordRowView(
                        record: record,
                        previousRecord: nil,
                        isFirstSugarOfDay: index == firstSugarIndex,
                        isFirstInSession: index == 0,
                        isLastInSession: session.records.count == 1 || index == session.records.count - 1
                    )
                    //                .frame(height: 150)
                }
            }
            //            .padding(.horizontal)
            //        }
            //        .frame(maxWidth: .infinity, alignment: .leading)
            //        .padding(.horizontal)
            //        .cornerRadius(8)
//        }
    }
}

#Preview {
    let sessions = SugarSession.mockArray
    ScrollView {
        VStack {
            ForEach(sessions) { session in
                SessionRowView(session: session)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

//struct SessionRowView: View {
//    let session: SugarSession
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(Array(session.records.enumerated()), id: \.element.id) { index, record in
//                RecordRowView(
//                    record: record,
//                    previousRecord: nil,
//                    isFirstSugarOfDay: false,
//                    isFirstInSession: index == 0
//                )
//            }
//
//            if !session.records.compactMap({ $0.food }).isEmpty {
//                Text(session.records.compactMap { $0.food }.joined(separator: ", "))
//                    .font(.subheadline)
//                    .padding(.top, 4)
//            }
//        }
//    }
//}

//struct SessionRowView: View {
//    let session: Session
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            ForEach(Array(session.records.enumerated()), id: \.element.id) { index, record in
//                RecordRowView(
//                    record: record,
//                    previousRecord: nil,
//                    isFirstSugarOfDay: false,
//                    isFirstInSession: index == 0
//                )
//            }
//            if !session.records.compactMap({ $0.food }).isEmpty {
//                Text(session.records.compactMap { $0.food }.joined(separator: ", "))
//                    .font(.subheadline)
//                    .padding(.top, 4)
//            }
//        }
//    }
//}
//
//struct Session: Identifiable {
//    let id = UUID()
//    let records: [Record]
//}
