//
//  ViewController.swift
//  GeneratePDFApp
//
//  Created by Piyush Pandey on 23/08/25.
//

import UIKit
import PDFKit
import CoreData
import Combine
import QuickLook

final class ViewController: UIViewController {

    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Transaction History"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let summaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let totalTransactionsCard: SummaryCardView = {
        let card = SummaryCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private let balanceCard: SummaryCardView = {
        let card = SummaryCardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private let generatePDFButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate PDF Report", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Properties
    private var viewModel: TransactionViewModel!
    private var previewItemURL: URL?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    init(viewModel: TransactionViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        setupUI()
        setupConstraints()
        setupTableView()
        setupActions()
        loadInitialData()
    }
    
    // MARK: - Setup
    private func bindViewModel() {
        
        // Observe changes
        viewModel.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateUI()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$showError
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showError in
                if showError {
                    self?.showErrorAlert()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(refreshButton)
        
        contentView.addSubview(summaryStackView)
        summaryStackView.addArrangedSubview(totalTransactionsCard)
        summaryStackView.addArrangedSubview(balanceCard)
        
        contentView.addSubview(generatePDFButton)
        contentView.addSubview(tableView)
        contentView.addSubview(loadingIndicator)
        
        // Configure summary cards
        totalTransactionsCard.configure(title: "Total Transactions", value: "0", icon: "list.bullet")
        balanceCard.configure(title: "Balance", value: "$0.00", icon: "dollarsign.circle")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header View
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 120),
            
            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            // Refresh Button
            refreshButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            refreshButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 44),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Summary Stack View
            summaryStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            summaryStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            summaryStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            summaryStackView.heightAnchor.constraint(equalToConstant: 120),
            
            // Generate PDF Button
            generatePDFButton.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: 20),
            generatePDFButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            generatePDFButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            generatePDFButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Table View
            tableView.topAnchor.constraint(equalTo: generatePDFButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 400),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Loading Indicator
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }
    
    private func setupActions() {
        generatePDFButton.addTarget(self, action: #selector(generatePDFButtonTapped), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadInitialData() {
        print("DEBUG: Starting to load initial data")
        Task {
            print("DEBUG: Fetching transactions in background task")
            await viewModel.fetchTransactions()
            print("DEBUG: Transaction fetch completed")
        }
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        totalTransactionsCard.updateValue("\(viewModel.totalTransactions)")
        balanceCard.updateValue(viewModel.formattedBalance)
        tableView.reloadData()
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            generatePDFButton.isEnabled = false
            refreshButton.isEnabled = false
        } else {
            loadingIndicator.stopAnimating()
            generatePDFButton.isEnabled = true
            refreshButton.isEnabled = true
        }
    }
    
    // MARK: - Actions
    @objc private func generatePDFButtonTapped() {
        guard let pdfData = viewModel.generatePDF() else {
            showAlert(title: "Error", message: "No transactions available to generate PDF")
            return
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Transaction_Report_\(viewModel.transactionId).pdf")
        try? pdfData.write(to: tempURL)
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewItemURL = tempURL
        
        present(previewController, animated: true)
    }
    
    @objc private func refreshButtonTapped() {
        Task {
            await viewModel.refreshData()
        }
    }
    
    // MARK: - Error Handling
    private func showErrorAlert() {
        guard let errorMessage = viewModel.errorMessage else { return }
        showAlert(title: "Error", message: errorMessage)
        viewModel.clearError()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        let transaction = viewModel.transactions[indexPath.row]
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - QLPreviewControllerDataSource Methods
extension ViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return previewItemURL! as QLPreviewItem
    }
}
