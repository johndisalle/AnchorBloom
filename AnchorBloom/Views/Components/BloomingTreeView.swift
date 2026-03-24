import SwiftUI

// MARK: - Blooming Tree View
/// A beautiful watercolor-style tree that grows flowers and fruit with user consistency.
struct BloomingTreeView: View {
    let growthLevel: Double
    let bloomCount: Int
    let fruitCount: Int
    let streakDays: Int

    @State private var animateIn = false
    @State private var bloomPulse = false

    private var growth: CGFloat { max(0.15, CGFloat(growthLevel)) }
    private var trunkH: CGFloat { 55 + growth * 65 }
    private var canopyR: CGFloat { 55 + growth * 55 }

    // MARK: - Colors
    private let bark = Color(red: 0.50, green: 0.36, blue: 0.24)
    private let barkDark = Color(red: 0.38, green: 0.26, blue: 0.16)
    private let barkLight = Color(red: 0.60, green: 0.46, blue: 0.32)
    private let leafDark = Color(red: 0.25, green: 0.42, blue: 0.22)
    private let leafMid = Color(red: 0.34, green: 0.54, blue: 0.30)
    private let leafBright = Color(red: 0.45, green: 0.64, blue: 0.38)
    private let leafLight = Color(red: 0.58, green: 0.74, blue: 0.50)

    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let baseY = size.height * 0.62

