//
//  SettingsSupportViews.swift
//  Trafikal
//

import SwiftUI
import UIKit

// MARK: - Support contact

private enum TrafikalSupportContact {
    static let supportEmail = "abashelariprod@gmail.com"
    static let websiteDisplay = "https://abashelari.com"

    static var mailtoURL: URL? {
        URL(string: "mailto:\(supportEmail)")
    }

    static var websiteURL: URL? {
        URL(string: websiteDisplay)
    }
}

// MARK: - Help & Support

struct HelpSupportView: View {
    @Environment(LocalizationManager.self) private var l10n

    @State private var fullName = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var description = ""
    @State private var showForm = false
    @State private var showError = false
    @State private var alertKind: HelpAlertKind = .none

    private enum HelpAlertKind {
        case none
        case sent
        case mailFailed
    }

    private var allFieldsFilled: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(
                title: showForm
                    ? l10n.text(.settingsSupportNavContact)
                    : l10n.text(.settingsSupportNavHelp),
                showsBackButton: true,
                onBack: showForm ? { showForm = false } : nil
            )

            Group {
                if showForm {
                    contactForm
                } else {
                    introContent
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
        .alert(helpAlertTitle, isPresented: Binding(
            get: { alertKind != .none },
            set: { if !$0 { alertKind = .none } }
        )) {
            Button(l10n.text(.commonOK), role: .cancel) {
                let wasSent = alertKind == .sent
                alertKind = .none
                if wasSent {
                    showForm = false
                }
            }
        } message: {
            Text(helpAlertMessage)
        }
    }

    private var introContent: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 32) {
                VStack(alignment: .center, spacing: 16) {
                    Text(l10n.text(.settingsSupportIntroTitle))
                        .font(.title3.bold())

                    Text(l10n.text(.settingsSupportIntroLine1))
                        .font(.body)

                    Text(l10n.text(.settingsSupportIntroLine2))
                        .font(.body)

                    Text(l10n.text(.settingsSupportIntroLine3))
                        .font(.body)

                    Divider()
                        .padding(.vertical, 8)
                        .padding(.top, 32)
                        .padding(.bottom, 32)

                    if let mailURL = TrafikalSupportContact.mailtoURL {
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Text("\(l10n.text(.settingsSupportEmailLabel)): ")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Link(destination: mailURL) {
                                Text(TrafikalSupportContact.supportEmail)
                                    .font(.subheadline)
                            }
                            Spacer(minLength: 0)
                        }
                    }

                    if let webURL = TrafikalSupportContact.websiteURL {
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Text("\(l10n.text(.settingsSupportWebsiteLabel)): ")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            Link(destination: webURL) {
                                Text(TrafikalSupportContact.websiteDisplay)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer(minLength: 0)
                        }
                    }

                    Divider()
                        .padding(.vertical, 8)
                        .padding(.top, 32)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)

