//
//  AboutSignImagesView.swift
//  Trafikal
//

import SwiftUI

struct AboutSignImagesView: View {
    @Environment(LocalizationManager.self) private var l10n

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.aboutSignImagesTitle), showsBackButton: true)

            List {
                Section {
                    Text(l10n.text(.aboutSignImagesBody))
                }
                Section(l10n.text(.aboutSource)) {
                    Link(l10n.text(.aboutCommonsLink), destination: URL(string: "https://commons.wikimedia.org/wiki/Road_signs_in_Sweden")!)
                }
                Section(l10n.text(.aboutInProject)) {
                    Text("Run `python3 Scripts/download_sign_assets.py` from the repo root to refresh images after editing `Scripts/sign-commons-map.json`.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .appListSurface()
        }
        .toolbar(.hidden, for: .navigationBar)
        .appScreenBackground()
    }
}