            drawGround(context: &context, cx: cx, baseY: baseY, size: size)
            drawRoots(context: &context, cx: cx, baseY: baseY)
            drawTrunk(context: &context, cx: cx, baseY: baseY)
            drawCanopy(context: &context, cx: cx, baseY: baseY)
            drawFlowers(context: &context, cx: cx, baseY: baseY)
            drawFruit(context: &context, cx: cx, baseY: baseY)
        }
        .frame(height: 280)
        .overlay(alignment: .bottom) {
            if streakDays > 0 {
                streakBadge
                    .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { animateIn = true }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { bloomPulse = true }
        }
    }

    // MARK: - Ground
    private func drawGround(context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat, size: CGSize) {
        // Soft ground shadow
        let groundRect = CGRect(x: cx - 100, y: baseY - 5, width: 200, height: 18)
        context.fill(
            Ellipse().path(in: groundRect),
            with: .color(leafDark.opacity(0.08))
        )

        // Subtle ground line
        let lineRect = CGRect(x: cx - 80, y: baseY + 2, width: 160, height: 8)
        context.fill(
            Ellipse().path(in: lineRect),
            with: .color(leafMid.opacity(0.06))
        )
    }

    // MARK: - Roots
    private func drawRoots(context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        let rootColor = bark.opacity(0.55)
        let spread = 30 + growth * 40

        // Root paths - thick, graceful curves
        let roots: [(dx: CGFloat, dy: CGFloat, ctrl: CGFloat, width: CGFloat)] = [
            (-spread, 28, -15, 5),
            (-spread * 0.55, 32, -8, 3.5),
            (spread * 0.5, 30, 10, 3.5),
            (spread * 1.05, 26, 18, 5),
            (3, 35, 5, 4),
        ]

        for root in roots {
            var path = Path()
            path.move(to: CGPoint(x: cx, y: baseY))
            path.addQuadCurve(
                to: CGPoint(x: cx + root.dx, y: baseY + root.dy),
                control: CGPoint(x: cx + root.dx * 0.5 + root.ctrl, y: baseY + root.dy * 0.4)
            )
            context.stroke(
                path,
                with: .color(rootColor),
                style: StrokeStyle(lineWidth: root.width, lineCap: .round)
            )
        }

        // Thin sub-roots
        let subRoots: [(startDx: CGFloat, startDy: CGFloat, dx: CGFloat, dy: CGFloat)] = [
            (-spread * 0.7, 20, -spread * 0.9, 34),
            (spread * 0.75, 18, spread * 1.0, 32),
            (-8, 28, -18, 40),
        ]

        for sub in subRoots {
            var path = Path()
            path.move(to: CGPoint(x: cx + sub.startDx, y: baseY + sub.startDy))
            path.addLine(to: CGPoint(x: cx + sub.dx, y: baseY + sub.dy))
            context.stroke(
                path,
                with: .color(bark.opacity(0.25)),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
        }
    }

    // MARK: - Trunk
    private func drawTrunk(context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        let topY = baseY - trunkH
        let baseW: CGFloat = 10 + growth * 6
        let topW: CGFloat = 5 + growth * 3

        // Main trunk
        var trunkPath = Path()
        trunkPath.move(to: CGPoint(x: cx - topW, y: topY))
        trunkPath.addCurve(
            to: CGPoint(x: cx - baseW, y: baseY),
            control1: CGPoint(x: cx - topW - 2, y: topY + trunkH * 0.4),
            control2: CGPoint(x: cx - baseW + 1, y: baseY - trunkH * 0.3)
        )
        trunkPath.addLine(to: CGPoint(x: cx + baseW, y: baseY))
        trunkPath.addCurve(
            to: CGPoint(x: cx + topW, y: topY),
            control1: CGPoint(x: cx + baseW - 1, y: baseY - trunkH * 0.3),
            control2: CGPoint(x: cx + topW + 2, y: topY + trunkH * 0.4)
        )
        trunkPath.closeSubpath()

        // Bark gradient via layered fills
        context.fill(trunkPath, with: .color(bark))

        // Light side highlight
        var highlightPath = Path()
        highlightPath.move(to: CGPoint(x: cx - topW * 0.2, y: topY))
        highlightPath.addCurve(
            to: CGPoint(x: cx + baseW * 0.4, y: baseY),
            control1: CGPoint(x: cx + topW * 0.3, y: topY + trunkH * 0.4),
            control2: CGPoint(x: cx + baseW * 0.3, y: baseY - trunkH * 0.3)
        )
        highlightPath.addLine(to: CGPoint(x: cx + baseW, y: baseY))
        highlightPath.addCurve(
            to: CGPoint(x: cx + topW, y: topY),
            control1: CGPoint(x: cx + baseW - 1, y: baseY - trunkH * 0.3),
            control2: CGPoint(x: cx + topW + 2, y: topY + trunkH * 0.4)
        )
        highlightPath.closeSubpath()
        context.fill(highlightPath, with: .color(barkLight.opacity(0.4)))

        // Dark side shadow
        var shadowPath = Path()
        shadowPath.move(to: CGPoint(x: cx - topW, y: topY))
        shadowPath.addCurve(
            to: CGPoint(x: cx - baseW, y: baseY),
            control1: CGPoint(x: cx - topW - 2, y: topY + trunkH * 0.4),
            control2: CGPoint(x: cx - baseW + 1, y: baseY - trunkH * 0.3)
        )
        shadowPath.addLine(to: CGPoint(x: cx - baseW * 0.3, y: baseY))
        shadowPath.addCurve(
            to: CGPoint(x: cx - topW * 0.3, y: topY),
            control1: CGPoint(x: cx - baseW * 0.2, y: baseY - trunkH * 0.3),
            control2: CGPoint(x: cx - topW * 0.1, y: topY + trunkH * 0.4)
        )
        shadowPath.closeSubpath()
        context.fill(shadowPath, with: .color(barkDark.opacity(0.35)))

        // Branches
        if growth > 0.2 {
            drawBranch(context: &context, cx: cx, startY: topY + trunkH * 0.25,
                       dx: -(25 + growth * 20), dy: -(15 + growth * 12), width: 4.5)
        }
        if growth > 0.15 {
            drawBranch(context: &context, cx: cx, startY: topY + trunkH * 0.15,
                       dx: 22 + growth * 18, dy: -(18 + growth * 10), width: 4)
        }
        if growth > 0.5 {
            drawBranch(context: &context, cx: cx, startY: topY + trunkH * 0.08,
                       dx: -(15 + growth * 10), dy: -(12 + growth * 8), width: 3)
        }
    }

    private func drawBranch(context: inout GraphicsContext, cx: CGFloat, startY: CGFloat, dx: CGFloat, dy: CGFloat, width: CGFloat) {
        var path = Path()
        path.move(to: CGPoint(x: cx, y: startY))
        path.addQuadCurve(
            to: CGPoint(x: cx + dx, y: startY + dy),
            control: CGPoint(x: cx + dx * 0.5, y: startY + dy * 0.2)
        )
        context.stroke(path, with: .color(bark), style: StrokeStyle(lineWidth: width, lineCap: .round))
    }

    // MARK: - Canopy
    private func drawCanopy(context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        let topY = baseY - trunkH
        let canopyCenterY = topY - canopyR * 0.25

        // Layer 1: Deep shadow layer (back)
        let backClusters: [(dx: CGFloat, dy: CGFloat, w: CGFloat, h: CGFloat)] = [
            (0, 8, canopyR * 2.0, canopyR * 1.5),
            (-canopyR * 0.5, 5, canopyR * 1.1, canopyR * 0.95),
            (canopyR * 0.5, 10, canopyR * 1.0, canopyR * 0.9),
        ]
        for c in backClusters {
            let rect = CGRect(
                x: cx + c.dx - c.w / 2,
                y: canopyCenterY + c.dy - c.h / 2,
                width: c.w, height: c.h
            )
            context.fill(Ellipse().path(in: rect), with: .color(leafDark.opacity(0.45)))
        }

        // Layer 2: Main canopy mass
        let mainClusters: [(dx: CGFloat, dy: CGFloat, w: CGFloat, h: CGFloat, color: Color)] = [
            (0, 0, canopyR * 1.85, canopyR * 1.4, leafMid.opacity(0.7)),
            (-canopyR * 0.35, -canopyR * 0.12, canopyR * 1.1, canopyR * 0.95, leafBright.opacity(0.65)),
            (canopyR * 0.3, canopyR * 0.05, canopyR * 1.05, canopyR * 0.85, leafMid.opacity(0.6)),
            (0, -canopyR * 0.3, canopyR * 0.95, canopyR * 0.8, leafBright.opacity(0.55)),
            (-canopyR * 0.55, canopyR * 0.1, canopyR * 0.7, canopyR * 0.65, leafMid.opacity(0.5)),
            (canopyR * 0.55, -canopyR * 0.05, canopyR * 0.65, canopyR * 0.6, leafBright.opacity(0.5)),
        ]
        for c in mainClusters {
            let rect = CGRect(
                x: cx + c.dx - c.w / 2,
                y: canopyCenterY + c.dy - c.h / 2,
                width: c.w, height: c.h
            )
            context.fill(Ellipse().path(in: rect), with: .color(c.color))
        }

        // Layer 3: Bright highlights (front)
        let highlights: [(dx: CGFloat, dy: CGFloat, w: CGFloat, h: CGFloat)] = [
            (-canopyR * 0.2, -canopyR * 0.2, canopyR * 0.8, canopyR * 0.65),
            (canopyR * 0.15, -canopyR * 0.05, canopyR * 0.65, canopyR * 0.55),
            (-canopyR * 0.05, -canopyR * 0.42, canopyR * 0.55, canopyR * 0.45),
        ]
        for c in highlights {
            let rect = CGRect(
                x: cx + c.dx - c.w / 2,
                y: canopyCenterY + c.dy - c.h / 2,
                width: c.w, height: c.h
            )
            context.fill(Ellipse().path(in: rect), with: .color(leafLight.opacity(0.35)))
        }
    }

    // MARK: - Flowers
    private func drawFlowers(context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        let count = min(bloomCount, 7)
        guard count > 0 else { return }

        let topY = baseY - trunkH
        let canopyCenterY = topY - canopyR * 0.25

        let positions: [(dx: CGFloat, dy: CGFloat)] = [
            (-canopyR * 0.42, canopyR * 0.05),
            (canopyR * 0.38, -canopyR * 0.18),
            (-canopyR * 0.05, -canopyR * 0.48),
            (-canopyR * 0.32, -canopyR * 0.28),
            (canopyR * 0.48, canopyR * 0.1),
            (canopyR * 0.12, -canopyR * 0.12),
            (-canopyR * 0.5, -canopyR * 0.15),
        ]

        let petalColors: [Color] = [
            Color(red: 0.96, green: 0.78, blue: 0.82),
            Color(red: 0.98, green: 0.86, blue: 0.88),
            Color(red: 0.92, green: 0.72, blue: 0.80),
            Color(red: 0.96, green: 0.88, blue: 0.82),
            Color(red: 0.90, green: 0.80, blue: 0.92),
            Color(red: 0.98, green: 0.84, blue: 0.84),
            Color(red: 1.00, green: 0.92, blue: 0.88),
        ]

        for i in 0..<count {
            let pos = positions[i]
            let fcx = cx + pos.dx
            let fcy = canopyCenterY + pos.dy
            let size: CGFloat = 14 + CGFloat(i % 3) * 4
            let petals = [5, 6, 5, 5, 6, 5, 5][i]
            let petalColor = petalColors[i]

            // Draw petals
            for p in 0..<petals {
                let angle = CGFloat(p) / CGFloat(petals) * 2 * .pi - .pi / 2
                let petalDist = size * 0.32
                let px = fcx + CoreGraphics.cos(angle) * petalDist
                let py = fcy + CoreGraphics.sin(angle) * petalDist
                let petalW = size * 0.38
                let petalH = size * 0.3

                let rect = CGRect(x: px - petalW / 2, y: py - petalH / 2, width: petalW, height: petalH)
                context.fill(
                    Ellipse().path(in: rect),
                    with: .color(petalColor)
                )
            }

            // Draw center
            let centerSize = size * 0.28
            let centerRect = CGRect(x: fcx - centerSize / 2, y: fcy - centerSize / 2, width: centerSize, height: centerSize)
            context.fill(
                Circle().path(in: centerRect),
                with: .color(ABTheme.warmGold)
            )

            // Tiny highlight on center
            let hlSize = size * 0.12
            let hlRect = CGRect(x: fcx - hlSize / 2 - 1, y: fcy - hlSize / 2 - 1, width: hlSize, height: hlSize)
            context.fill(
                Circle().path(in: hlRect),
                with: .color(ABTheme.warmGoldLight.opacity(0.8))
            )
        }
    }

    // MARK: - Fruit
    private func drawFruit(context: inout GraphicsContext, cx: CGFloat, baseY: CGFloat) {
        let count = min(fruitCount, 12)
        guard count > 0 else { return }

        let topY = baseY - trunkH
        let canopyCenterY = topY - canopyR * 0.1

        let positions: [(dx: CGFloat, dy: CGFloat)] = [
            (-canopyR * 0.35, canopyR * 0.12),
            (canopyR * 0.38, canopyR * 0.15),
            (-canopyR * 0.1, canopyR * 0.25),
            (canopyR * 0.22, canopyR * 0.22),
            (-canopyR * 0.5, canopyR * 0.02),
            (canopyR * 0.5, canopyR * 0.05),
            (-canopyR * 0.25, -canopyR * 0.05),
            (canopyR * 0.08, canopyR * 0.18),
            (-canopyR * 0.42, canopyR * 0.2),
            (canopyR * 0.4, canopyR * 0.1),
            (0, canopyR * 0.28),
            (canopyR * 0.18, -canopyR * 0.02),
        ]

        let fruitColors: [Color] = [
            Color(red: 0.82, green: 0.28, blue: 0.25),
            Color(red: 0.92, green: 0.58, blue: 0.25),
            Color(red: 0.85, green: 0.30, blue: 0.26),
            Color(red: 0.90, green: 0.52, blue: 0.22),
            Color(red: 0.84, green: 0.32, blue: 0.28),
            Color(red: 0.94, green: 0.60, blue: 0.28),
        ]

        for i in 0..<count {
            let pos = positions[i]
            let fruitX = cx + pos.dx
            let fruitY = canopyCenterY + pos.dy
            let size: CGFloat = 10 + CGFloat(i % 3) * 2
            let color = fruitColors[i % fruitColors.count]

            // Fruit body
            let fruitRect = CGRect(x: fruitX - size / 2, y: fruitY - size / 2, width: size, height: size)
            context.fill(Circle().path(in: fruitRect), with: .color(color))

            // Highlight
            let hlSize = size * 0.35
            let hlRect = CGRect(x: fruitX - hlSize / 2 - size * 0.12, y: fruitY - hlSize / 2 - size * 0.12, width: hlSize, height: hlSize * 0.7)
            context.fill(Ellipse().path(in: hlRect), with: .color(Color.white.opacity(0.45)))

            // Tiny stem
            var stem = Path()
            stem.move(to: CGPoint(x: fruitX, y: fruitY - size / 2))
            stem.addLine(to: CGPoint(x: fruitX + 1, y: fruitY - size / 2 - size * 0.3))
            context.stroke(stem, with: .color(bark.opacity(0.6)), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
        }
    }

    // MARK: - Streak Badge
    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.caption2)
                .foregroundColor(.orange)
            Text("\(streakDays)")
                .font(.system(.caption, design: .serif, weight: .bold))
                .foregroundColor(ABTheme.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(ABTheme.warmGoldLight.opacity(0.6))
        .cornerRadius(12)
    }
}

// MARK: - PrettyFlower (used by BloomView completion overlay)
struct PrettyFlower: View {
    let petalColor: Color
    let centerColor: Color
    let size: CGFloat
    let petalCount: Int

    var body: some View {
        ZStack {
            ForEach(0..<petalCount, id: \.self) { index in
                Ellipse()
                    .fill(petalColor)
                    .frame(width: size * 0.38, height: size * 0.55)
                    .offset(y: -size * 0.22)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(petalCount))))
            }
            Circle()
                .fill(centerColor)
                .frame(width: size * 0.3, height: size * 0.3)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            Text("New User (0 streak)").font(.caption)
            BloomingTreeView(growthLevel: 0.0, bloomCount: 0, fruitCount: 0, streakDays: 0)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)

            Text("Growing (streak 14)").font(.caption)
            BloomingTreeView(growthLevel: 0.5, bloomCount: 4, fruitCount: 3, streakDays: 14)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)

            Text("Full Bloom (streak 100)").font(.caption)
            BloomingTreeView(growthLevel: 1.0, bloomCount: 7, fruitCount: 12, streakDays: 100)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)
        }
        .padding()
    }
    .background(ABTheme.background)
}
