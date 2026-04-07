import SwiftUI
import UIKit

// MARK: - Journal Export View
/// Premium-only feature: exports all journal reflections as a beautiful PDF
struct JournalExportView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    // MARK: State
    @State private var entries: [DailyEntry] = []
    @State private var userProfile: UserProfile?
    @State private var isLoadingEntries = false
    @State private var isGeneratingPDF = false
    @State private var generatedPDFURL: URL?
    @State private var exportError: String?
    @State private var showError = false

    // Date range filter
    @State private var filterStartDate: Date = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
    @State private var filterEndDate: Date = Date()
    @State private var useCustomRange = false

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    // MARK: Computed stats
    private var filteredEntries: [DailyEntry] {
        guard useCustomRange else { return entries }
        return entries.filter { entry in
            entry.date >= filterStartDate && entry.date <= filterEndDate
        }
    }

    private var totalAnchors: Int {
        filteredEntries.filter { $0.anchorCompleted }.count
    }

    private var totalBlooms: Int {
        filteredEntries.filter { $0.bloomCompleted }.count
    }

    private var totalDrifts: Int {
        filteredEntries.reduce(0) { $0 + $1.driftEntries.count }
    }

    private var currentStreak: Int {
        userProfile?.currentStreak ?? 0
    }

    private var dateRangeLabel: String {
        if useCustomRange {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "\(formatter.string(from: filterStartDate)) – \(formatter.string(from: filterEndDate))"
        }
        return "All time"
    }

    // MARK: Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {

                    // Premium gate
                    if !subscriptionManager.isPremium {
                        premiumGateSection
                    } else {
                        titleSection
                        previewSection
                        dateRangeSection
                        statsSection
                        generateSection
                    }

                    Spacer(minLength: ABTheme.paddingXLarge)
                }
                .padding(ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("Export Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .task {
                await loadData()
            }
            .alert("Export Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(exportError ?? "An unknown error occurred.")
            }
        }
    }

    // MARK: - Premium Gate

    private var premiumGateSection: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "lock.fill")
                .font(.system(size: 40, weight: .regular, design: .default))
                .foregroundColor(ABTheme.warmGold)
                .padding(.top, ABTheme.paddingLarge)

            Text("Premium Feature")
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text("Export your entire prayer journal as a beautiful PDF — a keepsake of your year walking with God.")
                .font(.system(.body, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button("Upgrade to Premium") { }
                .buttonStyle(ABPremiumButtonStyle())
                .padding(.top, ABTheme.paddingSmall)
        }
        .padding(ABTheme.paddingMedium)
        .abCard()
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.richtext")
                .font(.system(size: 36, weight: .regular, design: .default))
                .foregroundColor(ABTheme.sageGreen)

            Text("Your Year with God — \(currentYear)")
                .font(ABTheme.headlineFont)
                .foregroundColor(ABTheme.primaryText)
                .multilineTextAlignment(.center)

            Text("A devotional journal from Anchor & Bloom")
                .font(.system(.subheadline, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
                .italic()
        }
        .multilineTextAlignment(.center)
        .padding(.top, ABTheme.paddingSmall)
    }

    // MARK: - Preview Section

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            Text("What's included")
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundColor(ABTheme.secondaryText)
                .textCase(.uppercase)

            VStack(spacing: 10) {
                previewRow(icon: "book.closed.fill", color: ABTheme.warmGold,
                           title: "Cover Page",
                           subtitle: "Your name, year, and total stats")
                previewRow(icon: "sun.horizon.fill", color: ABTheme.sageGreen,
                           title: "Morning Anchors",
                           subtitle: "Scripture, reflections & anchor tags")
                previewRow(icon: "moon.stars.fill", color: ABTheme.blushDark,
                           title: "Evening Blooms",
                           subtitle: "Roles, reflections & gratitude")
                previewRow(icon: "waveform.path.ecg", color: ABTheme.blush,
                           title: "Drift Entries",
                           subtitle: "Moments of grace and return")
                previewRow(icon: "star.fill", color: ABTheme.warmGold,
                           title: "Closing Page",
                           subtitle: "\"Keep growing, sister.\" — a summary")
            }
        }
        .padding(ABTheme.paddingMedium)
        .abCard()
    }

    private func previewRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundColor(ABTheme.primaryText)
                Text(subtitle)
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(ABTheme.secondaryText)
            }
            Spacer()
        }
    }

    // MARK: - Date Range Section

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            Text("Date range")
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundColor(ABTheme.secondaryText)
                .textCase(.uppercase)

            Toggle(isOn: $useCustomRange) {
                Text("Custom date range")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundColor(ABTheme.primaryText)
            }
            .tint(ABTheme.sageGreen)

            if useCustomRange {
                VStack(spacing: ABTheme.paddingSmall) {
                    DatePicker("From", selection: $filterStartDate, displayedComponents: .date)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(ABTheme.primaryText)
                        .tint(ABTheme.sageGreen)

                    DatePicker("To", selection: $filterEndDate, in: filterStartDate..., displayedComponents: .date)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(ABTheme.primaryText)
                        .tint(ABTheme.sageGreen)
                }
                .padding(.top, 4)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(.caption, design: .default))
                        .foregroundColor(ABTheme.sageGreen)
                    Text("Exporting all journal entries")
                        .font(.system(.caption, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)
                }
            }
        }
        .padding(ABTheme.paddingMedium)
        .abCard()
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: ABTheme.paddingSmall) {
            if isLoadingEntries {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                    Spacer()
                }
                .padding(ABTheme.paddingMedium)
            } else {
                Text("Your journey — \(dateRangeLabel)")
                    .font(.system(.caption, design: .serif, weight: .medium))
                    .foregroundColor(ABTheme.secondaryText)
                    .textCase(.uppercase)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    statCell(value: "\(filteredEntries.count)", label: "Total Entries",
                             icon: "book.fill", color: ABTheme.sageGreen)
                    statCell(value: "\(totalAnchors)", label: "Morning Anchors",
                             icon: "sun.horizon.fill", color: ABTheme.warmGold)
                    statCell(value: "\(totalBlooms)", label: "Evening Blooms",
                             icon: "moon.stars.fill", color: ABTheme.blushDark)
                    statCell(value: "\(currentStreak)", label: "Day Streak",
                             icon: "flame.fill", color: ABTheme.blush)
                }
            }
        }
        .padding(ABTheme.paddingMedium)
        .abCard()
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .regular, design: .default))
                .foregroundColor(color)

            Text(value)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)

            Text(label)
                .font(.system(.caption2, design: .serif))
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(ABTheme.paddingSmall)
        .background(color.opacity(0.07))
        .cornerRadius(ABTheme.cornerRadiusSmall)
    }

    // MARK: - Generate Section

    private var generateSection: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            if let pdfURL = generatedPDFURL {
                // Show share button once PDF is ready
                VStack(spacing: ABTheme.paddingSmall) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ABTheme.sageGreen)
                        Text("Your journal PDF is ready!")
                            .font(.system(.subheadline, design: .serif, weight: .medium))
                            .foregroundColor(ABTheme.primaryText)
                    }

                    ShareLink(
                        item: pdfURL,
                        preview: SharePreview(
                            "My Journal — Anchor & Bloom \(currentYear)",
                            icon: Image(systemName: "doc.richtext")
                        )
                    ) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share PDF Journal")
                        }
                    }
                    .buttonStyle(ABPrimaryButtonStyle())

                    Button {
                        generatedPDFURL = nil
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Regenerate")
                        }
                    }
                    .buttonStyle(ABSecondaryButtonStyle())
                }

            } else if isGeneratingPDF {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                        .scaleEffect(1.2)
                    Text("Crafting your journal…")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(ABTheme.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(ABTheme.paddingMedium)

            } else {
                Button {
                    Task { await generatePDF() }
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                        Text(filteredEntries.isEmpty ? "No entries to export" : "Generate PDF")
                    }
                }
                .buttonStyle(ABPrimaryButtonStyle())
                .disabled(filteredEntries.isEmpty || isLoadingEntries)
            }
        }
    }

    // MARK: - Data Loading

    private func loadData() async {
        isLoadingEntries = true
        defer { isLoadingEntries = false }

        async let entriesResult = firestoreService.fetchAllEntries()
        async let profileResult = firestoreService.fetchUserProfile()

        entries = (try? await entriesResult) ?? []
        userProfile = try? await profileResult
    }

    // MARK: - PDF Generation

    private func generatePDF() async {
        isGeneratingPDF = true
        defer { isGeneratingPDF = false }

        let entriesToExport = filteredEntries
        let profile = userProfile

        do {
            let url = try await Task.detached(priority: .userInitiated) {
                try JournalPDFGenerator.generate(
                    entries: entriesToExport,
                    profile: profile,
                    year: Calendar.current.component(.year, from: Date())
                )
            }.value
            generatedPDFURL = url
        } catch {
            exportError = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Journal PDF Generator

/// Generates a multi-page PDF of the user's journal using UIGraphicsPDFRenderer
enum JournalPDFGenerator {

    // MARK: Page size (US Letter)
    static let pageWidth: CGFloat  = 612
    static let pageHeight: CGFloat = 792
    static let marginH: CGFloat    = 56
    static let marginV: CGFloat    = 64
    static let contentWidth: CGFloat = pageWidth - marginH * 2

    // MARK: - Public Entry Point

    /// Generates the PDF and returns a file URL in the temp directory.
    static func generate(entries: [DailyEntry], profile: UserProfile?, year: Int) throws -> URL {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

        let sortedEntries = entries.sorted { $0.date < $1.date }

        let dateRange: String = {
            if let first = sortedEntries.first, let last = sortedEntries.last {
                let fmt = DateFormatter()
                fmt.dateStyle = .long
                fmt.timeStyle = .none
                return "\(fmt.string(from: first.date)) – \(fmt.string(from: last.date))"
            }
            return "\(year)"
        }()

        let totalAnchors = sortedEntries.filter { $0.anchorCompleted }.count
        let totalBlooms  = sortedEntries.filter { $0.bloomCompleted }.count
        let totalDrifts  = sortedEntries.reduce(0) { $0 + $1.driftEntries.count }
        let streak       = profile?.currentStreak ?? 0

        let data = renderer.pdfData { ctx in
            // Cover page
            ctx.beginPage()
            drawCoverPage(
                ctx: ctx,
                profile: profile,
                year: year,
                dateRange: dateRange,
                totalEntries: sortedEntries.count,
                totalAnchors: totalAnchors,
                totalBlooms: totalBlooms,
                streak: streak
            )

            // Entry pages — one page per journal day
            for entry in sortedEntries {
                ctx.beginPage()
                drawEntryPage(ctx: ctx, entry: entry)
            }

            // Final page
            ctx.beginPage()
            drawFinalPage(
                ctx: ctx,
                totalEntries: sortedEntries.count,
                totalAnchors: totalAnchors,
                totalBlooms: totalBlooms,
                totalDrifts: totalDrifts,
                streak: streak
            )
        }

        // Write to temp file
        let filename = "AnchorBloom_Journal_\(year).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: tempURL)
        return tempURL
    }

    // MARK: - Cover Page

    private static func drawCoverPage(
        ctx: UIGraphicsPDFRendererContext,
        profile: UserProfile?,
        year: Int,
        dateRange: String,
        totalEntries: Int,
        totalAnchors: Int,
        totalBlooms: Int,
        streak: Int
    ) {
        var y: CGFloat = marginV + 60

        // Brand accent bar at top
        let accentRect = CGRect(x: marginH, y: marginV, width: contentWidth, height: 3)
        UIColor(red: 0.56, green: 0.68, blue: 0.58, alpha: 1).setFill() // sageGreen
        UIBezierPath(roundedRect: accentRect, cornerRadius: 1.5).fill()

        y += 24

        // Main title
        let title = "Your Year with God — \(year)"
        draw(title, at: &y, font: serifBold(24), color: darkNavy(), alignment: .center)
        y += 12

        // User name
        if let name = profile?.displayName, !name.isEmpty {
            draw(name, at: &y, font: serifRegular(16), color: secondaryColor(), alignment: .center)
            y += 8
        }

        // Tagline
        draw("A devotional journal from Anchor & Bloom",
             at: &y, font: serifItalic(14), color: secondaryColor(), alignment: .center)
        y += 40

        // Divider
        drawHorizontalRule(at: y)
        y += 28

        // Date range
        draw("Journal period: \(dateRange)",
             at: &y, font: serifRegular(12), color: secondaryColor(), alignment: .center)
        y += 32

        // Stats grid (2 × 2)
        let statBoxW: CGFloat = contentWidth / 2 - 8
        let statBoxH: CGFloat = 72
        let stats: [(String, String)] = [
            ("\(totalEntries)", "Total Days"),
            ("\(totalAnchors)", "Morning Anchors"),
            ("\(totalBlooms)", "Evening Blooms"),
            ("\(streak)", "Current Streak")
        ]

        for (index, stat) in stats.enumerated() {
            let col = CGFloat(index % 2)
            let row = CGFloat(index / 2)
            let boxX = marginH + col * (statBoxW + 16)
            let boxY = y + row * (statBoxH + 12)
            drawStatBox(value: stat.0, label: stat.1, rect: CGRect(x: boxX, y: boxY, width: statBoxW, height: statBoxH))
        }
        y += 2 * (statBoxH + 12) + 40

        // Bottom watermark
        drawWatermark()
    }

    // MARK: - Entry Page

    private static func drawEntryPage(ctx: UIGraphicsPDFRendererContext, entry: DailyEntry) {
        var y: CGFloat = marginV

        // Date header
        let dateFmt = DateFormatter()
        dateFmt.dateStyle = .full
        dateFmt.timeStyle = .none
        let dateStr = dateFmt.string(from: entry.date)

        draw(dateStr, at: &y, font: serifBold(16), color: darkNavy(), alignment: .left)
        y += 4

        drawHorizontalRule(at: y)
        y += 20

        // Morning Anchor section
        draw("Morning Anchor", at: &y, font: serifBold(13), color: sageGreenColor(), alignment: .left)
        y += 8

        if entry.anchorCompleted {
            if let ref = entry.anchorScriptureRef, !ref.isEmpty {
                draw("Scripture: \(ref)", at: &y, font: serifItalic(11), color: secondaryColor(), alignment: .left)
                y += 6
            }

            if !entry.anchorTags.isEmpty {
                let tagsStr = "Anchor tags: " + entry.anchorTags.map { $0.rawValue }.joined(separator: ", ")
                draw(tagsStr, at: &y, font: serifRegular(11), color: secondaryColor(), alignment: .left)
                y += 6
            }

            if let reflection = entry.anchorReflection, !reflection.isEmpty {
                draw("Reflection:", at: &y, font: serifBold(11), color: darkNavy(), alignment: .left)
                y += 4
                drawWrapped(reflection, startY: &y, font: serifRegular(11), color: darkNavy())
                y += 8
            } else {
                draw("No reflection recorded.", at: &y, font: serifItalic(11), color: secondaryColor(), alignment: .left)
                y += 8
            }
        } else {
            draw("Not completed.", at: &y, font: serifItalic(11), color: secondaryColor(), alignment: .left)
            y += 8
        }

        y += 8
        draw("Evening Bloom", at: &y, font: serifBold(13), color: blushColor(), alignment: .left)
        y += 8

        if entry.bloomCompleted {
            if !entry.bloomRoles.isEmpty {
                let rolesStr = "Roles: " + entry.bloomRoles.map { $0.rawValue }.joined(separator: ", ")
                draw(rolesStr, at: &y, font: serifRegular(11), color: secondaryColor(), alignment: .left)
                y += 6
            }

            if let reflection = entry.bloomReflection, !reflection.isEmpty {
                draw("Reflection:", at: &y, font: serifBold(11), color: darkNavy(), alignment: .left)
                y += 4
                drawWrapped(reflection, startY: &y, font: serifRegular(11), color: darkNavy())
                y += 8
            } else {
                draw("No reflection recorded.", at: &y, font: serifItalic(11), color: secondaryColor(), alignment: .left)
                y += 8
            }
        } else {
            draw("Not completed.", at: &y, font: serifItalic(11), color: secondaryColor(), alignment: .left)
            y += 8
        }

        // Drift entries
        if !entry.driftEntries.isEmpty {
            y += 8
            draw("Drift Moments", at: &y, font: serifBold(13), color: warmGoldColor(), alignment: .left)
            y += 8

            let timeFmt = DateFormatter()
            timeFmt.dateStyle = .none
            timeFmt.timeStyle = .short

            for drift in entry.driftEntries {
                let timeStr = timeFmt.string(from: drift.timestamp)
                var line = "• \(drift.category.rawValue) — \(timeStr)"
                if let note = drift.note, !note.isEmpty {
                    line += ": \(note)"
                }
                drawWrapped(line, startY: &y, font: serifRegular(11), color: darkNavy())
                y += 4
            }
        }

        // Day separator at bottom
        if y < pageHeight - marginV - 20 {
            y = pageHeight - marginV - 20
        }
        drawHorizontalRule(at: y)

        drawWatermark()
    }

    // MARK: - Final Page

    private static func drawFinalPage(
        ctx: UIGraphicsPDFRendererContext,
        totalEntries: Int,
        totalAnchors: Int,
        totalBlooms: Int,
        totalDrifts: Int,
        streak: Int
    ) {
        var y: CGFloat = marginV + 80

        // Closing sentiment
        draw("Keep growing, sister.", at: &y, font: serifBold(28), color: darkNavy(), alignment: .center)
        y += 16

        draw("Every entry in these pages is a seed of faith planted.", at: &y, font: serifItalic(14), color: secondaryColor(), alignment: .center)
        draw("God wastes nothing.", at: &y, font: serifItalic(14), color: secondaryColor(), alignment: .center)
        y += 40

        drawHorizontalRule(at: y)
        y += 32

        // Summary stats
        draw("Your journey at a glance", at: &y, font: serifBold(14), color: darkNavy(), alignment: .center)
        y += 20

        let summaryLines: [(String, String)] = [
            ("Days in the journal:", "\(totalEntries)"),
            ("Morning Anchors completed:", "\(totalAnchors)"),
            ("Evening Blooms completed:", "\(totalBlooms)"),
            ("Drift moments logged:", "\(totalDrifts)"),
            ("Current streak:", "\(streak) days")
        ]

        for line in summaryLines {
            let rowStr = "\(line.0)  \(line.1)"
            draw(rowStr, at: &y, font: serifRegular(12), color: darkNavy(), alignment: .center)
            y += 4
        }

        y += 40

        // Brand closing
        draw("Anchor & Bloom", at: &y, font: serifBold(12), color: sageGreenColor(), alignment: .center)
        draw("anchorbloom.app", at: &y, font: serifRegular(11), color: secondaryColor(), alignment: .center)

        drawWatermark()
    }

    // MARK: - Drawing Helpers

    private static func draw(
        _ text: String,
        at y: inout CGFloat,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment
    ) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attrStr = NSAttributedString(string: text, attributes: attrs)
        let constraintSize = CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
        let boundingRect = attrStr.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil)
        let lineHeight = boundingRect.height

        let x: CGFloat
        switch alignment {
        case .center:
            x = marginH + (contentWidth - boundingRect.width) / 2
        default:
            x = marginH
        }

        attrStr.draw(in: CGRect(x: x, y: y, width: contentWidth, height: lineHeight + 2))
        y += lineHeight + 6
    }

    private static func drawWrapped(
        _ text: String,
        startY: inout CGFloat,
        font: UIFont,
        color: UIColor
    ) {
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 3
        paraStyle.alignment = .left

        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paraStyle
        ]
        let attrStr = NSAttributedString(string: text, attributes: attrs)
        let constraintSize = CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
        let boundingRect = attrStr.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, context: nil)

        attrStr.draw(in: CGRect(x: marginH, y: startY, width: contentWidth, height: boundingRect.height + 2))
        startY += boundingRect.height + 6
    }

    private static func drawHorizontalRule(at y: CGFloat) {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: marginH, y: y))
        path.addLine(to: CGPoint(x: pageWidth - marginH, y: y))
        UIColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.5).setStroke() // warmGold at 50%
        path.lineWidth = 0.75
        path.stroke()
    }

    private static func drawStatBox(value: String, label: String, rect: CGRect) {
        // Background
        UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1).setFill()
        UIBezierPath(roundedRect: rect, cornerRadius: 8).fill()

        // Border
        UIColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.3).setStroke()
        let border = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        border.lineWidth = 0.75
        border.stroke()

        // Value
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: serifBold(22),
            .foregroundColor: darkNavy()
        ]
        let valueStr = NSAttributedString(string: value, attributes: valueAttrs)
        let valueSize = valueStr.boundingRect(with: CGSize(width: rect.width - 16, height: .greatestFiniteMagnitude),
                                              options: .usesLineFragmentOrigin, context: nil).size
        let valueX = rect.midX - valueSize.width / 2
        valueStr.draw(at: CGPoint(x: valueX, y: rect.minY + 12))

        // Label
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: serifRegular(10),
            .foregroundColor: secondaryColor()
        ]
        let labelStr = NSAttributedString(string: label, attributes: labelAttrs)
        let labelSize = labelStr.boundingRect(with: CGSize(width: rect.width - 16, height: .greatestFiniteMagnitude),
                                              options: .usesLineFragmentOrigin, context: nil).size
        let labelX = rect.midX - labelSize.width / 2
        labelStr.draw(at: CGPoint(x: labelX, y: rect.minY + 40))
    }

    private static func drawWatermark() {
        let text = "Anchor & Bloom"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: serifRegular(9),
            .foregroundColor: UIColor(red: 0.56, green: 0.68, blue: 0.58, alpha: 0.5)
        ]
        let attrStr = NSAttributedString(string: text, attributes: attrs)
        let size = attrStr.boundingRect(with: CGSize(width: 200, height: 20),
                                        options: .usesLineFragmentOrigin, context: nil).size
        attrStr.draw(at: CGPoint(x: pageWidth / 2 - size.width / 2, y: pageHeight - marginV + 24))
    }

    // MARK: - Font Helpers

    private static func serifBold(_ size: CGFloat) -> UIFont {
        UIFont(name: "Georgia-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    private static func serifRegular(_ size: CGFloat) -> UIFont {
        UIFont(name: "Georgia", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    private static func serifItalic(_ size: CGFloat) -> UIFont {
        UIFont(name: "Georgia-Italic", size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }

    // MARK: - Color Helpers

    private static func darkNavy() -> UIColor {
        UIColor(red: 0.15, green: 0.18, blue: 0.27, alpha: 1)
    }

    private static func secondaryColor() -> UIColor {
        UIColor(red: 0.45, green: 0.48, blue: 0.55, alpha: 1)
    }

    private static func sageGreenColor() -> UIColor {
        UIColor(red: 0.56, green: 0.68, blue: 0.58, alpha: 1)
    }

    private static func blushColor() -> UIColor {
        UIColor(red: 0.78, green: 0.55, blue: 0.55, alpha: 1)
    }

    private static func warmGoldColor() -> UIColor {
        UIColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 1)
    }
}
