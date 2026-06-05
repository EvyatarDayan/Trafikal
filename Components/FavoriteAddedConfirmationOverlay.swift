//
//  FavoriteAddedConfirmationOverlay.swift
//  Trafikal
//

import SwiftUI

private struct FavoriteAddedConfirmationSheetModifier: ViewModifier {
    @Environment(FavoritesStore.self) private var favorites
    @Environment(LocalizationManager.self) private var l10n

    @State private var dontShowAgain = false

    private var presentedConfirmation: Binding<FavoriteAddedConfirmation?> {
        Binding(
            get: { favorites.addedConfirmation },
            set: { newValue in
                if newValue == nil {
                    favorites.acknowledgeAddedConfirmation(dontShowAgain: dontShowAgain)
                }
            }
        )
    }

    func body(content: Content) -> some View {
        content
            .sheet(item: presentedConfirmation) { kind in
                FavoriteAddedConfirmationSheet(
                    message: message(for: kind),
                    dontShowAgain: $dontShowAgain,
                    onOK: { presentedConfirmation.wrappedValue = nil }
                )
            }
            .onChange(of: favorites.addedConfirmation) { _, newValue in
                if newValue != nil {
                    dontShowAgain = false
                }
            }
    }

    private func message(for kind: FavoriteAddedConfirmation) -> String {
        switch kind {
        case .sign(let code):
            l10n.text(.favoritesAddedSign, code)
        case .question:
            l10n.text(.favoritesAddedQuestion)
        }
    }
}

private struct FavoriteAddedConfirmationSheet: View {
    @Environment(LocalizationManager.self) private var l10n

    let message: String
    @Binding var dontShowAgain: Bool
    let onOK: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(message)
                .font(.body.weight(.bold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                dontShowAgain.toggle()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(dontShowAgain ? Color.accentColor : .secondary)

                    Text(l10n.text(.favoritesDontShowAgain))
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            Button(l10n.text(.commonOK), action: onOK)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.top, 28)
        .padding(.bottom, 24)
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
    }
}

extension View {
    func favoriteAddedConfirmationOverlay() -> some View {
        modifier(FavoriteAddedConfirmationSheetModifier())
    }
}
