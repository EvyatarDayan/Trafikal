//
//  TheoryQuestionCategoryStyle.swift
//  Trafikal
//

import SwiftUI

enum TheoryQuestionCategoryStyle {
    static func systemImage(for category: String) -> String {
        let key = category.lowercased()

        if key.contains("trafikregler") || key.contains("traffic rules") || key.contains("general") || key.contains("allmän") {
            return "doc.text.fill"
        }
        if key.contains("trafikanter") || key.contains("road user") || key.contains("cycl") || key.contains("cykel") {
            return "person.2.fill"
        }
        if key.contains("hastighet") || key.contains("speed") {
            return "speedometer"
        }
        if key.contains("skylt") || key.contains("signal") || key.contains("sign") {
            return "signpost.right.fill"
        }
        if key.contains("motorväg") || key.contains("motorway") {
            return "road.lanes"
        }
        if key.contains("påfölj") || key.contains("penalt") || key.contains("enforcement") || key.contains("tillsyn") {
            return "exclamationmark.shield.fill"
        }
        if key.contains("miljö") || key.contains("environment") {
            return "leaf.fill"
        }
        if key.contains("belysning") || key.contains("lighting") {
            return "lightbulb.fill"
        }
        if key.contains("rondell") || key.contains("roundabout") {
            return "arrow.triangle.turn.up.right.circle.fill"
        }
        if key.contains("fordon") || key.contains("vehicle") || key.contains("equipment") {
            return "car.fill"
        }
        if key.contains("park") || key.contains("stopp") || key.contains("stop") {
            return "parkingsign.circle.fill"
        }
        if key.contains("omkör") || key.contains("overtak") {
            return "arrow.left.arrow.right"
        }
        if key.contains("bogser") || key.contains("tow") {
            return "link"
        }
        if key.contains("utryck") || key.contains("emergency") {
            return "light.beacon.max.fill"
        }

        return "questionmark.circle.fill"
    }

    static func accentColor(for category: String) -> Color {
        let key = category.lowercased()

        if key.contains("trafikregler") || key.contains("traffic rules") {
            return Color(red: 0.15, green: 0.35, blue: 0.85)
        }
        if key.contains("trafikanter") || key.contains("road user") {
            return Color(red: 0.1, green: 0.55, blue: 0.35)
        }
        if key.contains("hastighet") || key.contains("speed") {
            return Color(red: 0.9, green: 0.45, blue: 0.1)
        }
        if key.contains("påfölj") || key.contains("penalt") {
            return Color(red: 0.9, green: 0.2, blue: 0.2)
        }
        if key.contains("miljö") || key.contains("environment") {
            return Color(red: 0.2, green: 0.65, blue: 0.35)
        }

        let hash = abs(category.hashValue)
        let hues: [Color] = [
            .blue, .teal, .indigo, .mint, .orange, .purple, .cyan,
        ]
        return hues[hash % hues.count]
    }
}
