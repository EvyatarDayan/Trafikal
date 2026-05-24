//
//  HomeView.swift
//  Trafikal
//

import SwiftUI

/// Study tab root content (list of practice options).
struct StudyTabRoot: View {
    @Environment(LocalizationManager.self) private var l10n
    @Environment(SignCatalog.self) private var catalog

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: l10n.text(.studyTitle))

            List {
                if let error = catalog.loadError {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    NavigationLink {
                        StudyCardView(signs: catalog.signs)
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(l10n.text(.studyAllSigns))
                                    .font(.headline)
                                Text(l10n.text(.studyCardsInOrder, catalog.signs.count))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "rectangle.stack.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                } header: {
                    Text(l10n.text(.studyPractice))
                } footer: {
                    Text(l10n.text(.studyPracticeFooter, catalog.signs.count))
                }

                Section {
                    NavigationLink {
                        AboutSignImagesView()
                    } label: {
                        Label(l10n.text(.studyAboutImages), systemImage: "info.circle")
                    }
                }

                Section(l10n.text(.studyQuickStart)) {
                    ForEach(SignCategory.allCases) { category in
                        let items = catalog.signs(in: category)
                        if !items.isEmpty {
                            NavigationLink {
                                StudyCardView(signs: items)
                            } label: {
                                HStack {
                                    Image(systemName: category.systemImage)
                                        .foregroundStyle(category.accentColor)
                                    Text(category.title)
                                    Spacer()
                                    Text("\(items.count)")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .appListSurface()
        }
        .appRootScreen()
        .appScreenBackground()
    }
}
