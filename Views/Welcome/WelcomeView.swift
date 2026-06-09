//
//  WelcomeView.swift
//  Trafikal
//

import SwiftUI

struct WelcomeView: View {
    let titlePrefix: String
    let titleBrand: String
    let subtitle: String
    let startTitle: String
    var logoImageName: String = "Trafical"
    let onStart: () -> Void

    private var metrics: WelcomeMetrics { .current }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.welcomeBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: metrics.contentSpacing) {
                        logo

                        VStack(spacing: 10) {
                            VStack(spacing: 4) {
                                Text(titlePrefix)
                                Text(titleBrand)
                            }
                        .font(.system(size: metrics.titleSize, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.appBlue)
                            .multilineTextAlignment(.center)

                            Text(subtitle)
                                .font(.system(size: metrics.subtitleSize))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.top, 20)
                                .padding(.bottom, 10)
                                .frame(maxWidth: metrics.subtitleMaxWidth)
                        }
                        .padding(.horizontal, metrics.horizontalPadding)

                        Button(action: onStart) {
                            Text(startTitle)
                                .font(.system(size: metrics.startLabelSize, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, metrics.startButtonVerticalPadding)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Theme.appBlue,
                                                    Theme.appBlue.opacity(0.82)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule(style: .continuous)
                                        .stroke(Color.white.opacity(0.35), lineWidth: 2)
                                        .blendMode(.overlay)
                                )
                        }
                        .buttonStyle(WelcomeStartButtonStyle())
                        .frame(width: geometry.size.width * metrics.startButtonWidthRatio)
                    }

                    Spacer()
                }
            }
        }
    }

    private var logo: some View {
        Image(logoImageName)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: metrics.logoMaxWidth)
            .accessibilityLabel(titleBrand)
    }
}

private struct WelcomeMetrics {
    let logoMaxWidth: CGFloat
    let contentSpacing: CGFloat
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    let startButtonWidthRatio: CGFloat
    let startButtonVerticalPadding: CGFloat
    let startLabelSize: CGFloat
    let horizontalPadding: CGFloat
    let subtitleMaxWidth: CGFloat

    static var current: WelcomeMetrics {
        if UIDevice.current.userInterfaceIdiom == .pad {
            WelcomeMetrics(
                logoMaxWidth: 480,
                contentSpacing: 48,
                titleSize: 38,
                subtitleSize: 22,
                startButtonWidthRatio: 0.8,
                startButtonVerticalPadding: 22,
                startLabelSize: 32,
                horizontalPadding: 64,
                subtitleMaxWidth: 560
            )
        } else {
            WelcomeMetrics(
                logoMaxWidth: 300,
                contentSpacing: 32,
                titleSize: 28,
                subtitleSize: 17,
                startButtonWidthRatio: 0.8,
                startButtonVerticalPadding: 18,
                startLabelSize: 24,
                horizontalPadding: 36,
                subtitleMaxWidth: .infinity
            )
        }
    }
}

private struct WelcomeStartButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    WelcomeView(
        titlePrefix: "Welcome to",
        titleBrand: "Trafikal",
        subtitle: "Your complete companion for mastering the Swedish theory exam. Learn road signs, practice exam-style questions, and build confidence with tests - all available offline, whenever you're ready.",
        startTitle: "Start",
        onStart: {}
    )
}
