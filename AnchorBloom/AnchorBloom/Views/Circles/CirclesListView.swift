import SwiftUI
import FirebaseAuth

// MARK: - Circles List View
/// Sister Circles: private small groups for encouragement
struct CirclesListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var circles: [SisterCircle] = []
    @State private var publicCircles: [SisterCircle] = []
    @State private var showCreateCircle = false
    @State private var showJoinCircle = false
    @State private var selectedCircle: SisterCircle?
    @State private var isLoading = false
    @State private var showUpgradePrompt = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.title)
                            .foregroundColor(ABTheme.blush)

                        Text("Sister Circles")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Walk together in faith, encouragement, and prayer")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    // Action buttons
                    HStack(spacing: 12) {
                        Button {
                            let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? ""
                            let createdCount = circles.filter { $0.creatorID == userID }.count
                            if !subscriptionManager.isPremium && createdCount >= SisterCircle.maxFreeCircles {
                                showUpgradePrompt = true
                            } else {
                                showCreateCircle = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Circle")
                            }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())

                        Button {
                            showJoinCircle = true
                        } label: {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                Text("Join Circle")
                            }
                        }
                        .buttonStyle(ABSecondaryButtonStyle())
                    }

                    // Premium notice for free users
                    if !subscriptionManager.isPremium {
                        HStack(spacing: 10) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(ABTheme.warmGold)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Free members can view circles")
                                    .font(.system(.caption, design: .serif, weight: .medium))
                                Text("Upgrade to Premium to post and comment")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(ABTheme.warmGoldLight.opacity(0.3))
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                    }

                    // My Circles
                    if isLoading {
                        ProgressView()
                            .tint(ABTheme.sageGreen)
                            .padding(.top, 40)
                    } else if circles.isEmpty && publicCircles.isEmpty {
                        emptyState
                    } else {
                        if !circles.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("My Circles")
                                    .font(ABTheme.subheadlineFont)
                                    .foregroundColor(ABTheme.primaryText)

                                ForEach(circles) { circle in
                                    CircleCardView(circle: circle) {
                                        selectedCircle = circle
                                    }
                                }
                            }
                        }

                        // Public circles for discovery
                        if !publicCircles.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Discover Public Circles")
                                    .font(ABTheme.subheadlineFont)
                                    .foregroundColor(ABTheme.primaryText)

                                ForEach(publicCircles) { circle in
                                    CircleCardView(circle: circle, showPublicBadge: true) {
                                        selectedCircle = circle
                                    }
                                }
                            }
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationTitle("Circles")
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                await loadCircles()
            }
            .task {
                await loadCircles()
            }
            .sheet(isPresented: $showCreateCircle) {
                CreateCircleView { newCircle in
                    circles.append(newCircle)
                }
            }
            .sheet(isPresented: $showJoinCircle) {
                JoinCircleView { joinedCircle in
                    if let circle = joinedCircle {
                        circles.append(circle)
                    }
                }
            }
            .sheet(item: $selectedCircle) { circle in
                CircleDetailView(circle: circle)
            }
            .sheet(isPresented: $showUpgradePrompt) {
                SubscriptionView()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: ABTheme.paddingMedium) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundColor(ABTheme.blush.opacity(0.5))

            Text("No circles yet")
                .font(ABTheme.subheadlineFont)
                .foregroundColor(ABTheme.primaryText)

            Text("Create a circle or join one with an invite code to start growing together.")
                .font(ABTheme.captionFont)
                .foregroundColor(ABTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    private func loadCircles() async {
        isLoading = true
        defer { isLoading = false }
        do {
            circles = try await firestoreService.fetchUserCircles()
            publicCircles = try await firestoreService.fetchPublicCircles()
        } catch {
            // Handle error silently for MVP
        }
    }
}

// MARK: - Circle Card
struct CircleCardView: View {
    let circle: SisterCircle
    var showPublicBadge: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ABTheme.paddingMedium) {
                // Circle avatar
                ZStack {
                    Circle()
                        .fill(ABTheme.blush.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Text(String(circle.name.prefix(2)).uppercased())
                        .font(.system(.body, design: .serif, weight: .bold))
                        .foregroundColor(ABTheme.blush)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(circle.name)
                            .font(.system(.body, design: .serif, weight: .semibold))
                            .foregroundColor(ABTheme.primaryText)

                        if showPublicBadge {
                            HStack(spacing: 2) {
                                Image(systemName: "globe")
                                    .font(.system(size: 9))
                                Text("Public")
                                    .font(.system(size: 9, weight: .medium, design: .serif))
                            }
                            .foregroundColor(ABTheme.sageGreen)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(ABTheme.sageGreen.opacity(0.1))
                            .cornerRadius(6)
                        }
                    }

                    Text(circle.description)
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                        Text("\(circle.memberCount) members")
                            .font(.caption2)
                    }
                    .foregroundColor(ABTheme.secondaryText.opacity(0.7))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ABTheme.secondaryText)
            }
            .abCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Create Circle View
