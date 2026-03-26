import SwiftUI
import AuthenticationServices

// MARK: - Auth View
/// Sign in / Sign up screen with email and Apple sign-in
struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var firestoreService: FirestoreService

    @State private var isSignUp = true
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var currentNonce: String?

    var body: some View {
        ScrollView {
            VStack(spacing: ABTheme.paddingLarge) {
                Spacer().frame(height: 40)

                // Logo area
                VStack(spacing: 12) {
                    Image(systemName: "tree.fill")
                        .font(.system(size: 56))
                        .foregroundColor(ABTheme.sageGreen)

                    Text("Anchor & Bloom")
                        .font(ABTheme.titleFont)
                        .foregroundColor(ABTheme.primaryText)

                    Text("Rooted in Christ. Blooming in purpose.")
                        .font(ABTheme.captionFont)
                        .foregroundColor(ABTheme.secondaryText)
                }

                Spacer().frame(height: 20)

                // Toggle sign in / sign up
                Picker("", selection: $isSignUp) {
                    Text("Sign Up").tag(true)
                    Text("Sign In").tag(false)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, ABTheme.paddingLarge)

                // Form fields
                VStack(spacing: ABTheme.paddingMedium) {
                    if isSignUp {
                        ABTextField(
                            text: $displayName,
                            placeholder: "Your name",
                            icon: "person.fill"
                        )
                    }

                    ABTextField(
                        text: $email,
                        placeholder: "Email address",
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        autocapitalization: .never
                    )

                    ABTextField(
                        text: $password,
                        placeholder: "Password",
                        icon: "lock.fill",
                        isSecure: true
                    )
                }
                .padding(.horizontal, ABTheme.paddingLarge)

                // Error message
                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(ABTheme.destructive)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Primary button
                Button(isSignUp ? "Create Account" : "Sign In") {
                    Task {
                        do {
                            if isSignUp {
                                try await authManager.signUp(
                                    email: email,
                                    password: password,
                                    displayName: displayName
                                )
                                try await firestoreService.createInitialProfile(
                                    displayName: displayName,
                                    email: email
                                )
                            } else {
                                try await authManager.signIn(email: email, password: password)
                            }
                        } catch {
                            authManager.errorMessage = error.localizedDescription
                        }
                    }
                }
                .buttonStyle(ABPrimaryButtonStyle())
                .padding(.horizontal, ABTheme.paddingLarge)
                .disabled(authManager.isLoading)

                // Divider
                HStack {
                    Rectangle().frame(height: 1).foregroundColor(ABTheme.sageGreen.opacity(0.2))
                    Text("or").font(.caption).foregroundColor(ABTheme.secondaryText)
                    Rectangle().frame(height: 1).foregroundColor(ABTheme.sageGreen.opacity(0.2))
                }
                .padding(.horizontal, ABTheme.paddingLarge)

                // Sign in with Apple
                SignInWithAppleButton(.signIn) { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                } onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                           let nonce = currentNonce {
                            Task {
                                do {
                                    try await authManager.signInWithApple(
                                        credential: appleIDCredential,
                                        nonce: nonce
                                    )
                                    // Create profile if needed
                                    let name = [
                                        appleIDCredential.fullName?.givenName,
                                        appleIDCredential.fullName?.familyName
                                    ].compactMap { $0 }.joined(separator: " ")
                                    try await firestoreService.createInitialProfile(
                                        displayName: name.isEmpty ? "Beloved" : name,
                                        email: appleIDCredential.email ?? ""
                                    )
                                } catch {
                                    authManager.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    case .failure(let error):
                        authManager.errorMessage = error.localizedDescription
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 52)
                .cornerRadius(ABTheme.cornerRadius)
                .padding(.horizontal, ABTheme.paddingLarge)

                // Loading indicator
                if authManager.isLoading {
                    ProgressView()
                        .tint(ABTheme.sageGreen)
                }

                Spacer()
            }
        }
        .abScreenBackground()
    }
}

// MARK: - Custom Text Field
struct ABTextField: View {
    @Binding var text: String
    let placeholder: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var isSecure: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .foregroundColor(ABTheme.sageGreen)
                    .frame(width: 20)
            }

            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
            }
        }
        .font(ABTheme.bodyFont)
        .padding()
        .background(ABTheme.softWhite)
        .cornerRadius(ABTheme.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: ABTheme.cornerRadiusSmall)
                .stroke(ABTheme.sageGreen.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
        .environmentObject(FirestoreService())
}
