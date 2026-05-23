//
//  ScreenTitleBar.swift
//  Trafikal
//

import SwiftUI

struct ScreenTitleBar: View {
    let title: String
    var subtitle: String?
    var showsBackButton: Bool = false
    var onBack: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)

            if showsBackButton {
                HStack {
                    Button {
                        if let onBack {
                            onBack()
                        } else {
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(Theme.screenBackground)
    }
}