struct CreateCircleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var name = ""
    @State private var description = ""
    @State private var isPrivate = true
    @State private var isSaving = false

    let onCreated: (SisterCircle) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    ABTextField(text: $name, placeholder: "Circle name", icon: "heart.circle.fill")
                    ABTextField(text: $description, placeholder: "Description (e.g., 'Young moms growing in faith')", icon: "text.alignleft")

                    Toggle(isOn: $isPrivate) {
                        HStack {
                            Image(systemName: isPrivate ? "lock.fill" : "globe")
                                .foregroundColor(ABTheme.sageGreen)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(isPrivate ? "Private Circle" : "Public Circle")
                                    .font(ABTheme.bodyFont)
                                Text(isPrivate ? "Members join by invite code only" : "Visible to all users for browsing")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }
                    }
                    .tint(ABTheme.sageGreen)

                    Button("Create Circle") {
                        createCircle()
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(name.isEmpty || isSaving)
                }
                .padding(ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("New Circle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    private func createCircle() {
        isSaving = true
        let inviteCode = String((0..<6).map { _ in "ABCDEFGHJKLMNPQRSTUVWXYZ23456789".randomElement()! })

        let creatorID = Auth.auth().currentUser?.uid ?? ""
        let creatorName = Auth.auth().currentUser?.displayName ?? "You"
        let circle = SisterCircle(
            name: name,
            description: description,
            creatorID: creatorID,
            memberIDs: [creatorID],
            memberNames: [creatorID: creatorName],
            adminIDs: [creatorID],
            createdAt: Date(),
            isPrivate: isPrivate,
            inviteCode: inviteCode,
            maxMembers: SisterCircle.defaultMaxMembers,
            coverImageName: "default"
        )

        Task {
            _ = try? await firestoreService.createCircle(circle)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onCreated(circle)
            dismiss()
        }
    }
}

// MARK: - Join Circle View
struct JoinCircleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var inviteCode = ""
    @State private var isJoining = false
    @State private var errorMessage: String?

    let onJoined: (SisterCircle?) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: ABTheme.paddingLarge) {
                Spacer()

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(ABTheme.sageGreen)

                Text("Join a Circle")
                    .font(ABTheme.headlineFont)
                    .foregroundColor(ABTheme.primaryText)

                Text("Enter the invite code shared by your circle leader")
                    .font(ABTheme.captionFont)
                    .foregroundColor(ABTheme.secondaryText)
                    .multilineTextAlignment(.center)

                ABTextField(
                    text: $inviteCode,
                    placeholder: "Invite code",
                    icon: "key.fill",
                    autocapitalization: .characters
                )
                .padding(.horizontal, ABTheme.paddingLarge)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(ABTheme.destructive)
                }

                Button("Join Circle") {
                    joinCircle()
                }
                .buttonStyle(ABPrimaryButtonStyle())
                .padding(.horizontal, ABTheme.paddingLarge)
                .disabled(inviteCode.isEmpty || isJoining)

                Spacer()
                Spacer()
            }
            .abScreenBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    private func joinCircle() {
        isJoining = true
        errorMessage = nil
        Task {
            do {
                let circle = try await firestoreService.joinCircle(inviteCode: inviteCode)
                onJoined(circle)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isJoining = false
            }
        }
    }
}

// MARK: - Circle Detail View
struct CircleDetailView: View {
    let circle: SisterCircle
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var posts: [CirclePost] = []
    @State private var showNewPost = false
    @State private var isLoading = false
    @State private var isJoining = false
    @State private var showDeleteCircleAlert = false
    @State private var showManageMembers = false
    @State private var showLeaveAlert = false
    @State private var blockedUserIDs: [String] = []
    @State private var errorMessage: String?
    @State private var didJoin = false

    private var currentUserID: String {
        FirebaseAuth.Auth.auth().currentUser?.uid ?? ""
    }

    private var isMember: Bool {
        didJoin || circle.memberIDs.contains(currentUserID) || circle.creatorID == currentUserID
    }

    private var isAdmin: Bool {
        circle.isAdmin(currentUserID)
    }

    private var canPost: Bool {
        subscriptionManager.isPremium && isMember
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingMedium) {
                    // Circle header
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Text(circle.name)
                                .font(ABTheme.headlineFont)
                                .foregroundColor(ABTheme.primaryText)

                            Image(systemName: circle.isPrivate ? "lock.fill" : "globe")
                                .font(.caption)
                                .foregroundColor(ABTheme.secondaryText)
                        }

