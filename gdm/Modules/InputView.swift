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
        ScrollView {
            VStack(spacing: 20) {
                // Header
                headerView
                    .accessibilityIdentifier("InputViewTitle")
                
                // Main Content Cards
                VStack(spacing: 16) {
                    // Basic Info Card
                    basicInfoCard
                        .accessibilityIdentifier("BasicInfoCard")
                    
                    // Insulin Card
                    insulinCard
                        .accessibilityIdentifier("InsulinCard")
                    
                    // Food Card
                    foodCard
                        .accessibilityIdentifier("FoodCard")
                }
                
                // Add Button
                modernAddButton
                    .accessibilityIdentifier("AddRecordButton")
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("InputView")
        .background(Color(.systemGroupedBackground))
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
        VStack(spacing: 8) {
            Text("Добавить запись")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Заполните данные о замере")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }
    
    // MARK: - Basic Info Card
    
    private var basicInfoCard: some View {
        CardView(title: "Основные данные", icon: "calendar.badge.clock") {
            VStack(spacing: 16) {
                // Date and Time Row
                HStack(spacing: 12) {
                    // Date
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Дата", systemImage: "calendar")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Text(date.stringDate)
                                .font(.body.weight(.medium))
                            
                            DatePicker("Дата", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorMultiply(.clear)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityIdentifier("DatePicker")
                    }
                    
                    // Time
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Время", systemImage: "clock")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            Text(date.stringTime)
                                .font(.body.weight(.medium))
                            
                            DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                                .colorMultiply(.clear)
                                .labelsHidden()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .accessibilityIdentifier("TimePicker")
                    }
                }
                
                // Sugar Level
                VStack(alignment: .leading, spacing: 6) {
                    Label("Уровень сахара", systemImage: "drop.fill")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    TextField("Введите значение", text: $sugarString, prompt: Text("Например: 5.2"))
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .sugar)
                        .font(.body.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(focusedField == .sugar ? Color.accentColor : Color.clear, lineWidth: 2)
                        )
                        .accessibilityIdentifier("SugarInputField")
                    
                    Text("ммоль/л")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                }
            }
        }
    }
    
    // MARK: - Insulin Card
    
    private var insulinCard: some View {
        CardView(title: "Инсулин", icon: "syringe.fill") {
            VStack(spacing: 16) {
                // Insulin Type
                VStack(alignment: .leading, spacing: 6) {
                    Text("Тип инсулина")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    Picker("Тип инсулина", selection: $selectedInsulinType) {
                        ForEach(InsulinType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Insulin Units
                if selectedInsulinType != .none {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Дозировка")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            TextField("Единицы", text: $insulinUnitsString)
                                .keyboardType(.numberPad)
                                .focused($focusedField, equals: .insulinUnits)
                                .font(.body.weight(.medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(focusedField == .insulinUnits ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            
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
                        
                        Text("единиц")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Food Card
    
    private var foodCard: some View {
        CardView(title: "Питание", icon: "fork.knife") {
            VStack(spacing: 16) {
                // Food Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("Описание еды")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .topLeading) {
                        ClearTextEditor(text: $foodDescription)
                            .focused($focusedField, equals: .food)
                            .font(.body)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(focusedField == .food ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            .frame(height: 100)
                            .accessibilityIdentifier("FoodDescriptionField")
                        
                        if foodDescription.isEmpty {
                            Text("Например: Овсянка с молоком, банан")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                // Bread Units (only shown when food is entered)
                if isFoodEntered {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Хлебные единицы")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            TextField("ХЕ", text: $breadUnitsString)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .breadUnits)
                                .font(.body.weight(.medium))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(focusedField == .breadUnits ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            
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
                        
                        Text("ХЕ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.leading, 4)
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .accessibilityIdentifier("BreadUnitsView")
                }
            }
        }
    }
    
    // MARK: - Modern Add Button
    
    private var modernAddButton: some View {
        Button(action: addRecord) {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                
                Text("Добавить запись")
                    .font(.body.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: sugarString.isEmpty 
                        ? [Color.gray.opacity(0.6), Color.gray.opacity(0.4)]
                        : [Color.accentColor, Color.accentColor.opacity(0.8)]
                    ),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: sugarString.isEmpty ? Color.clear : Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(sugarString.isEmpty)
        .scaleEffect(sugarString.isEmpty ? 0.98 : 1.0)
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
