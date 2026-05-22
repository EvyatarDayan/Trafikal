//
//  SignCatalog.swift
//  Trafikal
//

import Foundation

@MainActor
@Observable
final class SignCatalog {
    static let shared = SignCatalog()

    private(set) var signs: [Sign] = []
    private(set) var loadError: String?

    private init() {
        load()
    }

    func load() {
        guard let url = Bundle.main.url(forResource: "signs", withExtension: "json") else {
            loadError = "signs.json is missing from the app bundle."
            signs = []
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let bundle = try JSONDecoder().decode(SignsBundle.self, from: data)
            signs = bundle.signs.sorted { $0.code < $1.code }
            loadError = nil
        } catch {
            loadError = "Could not load signs: \(error.localizedDescription)"
            signs = []
        }
    }

    func signs(in category: SignCategory) -> [Sign] {
        signs.filter { $0.category == category }
    }

    func sign(code: String) -> Sign? {
        signs.first { $0.code == code }
    }

    func count(for category: SignCategory) -> Int {
        signs(in: category).count
    }

    var shuffledForQuiz: [Sign] {
        signs.shuffled()
    }

    /// Same sign all day for every user (deterministic from date + catalog).
    func signOfToday(on date: Date = Date(), calendar: Calendar = .current) -> Sign? {
        guard !signs.isEmpty else { return nil }
        let day = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        let index = (year * 366 + day) % signs.count
        return signs[index]
    }
}
