import SwiftUI

// MARK: - Blooming Tree View
/// A storybook-illustration tree with distinct round foliage clusters.
struct BloomingTreeView: View {
    let growthLevel: Double
    let bloomCount: Int
    let fruitCount: Int
    let streakDays: Int

    @State private var animateIn = false
    @State private var bloomPulse = false

    private var growth: CGFloat { max(0.15, CGFloat(growthLevel)) }

    var body: some View {
        ZStack {
            // Ground shadow
            Ellipse()
                .fill(Color.black.opacity(0.06))
                .frame(width: 180, height: 16)
                .offset(y: 72)

            // Roots
            rootsView
                .offset(y: 52)

            // Trunk
            trunkView

            // Canopy - distinct round clusters
            canopyView
                .offset(y: -60 - growth * 20)

            // Flowers
            flowersView
                .offset(y: -60 - growth * 20)

            // Fruit
            fruitView
                .offset(y: -40 - growth * 10)

            // Streak badge
            if streakDays > 0 {
                streakBadge
                    .offset(y: 100)
            }
        }
        .frame(height: 260)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) { animateIn = true }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) { bloomPulse = true }
        }
    }

    // MARK: - Colors
    private let barkColor = Color(red: 0.48, green: 0.35, blue: 0.22)
    private let barkDark = Color(red: 0.36, green: 0.24, blue: 0.14)
    private let foliageDark = Color(red: 0.22, green: 0.40, blue: 0.20)
    private let foliageMid = Color(red: 0.32, green: 0.52, blue: 0.28)
    private let foliageBright = Color(red: 0.42, green: 0.62, blue: 0.36)
    private let foliageLight = Color(red: 0.55, green: 0.72, blue: 0.48)

    // MARK: - Trunk
    private var trunkView: some View {
        ZStack {
            // Main trunk
            TrunkShape()
                .fill(
                    LinearGradient(
                        colors: [barkDark, barkColor, barkColor.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 28 + growth * 10, height: 90 + growth * 30)
                .offset(y: 14)

            // Branches
            if growth > 0.2 {
                BranchCurve()
                    .stroke(barkColor, style: StrokeStyle(lineWidth: 5.5, lineCap: .round))
                    .frame(width: 55 + growth * 20, height: 35)
                    .scaleEffect(x: -1)
                    .offset(x: -(18 + growth * 12), y: -22 - growth * 10)
            }
            if growth > 0.15 {
                BranchCurve()
                    .stroke(barkColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 50 + growth * 18, height: 30)
                    .offset(x: 16 + growth * 10, y: -30 - growth * 12)
            }
            if growth > 0.5 {
                BranchCurve()
                    .stroke(barkColor.opacity(0.8), style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .frame(width: 30 + growth * 12, height: 20)
                    .scaleEffect(x: -1)
                    .offset(x: -(12 + growth * 8), y: -40 - growth * 8)
            }
        }
        .scaleEffect(y: animateIn ? 1 : 0, anchor: .bottom)
    }

    // MARK: - Roots
    private var rootsView: some View {
        ZStack {
            // Left main root
            RootCurve(flip: false)
                .stroke(
                    LinearGradient(colors: [barkColor, barkColor.opacity(0.3)], startPoint: .trailing, endPoint: .leading),
                    style: StrokeStyle(lineWidth: 5.5, lineCap: .round)
                )
                .frame(width: 70 + growth * 30, height: 30)
                .offset(x: -(35 + growth * 15), y: 0)

            // Right main root
            RootCurve(flip: true)
                .stroke(
                    LinearGradient(colors: [barkColor, barkColor.opacity(0.3)], startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 65 + growth * 28, height: 28)
                .offset(x: 32 + growth * 14, y: 2)

            // Center root
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 4, y: 30), control: CGPoint(x: -6, y: 15))
            }
            .stroke(
                LinearGradient(colors: [barkColor, barkColor.opacity(0.2)], startPoint: .top, endPoint: .bottom),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )
            .frame(width: 20, height: 30)

            // Thin sub-roots
            Path { path in
                path.move(to: CGPoint(x: 10, y: 0))
                path.addQuadCurve(to: CGPoint(x: 0, y: 18), control: CGPoint(x: 4, y: 8))
            }
            .stroke(barkColor.opacity(0.25), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: 20, height: 20)
            .offset(x: -(45 + growth * 15), y: 12)

            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(to: CGPoint(x: 12, y: 18), control: CGPoint(x: 8, y: 8))
            }
            .stroke(barkColor.opacity(0.25), style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: 20, height: 20)
            .offset(x: 42 + growth * 14, y: 10)
        }
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Canopy
    private var canopyView: some View {
        ZStack {
            // Each foliage ball is a circle with a radial gradient (light top-left, dark bottom-right)
            // giving it a distinct 3D sphere appearance.

            // Back layer - darker, larger balls
            FoliageBall(baseColor: foliageDark, lightColor: foliageMid, size: 62 + growth * 24)
                .offset(x: 0, y: 10)
            FoliageBall(baseColor: foliageDark, lightColor: foliageMid, size: 50 + growth * 18)
                .offset(x: -(38 + growth * 14), y: 12)
            FoliageBall(baseColor: foliageDark, lightColor: foliageMid, size: 48 + growth * 16)
                .offset(x: 40 + growth * 14, y: 14)

            // Mid layer
            FoliageBall(baseColor: foliageMid, lightColor: foliageBright, size: 58 + growth * 22)
                .offset(x: -(18 + growth * 6), y: -5)
            FoliageBall(baseColor: foliageMid, lightColor: foliageBright, size: 55 + growth * 20)
                .offset(x: 20 + growth * 8, y: -2)
            FoliageBall(baseColor: foliageMid, lightColor: foliageBright, size: 44 + growth * 16)
                .offset(x: -(44 + growth * 10), y: -4)
            FoliageBall(baseColor: foliageMid, lightColor: foliageBright, size: 42 + growth * 14)
                .offset(x: 46 + growth * 10, y: 0)

            // Front layer - lighter, smaller highlights
            FoliageBall(baseColor: foliageBright, lightColor: foliageLight, size: 46 + growth * 16)
                .offset(x: -8, y: -(18 + growth * 8))
            FoliageBall(baseColor: foliageBright, lightColor: foliageLight, size: 40 + growth * 14)
                .offset(x: 14, y: -(10 + growth * 4))
            FoliageBall(baseColor: foliageBright, lightColor: foliageLight, size: 34 + growth * 10)
                .offset(x: -(28 + growth * 6), y: -(14 + growth * 6))

            // Top crown
            FoliageBall(baseColor: foliageBright, lightColor: foliageLight, size: 36 + growth * 12)
                .offset(x: 2, y: -(30 + growth * 12))
        }
        .scaleEffect(animateIn ? 1 : 0.3)
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Flowers
    private var flowersView: some View {
        let count = min(bloomCount, 7)
        let positions: [CGSize] = [
            CGSize(width: -40, height: 8),
            CGSize(width: 35, height: -10),
            CGSize(width: -5, height: -35),
            CGSize(width: -28, height: -20),
            CGSize(width: 45, height: 12),
            CGSize(width: 10, height: -5),
            CGSize(width: -48, height: -10),
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

        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                SimpleFlower(
                    petalColor: petalColors[i],
                    size: 16 + CGFloat(i % 3) * 4
                )
                .offset(positions[i])
                .scaleEffect(bloomPulse ? 1.06 : 0.94)
                .animation(
                    .easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(Double(i) * 0.3),
                    value: bloomPulse
                )
                .opacity(animateIn ? 1 : 0)
            }
        }
    }

    // MARK: - Fruit
    private var fruitView: some View {
        let count = min(fruitCount, 12)
        let positions: [CGSize] = [
            CGSize(width: -35, height: 10),
            CGSize(width: 38, height: 14),
            CGSize(width: -10, height: 22),
            CGSize(width: 22, height: 20),
            CGSize(width: -50, height: 0),
            CGSize(width: 50, height: 4),
            CGSize(width: -24, height: -4),
            CGSize(width: 8, height: 16),
            CGSize(width: -42, height: 18),
            CGSize(width: 40, height: 8),
            CGSize(width: 0, height: 25),
            CGSize(width: 18, height: -2),
        ]
        let fruitColors: [Color] = [
            Color(red: 0.82, green: 0.28, blue: 0.25),
            Color(red: 0.92, green: 0.58, blue: 0.25),
            Color(red: 0.85, green: 0.30, blue: 0.26),
            Color(red: 0.90, green: 0.52, blue: 0.22),
            Color(red: 0.84, green: 0.32, blue: 0.28),
            Color(red: 0.94, green: 0.60, blue: 0.28),
        ]

        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                SmallFruit(color: fruitColors[i % fruitColors.count], size: 10 + CGFloat(i % 3) * 2)
                    .offset(positions[i])
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
}

// MARK: - Foliage Ball
/// A single round foliage cluster with 3D shading - the key building block.
struct FoliageBall: View {
    let baseColor: Color
    let lightColor: Color
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        lightColor,
                        baseColor,
                        baseColor.opacity(0.85)
                    ],
                    center: UnitPoint(x: 0.35, y: 0.3),
                    startRadius: size * 0.05,
                    endRadius: size * 0.55
                )
            )
            .frame(width: size, height: size)
            .shadow(color: baseColor.opacity(0.3), radius: 3, x: 2, y: 3)
    }
}

