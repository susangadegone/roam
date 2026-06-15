import SwiftUI

struct AuthView: View {
    @AppStorage("hasAccount") private var hasAccount = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    @State private var mode: Mode = .landing
    @State private var email = ""
    @State private var password = ""
    @State private var emailError = ""
    @State private var passwordError = ""

    enum Mode { case landing, signUp, signIn }

    var body: some View {
        ZStack {
            Theme.canvas.ignoresSafeArea()
            switch mode {
            case .landing: landingPage
            case .signUp:
                formPage(title: "Create account", subtitle: "Let's get you set up.", cta: "Continue") {
                    hasAccount = true
                    // hasSeenOnboarding stays false → RootView shows OnboardingView next
                }
            case .signIn:
                formPage(title: "Welcome back", subtitle: "Good to see you.", cta: "Sign in") {
                    hasSeenOnboarding = true
                    hasAccount = true
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mode)
    }

    // MARK: - Landing

    private var landingPage: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.cream)
                        .frame(width: 88, height: 88)
                        .overlay(Circle().strokeBorder(Theme.cocoaBorder, lineWidth: 1))
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(Theme.terracotta)
                }
                VStack(spacing: 8) {
                    Text("roam")
                        .font(.serifTitle(36, weight: .semibold))
                        .foregroundStyle(Theme.cocoa)
                    Text("Small steps, every day.\nLet's find what fits you.")
                        .font(.sans(15))
                        .foregroundStyle(Theme.cocoaMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                primaryButton("Create account") { mode = .signUp }
                outlineButton("Sign in")       { mode = .signIn }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }

    // MARK: - Form (sign up / sign in)

    private func formPage(title: String, subtitle: String, cta: String, onContinue: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                emailError = ""
                passwordError = ""
                mode = .landing
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Theme.cocoa)
            }
            .padding(.top, 64)
            .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.serifTitle(30, weight: .semibold))
                    .foregroundStyle(Theme.cocoa)
                Text(subtitle)
                    .font(.sans(15))
                    .foregroundStyle(Theme.cocoaMuted)
            }
            .padding(.top, 28)
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    inputField("Email address", text: $email, keyboard: .emailAddress)
                    if !emailError.isEmpty {
                        Text(emailError)
                            .font(.sans(12))
                            .foregroundStyle(Theme.terracotta)
                            .padding(.horizontal, 4)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    secureField("Password", text: $password)
                    if !passwordError.isEmpty {
                        Text(passwordError)
                            .font(.sans(12))
                            .foregroundStyle(Theme.terracotta)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .padding(.top, 28)
            .padding(.horizontal, 24)
            .onChange(of: email)    { emailError = "" }
            .onChange(of: password) { passwordError = "" }

            Spacer()

            primaryButton(cta) {
                if validate() { onContinue() }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }

    @discardableResult
    private func validate() -> Bool {
        emailError = ""
        passwordError = ""
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty || !trimmed.contains("@") || trimmed.hasPrefix("@") || trimmed.hasSuffix("@") {
            emailError = "Enter a valid email address"
        }
        if password.count < 6 {
            passwordError = "Password must be at least 6 characters"
        }
        return emailError.isEmpty && passwordError.isEmpty
    }

    // MARK: - Reusable components

    private func primaryButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            action()
        } label: {
            Text(label)
                .font(.sans(17, weight: .semibold))
                .foregroundStyle(Theme.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Capsule().fill(Theme.terracotta))
        }
        .buttonStyle(.plain)
    }

    private func outlineButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            Text(label)
                .font(.sans(17, weight: .medium))
                .foregroundStyle(Theme.cocoa)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Capsule().fill(Theme.cream))
                .overlay(Capsule().strokeBorder(Theme.cocoaBorder, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }

    private func inputField(_ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .textInputAutocapitalization(.never)
            .font(.sans(16))
            .foregroundStyle(Theme.cocoa)
            .tint(Theme.terracotta)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cream))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
    }

    private func secureField(_ placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .font(.sans(16))
            .foregroundStyle(Theme.cocoa)
            .tint(Theme.terracotta)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.cream))
            .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.cocoaBorder, lineWidth: 1))
    }
}

#Preview { AuthView() }