                        Text(circle.description)
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)

                        HStack(spacing: 12) {
                            Label("\(circle.memberCount) members", systemImage: "person.2.fill")
                            if isMember, let code = circle.inviteCode {
                                Label(code, systemImage: "key.fill")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    // Admin controls
                    if isAdmin {
                        HStack(spacing: 10) {
                            Button {
                                showManageMembers = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "person.2.badge.gearshape")
                                        .font(.caption2)
                                    Text("Members")
                                        .font(.system(.caption, design: .serif, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(ABTheme.sageGreen.opacity(0.1))
                                .foregroundColor(ABTheme.sageGreen)
                                .cornerRadius(20)
                            }

                            Button {
                                showDeleteCircleAlert = true
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "trash")
                                        .font(.caption2)
                                    Text("Delete Circle")
                                        .font(.system(.caption, design: .serif, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(ABTheme.destructive.opacity(0.1))
                                .foregroundColor(ABTheme.destructive)
                                .cornerRadius(20)
                            }
                        }
                    } else if isMember {
                        Button {
                            showLeaveAlert = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.right.circle")
                                    .font(.caption2)
                                Text("Leave Circle")
                                    .font(.system(.caption, design: .serif, weight: .medium))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(ABTheme.destructive.opacity(0.1))
                            .foregroundColor(ABTheme.destructive)
                            .cornerRadius(20)
                        }
                    } else if !isMember {
                        // Join button for non-members viewing public circles
                        Button {
                            joinThisCircle()
                        } label: {
                            HStack(spacing: 6) {
                                if isJoining {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "person.badge.plus")
                                }
                                Text("Join This Circle")
                            }
                        }
                        .buttonStyle(ABPrimaryButtonStyle())
                        .disabled(isJoining)
                    }

                    // Notices and post button
                    if !subscriptionManager.isPremium {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(ABTheme.warmGold)
                                .font(.caption)
                            Text("Upgrade to Premium to post, comment, and react")
                                .font(.system(.caption, design: .serif))
                                .foregroundColor(ABTheme.secondaryText)
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(ABTheme.warmGoldLight.opacity(0.2))
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                    } else if canPost {
                        Button {
                            showNewPost = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Share with Sisters")
                            }
                        }
                        .buttonStyle(ABSecondaryButtonStyle())
                    }

                    // Posts (filtered by blocked users)
                    if isLoading {
                        ProgressView().tint(ABTheme.sageGreen)
                    } else if filteredPosts.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.title)
                                .foregroundColor(ABTheme.blush.opacity(0.5))
                            Text("No posts yet. Be the first to share!")
                                .font(ABTheme.captionFont)
                                .foregroundColor(ABTheme.secondaryText)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(filteredPosts) { post in
                            CirclePostView(
                                post: post,
                                circleID: circle.id,
                                isCircleAdmin: isAdmin,
                                isPremium: subscriptionManager.isPremium,
                                blockedUserIDs: blockedUserIDs,
                                onDeleted: {
                                    posts.removeAll { $0.id == post.id }
                                },
                                onBlockedUser: { userID in
                                    blockedUserIDs.append(userID)
                                }
                            )
                        }
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ABTheme.paddingMedium)
            }
            .abScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .task {
                blockedUserIDs = await firestoreService.fetchBlockedUserIDs()
                await loadPosts()
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView(circleID: circle.id ?? "") { post in
                    posts.insert(post, at: 0)
                }
            }
            .sheet(isPresented: $showManageMembers) {
                ManageMembersView(circle: circle, blockedUserIDs: blockedUserIDs)
            }
            .alert("Delete Circle?", isPresented: $showDeleteCircleAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        guard let circleID = circle.id else { return }
                        do {
                            try await firestoreService.deleteCircle(circleID: circleID)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            } message: {
                Text("This will permanently delete \"\(circle.name)\" and all its posts. This cannot be undone.")
            }
            .alert("Leave Circle?", isPresented: $showLeaveAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Leave", role: .destructive) {
                    Task {
                        guard let circleID = circle.id else { return }
                        do {
                            try await firestoreService.leaveCircle(circleID: circleID)
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            } message: {
                Text("You'll need a new invite code to rejoin this circle.")
            }
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var filteredPosts: [CirclePost] {
        posts.filter { !blockedUserIDs.contains($0.authorID) }
    }

    private func joinThisCircle() {
        guard let circleID = circle.id else { return }
        isJoining = true
        Task {
            do {
                if !circle.isPrivate {
                    try await firestoreService.joinPublicCircle(circleID: circleID)
                } else {
                    _ = try await firestoreService.joinCircle(inviteCode: circle.inviteCode ?? "")
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                didJoin = true
            } catch {
                errorMessage = error.localizedDescription
            }
            isJoining = false
        }
    }

    private func loadPosts() async {
        isLoading = true
        defer { isLoading = false }
        if let circleID = circle.id {
            posts = (try? await firestoreService.fetchCirclePosts(circleID: circleID)) ?? []
        }
    }
}

// MARK: - Manage Members View (Admin)
struct ManageMembersView: View {
    let circle: SisterCircle
    var blockedUserIDs: [String] = []
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var removingMemberID: String?

    private var visibleMemberIDs: [String] {
        circle.memberIDs.filter { !blockedUserIDs.contains($0) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(visibleMemberIDs, id: \.self) { memberID in
                        let name = circle.memberNames[memberID] ?? "Member"
                        let isCreator = memberID == circle.creatorID

                        HStack {
                            Circle()
                                .fill(ABTheme.blush.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(String(name.prefix(1)).uppercased())
                                        .font(.system(.caption, design: .serif, weight: .bold))
                                        .foregroundColor(ABTheme.blush)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(name)
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(ABTheme.primaryText)
                                if isCreator {
                                    Text("Creator")
                                        .font(.caption2)
                                        .foregroundColor(ABTheme.warmGold)
                                } else if circle.adminIDs.contains(memberID) {
                                    Text("Admin")
                                        .font(.caption2)
                                        .foregroundColor(ABTheme.sageGreen)
                                }
                            }

                            Spacer()

                            if !isCreator {
                                Button {
                                    removingMemberID = memberID
                                } label: {
                                    Image(systemName: "person.badge.minus")
                                        .foregroundColor(ABTheme.destructive)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                } header: {
                    Text("\(circle.memberCount) Members")
                }
            }
            .scrollContentBackground(.hidden)
            .background(ABTheme.cream)
            .navigationTitle("Manage Members")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .alert("Remove Member?", isPresented: Binding(
                get: { removingMemberID != nil },
                set: { if !$0 { removingMemberID = nil } }
            )) {
                Button("Cancel", role: .cancel) { removingMemberID = nil }
                Button("Remove", role: .destructive) {
                    if let memberID = removingMemberID, let circleID = circle.id {
                        Task {
                            try? await firestoreService.removeMember(circleID: circleID, memberID: memberID)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            removingMemberID = nil
                        }
                    }
                }
            } message: {
                if let memberID = removingMemberID {
                    Text("Remove \(circle.memberNames[memberID] ?? "this member") from the circle?")
                }
            }
        }
    }
}

// MARK: - Circle Post View
struct CirclePostView: View {
    let post: CirclePost
    var circleID: String?
    var isCircleAdmin: Bool = false
    var isPremium: Bool = false
    var blockedUserIDs: [String] = []
    var onDeleted: (() -> Void)?
    var onBlockedUser: ((String) -> Void)?

    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false
    @State private var commentCount: Int
    @State private var showPostActions = false
    @State private var showReportSheet = false
    @State private var showDeletePostAlert = false
    @State private var showBlockAlert = false
    @State private var showUpgradePrompt = false

    private var isOwnPost: Bool {
        post.authorID == (FirebaseAuth.Auth.auth().currentUser?.uid ?? "")
    }

    init(post: CirclePost, circleID: String? = nil, isCircleAdmin: Bool = false, isPremium: Bool = false, blockedUserIDs: [String] = [], onDeleted: (() -> Void)? = nil, onBlockedUser: ((String) -> Void)? = nil) {
        self.post = post
        self.circleID = circleID
        self.isCircleAdmin = isCircleAdmin
        self.isPremium = isPremium
        self.blockedUserIDs = blockedUserIDs
        self.onDeleted = onDeleted
        self.onBlockedUser = onBlockedUser
        _likeCount = State(initialValue: post.likeCount)
        _commentCount = State(initialValue: post.commentCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author + type + actions menu
            HStack {
                Circle()
                    .fill((post.isAnonymous ?? false) ? ABTheme.secondaryText.opacity(0.2) : ABTheme.blush.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: (post.isAnonymous ?? false) ? "person.fill.questionmark" : "person.fill")
                            .font(.caption)
                            .foregroundColor((post.isAnonymous ?? false) ? ABTheme.secondaryText : ABTheme.blush)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(post.displayName)
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                    Text(post.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: post.type.icon)
                        .font(.caption2)
                    Text(post.type.rawValue)
                        .font(.caption2)
                }
                .foregroundColor(ABTheme.sageGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(ABTheme.sageGreen.opacity(0.1))
                .cornerRadius(8)

                // Actions menu (report, block, delete)
                Menu {
                    if !isOwnPost {
                        Button {
                            showReportSheet = true
                        } label: {
                            Label("Report Post", systemImage: "flag")
                        }

                        if !(post.isAnonymous ?? false) {
                            Button {
                                showBlockAlert = true
                            } label: {
                                Label("Block \(post.authorName)", systemImage: "hand.raised")
                            }
                        }
                    }

                    if isCircleAdmin || isOwnPost {
                        Button(role: .destructive) {
                            showDeletePostAlert = true
                        } label: {
                            Label("Delete Post", systemImage: "trash")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)
                        .padding(8)
                }
            }

            // Content
            Text(post.content)
                .font(ABTheme.bodyFont)
                .foregroundColor(ABTheme.primaryText)
                .lineSpacing(3)

            // Scripture reference if any
            if let scripture = post.scriptureReference, !scripture.isEmpty {
                Text(scripture)
                    .font(.system(.caption, design: .serif).italic())
                    .foregroundColor(ABTheme.sageGreen)
            }

            // Interaction bar
            HStack(spacing: 16) {
                Button {
                    if isPremium {
                        toggleLike()
                    } else {
                        showUpgradePrompt = true
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(isLiked ? ABTheme.blush : ABTheme.secondaryText)
                        Text("\(likeCount)")
                            .font(.caption)
                            .foregroundColor(ABTheme.secondaryText)
                    }
                }
                .buttonStyle(.plain)

                Button {
                    showComments = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .font(.caption)
                        Text("\(commentCount)")
                            .font(.caption)
                    }
                    .foregroundColor(ABTheme.secondaryText)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .abCard()
        .sheet(isPresented: $showComments) {
            CommentThreadView(
                post: post,
                isPremium: isPremium,
                isCircleAdmin: isCircleAdmin,
                circleID: circleID,
                blockedUserIDs: blockedUserIDs,
                onBlockedUser: onBlockedUser
            ) {
                commentCount += 1
            }
        }
        .sheet(isPresented: $showUpgradePrompt) {
            SubscriptionView()
        }
        .sheet(isPresented: $showReportSheet) {
            ReportContentView(
                reportedUserID: post.authorID,
                contentID: post.id,
                contentType: .post,
                circleID: circleID
            )
        }
        .alert("Delete Post?", isPresented: $showDeletePostAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                guard let postID = post.id else { return }
                Task {
                    try? await firestoreService.deletePost(postID: postID)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    onDeleted?()
                }
            }
        } message: {
            Text("This post and all its comments will be permanently deleted.")
        }
        .alert("Block \(post.authorName)?", isPresented: $showBlockAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Block", role: .destructive) {
                Task {
                    try? await firestoreService.blockUser(userID: post.authorID)
                    onBlockedUser?(post.authorID)
                }
            }
        } message: {
            Text("You won't see posts or comments from this user. You can unblock them in Settings.")
        }
    }

    private func toggleLike() {
        guard let postID = post.id else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        isLiked.toggle()
        likeCount += isLiked ? 1 : -1
        Task {
            try? await firestoreService.toggleLike(postID: postID)
        }
    }
}

// MARK: - Comment Thread View
struct CommentThreadView: View {
    let post: CirclePost
    let isPremium: Bool
    var isCircleAdmin: Bool = false
    var circleID: String?
    var blockedUserIDs: [String] = []
    var onBlockedUser: ((String) -> Void)?
    let onCommentAdded: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var comments: [CircleComment] = []
    @State private var newComment = ""
    @State private var isLoading = false
    @State private var isSending = false
    @State private var showCommentContentWarning = false

    private var filteredComments: [CircleComment] {
        comments.filter { !blockedUserIDs.contains($0.authorID) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Original post at top
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill((post.isAnonymous ?? false) ? ABTheme.secondaryText.opacity(0.2) : ABTheme.blush.opacity(0.3))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Image(systemName: (post.isAnonymous ?? false) ? "person.fill.questionmark" : "person.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor((post.isAnonymous ?? false) ? ABTheme.secondaryText : ABTheme.blush)
                                    )

                                Text(post.displayName)
                                    .font(.system(.caption, design: .serif, weight: .semibold))
                                    .foregroundColor(ABTheme.primaryText)

                                Spacer()

                                Text(post.createdAt, style: .relative)
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }

                            Text(post.content)
                                .font(ABTheme.bodyFont)
                                .foregroundColor(ABTheme.primaryText)
                                .lineSpacing(3)
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(ABTheme.sageGreen.opacity(0.04))

                        Divider()

                        // Comments
                        if isLoading {
                            ProgressView()
                                .tint(ABTheme.sageGreen)
                                .padding(.top, 30)
                        } else if filteredComments.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.title2)
                                    .foregroundColor(ABTheme.secondaryText.opacity(0.3))
                                Text("No comments yet")
                                    .font(ABTheme.captionFont)
                                    .foregroundColor(ABTheme.secondaryText)
                                Text("Be the first to encourage!")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText.opacity(0.6))
                            }
                            .padding(.top, 30)
                        } else {
                            ForEach(filteredComments) { comment in
                                CommentRow(
                                    comment: comment,
                                    postID: post.id,
                                    circleID: circleID,
                                    isCircleAdmin: isCircleAdmin,
                                    onDeleted: {
                                        comments.removeAll { $0.id == comment.id }
                                    },
                                    onBlockedUser: onBlockedUser
                                )
                                Divider().padding(.leading, 48)
                            }
                        }
                    }
                }

                Divider()

                // Comment input
                if isPremium {
                    HStack(spacing: 10) {
                        TextField("Write a comment...", text: $newComment)
                            .font(ABTheme.bodyFont)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(ABTheme.sageGreen.opacity(0.06))
                            .cornerRadius(20)

                        Button {
                            sendComment()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title2)
                                .foregroundColor(newComment.isEmpty ? ABTheme.secondaryText.opacity(0.3) : ABTheme.sageGreen)
                        }
                        .disabled(newComment.isEmpty || isSending)
                    }
                    .padding(ABTheme.paddingSmall)
                    .background(ABTheme.softWhite)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(ABTheme.warmGold)
                            .font(.caption)
                        Text("Upgrade to Premium to comment")
                            .font(.system(.caption, design: .serif))
                            .foregroundColor(ABTheme.secondaryText)
                    }
                    .padding(ABTheme.paddingSmall)
                    .background(ABTheme.warmGoldLight.opacity(0.2))
                }
            }
            .abScreenBackground()
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .task {
                await loadComments()
            }
            .alert("Content Not Allowed", isPresented: $showCommentContentWarning) {
                Button("OK") {}
            } message: {
                Text("Your comment contains language that doesn't align with our community guidelines. Please revise and try again.")
            }
        }
    }

    private func loadComments() async {
        guard let postID = post.id else { return }
        isLoading = true
        defer { isLoading = false }
        comments = (try? await firestoreService.fetchComments(postID: postID)) ?? []
    }

    private func sendComment() {
        guard let postID = post.id, !newComment.isEmpty else { return }
        if !ContentFilter.isClean(newComment) {
            showCommentContentWarning = true
            return
        }
        let text = newComment
        newComment = ""
        isSending = true
        Task {
            try? await firestoreService.addComment(postID: postID, content: text)
            onCommentAdded()
            await loadComments()
            isSending = false
        }
    }
}

