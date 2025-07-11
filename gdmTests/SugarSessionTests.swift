//
//  SugarSessionTests.swift
//  gdmTests
//
//  Created by Anatoliy Podkladov on 11.07.2025.
//

import Testing
import Foundation
@testable import gdm

/// Тесты для модели SugarSession
@Suite("SugarSession Tests")
struct SugarSessionTests {
    
    // MARK: - Helper Methods
    
    /// Создает запись с заданными параметрами
    private func createRecord(
        breadUnits: Double? = nil,
        insulinUnits: Int? = nil,
        insulinType: InsulinType = .novorapid
    ) -> Record {
        return Record(
            date: Date(),
            sugarLevel: 5.0,
            insulinType: insulinType,
            insulinUnits: insulinUnits,
            food: breadUnits != nil ? "Тест еда" : nil,
            breadUnits: breadUnits
        )
    }
    
    // MARK: - Initialization Tests
    
    @Test("SugarSession initialization with valid data")
    func sugarSession_InitializationWithValidData_CreatesCorrectInstance() throws {
        let date = Date()
        let records = [
            createRecord(breadUnits: 2.0, insulinUnits: 5),
            createRecord(breadUnits: 1.5, insulinUnits: 3)
        ]
        
        let session = SugarSession(date: date, records: records)
        
        #expect(session.date == date)
        #expect(session.records == records)
        #expect(session.records.count == 2)
    }
    
    @Test("SugarSession initialization with empty records")
    func sugarSession_InitializationWithEmptyRecords_CreatesValidInstance() throws {
        let date = Date()
        let session = SugarSession(date: date, records: [])
        
        #expect(session.date == date)
        #expect(session.records.isEmpty)
        #expect(session.totalCarbs == 0.0)
        #expect(session.totalInsulin == 0)
    }
    
    // MARK: - Total Carbs Tests
    
