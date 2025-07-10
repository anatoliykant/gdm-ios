# Технический контекст

## Используемые технологии

### Основной стек
- **Язык**: Swift 5.0
- **UI фреймворк**: SwiftUI
- **Минимальные версии**:
  - iOS 16.0+
  - macOS 15.0+
  - visionOS 2.5+
- **Xcode**: 16.4+

### Фреймворки и библиотеки
- **SwiftUI**: для создания пользовательского интерфейса
- **PDFKit**: для генерации PDF-отчетов
- **VisionKit**: для распознавания показания сахара в крови с приборов учета, единиц инсулина с ампул и шприцов
- **Swift Testing**: для unit тестирования

### Архитектурные компоненты
- **ObservableObject**: для reactive state management
- **EnvironmentObject**: для dependency injection
- **@Published**: для автоматического обновления UI

## Настройка проекта

### Xcode проект
```
Bundle Identifier: ai.pao.gdm
Display Name: GDM
App Category: Medical (public.app-category.medical)
Development Team: U688SQV65X
```

### Поддерживаемые платформы
```
iPhone: iOS 16.0+
iPad: iOS 16.0+
Mac: macOS 15.0+
Apple Vision: visionOS 2.5+
```

### Конфигурация сборки
```
Swift Version: 5.0
Deployment Target: iOS 16.0
Code Signing: Automatic
Hardened Runtime: YES (for macOS)
```

## Структура проекта

### Основные директории
```
gdm/
├── gdm/                    # Основной модуль
│   ├── Assets.xcassets/    # Ресурсы приложения
│   ├── Extension/          # Расширения
│   ├── Models/             # Модели данных
│   ├── Modules/            # UI компоненты
│   ├── Services/           # Бизнес-логика
│   └── *.swift             # Корневые файлы
├── gdmTests/               # Unit тесты
├── gdmUITests/             # UI тесты
└── memory-bank/            # Банк памяти
```

### Именование файлов
- **Models**: `Record.swift`, `InsulinType.swift`
- **Views**: `ContentView.swift`, `InputView.swift`
- **Services**: `DataStore.swift`, `PDFService.swift`
- **Extensions**: `DateTime.swift`

## Особенности конфигурации

### Права доступа (Entitlements)
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

### Локализация
- **Основная локаль**: Русский и английский языки
- **Форматирование**: Автоматическое определение формата времени
- **Decimal separator**: Поддержка как точки, так и запятой

### Поддержка разных экранов
- **iPhone**: Portrait, Landscape Left, Landscape Right
- **iPad**: All orientations
- **Mac**: адаптивный интерфейс

## Технические ограничения

### Хранение данных
- **Текущая реализация**: Mock data в памяти
- **Планируемое**: UserDefaults, CoreData или CloudKit
- **Экспорт**: только PDF через sharing, позже автоматическаяотправка на email/messenger

### Производительность
- **Группировка данных**: in-memory processing, позже сохраняется сразу на диск в определенном формате
- **UI обновления**: reactive через @Published
- **PDF генерация**: синхронная в основном потоке, возможно стоит перенести в бекграунд

### Безопасность
- **Данные**: хранятся локально и в iCloud облаке (безопасность на уровне apple)
- **Sharing**: только через системные механизмы
- **Sandbox**: полная изоляция приложения

## Интеграции

### Системные интеграции
- **Share Sheet**: для экспорта PDF
- **Calendar**: для работы с датами
- **Localization**: для форматирования времени

### Внешние зависимости
- **Отсутствуют**: проект не использует внешние пакеты, возможно позже появится API для работы с AI, SDK аналитки и крешей
- **Все зависимости**: только системные фреймворки

## Среда разработки

### Требования
- **Xcode**: 16.4+
- **macOS**: для разработки под все платформы
- **Apple Developer Account**: для тестирования на устройствах

### Настройка
```bash
# Клонирование репозитория
git clone https://github.com/anatoliykant/gdm.git

# Открытие в Xcode
open gdm.xcodeproj

# Запуск тестов
cmd+U
```

### Сборка и тестирование
```bash
# Сборка для iOS
xcodebuild -scheme gdm -destination 'platform=iOS Simulator,name=iPhone 15'

# Запуск тестов
xcodebuild test -scheme gdm -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Технические долги

### Из TODO в коде
1. **Хранение данных**: заменить mock на реальное хранение
2. **PDF формат**: улучшить форматирование
3. **Добавление данных**: исправить функционал
4. **Удаление записей**: добавить swipe-to-delete
5. **Локализация**: добавить поддержку дат и времени

### Архитектурные улучшения
- **Dependency Injection**: использовать протоколы для сервисов
- **Error Handling**: добавить обработку ошибок
- **Validation**: улучшить валидацию пользовательского ввода
- **Testing**: увеличить покрытие тестами

### UX улучшения
- **Accessibility**: добавить поддержку VoiceOver
- **Themes**: поддержка светлой/темной темы
- **Animations**: улучшить анимации переходов
- **Offline**: работа без интернета

## Мониторинг и отладка

### Инструменты
- **Xcode Debugger**: для отладки
- **Instruments**: для профилирования
- **Console**: для логирования

### Логирование
```swift
print("DataStore: Load records (placeholder)")
print("DataStore: Save records (placeholder)")
```

### Crash Reporting
- **Текущий**: только Xcode crash logs
- **Планируемый**: интеграция с системами мониторинга, Firebase crashlytics, Sentry или Countly