// MARK: - Simple Flower
struct SimpleFlower: View {
    let petalColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            // 5 petals as ellipses
            ForEach(0..<5, id: \.self) { i in
                Ellipse()
                    .fill(petalColor)
                    .frame(width: size * 0.4, height: size * 0.55)
                    .offset(y: -size * 0.2)
                    .rotationEffect(.degrees(Double(i) * 72))
            }
            // Gold center
            Circle()
                .fill(
                    RadialGradient(
                        colors: [ABTheme.warmGoldLight, ABTheme.warmGold],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.16
                    )
                )
                .frame(width: size * 0.3, height: size * 0.3)
        }
        .frame(width: size, height: size)
        .shadow(color: petalColor.opacity(0.3), radius: 3)
    }
}

// MARK: - PrettyFlower (kept for other views that reference it)
struct PrettyFlower: View {
    let petalColor: Color
    let centerColor: Color
    let size: CGFloat
    let petalCount: Int

    var body: some View {
        ZStack {
            ForEach(0..<petalCount, id: \.self) { i in
                Ellipse()
                    .fill(petalColor)
                    .frame(width: size * 0.38, height: size * 0.55)
                    .offset(y: -size * 0.22)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(petalCount))))
            }
            Circle()
                .fill(centerColor)
                .frame(width: size * 0.3, height: size * 0.3)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Small Fruit
