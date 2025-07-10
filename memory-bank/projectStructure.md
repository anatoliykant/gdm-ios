# Структура проекта

## Общая структура
```
gdm/
├── gdm/                         # Основной модуль приложения
│   ├── Assets.xcassets/         # Ресурсы приложения
│   ├── Extension/               # Расширения системных типов
│   ├── Models/                  # Модели данных
│   ├── Modules/                 # UI экранов, компонентов + Бизнес-логика во ViewModel's
│   ├── Services/                # Сервисы
│   ├── ContentView.swift        # Главный экран
│   ├── SugarListView.swift      # Альтернативный список (не используется)
│   ├── gdmApp.swift             # Точка входа приложения
│   └── gdm.entitlements         # Права доступа
├── gdmTests/                    # Unit тесты
├── gdmUITests/                  # UI тесты
├── gdm.xcodeproj/               # Xcode проект
├── memory-bank/                 # Банк памяти (документация и контекст для AI IDE, например, Cursor)
├── .gitignore                   # Git исключения
└── README.md                    # Документация проекта
```

## Детальная структура

### 📱 Основной модуль (gdm/)

#### 🎨 Assets.xcassets/
```
Assets.xcassets/
├── AccentColor.colorset/        # Акцентный цвет
│   └── Contents.json
├── AppIcon.appiconset/          # Иконка приложения
│   └── Contents.json
└── Contents.json
```

#### 🔧 Extension/
```
Extension/
└── DateTime.swift               # Расширения для работы с датами
```

#### 📊 Models/
```
Models/
├── InsulinType.swift           # Enum типов инсулина
├── Record.swift                # Основная модель записи
├── SugarColorLogic.swift       # Логика цветовой индикации
└── SugarSession.swift          # Группировка записей в сессии
```

#### 🎯 Modules/
```
Modules/
├── ActivityView.swift          # Системный sharing
├── ClearTextEditor.swift       # Кастомный текстовый редактор
├── DailySummaryRow.swift       # Суммарная строка по дню
├── InputView.swift             # Форма ввода данных
├── PDFActivityItemSource.swift # Кастомный источник для PDF
├── PDFService.swift            # Сервис генерации PDF
├── RecordListView.swift        # Старый список записей (не используется) - удалить?
├── RecordListView1.swift       # Основной список записей
├── RecordRowView.swift         # Отображение одной записи
└── SessionRowView.swift        # Отображение сессии
```

#### 🔄 Services/
```
Services/
└── DataStore.swift             # Управление данными (ObservableObject)
```

#### 🏠 Root Files
```
├── ContentView.swift           # Главный экран приложения
├── SugarListView.swift         # Альтернативный интерфейс (не используется)
├── gdmApp.swift                # Точка входа (@main)
└── gdm.entitlements            # Права доступа (sandbox)
```

### 🧪 Тестирование

#### ⚡ gdmTests/
```
gdmTests/
└── gdmTests.swift              # Unit тесты на Swift Testing
```

#### 🎭 gdmUITests/
```
gdmUITests/
├── gdmUITests.swift            # UI тесты
└── gdmUITestsLaunchTests.swift # Тесты запуска
```

### 🛠️ Конфигурация проекта

#### 📋 gdm.xcodeproj/
```
gdm.xcodeproj/
├── project.pbxproj             # Конфигурация проекта
├── project.xcworkspace/        # Workspace настройки
│   ├── contents.xcworkspacedata
│   └── xcshareddata/
└── xcshareddata/
    └── xcschemes/
        └── gdm.xcscheme        # Схема сборки
```

### 📚 Документация

#### 🧠 memory-bank/
```
memory-bank/
├── projectbrief.md             # Краткая справка проекта
├── productContext.md           # Контекст продукта
├── systemPatterns.md           # Архитектурные паттерны
├── techContext.md              # Технический контекст
├── activeContext.md            # Активный контекст
├── progress.md                 # Прогресс разработки
└── projectStructure.md         # Структура проекта (этот файл)
```

