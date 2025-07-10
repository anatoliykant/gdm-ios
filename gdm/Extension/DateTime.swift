//
//  DateTime.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-07.
//

import Foundation

extension Date {
    var stringDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
//        formatter.locale = Locale(identifier: "ru_RU") // FIXME: использовать другие локали
        return formatter.string(from: self)
    }
    
    var stringTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        // formatter.locale = .autoupdatingCurrent
//        formatter.locale = Locale(identifier: "en_US") // FIXME: использовать другие локали
        return formatter.string(from: self)
    }
}

var is12Hour: Bool {
    let fmt = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.autoupdatingCurrent) ?? ""
    debugPrint("Date format: \(fmt)")
    let isContains = fmt.contains("a")
    debugPrint("Is 12-hour format: \(isContains)")
    return isContains
}

let isLongTimeFormat = is12Hour// isAMPMFormat

//var isAMPMFormat: Bool {
//    let formatter = DateFormatter()
//    formatter.timeStyle = .short
//    // autoupdatingCurrent учтёт любые изменения в настройках «24-часовой формат»
//    formatter.locale = .autoupdatingCurrent
//    let formatString = formatter.dateFormat ?? ""
//    debugPrint("Date format: \(formatString)")
//    return formatString.contains("a")
//}

/// Indicates whether the current locale uses a 12-hour (AM/PM) clock
//var isAMPMFormat: Bool {
//    // "j" picks either h (12h) or H (24h) based on locale
//    let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current) ?? ""
//    return format.contains("a")
//}

//private var localizedTimeFormatter: DateFormatter {
//    let formatter = DateFormatter()
//    formatter.timeStyle = .short
//    formatter.locale = Locale.current
//    return formatter
//}