    @Test("SugarSession totalCarbs with valid bread units")
    func sugarSession_TotalCarbs_CalculatesCorrectly() throws {
        let records = [
            createRecord(breadUnits: 2.5),
            createRecord(breadUnits: 1.0),
            createRecord(breadUnits: 3.5)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 2.5 + 1.0 + 3.5
        #expect(session.totalCarbs == expectedTotal)
    }
    
    @Test("SugarSession totalCarbs with nil bread units")
    func sugarSession_TotalCarbs_WithNilBreadUnits_ReturnsZero() throws {
        let records = [
            createRecord(breadUnits: nil),
            createRecord(breadUnits: nil)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        #expect(session.totalCarbs == 0.0)
    }
    
    @Test("SugarSession totalCarbs with mixed nil and valid bread units")
    func sugarSession_TotalCarbs_WithMixedBreadUnits_CalculatesOnlyValid() throws {
        let records = [
            createRecord(breadUnits: 2.0),
            createRecord(breadUnits: nil),
            createRecord(breadUnits: 1.5),
            createRecord(breadUnits: nil)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 2.0 + 1.5
        #expect(session.totalCarbs == expectedTotal)
    }
    
    @Test("SugarSession totalCarbs with zero bread units")
    func sugarSession_TotalCarbs_WithZeroBreadUnits_IncludesZero() throws {
        let records = [
            createRecord(breadUnits: 0.0),
            createRecord(breadUnits: 2.0),
            createRecord(breadUnits: 0.0)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 0.0 + 2.0 + 0.0
        #expect(session.totalCarbs == expectedTotal)
    }
    
    // MARK: - Total Insulin Tests
    
    @Test("SugarSession totalInsulin with valid insulin units")
    func sugarSession_TotalInsulin_CalculatesCorrectly() throws {
        let records = [
            createRecord(insulinUnits: 5, insulinType: .novorapid),
            createRecord(insulinUnits: 3, insulinType: .levemir),
            createRecord(insulinUnits: 2, insulinType: .novorapid)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 5 + 3 + 2
        #expect(session.totalInsulin == expectedTotal)
    }
    
    @Test("SugarSession totalInsulin with nil insulin units")
    func sugarSession_TotalInsulin_WithNilInsulinUnits_ReturnsZero() throws {
        let records = [
            createRecord(insulinUnits: nil),
            createRecord(insulinUnits: nil)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        #expect(session.totalInsulin == 0)
    }
    
    @Test("SugarSession totalInsulin with mixed nil and valid insulin units")
    func sugarSession_TotalInsulin_WithMixedInsulinUnits_CalculatesOnlyValid() throws {
        let records = [
            createRecord(insulinUnits: 4, insulinType: .novorapid),
            createRecord(insulinUnits: nil),
            createRecord(insulinUnits: 6, insulinType: .levemir),
            createRecord(insulinUnits: nil)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 4 + 6
        #expect(session.totalInsulin == expectedTotal)
    }
    
    @Test("SugarSession totalInsulin with zero insulin units")
    func sugarSession_TotalInsulin_WithZeroInsulinUnits_IncludesZero() throws {
        let records = [
            createRecord(insulinUnits: 0, insulinType: .novorapid),
            createRecord(insulinUnits: 5, insulinType: .levemir),
            createRecord(insulinUnits: 0, insulinType: .novorapid)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 0 + 5 + 0
        #expect(session.totalInsulin == expectedTotal)
    }
    
    @Test("SugarSession totalInsulin with none insulin type")
    func sugarSession_TotalInsulin_WithNoneInsulinType_IncludesAllUnits() throws {
        let records = [
            createRecord(insulinUnits: 5, insulinType: .none),
            createRecord(insulinUnits: 3, insulinType: .novorapid),
            createRecord(insulinUnits: 2, insulinType: .levemir)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        // totalInsulin суммирует все insulinUnits независимо от типа
        let expectedTotal = 5 + 3 + 2
        #expect(session.totalInsulin == expectedTotal)
    }
    
    // MARK: - Combined Tests
    
    @Test("SugarSession with realistic data scenario")
    func sugarSession_WithRealisticData_CalculatesCorrectTotals() throws {
        let records = [
            createRecord(breadUnits: 2.5, insulinUnits: 7, insulinType: .novorapid), // завтрак
            createRecord(breadUnits: nil, insulinUnits: 2, insulinType: .novorapid), // корректировка через час
            createRecord(breadUnits: 3.0, insulinUnits: 8, insulinType: .novorapid), // обед  
            createRecord(breadUnits: nil, insulinUnits: nil, insulinType: .none), // контрольный замер
            createRecord(breadUnits: 1.5, insulinUnits: 4, insulinType: .novorapid), // ужин
            createRecord(breadUnits: nil, insulinUnits: 15, insulinType: .levemir) // ночной инсулин
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedCarbs = 2.5 + 3.0 + 1.5 // = 7.0
        let expectedInsulin = 7 + 2 + 8 + 4 + 15 // = 36
        
        #expect(session.totalCarbs == expectedCarbs)
        #expect(session.totalInsulin == expectedInsulin)
    }
    
    // MARK: - Edge Cases Tests
    
    @Test("SugarSession with very large numbers")
    func sugarSession_WithLargeNumbers_HandlesCorrectly() throws {
        let records = [
            createRecord(breadUnits: 99.9, insulinUnits: 100),
            createRecord(breadUnits: 50.0, insulinUnits: 99)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        #expect(session.totalCarbs == 149.9)
        #expect(session.totalInsulin == 199)
    }
    
    @Test("SugarSession with decimal precision")
    func sugarSession_WithDecimalPrecision_CalculatesAccurately() throws {
        let records = [
            createRecord(breadUnits: 1.1),
            createRecord(breadUnits: 2.2),
            createRecord(breadUnits: 3.3)
        ]
        let session = SugarSession(date: Date(), records: records)
        
        let expectedTotal = 1.1 + 2.2 + 3.3
        #expect(abs(session.totalCarbs - expectedTotal) < 0.0001) // учитываем погрешность с плавающей точкой
    }
} 