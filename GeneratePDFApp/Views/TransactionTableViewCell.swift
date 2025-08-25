import UIKit

final class TransactionTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let transactionIDLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let typeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(transactionIDLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(typeLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container view
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Transaction ID
            transactionIDLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            transactionIDLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            transactionIDLabel.trailingAnchor.constraint(equalTo: amountLabel.leadingAnchor, constant: -16),
            
            // Amount
            amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            amountLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Category
            categoryLabel.topAnchor.constraint(equalTo: transactionIDLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Date
            dateLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            // Status
            statusLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 16),
            statusLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            statusLabel.widthAnchor.constraint(equalToConstant: 80),
            statusLabel.heightAnchor.constraint(equalToConstant: 24),
            
            // Type
            typeLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            typeLabel.leadingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: 8),
            typeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            typeLabel.widthAnchor.constraint(equalToConstant: 60),
            typeLabel.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    // MARK: - Configuration
    func configure(with transaction: TransactionResponse) {
        transactionIDLabel.text = transaction.transactionID
        categoryLabel.text = transaction.transactionCategory
        dateLabel.text = formatDate(transaction.transactionDate)
        
        // Configure amount and type
        amountLabel.text = "$\(transaction.amount)"
        if transaction.transactionType.rawValue == TransactionType.credit.rawValue {
            amountLabel.textColor = .systemGreen
            typeLabel.text = "Credit"
            typeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            typeLabel.textColor = .systemGreen
        } else {
            amountLabel.textColor = .systemRed
            typeLabel.text = "Debit"
            typeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            typeLabel.textColor = .systemRed
        }
        
        // Configure status
        statusLabel.text = transaction.status.rawValue
        configureStatusColor(transaction.status)
    }
    
    private func configureStatusColor(_ status: TransactionStatus) {
        switch status {
        case .completed:
            statusLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGreen
        case .pending:
            statusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusLabel.textColor = .systemOrange
        case .failed:
            statusLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusLabel.textColor = .systemRed
        case .cancelled:
            statusLabel.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGray
        }
    }
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        
        return dateString
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        transactionIDLabel.text = nil
        categoryLabel.text = nil
        amountLabel.text = nil
        dateLabel.text = nil
        statusLabel.text = nil
        typeLabel.text = nil
    }
}
