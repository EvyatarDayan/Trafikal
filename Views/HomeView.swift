//
//  HomeView.swift
//  Trafikal
//

import SwiftUI

/// Study tab root content (list of practice options).
struct StudyTabRoot: View {
    @Environment(SignCatalog.self) private var catalog

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: "Study")

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
                                Text("All traffic signs")
                                    .font(.headline)
                                Text("\(catalog.signs.count) cards in order")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "rectangle.stack.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                } header: {
                    Text("Practice")
                } footer: {
                    Text("Move between cards and tap to reveal the meaning. \(catalog.signs.count) signs with official diagrams.")
                }

                Section {
                    NavigationLink {
                        AboutSignImagesView()
                    } label: {
                        Label("About sign images", systemImage: "info.circle")
                    }
                }

                Section("Quick start by category") {
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
