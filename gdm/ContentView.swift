
import PDFKit
import SwiftUI

// TODO:
// 1. Поправить формат шаринга PDF
// 2. Добавить сторадж вместо мок данных
// 3. Исправить функционал добавление данных
// 4. Добавить удаление свайпом
// 5. Добавить поддержку локализации для дат и времени
struct ContentView: View {
    
    @EnvironmentObject var dataStore: DataStore
    @Environment(\.locale) private var locale
    
    @State private var showInput = false
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    // MARK: - Inilialization
    
    init() {
        UITextView.appearance().backgroundColor = UIColor.clear
    }
    
    // MARK: - Lifecycle
    
    var body: some View {
        NavigationView {
            ZStack {
                
                RecordListView1()
                    .accessibilityIdentifier("RecordListView")
                
                addButton
            }
            .accessibilityIdentifier("MainNavigationView")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { PDFService(dataStore: dataStore).sharePDF() }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityIdentifier("ExportPDFButton")
                }
            }
            .navigationTitle("Дневник сахара")
            .onAppear {
                print("locale: \(locale)")
                print("isLongTimeFormat: \(isLongTimeFormat)")
            }
        }
        .sheet(isPresented: $showInput) {
            InputView()
                .environmentObject(dataStore)
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: shareItems)
        }
    }
    
    var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showInput = true }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                }
                .background(Color.accentColor)
                .clipShape(Circle())
                .shadow(radius: 4)
                .padding()
                .accessibilityIdentifier("AddRecordButton")
                .accessibilityLabel("Добавить запись")
            }
        }
    }
}

#Preview("ContentView") {
    ContentView()
        .environmentObject(DataStore())
//        .environment(\.locale, Locale(identifier: "ru_RU"))
}
