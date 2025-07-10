//
//  InputView.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import SwiftUI

struct InputView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Private properties

    @State private var date: Date = Date()
    @State private var sugarString: String = ""
    @State private var selectedInsulinType: InsulinType = .novorapid
    @State private var insulinUnitsString: String = "7"
    @State private var foodDescription: String = ""
    @State private var breadUnitsString: String = "1.0"

    @FocusState private var focusedField: FocusableField?
    
    private var isFoodEntered: Bool {
        !foodDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Model

    private enum FocusableField: Hashable {
        case sugar, insulinUnits, food, breadUnits
    }
    
//    init(
//        date: Date = Date(),
//        sugarString: String = "",
//        selectedInsulinType: InsulinType = .novorapid,
//        insulinUnitsString: String = "7",
//        foodDescription: String = "",
//        breadUnitsString: String = "1.0"
//    ) {
//        self.date = date
//        self.sugarString = sugarString
//        self.selectedInsulinType = selectedInsulinType
//        self.insulinUnitsString = insulinUnitsString
//        self.foodDescription = foodDescription
//    }
    
    // MARK: - Lifecycle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            title
            
            dateView
            
            timeView

            sugarInputView

            insulinRow

            foodDescriptionView
            
            breadUnitsView()
            
            addButton
            
            Spacer()
            
        }
        .animation(.easeInOut, value: foodDescription.isEmpty)
        .padding(.all, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onChange(of: selectedInsulinType) { newValue in
            if newValue == .none {
                insulinUnitsString = "0"
            } else if insulinUnitsString == "0" || insulinUnitsString.isEmpty {
                 insulinUnitsString = "7"
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Готово") {
                        focusedField = nil // This will attempt to dismiss keyboard
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var title: some View {
        Text("Добавить запись")
            .font(.title)
            .fontWeight(.semibold)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .center)
    }
     
    private var dateView: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "calendar")
                .foregroundColor(.gray.opacity(0.9))
                .frame(width: 24, height: 24)
            
            ZStack {
                
                Text(date.stringDate)
                    
                DatePicker("Дата", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .colorMultiply(.clear)
                    .labelsHidden()
                    .background(Color.clear)
            }
            .frame(minWidth: 150)
            .frame(height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
            )
            
            Spacer()
        }
    }
    
    private var timeView: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "clock")
                .foregroundColor(.gray.opacity(0.9))
                .frame(width: 24, height: 24)
            
            ZStack {
                
                Text(date.stringTime)
                
                DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .colorMultiply(.clear)
                    .labelsHidden()
                    .background(Color.clear)
            }
            .frame(width: 85, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
            )
            
            Spacer()
        }
    }
    
    private var sugarInputView: some View {
        HStack(spacing: 16) {
            
            Image(systemName: "drop")
                .foregroundColor(.gray.opacity(0.9))
                .frame(width: 24, height: 24)
            
            TextField("Сахар (ммоль/л)", text: $sugarString)
                .keyboardType(.decimalPad)
                .focused($focusedField, equals: .sugar)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                )
        }
    }
    
    private var insulinRow: some View {
        HStack(spacing: 0) {
            Image(systemName: "syringe")
                .foregroundColor(.gray.opacity(0.9))
                .padding(.trailing, 16)
            
            Picker("Инсулин", selection: $selectedInsulinType) {
                ForEach(InsulinType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
            .accentColor(Color.primary)
            .pickerStyle(.menu)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.6), lineWidth: 1)
            )
            
            
            Spacer()
            
            if selectedInsulinType != .none {
                Group {
                    TextField("ХЕ", text: $insulinUnitsString)
                        .frame(width: 21)
                        .multilineTextAlignment(.center)
                    
                    Stepper(
                        "",
                        value: Binding(
                            get: { Int(insulinUnitsString) ?? 7 },
                            set: { insulinUnitsString = String($0) }
                        ),
                        in: 1...100
                    )
                    .frame(width: 100)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            
        }
        .animation(.easeInOut, value: selectedInsulinType)
    }
    
    private var foodDescriptionView: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "fork.knife")
                .foregroundColor(.gray.opacity(0.9))
                .frame(width: 24, height: 24)
                .padding(.top, 8)
            
            ZStack(alignment: .topLeading) {
                
                ClearTextEditor(text: $foodDescription)
                    .padding(.horizontal, 8)
                    .focused($focusedField, equals: .food)
                // обёртка сама рисует фон, поэтому дополнительных background() не надо
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .frame(height: 200)
                
                if foodDescription.isEmpty {
                    Text("Еда (описание)")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.leading, 11) // Standard TextEditor padding
                        .padding(.top, 8) // Standard TextEditor padding
                }
                // The general keyboard toolbar "Done" button should still work.
            }
        }
    }
    
    @ViewBuilder
    private func breadUnitsView() -> some View {
        if !foodDescription.isEmpty {
            HStack(spacing: 0) {
                
                Text("ХЕ")
                    .font(.headline)
                    .foregroundColor(.gray.opacity(0.9))
                    .padding(.leading, 4)
                    .padding(.trailing, 20)
                
                TextField("ХЕ", text: $breadUnitsString)
                    .frame(width: 35)
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: .breadUnits)
                
                Stepper(
                    "",
                    value: Binding(
                        get: { Double(breadUnitsString) ?? 1.0 },
                        set: { breadUnitsString = String($0) }
                    ),
                    in: 0...10,
                    step: 0.5
                )
                .frame(width: 100)
                
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
        
    }
    
    private var addButton: some View {
        Button(action: addRecord) {
            Text("Добавить")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.primary.opacity(sugarString.isEmpty ? 0.5 : 1))
                .foregroundColor(Color(.systemBackground))
                .cornerRadius(10)
        }
        .disabled(!sugarString.isEmpty)
    }
        
    private func formatBreadUnits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.decimalSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func addRecord() {
        let sugarVal = Double(sugarString.replacingOccurrences(of: ",", with: "."))
        let units = selectedInsulinType == .none ? nil : Int(insulinUnitsString)
        let bu = isFoodEntered ? Double(breadUnitsString.replacingOccurrences(of: ",", with: ".")) : nil

        if selectedInsulinType != .none && (units == nil || units! < 0) {
            print("Validation: Insulin units must be non-negative if insulin type is selected.")
            return
        }
        
        if isFoodEntered && (bu == nil || bu! < 0) {
             print("Validation: Bread units must be non-negative if food is entered.")
            return
        }

        let newRecord = Record(
            date: date,
            sugarLevel: sugarVal,
            insulinType: selectedInsulinType,
            insulinUnits: units,
            food: isFoodEntered ? foodDescription.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            breadUnits: bu
        )
        dataStore.addRecord(newRecord)
        clearInputFields()
        focusedField = nil
        dismiss()
    }

    private func clearInputFields() {
        date = Date()
        sugarString = ""
        foodDescription = ""
    }
}

#Preview("InputView") {
    NavigationView {
        InputView()
            .padding()
            .background(Color.gray.opacity(0.1))
            .environmentObject(DataStore())
            .environment(\.locale, Locale(identifier: "ru_RU"))
    }
}
