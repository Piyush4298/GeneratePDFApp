import Foundation


protocol NetworkServiceProtocol {
    func fetchTransactions() async throws -> [TransactionResponse]
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://iosserver.free.beeceptor.com"
    
    func fetchTransactions() async throws -> [TransactionResponse] {
        guard let url = URL(string: "\(baseURL)/history") else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError("Invalid response")
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            let decoder = JSONDecoder()
            let transactions = try decoder.decode([TransactionResponse].self, from: data)
            return transactions
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
