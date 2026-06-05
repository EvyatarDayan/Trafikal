//
//  FavoritesStore.swift
//  Trafikal
//

import Foundation

enum FavoriteAddedConfirmation: Equatable, Identifiable {
    case sign(code: String)
    case question(id: Int)

    var id: String {
        switch self {
        case .sign(let code):
            "sign-\(code)"
        case .question(let id):
            "question-\(id)"
        }
    }
}

@MainActor
@Observable
final class FavoritesStore {
    static let shared = FavoritesStore()

    private(set) var signCodes: Set<String> = []
    private(set) var questionIDs: Set<Int> = []
    private(set) var addedConfirmation: FavoriteAddedConfirmation?
    private(set) var suppressAddedConfirmation = false

    private let signStorageKey = "trafikal.favoriteSigns"
    private let questionStorageKey = "trafikal.favoriteQuestions"
    private let suppressConfirmationKey = "trafikal.favoritesSuppressAddedConfirmation"

    private init() {
        load()
    }

    func isSignFavorite(_ code: String) -> Bool {
        signCodes.contains(code)
    }

    func isQuestionFavorite(_ id: Int) -> Bool {
        questionIDs.contains(id)
    }

    func toggleSign(_ code: String) {
        if signCodes.contains(code) {
            signCodes.remove(code)
            saveSigns()
        } else {
            signCodes.insert(code)
            saveSigns()
            presentAddedConfirmationIfNeeded(.sign(code: code))
        }
    }

    func toggleQuestion(_ id: Int) {
        if questionIDs.contains(id) {
            questionIDs.remove(id)
            saveQuestions()
        } else {
            questionIDs.insert(id)
            saveQuestions()
            presentAddedConfirmationIfNeeded(.question(id: id))
        }
    }

    func acknowledgeAddedConfirmation(dontShowAgain: Bool) {
        if dontShowAgain {
            suppressAddedConfirmation = true
            UserDefaults.standard.set(true, forKey: suppressConfirmationKey)
        }
        addedConfirmation = nil
    }

    private func presentAddedConfirmationIfNeeded(_ kind: FavoriteAddedConfirmation) {
        guard !suppressAddedConfirmation else { return }
        addedConfirmation = kind
    }

    func favoriteSigns(in catalog: SignCatalog) -> [Sign] {
        catalog.signs.filter { signCodes.contains($0.code) }
    }

    func favoriteQuestions(in catalog: TheoryQuestionCatalog) -> [TheoryQuestion] {
        catalog.questions.filter { questionIDs.contains($0.id) }
    }

    private func load() {
        if let codes = UserDefaults.standard.array(forKey: signStorageKey) as? [String] {
            signCodes = Set(codes)
        }
        if let ids = UserDefaults.standard.array(forKey: questionStorageKey) as? [Int] {
            questionIDs = Set(ids)
        }
        suppressAddedConfirmation = UserDefaults.standard.bool(forKey: suppressConfirmationKey)
    }

    private func saveSigns() {
        UserDefaults.standard.set(Array(signCodes).sorted(), forKey: signStorageKey)
    }

    private func saveQuestions() {
        UserDefaults.standard.set(Array(questionIDs).sorted(), forKey: questionStorageKey)
    }
}
