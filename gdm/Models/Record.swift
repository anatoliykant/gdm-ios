//
//  Record.swift
//

import SwiftUI

struct Record: Identifiable, Hashable {
    let id = UUID()
    var date: Date = Date()
    var sugarLevel: Double? = nil
    /// Insulin type and units
    var insulinType: InsulinType = .novorapid
    /// Default units if insulin is selected
    var insulinUnits: Int? = 7
    var food: String? = nil
    /// Bread units (ХЕ - хлебные единицы)
    var breadUnits: Double? = nil

    // Computed property to check if insulin was administered
    var didTakeInsulin: Bool {
        return insulinType != .none && insulinUnits != nil && insulinUnits! > 0
    }
}

extension Record {
    static var mockArray: [Record] = {
        let calendar = Calendar.current
        let today = Date()
        // let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        return [
            
            // MARK: Today
            // Morning
            Record(date: calendar.date(byAdding: .hour, value: -19, to: today)!, sugarLevel: 5.1, insulinType: .none),
            
            // Завтрак
            // замер перед едой, сразу прием пиши + учет ХЕ, укол инсулина
            Record(date: calendar.date(byAdding: .hour, value: -18, to: today)!, sugarLevel: 5.0, insulinType: .novorapid, insulinUnits: 7, food: "Хлеб Житный из вв 1 кусок, масло, сыр, вареное яйцо, зеленый салат", breadUnits: 6.0),
            // Через 1 час после еды замер сахара и при необходимости инсулин (почти всегда)
            Record(date: calendar.date(byAdding: .hour, value: -17, to: today)!, sugarLevel: 6.2, insulinType: .novorapid, insulinUnits: 1),
            // Через 2 час контрольный замер для построения кривой для врача (первые несколько дней, чтобы разобраться в дозах)
            Record(date: calendar.date(byAdding: .hour, value: -16, to: today)!, sugarLevel: 5.1, insulinType: .none),
            // Через 3 час контрольный замер для построения кривой для врача (первые несколько дней, чтобы разобраться в дозах)
            Record(date: calendar.date(byAdding: .hour, value: -15, to: today)!, sugarLevel: 4.8, insulinType: .none),
            
            // Обед
            // замер перед едой, сразу прием пиши + учет ХЕ, укол инсулина
            Record(date: calendar.date(byAdding: .hour, value: -13, to: today)!, sugarLevel: 4.7, insulinType: .novorapid, insulinUnits: 8, food: "Хлеб Бородинский из вв 2 куска, масло, суп тыквенный, брусничный морс без сахара", breadUnits: 8.0),
            // Через 1 час после еды замер сахара и при необходимости инсулин (почти всегда)
            Record(date: calendar.date(byAdding: .hour, value: -12, to: today)!, sugarLevel: 6.0, insulinType: .novorapid, insulinUnits: 2),
            // Через 2 час контрольный замер для построения кривой для врача (первые несколько дней, чтобы разобраться в дозах)
            Record(date: calendar.date(byAdding: .hour, value: -11, to: today)!, sugarLevel: 5.0, insulinType: .none),
            // Через 3 час контрольный замер для построения кривой для врача (первые несколько дней, чтобы разобраться в дозах)
            Record(date: calendar.date(byAdding: .hour, value: -10, to: today)!, sugarLevel: 4.6, insulinType: .none),
            
            // Ужин
            // замер перед едой, сразу прием пиши + учет ХЕ, укол инсулина
            Record(date: calendar.date(byAdding: .hour, value: -8, to: today)!, sugarLevel: 4.3, insulinType: .novorapid, insulinUnits: 8, food: "Хлебцы без глютена 2 куска, масло, тушеные овощи с говядиной, свежий огурец, черный чай без сахара", breadUnits: 5.0),
            // Через 1 час после еды замер сахара и при необходимости инсулин
            Record(date: calendar.date(byAdding: .hour, value: -7, to: today)!, sugarLevel: 5.4, insulinType: .none),
            // Через 2 час контрольный замер для построения кривой для врача (первые несколько дней, чтобы разобраться в дозах)
            Record(date: calendar.date(byAdding: .hour, value: -6, to: today)!, sugarLevel: 5.1, insulinType: .none),
            // Через 3 час контрольный замер для построения кривой для врача (первые несколько дней, чтобы разобраться в дозах)
            Record(date: calendar.date(byAdding: .hour, value: -5, to: today)!, sugarLevel: 4.8, insulinType: .none),
            
            // Паужин
            // Легкий перекус перед сном – кефир/ряженка
            // TODO: добавить паужин и ночной укол инсулина
            
            // MARK: Yesterday
            // Утро
//            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 5, minute: 30, second: 0, of: today)!)!, sugarLevel: 5.2, insulinType: .none), // No XE specified
//            // Завтрак – fixme
//            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 6, minute: 30, second: 0, of: today)!)!, sugarLevel: 5.1, food: "Лёгкий салат (кабачок, огурец, авокадо, маш, зеленый салат)", breadUnits: 1.0),
//            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 7, minute: 0, second: 0, of: today)!)!, sugarLevel: 6.3),
//            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today)!)!, sugarLevel: 5.6),
//            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today)!)!, sugarLevel: 5.0),
            
            // TODO: добавить обед
            
            // Ужин
            Record(
                date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 20, minute: 50, second: 0, of: today)!)!,
                sugarLevel: 5.0,
                insulinType: .novorapid,
                insulinUnits: 8,
                food: "Киноа 100г, тушенная говядина, вафля (льняная мука, кефир, яйцо), сулини из вв, огурец, помидоры черри, зеленый салат",
                breadUnits: 3.5
            ),
            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 21, minute: 50, second: 0, of: today)!)!, sugarLevel: 4.5, insulinType: .none),
            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 22, minute: 50, second: 0, of: today)!)!, insulinType: .novorapid, insulinUnits: 1, food: "ряженка 1 стакан", breadUnits: 1.0),
            Record(date: calendar.date(byAdding: .day, value: -1, to: calendar.date(bySettingHour: 23, minute: 59, second: 0, of: today)!)!, sugarLevel: 6.0, insulinType: .levemir, insulinUnits: 16),
            
            // MARK: Day before yesterday's records
            // Утро
            Record(date: calendar.date(byAdding: .day, value: -2, to: calendar.date(bySettingHour: 7, minute: 10, second: 0, of: today)!)!, sugarLevel: 5.7),
            Record(date: calendar.date(byAdding: .day, value: -2, to: calendar.date(bySettingHour: 8, minute: 10, second: 0, of: today)!)!, sugarLevel: 5.9, insulinType: .novorapid, insulinUnits: 6, food: "Курица с овощами", breadUnits: 2.5),
            Record(date: calendar.date(byAdding: .day, value: -2, to: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: today)!)!, sugarLevel: 6.5, insulinType: .none),
            // Record(date: calendar.date(byAdding: .day, value: -2, to: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today)!)!, food: "Овсянка с ягодами", breadUnits: 2.0),
            Record(date: calendar.date(byAdding: .day, value: -2, to: calendar.date(bySettingHour: 10, minute: 10, second: 0, of: today)!)!, sugarLevel: 5.0, insulinType: .none),
            
            // Ужин
            Record(date: calendar.date(byAdding: .day, value: -2, to: calendar.date(bySettingHour: 23, minute: 59, second: 0, of: today)!)!, sugarLevel: 4.8, insulinType: .levemir, insulinUnits: 14),
        ]
    }()
    static var mockArray2: [Record] = {
        let calendar = Calendar.current
        let today = Date()
        return [
            Record(date: calendar.date(byAdding: .hour, value: -1, to: today)!, sugarLevel: 5.5, insulinType: .novorapid, insulinUnits: 3, food: "Яблоко", breadUnits: 1.0),
            Record(date: calendar.date(byAdding: .hour, value: -2, to: today)!, sugarLevel: 6.0, insulinType: .levemir, insulinUnits: 4, food: "Груша", breadUnits: 2.0),
            Record(date: calendar.date(byAdding: .hour, value: -3, to: today)!, sugarLevel: 7.0, insulinType: .none, insulinUnits: nil, food: "Хлеб", breadUnits: 3.0)
        ]
    }()
}
