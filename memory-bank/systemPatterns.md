# Системные паттерны

## Архитектура приложения

### MVVM Pattern
```
View (SwiftUI) → ViewModel (ObservableObject) → Model (Data)
```

**Компоненты:**
- **Views**: SwiftUI views (`ContentView`, `InputView`, `RecordListView1`)
- **ViewModels**: Использутеся для бизнес логики, взаимодействия с сервисами для записи и хранения информации
- **Models**: Data structures (`Record`, `SugarSession`, `InsulinType`)
- **Services**: Хранение и шеринг данных (`DataStore`, `PDFService`)

### Dependency Injection
```swift
// EnvironmentObject для передачи DataStore
ContentView()
    .environmentObject(DataStore())
```

## Ключевые паттерны проектирования

### 1. ObservableObject Pattern
```swift
final class DataStore: ObservableObject {
    @Published var records: [Record] = []
    
    func addRecord(_ record: Record) {
        records.append(record)
        records.sort { $0.date > $1.date }
        saveRecords()
    }
}
```

**Применение:**
- Автоматическое обновление UI при изменении данных
- Централизованное управление состоянием
- Реактивные обновления через `@Published`

### 2. Strategy Pattern (SugarColorLogic)
```swift
struct SugarColorLogic {
    static func color(
        for record: Record,
        previousRecord: Record?,
        isFirstSugarOfDay: Bool
    ) -> Color {
        // Различные стратегии определения цвета
        // в зависимости от контекста
    }
}
```

**Применение:**
- Различные алгоритмы для разных условий
- Легкость тестирования и изменения логики
- Разделение бизнес-логики от представления

### 3. Factory Pattern (Model Creation)
```swift
extension Record {
    static var mockArray: [Record] = {
        // Фабрика для создания тестовых данных
        return [/* мок данные */]
    }()
}
```

### 4. Service Layer Pattern
```swift
struct PDFService {
    private let dataStore: DataStore
    
    init(dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    func sharePDF() {
        // Логика генерации и шаринга PDF
    }
}
```

## Архитектурные решения

### 1. Группировка данных
```swift
// Группировка записей по дням
// TODO: использовать специальную структуру – исправить
private var groupedRecords: [Date: [Record]] {
    Dictionary(grouping: dataStore.records) { record in
        Calendar.current.startOfDay(for: record.date)
    }
}

// Группировка в сессии
private func sessions(for day: Date) -> [SugarSession] {
    // Логика группировки записей в сессии
    // основанная на наличии еды
}
```

### 2. Reactive UI Updates
```swift
struct RecordListView1: View {
    @EnvironmentObject var dataStore: DataStore
    
    // UI автоматически обновляется при изменении dataStore.records
    private var groupedRecords: [Date: [Record]] {
        Dictionary(grouping: dataStore.records) { ... }
    }
}
```

### 3. Presentation Logic
```swift
struct RecordRowView: View {
    let record: Record
    let previousRecord: Record?
    let isFirstSugarOfDay: Bool
    let isFirstInSession: Bool
    let isLastInSession: Bool
    
    // Вся логика представления изолирована в компоненте
    private var sugarDisplayColor: Color {
        SugarColorLogic.color(
            for: record,
            previousRecord: previousRecord,
            isFirstSugarOfDay: isFirstSugarOfDay
        )
    }
}
```

## Связи и зависимости

### Data Flow
```
User Input → InputView → DataStore → RecordListView1 → RecordRowView
                           ↓
                      PDFService → PDF Export
```

### Component Dependencies
```
ContentView
├── RecordListView1
│   ├── SessionRowView
│   │   └── RecordRowView
│   └── DailySummaryRow
├── InputView
│   └── ClearTextEditor
└── PDFService
    └── PDFActivityItemSource
```

### Model Relationships
```
Record (main entity)
├── InsulinType (enum)
├── Date (system type)
└── SugarSession (aggregate)
    └── Collection<Record>
```

