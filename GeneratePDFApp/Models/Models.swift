import Foundation
import UIKit

// MARK: - API Response Models
struct TransactionResponse: Codable {
    let transactionDate: String
    let transactionCategory: String
    let transactionID: String
    let status: TransactionStatus
    let amount: String
    let transactionType: TransactionType
    
    enum CodingKeys: String, CodingKey {
        case transactionDate
        case transactionCategory
        case transactionID
        case status
        case amount
        case transactionType
    }
}

enum TransactionStatus: String, Codable, CaseIterable {
    case completed = "COMPLETED"
    case pending = "PENDING"
    case failed = "FAILED"
    case cancelled = "CANCELLED"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var color: UIColor {
        switch self {
        case .completed:
            return .systemGreen
        case .pending:
            return .systemOrange
        case .failed:
            return .systemRed
        case .cancelled:
            return .systemGray
        }
    }
}

enum TransactionType: String, Codable, CaseIterable {
    case credit = "CREDIT"
    case debit = "DEBIT"
    
    var displayName: String {
        return rawValue.capitalized
    }
    
    var isCredit: Bool {
        return self == .credit
    }
}

// MARK: - User Details Model
struct UserDetails {
    static let name = "Piyush Pandey"
    static let email = "piyush.pandey@example.com"
    static let mobile = "+91 9100339934"
    static let cardNumber = "**** **** **** 1234"
    static let cardType = "PERSONAL"
    static let address = "Mumbai, Maharashtra"
}

// MARK: - PDF Generation Models
struct PDFTableRow {
    let date: String
    let narration: String
    let transactionID: String
    let status: String
    let credit: String
    let debit: String
    
    init(from transaction: TransactionResponse) {
        self.date = transaction.transactionDate
        self.narration = transaction.transactionCategory
        self.transactionID = transaction.transactionID
        self.status = transaction.status.rawValue
        
        if transaction.transactionType.rawValue == TransactionType.credit.rawValue {
            self.credit = transaction.amount
            self.debit = ""
        } else {
            self.credit = ""
            self.debit = transaction.amount
        }
    }
}
