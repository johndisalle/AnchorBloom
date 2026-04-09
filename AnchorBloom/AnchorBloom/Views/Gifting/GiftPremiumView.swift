import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Gift Premium View
struct GiftPremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var recipientName = ""
    @State private var recipientEmail = ""
    @State private var personalMessage = ""
    @State private var selectedPlan: GiftPlan = .yearly
    @State private var showPreview = false
    @State private var isSending = false
    @State private var showSuccess = false

    enum GiftPlan: String, CaseIterable {
        case monthly = "1 Month"
        case threeMonth = "3 Months"
        case yearly = "1 Year"

        var price: String {
            switch self {
            case .monthly: return "$3.99"
            case .threeMonth: return "$9.99"
            case .yearly: return "$29.99"
            }
        }

        var description: String {
            switch self {
            case .monthly: return "A month of deeper growth"
            case .threeMonth: return "A season of transformation"
            case .yearly: return "A full year of blooming — best value"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    if showSuccess {
                        successView
                    } else {
                        giftForm
                    }
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Gift Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .sheet(isPresented: $showPreview) {
                GiftCardPreviewView(
                    recipientName: recipientName,
                    senderName: Auth.auth().currentUser?.displayName ?? "A Sister in Christ",
                    message: personalMessage,
                    plan: selectedPlan
                )
            }
        }
    }

    // MARK: - Gift Form

    private var giftForm: some View {
        VStack(spacing: ABTheme.paddingLarge) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 40))
                    .foregroundColor(ABTheme.warmGold)

                Text("Gift Anchor & Bloom Premium")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)
                    .multilineTextAlignment(.center)

                Text("Give a sister the gift of deeper growth in Christ")
                    .font(ABTheme.captionFont)
                    .foregroundColor(ABTheme.secondaryText)
            }
            .padding(.top, ABTheme.paddingSmall)

            // Plan selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Choose a Plan")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)

                ForEach(GiftPlan.allCases, id: \.self) { plan in
                    Button {
                        selectedPlan = plan
                    } label: {
                        HStack(spacing: 12) {
                            Circle()
                                .stroke(selectedPlan == plan ? ABTheme.warmGold : ABTheme.secondaryText.opacity(0.3), lineWidth: 2)
                                .frame(width: 22, height: 22)
                                .overlay(
                                    Circle()
                                        .fill(selectedPlan == plan ? ABTheme.warmGold : Color.clear)
                                        .frame(width: 12, height: 12)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(plan.rawValue)
                                        .font(.system(.body, design: .serif, weight: .semibold))
                                        .foregroundColor(ABTheme.primaryText)
                                    Spacer()
                                    Text(plan.price)
                                        .font(.system(.body, design: .serif, weight: .bold))
                                        .foregroundColor(ABTheme.warmGold)
                                }
                                Text(plan.description)
                                    .font(.caption)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(selectedPlan == plan ? ABTheme.warmGold.opacity(0.08) : ABTheme.cardBackground)
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                .stroke(selectedPlan == plan ? ABTheme.warmGold.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Recipient info
            VStack(alignment: .leading, spacing: 8) {
                Text("Who's This For?")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)

                TextField("Her name", text: $recipientName)
                    .font(ABTheme.bodyFont)
                    .padding()
                    .background(ABTheme.softWhite)
                    .cornerRadius(ABTheme.cornerRadiusSmall)
                    .overlay(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall).stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1))

                TextField("Her email", text: $recipientEmail)
                    .font(ABTheme.bodyFont)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .padding()
                    .background(ABTheme.softWhite)
                    .cornerRadius(ABTheme.cornerRadiusSmall)
                    .overlay(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall).stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1))
            }

            // Personal message
            VStack(alignment: .leading, spacing: 8) {
                Text("Add a Personal Message (optional)")
                    .font(ABTheme.subheadlineFont)
                    .foregroundColor(ABTheme.primaryText)

                TextEditor(text: $personalMessage)
                    .font(.system(.body, design: .serif))
                    .frame(minHeight: 80)
                    .padding(8)
                    .background(ABTheme.softWhite)
                    .cornerRadius(ABTheme.cornerRadiusSmall)
                    .overlay(RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall).stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1))
            }

            // Preview & Send
            Button { showPreview = true } label: {
                HStack {
                    Image(systemName: "eye.fill")
                    Text("Preview Gift Card")
                }
            }
            .buttonStyle(ABSecondaryButtonStyle())
            .disabled(recipientName.isEmpty || recipientEmail.isEmpty)

            Button { sendGift() } label: {
                HStack {
                    if isSending {
                        ProgressView().tint(.white).scaleEffect(0.8)
                    } else {
                        Image(systemName: "gift.fill")
                    }
                    Text("Send Gift")
                }
            }
            .buttonStyle(ABPremiumButtonStyle())
            .disabled(recipientName.isEmpty || recipientEmail.isEmpty || isSending)

            Spacer().frame(height: 40)
        }
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: ABTheme.paddingLarge) {
            Spacer().frame(height: 60)

            Image(systemName: "gift.fill")
                .font(.system(size: 56))
                .foregroundColor(ABTheme.warmGold)

            Text("Gift Sent!")
                .font(ABTheme.titleFont)
                .foregroundColor(ABTheme.primaryText)

            Text("\(recipientName) will receive a beautiful gift notification at \(recipientEmail)")
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)

            Text("You just invested in a sister's spiritual growth. That's kingdom work.")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(ABTheme.warmGold)
                .multilineTextAlignment(.center)

            Button("Done") { dismiss() }
                .buttonStyle(ABPrimaryButtonStyle())

            Spacer()
        }
        .padding(ABTheme.paddingLarge)
    }

    // MARK: - Send Gift

    private func sendGift() {
        isSending = true
        let senderID = Auth.auth().currentUser?.uid ?? ""
        let senderName = Auth.auth().currentUser?.displayName ?? "A Sister"

        let giftData: [String: Any] = [
            "senderID": senderID,
            "senderName": senderName,
            "recipientName": recipientName,
            "recipientEmail": recipientEmail.lowercased(),
            "personalMessage": personalMessage,
            "plan": selectedPlan.rawValue,
            "createdAt": Timestamp(date: Date()),
            "redeemed": false
        ]

        Task {
            _ = try? await Firestore.firestore().collection("gifts").addDocument(data: giftData)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            showSuccess = true
            isSending = false
        }
    }
}