// MARK: - Comment Row
struct CommentRow: View {
    let comment: CircleComment
    var postID: String?
    var circleID: String?
    var isCircleAdmin: Bool = false
    var onDeleted: (() -> Void)?
    var onBlockedUser: ((String) -> Void)?

    @EnvironmentObject var firestoreService: FirestoreService

    @State private var showReportSheet = false
    @State private var showDeleteAlert = false
    @State private var showBlockAlert = false

    private var isOwnComment: Bool {
        comment.authorID == (FirebaseAuth.Auth.auth().currentUser?.uid ?? "")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(ABTheme.sageGreen.opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Text(String(comment.authorName.prefix(1)))
                        .font(.system(.caption2, design: .serif, weight: .bold))
                        .foregroundColor(ABTheme.sageGreen)
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(comment.authorName)
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)
                    Text(comment.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundColor(ABTheme.secondaryText)
                }

                Text(comment.content)
                    .font(ABTheme.bodyFont)
                    .foregroundColor(ABTheme.primaryText)
                    .lineSpacing(2)
            }

            Spacer()

            // Actions menu
            Menu {
                if !isOwnComment {
                    Button {
                        showReportSheet = true
                    } label: {
                        Label("Report Comment", systemImage: "flag")
                    }

                    Button {
                        showBlockAlert = true
                    } label: {
                        Label("Block \(comment.authorName)", systemImage: "hand.raised")
                    }
                }

                if isCircleAdmin || isOwnComment {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete Comment", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 10))
                    .foregroundColor(ABTheme.secondaryText.opacity(0.6))
                    .padding(6)
            }
        }
        .padding(.horizontal, ABTheme.paddingMedium)
        .padding(.vertical, 8)
        .sheet(isPresented: $showReportSheet) {
            ReportContentView(
                reportedUserID: comment.authorID,
                contentID: comment.id,
                contentType: .comment,
                circleID: circleID
            )
        }
        .alert("Delete Comment?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                guard let commentID = comment.id, let postID = postID else { return }
                Task {
                    try? await firestoreService.deleteComment(commentID: commentID, postID: postID)
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    onDeleted?()
                }
            }
        }
        .alert("Block \(comment.authorName)?", isPresented: $showBlockAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Block", role: .destructive) {
                Task {
                    try? await firestoreService.blockUser(userID: comment.authorID)
                    onBlockedUser?(comment.authorID)
                }
            }
        } message: {
            Text("You won't see posts or comments from this user. You can unblock them in Settings.")
        }
    }
}

