import SwiftUI

// MARK: - Circles List View
/// Sister Circles: private small groups for encouragement
struct CirclesListView: View {
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var circles: [SisterCircle] = []
    @State private var showCreateCircle = false
    @State private var showJoinCircle = false
    @State private var selectedCircle: SisterCircle?
    @State private var isLoading = false

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
                            showCreateCircle = true
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

                    // Circles list
                    if isLoading {
                        ProgressView()
                            .tint(ABTheme.sageGreen)
                            .padding(.top, 40)
                    } else if circles.isEmpty {
                        emptyState
                    } else {
                        ForEach(circles) { circle in
                            CircleCardView(circle: circle) {
                                selectedCircle = circle
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
        } catch {
            // Handle error silently for MVP
        }
    }
}

// MARK: - Circle Card
struct CircleCardView: View {
    let circle: SisterCircle
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
                    Text(circle.name)
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundColor(ABTheme.primaryText)

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
                            Text("Private Circle")
                                .font(ABTheme.bodyFont)
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

        let circle = SisterCircle(
            name: name,
            description: description,
            creatorID: "",
            memberIDs: [],
            memberNames: [:],
            createdAt: Date(),
            isPrivate: isPrivate,
            inviteCode: inviteCode,
            maxMembers: SisterCircle.defaultMaxMembers,
            coverImageName: "default"
        )

        Task {
            _ = try? await firestoreService.createCircle(circle)
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingMedium) {
                    // Circle header
                    VStack(spacing: 8) {
                        Text(circle.name)
                            .font(ABTheme.headlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        Text(circle.description)
                            .font(ABTheme.captionFont)
                            .foregroundColor(ABTheme.secondaryText)

                        HStack(spacing: 12) {
                            Label("\(circle.memberCount) members", systemImage: "person.2.fill")
                            if let code = circle.inviteCode {
                                Label(code, systemImage: "key.fill")
                            }
                        }
                        .font(.caption)
                        .foregroundColor(ABTheme.secondaryText)
                    }
                    .padding(.top, ABTheme.paddingSmall)

                    // New post button (premium only)
                    if subscriptionManager.isPremium {
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

                    // Posts
                    if isLoading {
                        ProgressView().tint(ABTheme.sageGreen)
                    } else if posts.isEmpty {
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
                        ForEach(posts) { post in
                            CirclePostView(post: post)
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
                await loadPosts()
            }
            .sheet(isPresented: $showNewPost) {
                NewPostView(circleID: circle.id ?? "") { post in
                    posts.insert(post, at: 0)
                }
            }
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

// MARK: - Circle Post View
struct CirclePostView: View {
    let post: CirclePost
    @EnvironmentObject var firestoreService: FirestoreService
    @EnvironmentObject var subscriptionManager: SubscriptionManager

    @State private var isLiked = false
    @State private var likeCount: Int
    @State private var showComments = false
    @State private var commentCount: Int

    init(post: CirclePost) {
        self.post = post
        _likeCount = State(initialValue: post.likeCount)
        _commentCount = State(initialValue: post.commentCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Author + type
            HStack {
                Circle()
                    .fill(ABTheme.blush.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(String(post.authorName.prefix(1)))
                            .font(.system(.caption, design: .serif, weight: .bold))
                            .foregroundColor(ABTheme.blush)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text(post.authorName)
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
                // Like button
                Button {
                    toggleLike()
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

                // Comment button
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
                isPremium: subscriptionManager.isPremium
            ) {
                commentCount += 1
            }
        }
    }

    private func toggleLike() {
        guard let postID = post.id else { return }
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
    let onCommentAdded: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var comments: [CircleComment] = []
    @State private var newComment = ""
    @State private var isLoading = false
    @State private var isSending = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Comments list
                ScrollView {
                    VStack(spacing: 0) {
                        // Original post at top
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(ABTheme.blush.opacity(0.3))
                                    .frame(width: 28, height: 28)
                                    .overlay(
                                        Text(String(post.authorName.prefix(1)))
                                            .font(.system(.caption2, design: .serif, weight: .bold))
                                            .foregroundColor(ABTheme.blush)
                                    )

                                Text(post.authorName)
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
                        } else if comments.isEmpty {
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
                            ForEach(comments) { comment in
                                CommentRow(comment: comment)
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
        }
        .padding(.horizontal, ABTheme.paddingMedium)
        .padding(.vertical, 8)
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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ABTheme.paddingLarge) {
                    // Post type picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What are you sharing?")
                            .font(ABTheme.subheadlineFont)
                            .foregroundColor(ABTheme.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(CirclePostType.allCases, id: \.self) { type in
                                    Button {
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
        }
    }

    private func createPost() {
        let post = CirclePost(
            circleID: circleID,
            authorID: "",
            authorName: "You",
            type: selectedType,
            content: content,
            scriptureReference: scriptureRef.isEmpty ? nil : scriptureRef,
            createdAt: Date(),
            likedByIDs: [],
            commentCount: 0
        )
        Task {
            try? await firestoreService.createPost(post)
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
