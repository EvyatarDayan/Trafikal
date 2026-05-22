//
//  SignGraphicView.swift
//  Trafikal
//
//  Vector-style Swedish road sign shapes (no bitmap assets required).
//

import SwiftUI

struct SignGraphicView: View {
    let sign: Sign

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                graphic(for: sign.code, side: side)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func graphic(for code: String, side: CGFloat) -> some View {
        switch code {
        case "A1": warningTriangle(side: side) { curveSymbol(side: side * 0.35) }
        case "A4": warningTriangle(side: side) { crossSymbol(side: side * 0.32) }
        case "A20": warningTriangle(side: side) { crossingSymbol(side: side * 0.34) }
        case "B1": yieldTriangle(side: side)
        case "B2": stopSign(side: side)
        case "B4": priorityDiamond(side: side)
        case "C1": prohibitionCircle(side: side) { noEntryBar(width: side * 0.42) }
        case "C31": speedLimitCircle(side: side, value: sign.displayValue ?? "50")
        case "C32": endSpeedLimitCircle(side: side)
        case "D1": mandatoryCircle(side: side) { arrowUp(height: side * 0.3) }
        case "D2": mandatoryCircle(side: side) { arrowRight(width: side * 0.3) }
        case "D4": mandatoryCircle(side: side) { cycleSymbol(side: side * 0.28) }
        case "E1": informationPlate(side: side) { Text("P").font(.system(size: side * 0.38, weight: .bold)) }
        case "E19": informationPlate(side: side) { pedestrianSymbol(side: side * 0.32) }
        case "T1": supplementaryPlate(side: side, value: sign.displayValue ?? "150")
        default: fallbackBadge(side: side)
        }
    }

    // MARK: - Warning (yellow triangle, red border)

    private func warningTriangle<Content: View>(side: CGFloat, @ViewBuilder symbol: () -> Content) -> some View {
        TriangleShape()
            .fill(Color(red: 0.98, green: 0.88, blue: 0.1))
            .overlay {
                TriangleShape()
                    .stroke(Color.red, lineWidth: side * 0.05)
            }
            .frame(width: side * 0.88, height: side * 0.88)
            .overlay { symbol().foregroundStyle(.black) }
    }

    // MARK: - Priority

    private func yieldTriangle(side: CGFloat) -> some View {
        InvertedTriangleShape()
            .fill(.white)
            .overlay {
                InvertedTriangleShape()
                    .stroke(Color.red, lineWidth: side * 0.05)
            }
            .frame(width: side * 0.82, height: side * 0.72)
    }

    private func stopSign(side: CGFloat) -> some View {
        OctagonShape()
            .fill(Color.red)
            .frame(width: side * 0.82, height: side * 0.82)
            .overlay {
                Text("STOP")
                    .font(.system(size: side * 0.14, weight: .heavy))
                    .foregroundStyle(.white)
            }
    }

    private func priorityDiamond(side: CGFloat) -> some View {
        DiamondShape()
            .fill(Color(red: 0.98, green: 0.88, blue: 0.1))
            .overlay {
                DiamondShape()
                    .stroke(.white, lineWidth: side * 0.04)
            }
            .frame(width: side * 0.55, height: side * 0.55)
    }

    // MARK: - Prohibition / mandatory

    private func prohibitionCircle<Content: View>(side: CGFloat, @ViewBuilder symbol: () -> Content) -> some View {
        Circle()
            .fill(.white)
            .overlay {
                Circle()
                    .stroke(Color.red, lineWidth: side * 0.07)
            }
            .frame(width: side * 0.82, height: side * 0.82)
            .overlay { symbol().foregroundStyle(.black) }
    }