## Назначение компонентов

### 🎯 Архитектурные слои

#### Presentation Layer
- **ContentView**: Главный экран с навигацией
- **InputView**: Форма ввода новых записей
- **RecordListView1**: Список всех записей
- **RecordRowView**: Отображение одной записи
- **SessionRowView**: Группировка записей в сессии

#### Business Logic Layer
- **DataStore**: Управление состоянием приложения
- **PDFService**: Генерация PDF отчетов
- **SugarColorLogic**: Логика определения цветов

#### Data Layer
- **Record**: Модель записи о сахаре
- **InsulinType**: Типы инсулина
- **SugarSession**: Группировка записей

### 🔄 Потоки данных

#### Input Flow
```
User Input → InputView → DataStore → RecordListView1 → UI Update
```

#### Display Flow
```
DataStore → RecordListView1 → SessionRowView → RecordRowView → UI
```

#### Export Flow
```
DataStore → PDFService → PDF Generation → ActivityView → System Share
```

## Принципы организации

### 📁 Структура папок
1. **Модульность**: каждый компонент в отдельном файле
2. **Слои**: четкое разделение на Models/Services/Modules и позже ViewModels
3. **Группировка**: связанные компоненты в одной папке
4. **Именование**: описательные имена файлов

### 🎯 Зависимости
- **Models**: не зависят от других слоев
- **Services**: могут использовать Models
- **Views**: могут использовать Models и Services (временно)
- **ViewModels**: должны использовать Services и бизнес логику для управления данными на View's
- **Tests**: могут использовать все слои

### 🔄 Паттерны
- **MVVM**: Views + ObservableObject
- **Service Layer**: бизнес-логика в отдельных классах ViewModel
- **Factory**: создание mock данных в extensions
- **Strategy**: различные алгоритмы для цветов

## Файловая конвенция

### 📝 Именование файлов
- **Views**: заканчиваются на `View.swift`
- **ViewModels**: заканчиваются на `ViewModel.swift`
- **Models**: именительный падеж (`Record.swift`)
- **Services**: заканчиваются на `Service.swift`
- **Extensions**: `TypeName.swift` для расширений

### 🎨 SwiftUI структура
```swift
struct ComponentView: View {
    // MARK: - Dependencies
    // MARK: - Properties
    // MARK: - Body
    var body: some View { ... }
    // MARK: - Private Views
    // MARK: - Methods
}
```

### 📊 Data Models
```swift
struct Model: Identifiable, Hashable {
    let id = UUID()
    // Properties
    
    // Computed properties
    
    // Extensions for mock data
}
```

## Метрики проекта

### 📈 Размер кодовой базы
- **Общие файлы**: ~35 файлов
- **Swift файлы**: ~25 файлов
- **Строки кода**: ~3500 строк
- **Тесты**: ~50 строк

### 🏗️ Архитектурные метрики
- **Models**: 4 файла
- **Services**: 1 файл
- **Views**: 8 файлов
- **ViewModels**: 0 покафайлов
- **Extensions**: 1 файл

### 📚 Документация
- **README**: базовый
- **Банк памяти**: 7 файлов
- **Комментарии**: частично
- **TODO**: ~10 элементов

## Рекомендации по развитию

### 🔄 Рефакторинг
1. **Разделить Services**: выделить отдельные сервисы
2. **Протоколы**: добавить абстракции
3. **Dependency Injection**: улучшить архитектуру
4. **Бизнес логика**: вынести всю бизнес логику во ViewModels
5. **Error Handling**: добавить обработку ошибок

### 📈 Масштабирование
1. **Модули**: группировать в feature modules
2. **Shared**: выделить общие компоненты
3. **Resources**: структурировать ресурсы
4. **Localization**: добавить локализацию (в первой итерации на русский и английский языки)

### 🧪 Тестирование
1. **Unit Tests**: для каждого сервиса и ViewModels
2. **UI Tests**: для основных сценариев
3. **Integration Tests**: для потоков данных
4. **Performance Tests**: для критичных операций