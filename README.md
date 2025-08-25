# GeneratePDFApp - iOS Transaction Report Generator

A comprehensive iOS application built with Swift that fetches transaction data from an API, displays it in a beautiful UI, and generates professional PDF reports.

## Features

### 🚀 Core Functionality
- **API Integration**: Fetches transaction data from REST API
- **Real-time Data**: Live transaction updates with pull-to-refresh
- **PDF Generation**: Creates professional PDF reports with tables and user details
- **Offline Support**: CoreData integration for data persistence
- **Modern UI**: Beautiful, responsive interface with Auto Layout

### 📱 User Interface
- **Transaction List**: Card-based transaction display with status indicators
- **Summary Cards**: Real-time transaction count and balance display
- **Generate PDF Button**: One-tap PDF report generation
- **Loading States**: Smooth loading indicators and error handling
- **Responsive Design**: Optimized for all iOS device sizes

### 🔧 Technical Features
- **MVVM Architecture**: Clean separation of concerns
- **Protocol-Oriented Design**: Highly testable and maintainable code
- **Combine Framework**: Modern reactive programming
- **CoreData Integration**: Robust data persistence
- **Error Handling**: Comprehensive error management
- **Memory Management**: Efficient resource usage

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** architectural pattern with clean separation of concerns:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│     View        │    │    ViewModel     │    │      Model      │
│                 │◄──►│                  │◄──►│                 │
│  ViewController │    │ TransactionVM    │    │ CoreData Models │
│  TableView      │    │                  │    │ API Models      │
│  UI Components  │    │ Business Logic   │    │ Services        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Layer Breakdown

1. **Presentation Layer (View)**
   - `ViewController`: Main UI controller
   - `TransactionTableViewCell`: Custom table cell
   - `SummaryCardView`: Summary statistics cards

2. **Business Logic Layer (ViewModel)**
   - `TransactionViewModel`: Manages data and business logic
   - Reactive updates using Combine framework

3. **Data Layer (Model)**
   - `TransactionResponse`: API response models
   - `Transaction`: CoreData entity
   - `NetworkService`: API communication
   - `CoreDataService`: Data persistence
   - `PDFService`: PDF generation

## Installation & Setup

### Prerequisites
- Xcode 14.0+
- iOS 15.0+
- Swift 5.7+

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd GeneratePDFApp
   ```

2. **Open in Xcode**
   ```bash
   open GeneratePDFApp.xcodeproj
   ```

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### CoreData Setup

The app automatically sets up CoreData with the following entity:

- **Transaction**: Stores transaction data locally
  - `transactionDate`: Date of transaction
  - `transactionCategory`: Category/description
  - `transactionID`: Unique identifier
  - `status`: Transaction status
  - `amount`: Transaction amount
  - `transactionType`: Credit/Debit type
  - `createdAt`: Local creation timestamp


### Error Handling
- Network connectivity issues
- API response errors
- Data parsing failures
- Offline fallback to cached data

## PDF Generation

### Features
- **Professional Layout**: Clean, structured design
- **User Details**: Hardcoded user information header
- **Transaction Table**: Organized data presentation
- **Multi-page Support**: Automatic pagination
- **Metadata**: PDF properties and security

### PDF Structure
1. **Header Section**
   - App logo placeholder
   - "Transaction Report" title

2. **User Information**
   - Name, Email, Mobile
   - Card details and address

3. **Transaction Table**
   - Date, Narration, Transaction ID
   - Status, Credit, Debit columns
   - Formatted data rows

## Performance Optimizations

### Caching Strategy
- **CoreData**: Local data persistence
- **Offline Support**: Cached data when offline
- **Efficient Queries**: Optimized CoreData fetch requests

### UI Performance
- **Cell Reuse**: Efficient table view cell management
- **Lazy Loading**: On-demand data loading
- **Background Processing**: Non-blocking UI updates

### DEMO

TBD

---

**Built with ❤️ using Swift and iOS best practices**