    private func mandatoryCircle<Content: View>(side: CGFloat, @ViewBuilder symbol: () -> Content) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.1, green: 0.35, blue: 0.85))
            symbol()
                .foregroundStyle(.white)
                .padding(side * 0.2)
        }
        .frame(width: side * 0.82, height: side * 0.82)
    }

    private func speedLimitCircle(side: CGFloat, value: String) -> some View {
        prohibitionCircle(side: side) {
            Text(value)
                .font(.system(size: side * 0.22, weight: .bold))
        }
    }

    private func endSpeedLimitCircle(side: CGFloat) -> some View {
        prohibitionCircle(side: side) {
            ZStack {
                Text("50")
                    .font(.system(size: side * 0.18, weight: .bold))
                Rectangle()
                    .fill(.black)
                    .frame(width: side * 0.5, height: side * 0.04)
                    .rotationEffect(.degrees(-35))
            }
        }
    }

    // MARK: - Information / supplementary

    private func informationPlate<Content: View>(side: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        RoundedRectangle(cornerRadius: side * 0.06)
            .fill(Color(red: 0.1, green: 0.35, blue: 0.85))
            .frame(width: side * 0.72, height: side * 0.72)
            .overlay { content().foregroundStyle(.white) }
    }

    private func supplementaryPlate(side: CGFloat, value: String) -> some View {
        RoundedRectangle(cornerRadius: side * 0.04)
            .fill(.white)
            .overlay {
                RoundedRectangle(cornerRadius: side * 0.04)
                    .stroke(.black, lineWidth: side * 0.03)
            }
            .frame(width: side * 0.78, height: side * 0.42)
            .overlay {
                Text(value)
                    .font(.system(size: side * 0.2, weight: .bold))
                    .foregroundStyle(.black)
            }
    }

    private func fallbackBadge(side: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: side * 0.12)
            .fill(sign.category.accentColor.opacity(0.25))
            .overlay {
                Text(sign.code)
                    .font(.system(size: side * 0.22, weight: .bold))
            }
            .frame(width: side * 0.8, height: side * 0.8)
    }

    // MARK: - Symbols

    private func curveSymbol(side: CGFloat) -> some View {
        Image(systemName: "arrow.turn.right.up")
            .font(.system(size: side, weight: .bold))
    }

    private func crossSymbol(side: CGFloat) -> some View {
        Image(systemName: "arrow.up.arrow.down")
            .font(.system(size: side, weight: .bold))
            .rotationEffect(.degrees(45))
    }

    private func crossingSymbol(side: CGFloat) -> some View {
        HStack(spacing: side * 0.08) {
            Image(systemName: "figure.walk")
            Image(systemName: "bicycle")
        }
        .font(.system(size: side * 0.85, weight: .semibold))
    }

    private func noEntryBar(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.red)
            .frame(width: width, height: width * 0.18)
    }

    private func arrowUp(height: CGFloat) -> some View {
        Image(systemName: "arrow.up")
            .font(.system(size: height, weight: .black))
    }

    private func arrowRight(width: CGFloat) -> some View {
        Image(systemName: "arrow.right")
            .font(.system(size: width, weight: .black))
    }

    private func cycleSymbol(side: CGFloat) -> some View {
        Image(systemName: "bicycle")
            .font(.system(size: side, weight: .semibold))
    }

    private func pedestrianSymbol(side: CGFloat) -> some View {
        Image(systemName: "figure.walk")
            .font(.system(size: side, weight: .semibold))
    }
}

// MARK: - Shapes

private struct TriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct InvertedTriangleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct OctagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        let inset = rect.width * 0.22
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + inset))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: rect.maxX - inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + inset, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - inset))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + inset))
        path.closeSubpath()
        return path
    }
}

#Preview {
    SignGraphicView(sign: Sign(
        code: "B2",
        category: .priority,
        name: "Stop",
        meaning: "",
        keywords: [],
        imageName: nil,
        numericValue: nil,
        valueUnit: nil,
        relatedCodes: [],
        difficulty: 1,
        examTip: nil
    ))
    .frame(width: 140, height: 140)
    .padding()
}
