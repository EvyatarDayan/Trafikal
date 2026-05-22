//
//  TestsTabView.swift
//  Trafikal
//

import SwiftUI

struct TestsTabView: View {
    @State private var showTestSession = false
    @State private var showHistory = false

    private let contentMaxWidth: CGFloat = 320

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScreenTitleBar(title: "Tests")

                HStack {
                    Button {
                        showHistory = true
                    } label: {
                        Text("History")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.blue)
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Text("Test yourself")
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)

                        Text(introductionText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        introBullet("Each test has 10 questions about Swedish road signs.")
                        introBullet("You will see a sign and pick its meaning from four answers.")
                        introBullet("After each question you can see if you were right or wrong.")
                        introBullet("Completed tests are saved in History so you can track your progress.")
                    }
                    .frame(maxWidth: contentMaxWidth, alignment: .leading)

                    Button {
                        showTestSession = true
                    } label: {
                        Text("Start new test")
                            .font(.headline)
                            .frame(minWidth: 200)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 18)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .appRootScreen()
        .appScreenBackground()
        .navigationDestination(isPresented: $showTestSession) {
            TestSessionView()
        }
        .navigationDestination(isPresented: $showHistory) {
            HistoryView()
        }
    }

    private var introductionText: String {
        "In this section you can test your skills on traffic signs. "
            + "Questions are drawn from the full sign catalog, so every test is a little different."
    }

    private func introBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundStyle(.blue)
                .padding(.top, 2)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        TestsTabView()
    }
    .environment(SignCatalog.shared)
    .environment(TestHistoryStore.shared)
}
