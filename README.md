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

**[Follow here for Video Demo link](https://drive.google.com/drive/folders/1SzcTrUMCiDonnJNYNJ77JqtsE2PIQlhk?usp=sharing)**

| First Load  | Post Loading |
| ------------ | ----------- | 
| <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-08-25 at 10 55 04" src="https://github.com/user-attachments/assets/fcce23ab-24af-4622-b13d-b2ad375f9066" /> | <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-08-25 at 10 55 22" src="https://github.com/user-attachments/assets/c4083674-0f55-4a68-ac6f-d2395ee8f512" /> |

| PDF Preview  | Reloading Data |
| ------------ | ----------- | 
| <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-08-25 at 10 55 34" src="https://github.com/user-attachments/assets/d9874f73-f72b-4555-869c-a50f74a2168b" /> | <img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-08-25 at 10 55 43" src="https://github.com/user-attachments/assets/6140bc77-b076-479d-800c-b557216e3b35" /> |

---

**Built with ❤️ using Swift and iOS best practices**