struct SmallFruit: View {
    let color: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.95), color, color.opacity(0.7)],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.55
                    )
                )
                .frame(width: size, height: size)

            // Highlight
            Ellipse()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.35, height: size * 0.25)
                .offset(x: -size * 0.1, y: -size * 0.12)

            // Stem
            RoundedRectangle(cornerRadius: 0.5)
                .fill(Color(red: 0.4, green: 0.3, blue: 0.2))
                .frame(width: 1.5, height: size * 0.3)
                .offset(y: -size * 0.55)
        }
    }
}

// MARK: - Trunk Shape
struct TrunkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.3, y: 0))
        path.addCurve(
            to: CGPoint(x: w * 0.08, y: h),
            control1: CGPoint(x: w * 0.27, y: h * 0.35),
            control2: CGPoint(x: w * 0.06, y: h * 0.7)
        )
        path.addLine(to: CGPoint(x: w * 0.92, y: h))
        path.addCurve(
            to: CGPoint(x: w * 0.7, y: 0),
            control1: CGPoint(x: w * 0.94, y: h * 0.7),
            control2: CGPoint(x: w * 0.73, y: h * 0.35)
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Branch Curve
struct BranchCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: 0),
            control: CGPoint(x: rect.width * 0.35, y: rect.height * 0.2)
        )
        return path
    }
}

// MARK: - Root Curve
struct RootCurve: Shape {
    let flip: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if flip {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.width * 0.4, y: rect.height * 0.3)
            )
        } else {
            path.move(to: CGPoint(x: rect.width, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: rect.height),
                control: CGPoint(x: rect.width * 0.6, y: rect.height * 0.3)
            )
        }
        return path
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            Text("New User").font(.caption)
            BloomingTreeView(growthLevel: 0.0, bloomCount: 0, fruitCount: 0, streakDays: 0)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)

            Text("Growing").font(.caption)
            BloomingTreeView(growthLevel: 0.5, bloomCount: 4, fruitCount: 3, streakDays: 14)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)

            Text("Full Bloom").font(.caption)
            BloomingTreeView(growthLevel: 1.0, bloomCount: 7, fruitCount: 12, streakDays: 100)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)
        }
        .padding()
    }
    .background(ABTheme.background)
}
