//
//  InputView.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 01.06.2025.
//

import AVFoundation
import SwiftUI

struct InputView: View {
    
    // MARK: - Dependencies
    
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Private properties

    @State private var date: Date = Date()
    @State private var sugarString: String = ""
    @State private var foodOrNotFoodTime: FoodOrNotFoodTime = .empty // FIXME: обновлять в зависимости от времени
    @State private var selectedInsulinType: InsulinType = .novorapid
    @State private var reminder: Reminder = .afterOneHour
    @State private var insulinUnitsString: String = "7"
    @State private var foodDescription: String = ""
    @State private var breadUnitsString: String = "0"

    @FocusState private var focusedField: FocusableField?
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCameraPermissionAlert = false
    
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
            
            VStack(alignment: .leading, spacing: 16) {
                // Header
                headerView
                    .padding(.top, 20)
                    .accessibilityIdentifier("InputViewTitle")
                
                // Date and Time Row
                dateAndTimeView
                .frame(maxWidth: .infinity)
                
                
                simpleFieldView(
                    title: "",
                    content: {
                        Picker("Прием пиши или нет?", selection: $foodOrNotFoodTime) {
                            ForEach(FoodOrNotFoodTime.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                )
                .accessibilityIdentifier("FoorOrNotFoodTimePicker")
                
                // Sugar Level
                sugarLevelView
                .accessibilityIdentifier("SugarInputView")
                
                foodView
                
                // Insulin Row
                HStack(spacing: 12) {
                    
                    let insulinWidth = UIScreen.main.bounds.width - 40 - 12 - 120
                    // let insulinWidth = (UIScreen.main.bounds.width - 40 - 12) / 3 * 2
                    // let insulinValueWidth = (UIScreen.main.bounds.width - 40 - 12) / 3
                    
                    simpleFieldView(
                        title: "",
                        width: insulinWidth,
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
                            title: "",
                            // width: insulinValueWidth,
                            horizontalPadding: 8,
                            content: {
                                HStack(spacing: 0) {
                                    TextField("0", text: $insulinUnitsString)
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .insulinUnits)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                        .padding(.trailing, 8)
//                                        .frame(width: 60)
                                    
                                    // Spacer()
                                    
                                    Stepper(
                                        "",
                                        value: Binding(
                                            get: { Int(insulinUnitsString) ?? 7 },
                                            set: { insulinUnitsString = String($0) }
                                        ),
                                        in: 1...20
                                    )
                                    .labelsHidden()
                                }
                                .frame(width: 110)
                            }
                        )
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .accessibilityIdentifier("InsulinRow")
                
                if isFoodEntered || breadUnitsString != "0" {
                    // Reminder (if needed)
                    simpleFieldView(
                        icon: "iconBell",
                        title: "",
                        elementPadding: 0,
                        content: {
                            HStack {
                                //                                if reminder == nil {
                                //                                    Button
                                //                                    Text("Напоминание")
                                //                                        .foregroundColor(.secondary)
                                //                                        .font(.body)
                                //                                } else {
                                Picker("Напоминание", selection: $reminder) {
                                    ForEach(Reminder.allCases) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                // .pickerStyle(.menu)
                                .font(.body)
                                //                                }
                                
                                Spacer()
                            }
                        }
                    )
                }
                
                Spacer()
                
                // Simple Add Button
                simpleAddButton
                    .accessibilityIdentifier("AddRecordButton")
            }
        }
        .padding(.horizontal, 20)        // .padding(.top, 20)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("InputView")
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
        .background(Color(.systemBackground).ignoresSafeArea())
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
        }
        .alert("Доступ к камере", isPresented: $showingCameraPermissionAlert) {
            Button("Настройки") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Отмена", role: .cancel) { }
        } message: {
            Text("Для добавления фото еды необходимо разрешить доступ к камере в настройках приложения.")
        }

    }
    
    // MARK: - Camera Functions
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingImagePicker = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingImagePicker = true
                    } else {
                        showingCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            showingCameraPermissionAlert = true
        @unknown default:
            showingCameraPermissionAlert = true
        }
    }
    
    // MARK: - Captured Image View
    
    private func capturedImageView(image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Фото еды")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Удалить") {
                    selectedImage = nil
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.textFieldBorder, lineWidth: 1)
                )
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        Text("Новая запись")
            .font(.title2.bold())
            .foregroundColor(.primary)
            // .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var dateAndTimeView: some View {
        
        HStack(spacing: 12) {
            
            let width = (UIScreen.main.bounds.width - 40 - 12) / 2
            
            simpleFieldView(
                icon: "iconCalendar",
                title: "Дата",
                width: width,
                content: {
                    ZStack {
                        HStack {
                            Text(date.stringDate)
                                .font(.body)
                            
                            Spacer()
                        }
                        
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .colorMultiply(.clear)
                            .labelsHidden()
                    }
                }
            )
            .accessibilityIdentifier("DatePicker")
            
            simpleFieldView(
                icon: "iconTimer",
                title: "Время",
                width: width,
                content: {
                    ZStack {
                        HStack {
                            Text(date.stringTime)
                                .font(.body)
                            Spacer()
                        }
                        
                        DatePicker("Время", selection: $date, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .colorMultiply(.clear)
                            .labelsHidden()
                    }
                }
            )
            .accessibilityIdentifier("TimePicker")
        }
    }
    
    private var sugarLevelView: some View {
        
        simpleFieldView(
            icon: "iconBlood",
            title: "",
            content: {
                TextField("Сахар (ммоль/л)", text: $sugarString)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .sugar)
                    .font(.body)
                    .accessibilityIdentifier("SugarInputField")
            }
        )
    }
    
    private var foodView: some View {
        Group {
            
            // Meal Type (if needed)
            simpleFieldView(
                iconPosition: .trailing,
                icon: "iconCamera",
                iconSize: 24,
                iconBacgroundSize: 34,
                iconButtonAction: openCamera,
//                    {
//                    print("Camera button tapped")
//                },
                title: "",
                content: {
                    TextField("Что было в меню", text: $foodDescription)
                        .focused($focusedField, equals: .food)
                        .font(.body)
                        .accessibilityIdentifier("FoodDescriptionField")
                }
            )
            .accessibilityIdentifier("FoodDescriptionView")
            
            // Bread Units (only if food entered)
            if isFoodEntered {
                simpleFieldView(
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
        }
    }
    
    // MARK: - Simple Field View
    
    enum IconPosition {
        case leading, trailing
    }
    
    @ViewBuilder
    private func simpleFieldView<Content: View>(
        iconPosition: IconPosition = .leading,
        icon: String? = nil,
        iconSize: CGFloat = 14,
        iconBacgroundSize: CGFloat = 28,
        iconButtonAction: @escaping () -> Void = {},
        title: String,
        width: CGFloat? = nil,
        elementPadding: CGFloat = 11,
        horizontalPadding: CGFloat = 11,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack(spacing: elementPadding) {
            if let icon, !icon.isEmpty, iconPosition == .leading {
                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(.black)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: iconSize, height: iconSize)
                    .frame(width: iconBacgroundSize, height: iconBacgroundSize)
                    .background(Color.iconBacknground)
                    .cornerRadius(10)
            }
            
            //            if !title.isEmpty {
            //                Text(title)
            //                    .font(.body)
            //                    .foregroundColor(.secondary)
            //                    .frame(minWidth: 60, alignment: .leading)
            //            }
            
            content()
            
            if let icon, !icon.isEmpty, iconPosition == .trailing {
                Button(action: iconButtonAction) {
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.black)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: iconSize, height: iconSize)
                        .frame(width: iconBacgroundSize, height: iconBacgroundSize)
                        .background(Color.iconBacknground)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .frame(width: width ?? .infinity, alignment: .leading)
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .inset(by: 0.5)
                .stroke(Color.textFieldBorder, lineWidth: 1)
        )
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
