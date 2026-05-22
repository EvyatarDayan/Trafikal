//
//  SettingsView.swift
//  Trafikal
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            Form {
                Section {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                Section("Preferences") {
                    darkModeRow
                }

                Section {
                    Text("")
                        .frame(height: 30)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
            }
            .scrollContentBackground(.hidden)
            .background(Theme.screenBackground)
        }
        .appRootScreen()
        .background(Theme.screenBackground)
    }

    private var pageHeader: some View {
        VStack(spacing: 4) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("Customize your app preferences")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal)
        .padding(.top, 15)
        .padding(.bottom, 6)
        .background(Theme.screenBackground)
    }

    private var darkModeRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "moon.fill")
                .font(.title2)
                .foregroundStyle(.purple)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dark mode")
                    .font(.body)
                    .foregroundStyle(.primary)
                Text("Toggle appearance")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
                .scaleEffect(0.72, anchor: .trailing)
        }
    }
}

#Preview {
    SettingsView()
}