// MARK: - Report Content View
struct ReportContentView: View {
    let reportedUserID: String
    var contentID: String?
    let contentType: ReportContentType
    var circleID: String?

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var selectedReason: ReportReason?
    @State private var details = ""
    @State private var isSubmitting = false
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            VStack(spacing: ABTheme.paddingLarge) {
                if submitted {
                    // Success state
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(ABTheme.sageGreen)

                        Text("Report Submitted")
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text("Thank you for helping keep our community safe. We'll review this report soon.")
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)
                            .multilineTextAlignment(.center)

                        Button("Done") { dismiss() }
                            .buttonStyle(ABPrimaryButtonStyle())
                    }
                    .padding(ABTheme.paddingLarge)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: ABTheme.paddingLarge) {
                            Text("Why are you reporting this \(contentType.rawValue)?")
                                .font(ABTheme.subheadlineFont)
                                .foregroundColor(ABTheme.primaryText)

                            // Reason selection
                            ForEach(ReportReason.allCases, id: \.self) { reason in
                                Button {
                                    selectedReason = reason
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: reason.icon)
                                            .font(.body)
                                            .frame(width: 24)
                                            .foregroundColor(selectedReason == reason ? ABTheme.sageGreen : ABTheme.secondaryText)

                                        Text(reason.rawValue)
                                            .font(ABTheme.bodyFont)
                                            .foregroundColor(ABTheme.primaryText)

                                        Spacer()

                                        if selectedReason == reason {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(ABTheme.sageGreen)
                                        }
                                    }
                                    .padding(ABTheme.paddingMedium)
                                    .background(selectedReason == reason ? ABTheme.sageGreen.opacity(0.08) : ABTheme.softWhite)
                                    .cornerRadius(ABTheme.cornerRadiusSmall)
                                }
                                .buttonStyle(.plain)
                            }

                            // Optional details
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Additional details (optional)")
                                    .font(ABTheme.captionFont)
                                    .foregroundColor(ABTheme.secondaryText)

                                TextEditor(text: $details)
                                    .font(ABTheme.bodyFont)
                                    .frame(minHeight: 80)
                                    .padding(ABTheme.paddingSmall)
                                    .background(ABTheme.softWhite)
                                    .cornerRadius(ABTheme.cornerRadiusSmall)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                            .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
                                    )
                            }

                            Button("Submit Report") {
                                submitReport()
                            }
                            .buttonStyle(ABPrimaryButtonStyle())
                            .disabled(selectedReason == nil || isSubmitting)
                        }
                        .padding(ABTheme.paddingLarge)
                    }
                }
            }
            .abScreenBackground()
            .navigationTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
        }
    }

    private func submitReport() {
        guard let reason = selectedReason else { return }
        isSubmitting = true
        Task {
            try? await firestoreService.submitReport(
                reportedUserID: reportedUserID,
                contentID: contentID,
                contentType: contentType,
                reason: reason,
                details: details.isEmpty ? nil : details,
                circleID: circleID
            )
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation { submitted = true }
        }
    }
}

