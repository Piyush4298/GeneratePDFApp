import Foundation
import UIKit
import PDFKit

protocol PDFServiceProtocol {
    func generateTransactionReport(transactions: [TransactionResponse]) -> Data?
}

final class PDFService: PDFServiceProtocol {
    
    func generateTransactionReport(transactions: [TransactionResponse]) -> Data? {
        let pageWidth: CGFloat = 612.0  // 8.5 x 72
        let pageHeight: CGFloat = 792.0 // 11 x 72
        let margin: CGFloat = 50.0
        
        let pdfMetaData = [
            kCGPDFContextCreator: "Transaction Report App",
            kCGPDFContextAuthor: UserDetails.name,
            kCGPDFContextTitle: "Transaction Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        
        let data = renderer.pdfData { context in
            let tableRows = transactions.map { PDFTableRow(from: $0) }
            generatePDFPages(context: context, tableRows: tableRows, pageWidth: pageWidth, pageHeight: pageHeight, margin: margin)
        }
        
        return data
    }
    
    private func generatePDFPages(context: UIGraphicsPDFRendererContext, tableRows: [PDFTableRow], pageWidth: CGFloat, pageHeight: CGFloat, margin: CGFloat) {
        context.beginPage()
        let contentHeight = pageHeight - (2 * margin)
        
        var currentY: CGFloat = margin
        var currentPage = 0
        
        // Generate header for first page
        currentY = generateHeader(context: context, pageWidth: pageWidth, margin: margin)
        
        // Generate user details
        currentY = generateUserDetails(context: context, pageWidth: pageWidth, margin: margin, currentY: currentY)
        
        // Generate table
        let (_, needsNewPage) = generateTable(context: context, tableRows: tableRows, pageWidth: pageWidth, margin: margin, currentY: currentY, contentHeight: contentHeight)
        
        if needsNewPage {
            context.beginPage()
            currentPage += 1
            currentY = margin
            currentY = generateTableHeader(context: context, pageWidth: pageWidth, margin: margin, currentY: currentY)
            generateTableRows(context: context, tableRows: tableRows, pageWidth: pageWidth, margin: margin, currentY: currentY)
        }
    }
    
    private func generateHeader(
        context: UIGraphicsPDFRendererContext,
        pageWidth: CGFloat,
        margin: CGFloat
    ) -> CGFloat {
        let logoHeight: CGFloat = 60
        let logoWidth = logoHeight * 3
        let topY: CGFloat = margin
        
        if let logoImage = UIImage(named: "logo") {
            let logoX = pageWidth - margin - logoWidth
            let logoRect = CGRect(x: logoX, y: topY, width: logoWidth, height: logoHeight)
            logoImage.draw(in: logoRect)
        }
        
        return topY
    }


    
    private func generateUserDetails(context: UIGraphicsPDFRendererContext, pageWidth: CGFloat, margin: CGFloat, currentY: CGFloat) -> CGFloat {
        let detailFont = UIFont.systemFont(ofSize: 12)
        let detailAttributes: [NSAttributedString.Key: Any] = [
            .font: detailFont,
            .foregroundColor: UIColor.black
        ]
        
        let details = [
            "Name: \(UserDetails.name)",
            "Email: \(UserDetails.email)",
            "Mobile: \(UserDetails.mobile)",
            "Card Number: \(UserDetails.cardNumber)",
            "Card Type: \(UserDetails.cardType)",
            "Address: \(UserDetails.address)"
        ]
        
        var y = currentY
        for detail in details {
            detail.draw(at: CGPoint(x: margin, y: y), withAttributes: detailAttributes)
            y += 20
        }
        
        return y + 20
    }
    
    private func generateTable(context: UIGraphicsPDFRendererContext, tableRows: [PDFTableRow], pageWidth: CGFloat, margin: CGFloat, currentY: CGFloat, contentHeight: CGFloat) -> (CGFloat, Bool) {
        let tableHeaderHeight = generateTableHeader(context: context, pageWidth: pageWidth, margin: margin, currentY: currentY)
        let tableRowsHeight = generateTableRows(context: context, tableRows: tableRows, pageWidth: pageWidth, margin: margin, currentY: tableHeaderHeight)
        
        let totalTableHeight = tableHeaderHeight - currentY + tableRowsHeight
        let needsNewPage = totalTableHeight > contentHeight
        
        return (totalTableHeight, needsNewPage)
    }
    
    private func generateTableHeader(
        context: UIGraphicsPDFRendererContext,
        pageWidth: CGFloat,
        margin: CGFloat,
        currentY: CGFloat
    ) -> CGFloat {
        
        let headerFont = UIFont.boldSystemFont(ofSize: 12)
        let columns = ["Date", "Narration", "Transaction ID", "Status", "Credit", "Debit"]
        let columnWidths: [CGFloat] = [80, 120, 120, 80, 60, 60]
        let tableWidth = columnWidths.reduce(0, +)
        let rowHeight: CGFloat = 50
        var x = margin
        
        // Draw header background (dark blue)
        let headerRect = CGRect(x: margin, y: currentY, width: tableWidth, height: rowHeight)
        UIColor.darkGray.setFill()
        context.cgContext.fill(headerRect)
        
        for (index, title) in columns.enumerated() {
            let columnRect = CGRect(x: x, y: currentY, width: columnWidths[index], height: rowHeight)
            
            // Text attributes
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: headerFont,
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            // Measure text size for vertical centering
            let textSize = NSString(string: title).size(withAttributes: attributes)
            let textY = currentY + (rowHeight - textSize.height) / 2
            
            // Draw text centered
            let textRect = CGRect(
                x: columnRect.origin.x,
                y: textY,
                width: columnRect.width,
                height: textSize.height
            )
            NSString(string: title).draw(in: textRect, withAttributes: attributes)
            
            // Column border
            context.cgContext.setStrokeColor(UIColor.white.cgColor)
            context.cgContext.stroke(columnRect)
            
            x += columnWidths[index]
        }
        
        // Draw full header outline (outer border)
        context.cgContext.setStrokeColor(UIColor.black.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.stroke(headerRect)
        
        return currentY + rowHeight
    }


    
    @discardableResult
    private func generateTableRows(
        context: UIGraphicsPDFRendererContext,
        tableRows: [PDFTableRow],
        pageWidth: CGFloat,
        margin: CGFloat,
        currentY: CGFloat
    ) -> CGFloat {
        
        let rowFont = UIFont.systemFont(ofSize: 10)
        let rowAttributes: [NSAttributedString.Key: Any] = [
            .font: rowFont,
            .foregroundColor: UIColor.black
        ]
        
        let columnWidths: [CGFloat] = [80, 120, 120, 80, 60, 60]
        let tableWidth = columnWidths.reduce(0, +)
        var y = currentY
        
        for row in tableRows {
            let rowData = [row.date, row.narration, row.transactionID, row.status, row.credit, row.debit]
            
            // 1. Compute row height (dynamic)
            var maxRowHeight: CGFloat = 0
            for (index, data) in rowData.enumerated() {
                let boundingRect = NSString(string: data).boundingRect(
                    with: CGSize(width: columnWidths[index] - 8, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: rowAttributes,
                    context: nil
                )
                maxRowHeight = max(maxRowHeight, ceil(boundingRect.height))
            }
            let rowHeight = maxRowHeight + 12  // padding
            
            // 2. Draw row background (alternating for readability)
            if tableRows.firstIndex(where: { $0.transactionID == row.transactionID })! % 2 == 0 {
                UIColor.systemGray6.setFill()
                context.cgContext.fill(CGRect(x: margin, y: y, width: tableWidth, height: rowHeight))
            }
            
            // 3. Draw each cell with border
            var x = margin
            for (index, data) in rowData.enumerated() {
                let columnRect = CGRect(x: x, y: y, width: columnWidths[index], height: rowHeight)
                
                // Cell text
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: rowFont,
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: paragraphStyle
                ]
                NSString(string: data).draw(in: columnRect.insetBy(dx: 4, dy: 4), withAttributes: attributes)
                
                // Cell border
                context.cgContext.setStrokeColor(UIColor.black.cgColor)
                context.cgContext.stroke(columnRect)
                
                x += columnWidths[index]
            }
            
            y += rowHeight
        }
        
        return y
    }

}
