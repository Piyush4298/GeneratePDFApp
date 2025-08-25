import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func saveTransactions(_ transactions: [TransactionResponse]) throws
    func fetchTransactions() throws -> [TransactionResponse]
    func clearAllTransactions() throws
    func saveContext() throws
}

final class CoreDataService: CoreDataServiceProtocol {
    private let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func saveTransactions(_ transactions: [TransactionResponse]) throws {
        let context = persistentContainer.viewContext
        
        print("DEBUG: Starting to save \(transactions.count) transactions")
        print("DEBUG: Available entities: \(context.persistentStoreCoordinator?.managedObjectModel.entities.map { $0.name ?? "unnamed" } ?? [])")
        
        // Clear existing transactions
        try clearAllTransactions()
        
        // Save new transactions
        for (index, transactionResponse) in transactions.enumerated() {
            print("DEBUG: Creating transaction \(index + 1)")
            let transaction = Transaction(context: context)
            transaction.transactionDate = transactionResponse.transactionDate
            transaction.transactionCategory = transactionResponse.transactionCategory
            transaction.transactionID = transactionResponse.transactionID
            transaction.status = transactionResponse.status.rawValue
            transaction.amount = transactionResponse.amount
            transaction.transactionType = transactionResponse.transactionType.rawValue
            transaction.createdAt = Date()
            print("DEBUG: Transaction \(index + 1) created successfully")
        }
        
        print("DEBUG: All transactions created, saving context")
        try saveContext()
        print("DEBUG: Context saved successfully")
    }
    
    func fetchTransactions() throws -> [TransactionResponse] {
        let context = persistentContainer.viewContext
        
        // Debug: Print available entities
        print("Available entities in context: \(context.persistentStoreCoordinator?.managedObjectModel.entities.map { $0.name ?? "unnamed" } ?? [])")
        
        // Debug: Check if the entity exists
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Transaction", in: context) else {
            print("ERROR: Transaction entity not found!")
            print("Available entities: \(context.persistentStoreCoordinator?.managedObjectModel.entities.map { $0.name ?? "unnamed" } ?? [])")
            throw NSError(domain: "CoreDataService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Transaction entity not found in Core Data model"])
        }
        
        print("SUCCESS: Transaction entity found: \(entityDescription.name ?? "unnamed")")
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let coreDataTransactions = try context.fetch(request)
        
        return coreDataTransactions.map { $0.toResponse() }
    }
    
    func clearAllTransactions() throws {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = Transaction.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try context.execute(deleteRequest)
    }
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try context.save()
        }
    }
}

extension Transaction {
    func toResponse() -> TransactionResponse {
        return TransactionResponse(
            transactionDate: self.transactionDate ?? "",
            transactionCategory: self.transactionCategory ?? "",
            transactionID: self.transactionID ?? "",
            status: TransactionStatus(rawValue: self.status ?? "") ?? .pending,
            amount: self.amount ?? "",
            transactionType: TransactionType(rawValue: self.transactionType ?? "") ?? .debit
        )
    }
}