## Принципы разработки

### Single Responsibility Principle
- `DataStore`: только управление данными
- `PDFService`: только генерация PDF
- `SugarColorLogic`: только логика цветов
- `RecordRowView`: только отображение записи

### Open/Closed Principle
- `InsulinType`: легко добавлять новые типы инсулина
- `SugarColorLogic`: легко изменять правила цветов
- Компоненты UI легко расширяются

### Dependency Inversion
- Views зависят от абстракций (ObservableObject)
- Services получают зависимости через конструктор
- Models не зависят от UI

## Правила безопасности кода

### ⚠️ КРИТИЧЕСКОЕ: Никогда не использовать Force Unwrap (!)
**Запрещено:**
```swift
let value = someOptional!  // НИКОГДА НЕ ДЕЛАТЬ
let text = record.food!    // КРАЙНЕ ОПАСНО
```

**Правильно:**
```swift
// Guard let для early return
guard let value = someOptional else { return }

// If let для условной обработки
if let food = record.food {
    processFood(food)
}

// Nil coalescing для значений по умолчанию
let text = record.food ?? "Не указано"

// Optional chaining
let count = record.food?.count

// Optional binding с fallback
let safeValue = someOptional ?? defaultValue
```

### Безопасная работа с Optional

**1. Guard Let Pattern**
```swift
func updateRecord(_ record: Record) throws {
    guard let index = records.firstIndex(where: { $0.id == record.id }) else {
        throw DataError.recordNotFound
    }
    records[index] = record
}
```

**2. Nil Coalescing**
```swift
let insulinUnits = record.insulinUnits ?? 0
let foodDescription = record.food ?? "Не указано"
```

**3. Optional Chaining**
```swift
let trimmedFood = record.food?.trimmingCharacters(in: .whitespacesAndNewlines)
let foodLength = record.food?.count ?? 0
```

**4. Compact Map для коллекций**
```swift
let validUnits = records.compactMap { $0.insulinUnits }
let foodItems = records.compactMap { $0.food }
```

## Паттерны UI

### Composition Pattern
```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                RecordListView1()  // Основной контент
                addButton          // Floating action button
            }
        }
    }
}
```

### State Management
```swift
@State private var showInput = false
@State private var showShareSheet = false
@FocusState private var focusedField: FocusableField?
```

### Conditional Rendering
```swift
if !foodDescription.isEmpty {
    breadUnitsView()
        .transition(.move(edge: .top).combined(with: .opacity))
}
```

## Тестируемость

### 🧪 Правила тестирования

**ВАЖНО: Мы НЕ пишем unit тесты для View компонентов!**

✅ **Тестируем:**
- Бизнес-логику (`SugarColorLogic`, `ValidationService`)
- Сервисы (`DataStore`, `PDFService`)
- Модели (`Record`, `SugarSession`, `InsulinType`)
- Extensions (`Date`, `String`, etc.)
- Computed properties и методы

❌ **НЕ тестируем:**
- SwiftUI Views (`ContentView`, `InputView`, `RecordListView1`)
- UI компоненты (`SessionRowView`, `RecordRowView`)
- View модификаторы и presentation logic
- Navigation и UI state

**Причины:**
- View тесты сложны и хрупки
- SwiftUI лучше тестировать через UI тесты
- Бизнес-логика должна быть отделена от UI
- Focus на тестировании логики, а не представления

### Изолированная логика
- `SugarColorLogic` - pure functions
- `DataStore` - testable business logic
- Models - simple data structures

### Мок данные
- `Record.mockArray` для тестирования UI
- `SugarSession.mockArray` для тестирования группировки

### Dependency Injection
- Services можно легко мокать
- ObservableObject позволяет тестировать состояние

### Структура тестов
- Каждый сервис/модель в отдельном файле тестов
- Comprehensive coverage для бизнес-логики
- Edge cases и error handling
- **Цель: 70%+ покрытие кода** ✅ **ДОСТИГНУТА** 