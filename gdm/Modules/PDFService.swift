//
//  PDFService.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-07.
//

import PDFKit

struct PDFService {
    
    private let dataStore: DataStore
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    func sharePDF() {
        let pdfData = generatePDF()
        //        shareItems = [pdfData]
        //        showShareSheet = true
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("SugarDiary.pdf")
        do {
            try pdfData.write(to: tempURL)
            ////            shareItems = [tempURL]
            ////            showShareSheet = true
            //            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            //            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            //               let rootVC = windowScene.windows.first?.rootViewController {
            //                rootVC.present(activityVC, animated: true)
            //            }
            
            let itemSource = PDFActivityItemSource(url: tempURL, data: pdfData, fileName: "SugarDiary.pdf")
            let activityVC = UIActivityViewController(activityItems: [itemSource], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch {
            assertionFailure("⛔️ Failed to write PDF to temp file: \(error)")
        }
    }
    
    private func generatePDF() -> Data {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { ctx in
            ctx.beginPage()
            var y: CGFloat = 20
            let left: CGFloat = 20
            let lineH: CGFloat = 20
            let sortedRecords = dataStore.records.sorted { $0.date < $1.date }
            for rec in sortedRecords {
                let dateStr = DateFormatter.localizedString(from: rec.date, dateStyle: .short, timeStyle: .short)
                let sugarVal = rec.sugarLevel ?? 0
                // Compute sugar color
                let prevRecord = dataStore.getPreviousRecord(before: rec.date)
                let isFirst = dataStore.isFirstSugarRecordOfDay(for: rec)
                let sugarUIColor: UIColor
                if isFirst {
                    sugarUIColor = sugarVal <= 5.0 ? .green : .red
                } else if let prev = prevRecord, prev.food != nil {
                    let hours = rec.date.timeIntervalSince(prev.date) / 3600
                    if hours >= 0.8 && hours < 1.8 {
                        sugarUIColor = sugarVal <= 7.0 ? .green : .red
                    } else if hours >= 1.8 && hours < 2.8 {
                        sugarUIColor = sugarVal <= 6.7 ? .green : .red
                    } else if hours >= 2.8 {
                        sugarUIColor = sugarVal <= 5.8 ? .green : .red
                    } else {
                        sugarUIColor = sugarVal <= 5.0 ? .green : .red
                    }
                } else {
                    sugarUIColor = sugarVal <= 5.0 ? .green : .red
                }
                // Prepare attributes
                let attrsDate: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label
                ]
                let sugarStr = String(format: "Сахар: %.1f", sugarVal)
                let attrsSugar: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: sugarUIColor
                ]
                let insulinUIColor: UIColor = {
                    switch rec.insulinType {
                    case .novorapid: return .orange
                    case .levemir:   return .blue
                    default:         return .gray
                    }
                }()
                let attrsInsulin: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: insulinUIColor
                ]
                let attrsNormal: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor.label
                ]
                // Build attributed line
                let lineText = NSMutableAttributedString(string: "\(dateStr) — ", attributes: attrsDate)
                // Sugar part
                lineText.append(NSAttributedString(string: sugarStr, attributes: attrsSugar))
                // Insulin part, if any
                if let insulinUnits = rec.insulinUnits, rec.insulinType != .none {
                    let insulinName = rec.insulinType.rawValue.capitalized
                    lineText.append(NSAttributedString(string: ", \(insulinName): \(insulinUnits) ед.", attributes: attrsInsulin))
                }
                // Bread units part, if any
                if let bu = rec.breadUnits {
                    let buStr = String(format: "%.1f", bu)
                    lineText.append(NSAttributedString(string: ", ХЕ: \(buStr)", attributes: attrsNormal))
                }
                // Draw
                lineText.draw(at: CGPoint(x: left, y: y))
                y += lineH
            }
        }
        return data
    }
    
    //    private func generatePDF() -> Data {
    //        let pdfMeta = [kCGPDFContextCreator: "Sugar Diary"]
    //        let format = UIGraphicsPDFRendererFormat()
    //        format.documentInfo = pdfMeta as [String: Any]
    //        let pageRect = CGRect(x: 0, y: 0, width: 8.5 * 72, height: 11 * 72)
    //        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    //        let data = renderer.pdfData { ctx in
    //            ctx.beginPage()
    //            var y: CGFloat = 20
    //            let left: CGFloat = 20
    //            let lineH: CGFloat = 20
    //            let titleAttrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    //            "Дневник сахара".draw(at: CGPoint(x: left, y: y), withAttributes: titleAttrs)
    //            y += lineH * 2
    //            let textAttrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
    //            for rec in dataStore.records {
    //                let dateStr = DateFormatter.localizedString(from: rec.date, dateStyle: .short, timeStyle: .short)
    //                let sugarStr = String(format: "Сахар: %.1f", rec.sugarLevel ?? 0)
    //                var details = sugarStr
    //                if let insulinUnits = rec.insulinUnits, rec.insulinType != .none {
    //                    // Добавляем тип и количество инсулина
    //                    let insulinName = rec.insulinType.rawValue.capitalized
    //                    details += ", \(insulinName): \(insulinUnits) ед."
    //                }
    //                if let bu = rec.breadUnits {
    //                    // Добавляем хлебные единицы
    //                    let buStr = String(format: "%.1f", bu)
    //                    details += ", ХЕ: \(buStr)"
    //                }
    //                let line = "\(dateStr) — \(details)\n"
    //                line.draw(at: CGPoint(x: left, y: y), withAttributes: textAttrs)
    //                y += lineH
    //            }
    //        }
    //        return data
    //    }
}
