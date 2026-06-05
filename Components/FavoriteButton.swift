//
//  FavoriteButton.swift
//  Trafikal
//

import SwiftUI

struct FavoriteToggleButton: View {
    let isFavorite: Bool
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.body.weight(.semibold))
                .foregroundStyle(isFavorite ? .red : .secondary)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

struct SignFavoriteButton: View {
    @Environment(FavoritesStore.self) private var favorites
    @Environment(LocalizationManager.self) private var l10n

    let signCode: String

    var body: some View {
        FavoriteToggleButton(
            isFavorite: favorites.isSignFavorite(signCode),
            accessibilityLabel: favorites.isSignFavorite(signCode)
                ? l10n.text(.favoritesRemoveSign)
                : l10n.text(.favoritesAddSign)
        ) {
            favorites.toggleSign(signCode)
        }
    }
}

struct QuestionFavoriteButton: View {
    @Environment(FavoritesStore.self) private var favorites
    @Environment(LocalizationManager.self) private var l10n

    let questionID: Int

    var body: some View {
        FavoriteToggleButton(
            isFavorite: favorites.isQuestionFavorite(questionID),
            accessibilityLabel: favorites.isQuestionFavorite(questionID)
                ? l10n.text(.favoritesRemoveQuestion)
                : l10n.text(.favoritesAddQuestion)
        ) {
            favorites.toggleQuestion(questionID)
        }
    }
}
