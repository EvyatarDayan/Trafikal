//
//  AboutSignImagesView.swift
//  Trafikal
//

import SwiftUI

struct AboutSignImagesView: View {
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: "Sign images", showsBackButton: true)

            List {
                Section {
                    Text("Sign images are bundled from Wikimedia Commons diagrams of Swedish road signs. Many are public domain as depictions of signs from the Swedish Transport Agency.")
                }
                Section("Source") {
                    Link("Road signs in Sweden (Commons)", destination: URL(string: "https://commons.wikimedia.org/wiki/Road_signs_in_Sweden")!)
                }
                Section("In this project") {
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