// MARK: - New Post View
struct NewPostView: View {
    let circleID: String
    let onCreated: (CirclePost) -> Void

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var content = ""
    @State private var selectedType: CirclePostType = .encouragement
    @State private var scriptureRef = ""
    @State private var isAnonymous = false
    @State private var showPrompt = true
    @State private var showContentWarning = false
    @State private var contentWarningText = ""
    @AppStorage("hasAcceptedCircleTerms") private var hasAcceptedCircleTerms = false
    @State private var showTermsGate = false

    var body: some View {
        NavigationStack {
            if !hasAcceptedCircleTerms {
                // Terms acceptance gate
                VStack(spacing: ABTheme.paddingLarge) {
                    Spacer()

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 48))
                        .foregroundColor(ABTheme.sageGreen)

                    Text("Community Guidelines")
                        .font(ABTheme.headlineFont)
                        .foregroundColor(ABTheme.primaryText)

                    Text("Before posting, please agree to our community standards. Anchor & Bloom has zero tolerance for objectionable, abusive, or inappropriate content. Violations result in immediate removal and account action.")
                        .font(ABTheme.bodyFont)
                        .foregroundColor(ABTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, ABTheme.paddingLarge)

                    Link("Read Full Terms of Use", destination: URL(string: "https://github.com/johndisalle/AnchorBloom/blob/claude/anchor-bloom-mvp-D2kbN/docs/terms.md")!)
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.sageGreen)

                    Button("I Agree to the Community Guidelines") {
                        hasAcceptedCircleTerms = true
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .padding(.horizontal, ABTheme.paddingLarge)

                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.secondaryText)
                        .font(.system(.body, design: .serif))

                    Spacer()
                }
                .abScreenBackground()
            } else {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Daily prompt
                    if showPrompt {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(ABTheme.warmGold)
                                Text("Today's Prompt")
                                    .font(.system(.caption, design: .serif, weight: .semibold))
                                    .foregroundColor(ABTheme.warmGold)
                                Spacer()
                                Button {
                                    withAnimation { showPrompt = false }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.caption2)
                                        .foregroundColor(ABTheme.secondaryText)
                                }
                            }

                            Text(CirclePrompts.todayPrompt)
                                .font(.system(.body, design: .serif).italic())
                                .foregroundColor(ABTheme.primaryText)
                                .lineSpacing(3)

                            Button {
                                content = CirclePrompts.todayPrompt + "\n\n"
                                showPrompt = false
                            } label: {
                                Text("Use this prompt")
                                    .font(.system(.caption, design: .serif, weight: .medium))
                                    .foregroundColor(ABTheme.sageGreen)
                            }
                        }
                        .padding(ABTheme.paddingMedium)
                        .background(ABTheme.warmGoldLight.opacity(0.2))
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                    }

                    // Post type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What are you sharing?")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(CirclePostType.allCases, id: \.self) { type in
                                    Button {
                                        UISelectionFeedbackGenerator().selectionChanged()
                                        selectedType = type
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: type.icon)
                                                .font(.caption2)
                                            Text(type.rawValue)
                                                .font(.system(.caption, design: .serif))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedType == type ? ABTheme.sageGreen : ABTheme.sageGreen.opacity(0.08))
                                        .foregroundColor(selectedType == type ? .white : ABTheme.primaryText)
                                        .cornerRadius(20)
                                    }
                                }
                            }
                        }
                    }

                    // Content
                    TextEditor(text: $content)
                        .font(ABTheme.bodyFont)
                        .frame(minHeight: 150)
                        .padding(ABTheme.paddingSmall)
                        .background(ABTheme.softWhite)
                        .cornerRadius(ABTheme.cornerRadiusSmall)
                        .overlay(
                            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                                .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
                        )

                    // Optional scripture
                    ABTextField(text: $scriptureRef, placeholder: "Scripture reference (optional)", icon: "book.fill")

                    // Anonymous toggle
                    Toggle(isOn: $isAnonymous) {
                        HStack(spacing: 8) {
                            Image(systemName: isAnonymous ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(ABTheme.sageGreen)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Post Anonymously")
                                    .font(.system(.body, design: .serif))
                                    .foregroundColor(ABTheme.primaryText)
                                Text(isAnonymous ? "Your name will be hidden from sisters" : "Your name will be shown on this post")
                                    .font(.caption2)
                                    .foregroundColor(ABTheme.secondaryText)
                            }
                        }
                    }
                    .tint(ABTheme.sageGreen)

                    // Post button
                    Button("Share with Sisters") {
                        createPost()
                    }
                    .buttonStyle(ABPrimaryButtonStyle())
                    .disabled(content.isEmpty)
                }
                .padding(ABTheme.paddingLarge)
            }
            .abScreenBackground()
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(ABTheme.sageGreen)
                }
            }
            .alert("Content Not Allowed", isPresented: $showContentWarning) {
                Button("OK") {}
            } message: {
                Text("Your post contains language that doesn't align with our community guidelines. Please revise and try again.")
            }
        }
        } // end else (terms accepted)
    }

    private func createPost() {
        // Content filter check
        if !ContentFilter.isClean(content) || !ContentFilter.isClean(scriptureRef) {
            showContentWarning = true
            return
        }

        let userID = FirebaseAuth.Auth.auth().currentUser?.uid ?? ""
        let userName = FirebaseAuth.Auth.auth().currentUser?.displayName ?? "Sister"
        let post = CirclePost(
            circleID: circleID,
            authorID: userID,
            authorName: userName,
            type: selectedType,
            content: content,
            scriptureReference: scriptureRef.isEmpty ? nil : scriptureRef,
            createdAt: Date(),
            likedByIDs: [],
            commentCount: 0,
            isAnonymous: isAnonymous
        )
        Task {
            try? await firestoreService.createPost(post)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            onCreated(post)
            dismiss()
        }
    }
}

#Preview {
    CirclesListView()
        .environmentObject(FirestoreService())
        .environmentObject(SubscriptionManager())
}
