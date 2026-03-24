import Foundation
import FirebaseAuth
import AuthenticationServices

// MARK: - Authentication Manager
/// Handles all authentication flows: email/password and Sign in with Apple
@MainActor
final class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authStateListener: AuthStateDidChangeListenerHandle?

    init() {
        setupAuthStateListener()
    }

    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }

    // MARK: - Auth State Listener
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }

    // MARK: - Email/Password Sign Up
    func signUp(email: String, password: String, displayName: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Email/Password Sign In
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign in with Apple
    func signInWithApple(credential: ASAuthorizationAppleIDCredential, nonce: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        guard let appleIDToken = credential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            errorMessage = "Unable to process Apple ID token."
            throw AuthError.invalidCredential
        }

        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )

        do {
            try await Auth.auth().signIn(with: firebaseCredential)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Out
    func signOut() throws {
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Delete Account
    func deleteAccount() async throws {
        guard let user = currentUser else { return }
        do {
            try await user.delete()
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case invalidCredential
    case userNotFound

    var errorDescription: String? {
        switch self {
        case .invalidCredential: return "Invalid credentials. Please try again."
        case .userNotFound: return "No account found. Please sign up first."
        }
    }
}

// MARK: - Apple Sign In Nonce Helpers
import CryptoKit

func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
        fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
    }
    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
    }
    return String(nonce)
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
}
