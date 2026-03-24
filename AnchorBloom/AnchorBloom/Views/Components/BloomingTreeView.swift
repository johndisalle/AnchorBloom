import SwiftUI

// MARK: - Blooming Tree View
/// The signature visual: a rooted tree that grows flowers and fruit with user consistency.
/// Growth level (0.0-1.0), bloom count (0-7 for weekly), fruit count (0-12 for milestones).
struct BloomingTreeView: View {
    let growthLevel: Double   // 0.0 to 1.0 — how tall/full the tree is
    let bloomCount: Int       // Number of flowers blooming (0-7)
    let fruitCount: Int       // Number of fruit on the tree (0-12)
    let streakDays: Int

    @State private var animateIn = false
    @State private var bloomPulse = false

    // Tree dimensions scale with growth
    private var trunkHeight: CGFloat { 60 + CGFloat(growthLevel) * 100 }
    private var canopySize: CGFloat { 80 + CGFloat(growthLevel) * 120 }
    private var rootSpread: CGFloat { 30 + CGFloat(growthLevel) * 50 }

    var body: some View {
        ZStack {
            // Ground line
            Ellipse()
                .fill(ABTheme.sageGreen.opacity(0.15))
                .frame(width: 200, height: 30)
                .offset(y: trunkHeight / 2 + 10)

            // Roots (visible tendrils going down)
            rootsView
                .offset(y: trunkHeight / 2)

            // Trunk
            trunkView

            // Canopy (leaf mass)
            canopyView
                .offset(y: -trunkHeight / 2 - canopySize / 3)

            // Flowers
            flowersView
                .offset(y: -trunkHeight / 2 - canopySize / 3)

            // Fruit
            fruitView
                .offset(y: -trunkHeight / 2 - canopySize / 4 + 20)

            // Streak badge at base
            if streakDays > 0 {
                streakBadge
                    .offset(y: trunkHeight / 2 + 30)
            }
        }
        .frame(height: trunkHeight + canopySize + 80)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animateIn = true
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                bloomPulse = true
            }
        }
    }

    // MARK: - Roots
    private var rootsView: some View {
        ZStack {
            // Left root
            CurvedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: -rootSpread, y: 25), controlOffset: -10)
                .stroke(ABTheme.sageGreenDark.opacity(0.6), lineWidth: 3)

            // Right root
            CurvedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: rootSpread, y: 25), controlOffset: 10)
                .stroke(ABTheme.sageGreenDark.opacity(0.6), lineWidth: 3)

            // Center root
            CurvedLine(start: CGPoint(x: 0, y: 0), end: CGPoint(x: 5, y: 30), controlOffset: 3)
                .stroke(ABTheme.sageGreenDark.opacity(0.4), lineWidth: 2)
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Trunk
    private var trunkView: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.45, green: 0.35, blue: 0.25),
                        Color(red: 0.55, green: 0.42, blue: 0.30)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 14 + CGFloat(growthLevel) * 8, height: trunkHeight)
            .scaleEffect(y: animateIn ? 1 : 0, anchor: .bottom)
    }

    // MARK: - Canopy
    private var canopyView: some View {
        ZStack {
            // Main canopy shape
            Ellipse()
                .fill(ABTheme.sageGreen.opacity(0.35))
                .frame(width: canopySize * 1.2, height: canopySize)
                .blur(radius: 2)

            Ellipse()
                .fill(ABTheme.sageGreen.opacity(0.5))
                .frame(width: canopySize, height: canopySize * 0.85)

            // Inner highlight
            Ellipse()
                .fill(ABTheme.sageGreen.opacity(0.25))
                .frame(width: canopySize * 0.6, height: canopySize * 0.5)
                .offset(x: -10, y: -8)
        }
        .scaleEffect(animateIn ? 1 : 0.3)
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Flowers
    private var flowersView: some View {
        ZStack {
            ForEach(0..<min(bloomCount, 7), id: \.self) { index in
                FlowerView(
                    color: flowerColor(for: index),
                    size: 18 + CGFloat(index % 3) * 4
                )
                .offset(flowerOffset(index: index, canopySize: canopySize))
                .scaleEffect(bloomPulse ? 1.05 : 0.95)
                .opacity(animateIn ? 1 : 0)
                .animation(
                    .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                    value: bloomPulse
                )
            }
        }
    }

    // MARK: - Fruit
    private var fruitView: some View {
        ZStack {
            ForEach(0..<min(fruitCount, 12), id: \.self) { index in
                Circle()
                    .fill(ABTheme.warmGold)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .fill(ABTheme.warmGoldLight)
                            .frame(width: 4, height: 4)
                            .offset(x: -1, y: -1)
                    )
                    .offset(fruitOffset(index: index, canopySize: canopySize))
                    .opacity(animateIn ? 1 : 0)
            }
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

    // MARK: - Helpers
    private func flowerColor(for index: Int) -> Color {
        let colors: [Color] = [
            ABTheme.blush,
            Color(red: 0.95, green: 0.80, blue: 0.85),
            ABTheme.warmGold.opacity(0.8),
            Color(red: 0.85, green: 0.75, blue: 0.90),
            ABTheme.blush.opacity(0.7),
            Color(red: 0.90, green: 0.82, blue: 0.75),
            ABTheme.sageGreen.opacity(0.6)
        ]
        return colors[index % colors.count]
    }

    private func flowerOffset(index: Int, canopySize: CGFloat) -> CGSize {
        let positions: [CGSize] = [
            CGSize(width: -canopySize * 0.3, height: -canopySize * 0.1),
            CGSize(width: canopySize * 0.25, height: -canopySize * 0.2),
            CGSize(width: 0, height: -canopySize * 0.35),
            CGSize(width: -canopySize * 0.15, height: canopySize * 0.1),
            CGSize(width: canopySize * 0.35, height: 0),
            CGSize(width: -canopySize * 0.35, height: -canopySize * 0.25),
            CGSize(width: canopySize * 0.1, height: canopySize * 0.15)
        ]
        return positions[index % positions.count]
    }

    private func fruitOffset(index: Int, canopySize: CGFloat) -> CGSize {
        let angle = Double(index) * (360.0 / 12.0) * .pi / 180.0
        let radius = canopySize * 0.3
        return CGSize(
            width: cos(angle) * radius,
            height: sin(angle) * radius * 0.6
        )
    }
}

// MARK: - Flower Shape
struct FlowerView: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            // Petals
            ForEach(0..<5, id: \.self) { index in
                Ellipse()
                    .fill(color)
                    .frame(width: size * 0.5, height: size * 0.8)
                    .offset(y: -size * 0.3)
                    .rotationEffect(.degrees(Double(index) * 72))
            }
            // Center
            Circle()
                .fill(ABTheme.warmGold)
                .frame(width: size * 0.35, height: size * 0.35)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Curved Line Shape
struct CurvedLine: Shape {
    let start: CGPoint
    let end: CGPoint
    let controlOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = (start.x + end.x) / 2
        let midY = (start.y + end.y) / 2
        let control = CGPoint(x: midX + controlOffset, y: midY)

        path.move(to: CGPoint(x: rect.midX + start.x, y: rect.midY + start.y))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + end.x, y: rect.midY + end.y),
            control: CGPoint(x: rect.midX + control.x, y: rect.midY + control.y)
        )
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        BloomingTreeView(growthLevel: 0.1, bloomCount: 1, fruitCount: 0, streakDays: 1)
        BloomingTreeView(growthLevel: 0.5, bloomCount: 4, fruitCount: 3, streakDays: 14)
        BloomingTreeView(growthLevel: 1.0, bloomCount: 7, fruitCount: 12, streakDays: 100)
    }
    .padding()
    .background(ABTheme.background)
}
