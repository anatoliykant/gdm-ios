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
    
    // MARK: - Lifecycle

    var body: some View {
        VStack(spacing: 16) {
            // Header
            headerView
                .accessibilityIdentifier("InputViewTitle")
            
            // Date and Time Row
            HStack(spacing: 12) {
                simpleFieldView(
                    icon: "calendar",
                    title: "Дата",
                    content: {
                        ZStack {
                            Text(date.stringDate)
                                .font(.body)
                            
                            DatePicker("Дата", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorMultiply(.clear)
                                .labelsHidden()
                        }
                    }
                )
                .accessibilityIdentifier("DatePicker")
                
                simpleFieldView(
                    icon: "clock",
                    title: "Время",
                    content: {
                        ZStack {
                            Text(date.stringTime)
                                .font(.body)
                            
                            DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .colorMultiply(.clear)
                                .labelsHidden()
                        }
                    }
                )
                .accessibilityIdentifier("TimePicker")
            }
            
            // Sugar Level
            simpleFieldView(
                icon: "drop",
                title: "Сахар (ммоль/л)",
                content: {
                    TextField("Например: 5.2", text: $sugarString)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .sugar)
                        .font(.body)
                        .accessibilityIdentifier("SugarInputField")
                }
            )
            .accessibilityIdentifier("SugarInputView")
            
            // Meal Type (if needed)
            simpleFieldView(
                icon: "fork.knife",
                title: "Что было в меню",
                content: {
                    TextField("Описание еды", text: $foodDescription)
                        .focused($focusedField, equals: .food)
                        .font(.body)
                        .accessibilityIdentifier("FoodDescriptionField")
                }
            )
            .accessibilityIdentifier("FoodDescriptionView")
            
            // Bread Units (only if food entered)
            if isFoodEntered {
                simpleFieldView(
                    icon: "square.grid.3x3",
                    title: "ХЕ",
                    content: {
                        HStack {
                            TextField("0", text: $breadUnitsString)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .breadUnits)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .frame(width: 60)
                            
                            Spacer()
                            
                            Stepper(
                                "",
                                value: Binding(
                                    get: { Double(breadUnitsString) ?? 1.0 },
                                    set: { breadUnitsString = String($0) }
                                ),
                                in: 0...10,
                                step: 0.5
                            )
                            .labelsHidden()
                        }
                    }
                )
                .transition(.move(edge: .top).combined(with: .opacity))
                .accessibilityIdentifier("BreadUnitsView")
            }
            
            // Insulin Row
            HStack(spacing: 12) {
                simpleFieldView(
                    icon: "syringe",
                    title: "Инсулин",
                    content: {
                        Picker("Тип инсулина", selection: $selectedInsulinType) {
                            ForEach(InsulinType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.body)
                    }
                )
                
                if selectedInsulinType != .none {
                    simpleFieldView(
                        icon: "",
                        title: "",
                        content: {
                            HStack {
                                TextField("0", text: $insulinUnitsString)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .insulinUnits)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60)
                                
                                Spacer()
                                
                                Stepper(
                                    "",
                                    value: Binding(
                                        get: { Int(insulinUnitsString) ?? 7 },
                                        set: { insulinUnitsString = String($0) }
                                    ),
                                    in: 1...100
                                )
                                .labelsHidden()
                            }
                        }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .accessibilityIdentifier("InsulinRow")
            
            // Reminder (if needed)
            simpleFieldView(
                icon: "bell",
                title: "Напоминание",
                content: {
                    Text("Настроить позже")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            )
            
            Spacer()
            
            // Simple Add Button
            simpleAddButton
                .accessibilityIdentifier("AddRecordButton")
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("InputView")
        .background(Color(.systemBackground))
        .animation(.easeInOut(duration: 0.3), value: foodDescription.isEmpty)
        .animation(.easeInOut(duration: 0.3), value: selectedInsulinType)
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
                        focusedField = nil
                    }
                    .font(.body.weight(.medium))
                    .foregroundColor(.accentColor)
                    .accessibilityIdentifier("KeyboardDoneButton")
                }
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        Text("Новая запись")
            .font(.title2.bold())
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Simple Field View
    
    @ViewBuilder
    private func simpleFieldView<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            if !icon.isEmpty {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
            }
            
            if !title.isEmpty {
                Text(title)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 60, alignment: .leading)
            }
            
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Simple Add Button
    
    private var simpleAddButton: some View {
        Button(action: addRecord) {
            Text("Добавить")
                .font(.body.weight(.semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black)
                .cornerRadius(12)
        }
        .disabled(sugarString.isEmpty)
        .opacity(sugarString.isEmpty ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: sugarString.isEmpty)
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

        if selectedInsulinType != .none {
            guard let insulinUnits = units, insulinUnits >= 0 else {
                print("Validation: Insulin units must be non-negative if insulin type is selected.")
                return
            }
        }
        
        if isFoodEntered {
            guard let breadUnits = bu, breadUnits >= 0 else {
                print("Validation: Bread units must be non-negative if food is entered.")
                return
            }
        }

        let newRecord = Record(
            date: date,
            sugarLevel: sugarVal,
            insulinType: selectedInsulinType,
            insulinUnits: units,
            food: isFoodEntered ? foodDescription.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            breadUnits: bu
        )
        
        let result = dataStore.addRecordSafely(newRecord)
        if result.isSuccess {
            clearInputFields()
            focusedField = nil
            dismiss()
        } else {
            // TODO: Показать ошибку пользователю
            print("Ошибка валидации: \(result.errorMessage ?? "Неизвестная ошибка")")
        }
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