                Text(l10n.text(.settingsSupportOr))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)

                Button {
                    showForm = true
                } label: {
                    Text(l10n.text(.settingsSupportContactForm))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
                        .padding(.horizontal, 32)
                }

                Text(l10n.text(.settingsSupportAimRespond))
                    .font(.body.bold())
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 32)
        }
        .scrollContentBackground(.hidden)
    }

    private var contactForm: some View {
        Form {
            Section(header: Text(l10n.text(.settingsSupportSectionFullName))) {
                TextField(l10n.text(.settingsSupportPlaceholderFullName), text: $fullName)
            }

            Section(header: Text(l10n.text(.settingsSupportSectionYourEmail))) {
                TextField(l10n.text(.settingsSupportPlaceholderYourEmail), text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            Section(header: Text(l10n.text(.settingsSupportSectionSubject))) {
                TextField("", text: $subject)
                    .onChange(of: subject) { _, newValue in
                        if newValue.count > 100 {
                            subject = String(newValue.prefix(100))
                        }
                    }
                HStack {
                    Spacer()
                    Text("\(subject.count)/100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section(header: Text(l10n.text(.settingsSupportSectionDescription))) {
                TextEditor(text: $description)
                    .frame(height: 120)
                    .onChange(of: description) { _, newValue in
                        if newValue.count > 400 {
                            description = String(newValue.prefix(400))
                        }
                    }
                HStack {
                    Spacer()
                    Text("\(description.count)/400")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if showError && !allFieldsFilled {
                Section {
                    Text(l10n.text(.settingsSupportAllRequired))
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            Section {
                Button {
                    if allFieldsFilled {
                        showError = false
                        sendSupportMail()
                    } else {
                        showError = true
                    }
                } label: {
                    Text(l10n.text(.settingsSupportSend))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(allFieldsFilled ? Color.green : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: ListCardStyle.cornerRadius, style: .continuous))
                }
                .disabled(!allFieldsFilled)
            }
            .listRowBackground(Color.clear)
        }
        .scrollContentBackground(.hidden)
    }

    private var helpAlertTitle: String {
        switch alertKind {
        case .mailFailed:
            return l10n.text(.settingsSupportNavHelp)
        case .sent, .none:
            return l10n.text(.settingsSupportAlertSentTitle)
        }
    }

    private var helpAlertMessage: String {
        switch alertKind {
        case .sent:
            return l10n.text(.settingsSupportAlertSentMessage)
        case .mailFailed:
            return l10n.text(.settingsSupportAlertMailFail, TrafikalSupportContact.supportEmail)
        case .none:
            return ""
        }
    }

    private func sendSupportMail() {
        guard allFieldsFilled else {
            showError = true
            return
        }
        showError = false

        let body = """
        From: \(fullName)
        Reply email: \(email)

        \(description)
        """
        guard var components = URLComponents(string: "mailto:\(TrafikalSupportContact.supportEmail)") else {
            alertKind = .mailFailed
            return
        }
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        guard let url = components.url else {
            alertKind = .mailFailed
            return
        }
        UIApplication.shared.open(url) { success in
            DispatchQueue.main.async {
                alertKind = success ? .sent : .mailFailed
            }
        }
    }
}

// MARK: - Terms, Privacy & Disclaimer

struct TermsPrivacyView: View {
    @Environment(LocalizationManager.self) private var l10n
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.settingsTermsNavTitle), showsBackButton: true)

            Picker(selection: $selectedTab) {
                Text(l10n.text(.settingsLegalTabTerms)).tag(0)
                Text(l10n.text(.settingsLegalTabPrivacy)).tag(1)
                Text(l10n.text(.settingsLegalTabDisclaimer)).tag(2)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, ListCardStyle.horizontalPadding)
            .padding(.top, 8)

            ScrollView {
                Text(contentText)
                    .font(.body)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(ListCardStyle.horizontalPadding)
                    .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }

    private var contentText: String {
        switch selectedTab {
        case 0: TrafikalLegalEnglish.termsOfUse
        case 1: TrafikalLegalEnglish.privacyPolicy
        default: TrafikalLegalEnglish.disclaimer
        }
    }
}

private enum TrafikalLegalEnglish {
    static let termsOfUse = """
    TERMS OF USE

    Last Updated: May 22, 2026

    Welcome to Trafikal. These Terms of Use (“Terms”) govern your access to and use of the Trafikal mobile application (“App”). By using the App, you agree to these Terms.

    1. ACCEPTANCE OF TERMS
    By downloading, installing, or using Trafikal, you acknowledge that you have read and agree to these Terms and our Privacy Policy.

    2. DESCRIPTION OF SERVICE
    Trafikal is an educational app for learning Swedish road signs and driving theory questions. Features include browsing signs by category, studying sign meanings, browsing theory questions, practice tests for signs and theory, test history stored on your device, daily sign highlights, language selection, and dark mode.

    3. NOT AN OFFICIAL EXAM OR AUTHORITY
    Trafikal is a study aid only. It does not issue licences, administer official driving tests, or represent Transportstyrelsen or any government authority. You are responsible for verifying information against current official sources before relying on it for real-world driving or examinations.

    4. USER ACCOUNTS
    You may use the App without creating an account. Core features are designed to work with data stored on your device.

    5. ACCEPTABLE USE
    You agree to use the App only for lawful purposes. You agree not to attempt to reverse engineer, interfere with, or misuse the App in a way that could harm its operation or other users’ devices.

    6. INTELLECTUAL PROPERTY
    The App, its design, and related materials are protected by applicable intellectual property laws. Road sign images used in the App may be subject to separate licences as described in the sign images information section of the App.

    7. LIMITATION OF LIABILITY
    The App is provided “as is” without warranties of any kind to the maximum extent permitted by law. We are not liable for indirect, incidental, or consequential damages arising from your use of the App.

    8. CHANGES TO TERMS
    We may update these Terms from time to time. Continued use of the App after changes constitutes acceptance of the updated Terms.

    9. CONTACT
    For questions about these Terms, use Help & Support in the App settings.
    """

    static let privacyPolicy = """
    PRIVACY POLICY

    Last Updated: May 22, 2026

    This Privacy Policy explains how Trafikal handles information when you use the App.

    1. LOCAL-FIRST DESIGN
    Trafikal stores test history, preferences (such as language and appearance), and related app data on your device. There is no sign-in account required to use the core features described in the App.

    2. STUDY CONTENT
    Sign and theory question content is bundled in the App for offline use. We do not upload your study progress to our servers as part of normal App operation.

    3. PHOTOS AND MEDIA
    Trafikal does not require access to your photo library for its core features. Sign illustrations are provided within the App bundle or drawn in the interface.

    4. HELP & SUPPORT
    If you contact us through the in-app form or email links, you choose what information to send (such as your name, email address, and message). That communication is handled by your email app or provider, not stored by us in the App beyond what you send.

    5. ANALYTICS AND SALE OF DATA
    Trafikal is not designed to sell your personal information. Data you enter for study and tests stays on your device unless you explicitly share it (for example via email when contacting support).

    6. CHILDREN
    Trafikal is intended for learners preparing for driving-related knowledge. Parents and guardians are responsible for supervising use by minors.

    7. SECURITY
    Protection of your information depends on your device security (passcode, biometrics, backups, and device access). Follow good device security practices.

    8. CHANGES TO THIS POLICY
    We may update this Privacy Policy from time to time. The “Last Updated” date will be revised when material changes are made.

    9. CONTACT
    For privacy questions, contact us through Help & Support in the App settings.
    """

    static let disclaimer = """
    DISCLAIMER

    Last Updated: May 22, 2026

    1. NO WARRANTY
    Trafikal is provided “as is” and “as available” without warranties of any kind, to the fullest extent permitted by law.

    2. ACCURACY
    Sign meanings, theory questions, and explanations depend on the content included in the App and may not reflect the latest rules, signs, or exam formats. You are responsible for verifying information with official Swedish driving and traffic authorities before examinations or real-world decisions.

    3. LIMITATION OF LIABILITY
    To the fullest extent permitted by law, Trafikal and its developers shall not be liable for indirect, incidental, special, consequential, or punitive damages arising from use of the App.

    4. NOT PROFESSIONAL ADVICE
    Trafikal is an educational study tool and does not provide legal, regulatory, or professional driving instruction.

    5. DEVICE AND BACKUPS
    You are responsible for maintaining backups if you need to preserve your test history. Clearing app data or uninstalling the App may remove locally stored information.

    6. ACCEPTANCE
    By using Trafikal, you acknowledge that you have read and agree to this Disclaimer.
    """
}

// MARK: - About

private enum AboutAbashelariCopy {
    static let paragraph1 = "At ABASHELARI, we believe in creating software that makes everyday life simpler, smarter, and more enjoyable. Our mission is to develop innovative digital solutions that blend creativity with technology, offering users tools that are intuitive, reliable, and engaging."

    static let paragraph2 = "Whether it's educational apps, lifestyle tools, or entertainment experiences, ABASHELARI is dedicated to delivering high-quality products that inspire learning, spark curiosity, and bring value to people around the world."

    static let paragraph3 = "Driven by passion and guided by innovation, ABASHELARI is committed to continuous improvement and to building software that connects people with what matters most."
}

struct AboutView: View {
    @Environment(LocalizationManager.self) private var l10n

    private static let commonsSignsURL = URL(string: "https://commons.wikimedia.org/wiki/Road_signs_in_Sweden")!

    private var versionString: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return l10n.text(.settingsAboutVersionFormat, short, build)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.settingsAboutNavTitle), showsBackButton: true)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(l10n.text(.settingsAboutAppHeading))
                            .font(.title2.bold())

                        Text(l10n.text(.settingsAboutBody))
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }

                    Divider()
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(l10n.text(.aboutSignImagesTitle))
                            .font(.title2.bold())

                        Text(l10n.text(.aboutSignImagesBody))
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Link(l10n.text(.aboutCommonsLink), destination: Self.commonsSignsURL)
                            .font(.body)
                    }

                    Divider()
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("About ABASHELARI")
                            .font(.title2.bold())

                        Text(AboutAbashelariCopy.paragraph1)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Text(AboutAbashelariCopy.paragraph2)
                            .font(.body)
                            .multilineTextAlignment(.leading)

                        Text(AboutAbashelariCopy.paragraph3)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }

                    Text(versionString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(ListCardStyle.horizontalPadding)
                .padding(.bottom, 24)
            }
            .scrollContentBackground(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }
}
