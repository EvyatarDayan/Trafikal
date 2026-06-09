//
//  FavoritesExporter.swift
//  Trafikal
//

import Foundation
import SwiftUI
import UIKit

struct FavoritesSignExportItem: Sendable {
    let code: String
    let name: String
    let category: String
    let meaning: String
    let imagePNGData: Data?
}

struct FavoritesQuestionExportItem: Sendable {
    let id: Int
    let category: String
    let question: String
    let answer: String
    let explanation: String
}

struct FavoritesExportContent: Sendable {
    struct Labels: Sendable {
        let documentTitle: String
        let summaryFormat: String
        let signsSectionTitle: String
        let questionsSectionTitle: String
        let codeLabel: String
        let nameLabel: String
        let categoryLabel: String
        let meaningLabel: String
        let questionLabel: String
        let answerLabel: String
        let explanationLabel: String
    }

    let signs: [FavoritesSignExportItem]
    let questions: [FavoritesQuestionExportItem]
    let labels: Labels
    let exportedAt: Date
    let locale: Locale
}

enum FavoritesExporter {
    private static let signImageMaxSide: CGFloat = 88

    @MainActor
    static func pngData(for sign: Sign) -> Data? {
        if let imageName = sign.imageName, let image = UIImage(named: imageName) {
            return image.pngData()
        }

        let renderer = ImageRenderer(
            content: SignGraphicView(sign: sign)
                .frame(width: signImageMaxSide, height: signImageMaxSide)
        )
        renderer.scale = 2
        return renderer.uiImage?.pngData()
    }

    static func dateStamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }

    static func createPDF(content: FavoritesExportContent, fileName: String) throws -> URL {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let margin: CGFloat = 48
        let contentWidth = pageRect.width - (margin * 2)
        let bottomLimit = pageRect.height - margin
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let accentColor = UIColor(red: 23 / 255, green: 94 / 255, blue: 155 / 255, alpha: 1)
        let totalCount = content.signs.count + content.questions.count

        let dateFormatter = DateFormatter()
        dateFormatter.locale = content.locale
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let exportedAtText = dateFormatter.string(from: content.exportedAt)
        let summary = String(format: content.labels.summaryFormat, exportedAtText, totalCount)

        try renderer.writePDF(to: fileURL) { context in
            var y = margin

            func beginPage() {
                context.beginPage()
                y = margin
            }

            func drawSectionTitle(_ text: String, spacingAfter: CGFloat = 18) {
                let font = UIFont.systemFont(ofSize: 24, weight: .bold)
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: accentColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                let rect = NSString(string: text).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )

                if y + ceil(rect.height) > bottomLimit {
                    beginPage()
                }

                NSString(string: text).draw(
                    in: CGRect(
                        x: margin,
                        y: y,
                        width: contentWidth,
                        height: ceil(rect.height)
                    ),
                    withAttributes: attributes
                )
                y += ceil(rect.height) + spacingAfter
            }

            func drawCenteredText(
                _ text: String,
                font: UIFont,
                color: UIColor = .label,
                spacingAfter: CGFloat = 8
            ) {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center

                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraphStyle
                ]
                let rect = NSString(string: text).boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )

                if y + ceil(rect.height) > bottomLimit {
                    beginPage()
                }

                NSString(string: text).draw(
                    in: CGRect(
                        x: margin,
                        y: y,
                        width: contentWidth,
                        height: ceil(rect.height)
                    ),
                    withAttributes: attributes
                )
                y += ceil(rect.height) + spacingAfter
            }

            func drawText(
                _ text: String,
                font: UIFont,
                color: UIColor = .label,
                indent: CGFloat = 0,
                spacingAfter: CGFloat = 8
            ) {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color
                ]
                let rect = NSString(string: text).boundingRect(
                    with: CGSize(width: contentWidth - indent, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )

                if y + ceil(rect.height) > bottomLimit {
                    beginPage()
                }

                NSString(string: text).draw(
                    in: CGRect(
                        x: margin + indent,
                        y: y,
                        width: contentWidth - indent,
                        height: ceil(rect.height)
                    ),
                    withAttributes: attributes
                )
                y += ceil(rect.height) + spacingAfter
            }

            func drawImage(_ pngData: Data?, spacingAfter: CGFloat = 10) {
                guard let pngData, let image = UIImage(data: pngData) else { return }

                let maxSide = Self.signImageMaxSide
                let aspect = image.size.width / max(image.size.height, 1)
                let width: CGFloat
                let height: CGFloat
                if aspect >= 1 {
                    width = maxSide
                    height = maxSide / aspect
                } else {
                    height = maxSide
                    width = maxSide * aspect
                }

                if y + height > bottomLimit {
                    beginPage()
                }

                let imageRect = CGRect(x: margin, y: y, width: width, height: height)
                image.draw(in: imageRect)
                y += height + spacingAfter
            }

            func drawDivider() {
                if y + 18 > bottomLimit {
                    beginPage()
                }

                y += 6
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: y))
                UIColor.separator.setStroke()
                path.lineWidth = 1
                path.stroke()
                y += 18
            }

            beginPage()
            drawCenteredText(
                content.labels.documentTitle,
                font: .systemFont(ofSize: 28, weight: .bold),
                color: accentColor,
                spacingAfter: 6
            )
            drawCenteredText(
                summary,
                font: .systemFont(ofSize: 12),
                color: .secondaryLabel,
                spacingAfter: 24
            )

            if !content.signs.isEmpty {
                drawSectionTitle(content.labels.signsSectionTitle)

                for (index, sign) in content.signs.enumerated() {
                    if y > bottomLimit - 200 {
                        beginPage()
                    }

                    drawText(
                        "\(index + 1). \(sign.code)",
                        font: .systemFont(ofSize: 18, weight: .semibold),
                        color: accentColor,
                        spacingAfter: 8
                    )
                    drawImage(sign.imagePNGData, spacingAfter: 10)
                    drawText(
                        "\(content.labels.nameLabel): \(sign.name)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 5
                    )
                    drawText(
                        "\(content.labels.categoryLabel): \(sign.category)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 5
                    )
                    drawText(
                        "\(content.labels.meaningLabel): \(sign.meaning)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 10
                    )

                    if index < content.signs.count - 1 {
                        drawDivider()
                    }
                }
            }

            if !content.questions.isEmpty {
                beginPage()
                drawSectionTitle(content.labels.questionsSectionTitle)

                for (index, question) in content.questions.enumerated() {
                    if y > bottomLimit - 160 {
                        beginPage()
                    }

                    drawText(
                        "\(index + 1). #\(question.id)",
                        font: .systemFont(ofSize: 18, weight: .semibold),
                        color: accentColor,
                        spacingAfter: 6
                    )
                    drawText(
                        "\(content.labels.categoryLabel): \(question.category)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 5
                    )
                    drawText(
                        "\(content.labels.questionLabel): \(question.question)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 5
                    )
                    drawText(
                        "\(content.labels.answerLabel): \(question.answer)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 5
                    )
                    drawText(
                        "\(content.labels.explanationLabel): \(question.explanation)",
                        font: .systemFont(ofSize: 14),
                        spacingAfter: 10
                    )

                    if index < content.questions.count - 1 {
                        drawDivider()
                    }
                }
            }
        }

        return fileURL
    }
}
