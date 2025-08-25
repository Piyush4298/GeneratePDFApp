import Foundation
import CoreData
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let networkService: NetworkServiceProtocol
    private let coreDataService: CoreDataServiceProtocol
    private let pdfService: PDFServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService(),
         coreDataService: CoreDataServiceProtocol,
         pdfService: PDFServiceProtocol = PDFService()) {
        self.networkService = networkService
        self.coreDataService = coreDataService
        self.pdfService = pdfService
    }
    
    func fetchTransactions() async {
        print("DEBUG: ViewModel fetchTransactions started")
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            print("DEBUG: Fetching from API...")
            let apiTransactions = try await networkService.fetchTransactions()
            print("DEBUG: API returned \(apiTransactions.count) transactions")

            // Update UI immediately
            self.transactions = apiTransactions

            // Save to CoreData in background
            Task.detached {
                do {
                    print("DEBUG: Saving to CoreData...")
                    try await self.coreDataService.saveTransactions(apiTransactions)
                    print("DEBUG: CoreData save successful")
                } catch {
                    print("DEBUG: CoreData save failed: \(error.localizedDescription)")
                }
            }
        } catch {
            print("DEBUG: API error: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            showError = true

            // Fallback: load cached data
            do {
                print("DEBUG: Loading cached data from CoreData...")
                try loadTransactionsFromCoreData()
                print("DEBUG: Cached data load successful")
            } catch {
                print("DEBUG: Cached data load failed: \(error.localizedDescription)")
                errorMessage = "Failed to load cached data: \(error.localizedDescription)"
                showError = true
            }
        }

        isLoading = false
        print("DEBUG: fetchTransactions completed")
    }
    
    func loadTransactionsFromCoreData() throws {
        print("DEBUG: loadTransactionsFromCoreData started")
        transactions = try coreDataService.fetchTransactions()
        print("DEBUG: loadTransactionsFromCoreData completed, got \(transactions.count) transactions")
    }
    
    func generatePDF() -> Data? {
        guard !transactions.isEmpty else { return nil }
        return pdfService.generateTransactionReport(transactions: transactions)
    }
    
    func refreshData() async {
        await fetchTransactions()
    }
    
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    // MARK: - Computed Properties
    
    var totalTransactions: Int {
        return transactions.count
    }
    
    var totalCredit: Double {
        return transactions.compactMap { transaction in
            if transaction.transactionType.rawValue == TransactionType.credit.rawValue {
                return Double(transaction.amount)
            }
            return nil
        }.reduce(0, +)
    }
    
    var totalDebit: Double {
        return transactions.compactMap { transaction in
            if transaction.transactionType.rawValue == TransactionType.debit.rawValue {
                return Double(transaction.amount)
            }
            return nil
        }.reduce(0, +)
    }
    
    var balance: Double {
        return totalCredit - totalDebit
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: balance)) ?? "$0.00"
    }
    
    var transactionId: String {
        return UUID().uuidString
    }
}