// MARK: - Gift Card Preview
struct GiftCardPreviewView: View {
    let recipientName: String
    let senderName: String
    let message: String
    let plan: GiftPremiumView.GiftPlan
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: ABTheme.paddingLarge) {
                Spacer()

                // Gift card
                GiftCardImage(recipientName: recipientName, senderName: senderName, message: message, plan: plan)
                    .frame(maxWidth: 340)

                Spacer()

                // Share
                if let image = renderCard() {
                    ShareLink(item: image, preview: SharePreview("Anchor & Bloom Gift", image: image)) {
                        HStack { Image(systemName: "square.and.arrow.up"); Text("Share Gift Card") }
                    }
                    .buttonStyle(ABSecondaryButtonStyle())
                }

                Spacer().frame(height: 20)
            }
            .padding(.horizontal, ABTheme.paddingLarge)
            .abScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    @MainActor
    private func renderCard() -> Image? {
        let renderer = ImageRenderer(
            content: GiftCardImage(recipientName: recipientName, senderName: senderName, message: message, plan: plan)
                .frame(width: 600, height: 400)
        )
        renderer.scale = 3.0
        guard let uiImage = renderer.uiImage else { return nil }
        return Image(uiImage: uiImage)
    }
}

// MARK: - Gift Card Image (Renderable)
struct GiftCardImage: View {
    let recipientName: String
    let senderName: String
    let message: String
    let plan: GiftPremiumView.GiftPlan

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.87, blue: 0.73), Color(red: 0.85, green: 0.75, blue: 0.55), Color(red: 0.93, green: 0.87, blue: 0.73)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.3), lineWidth: 2).padding(8)

            VStack(spacing: 12) {
                Spacer()

                Image(systemName: "gift.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))

                Text("A Gift for You")
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundColor(.white)

                Text("Dear \(recipientName),")
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(.white.opacity(0.9))

                if !message.isEmpty {
                    Text("\"\(message)\"")
                        .font(.system(.caption, design: .serif).italic())
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 20)
                }

                Text("\(plan.rawValue) of Anchor & Bloom Premium")
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.2))
                    .cornerRadius(12)

                Text("With love, \(senderName)")
                    .font(.system(.caption, design: .serif))
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "anchor").font(.system(size: 10))
                    Text("Anchor & Bloom").font(.system(.caption2, design: .serif, weight: .medium))
                }.foregroundColor(.white.opacity(0.4)).padding(.bottom, 12)
            }
            .padding(ABTheme.paddingLarge)
        }
        .aspectRatio(1.5, contentMode: .fit)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
    }
}
