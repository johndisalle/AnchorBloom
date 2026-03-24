import SwiftUI

// MARK: - Blooming Tree View
/// SF Symbol tree with animated growth ring, bloom petals, and fruit dots.
struct BloomingTreeView: View {
    let growthLevel: Double
    let bloomCount: Int
    let fruitCount: Int
    let streakDays: Int

    @State private var animateIn = false
    @State private var ringAppear = false
    @State private var bloomPulse = false
    @State private var shimmer = false

    private var growth: CGFloat { CGFloat(growthLevel) }
    private let ringSize: CGFloat = 190
    private let ringWidth: CGFloat = 8

    var body: some View {
        ZStack {
            // Outer glow when growth is high
            if growth > 0.5 {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ABTheme.sageGreen.opacity(0.08 * growth),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: ringSize * 0.35,
                            endRadius: ringSize * 0.65
                        )
                    )
                    .frame(width: ringSize + 40, height: ringSize + 40)
            }

            // Background track ring
            Circle()
                .stroke(
                    ABTheme.sageGreen.opacity(0.12),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)

            // Growth progress ring
            Circle()
                .trim(from: 0, to: ringAppear ? growth : 0)
                .stroke(
                    AngularGradient(
                        colors: [
                            ABTheme.sageGreen.opacity(0.5),
                            ABTheme.sageGreen,
                            Color(red: 0.45, green: 0.68, blue: 0.40),
                            ABTheme.sageGreen
                        ],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * growth)
                    ),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .shadow(color: ABTheme.sageGreen.opacity(0.3), radius: 4)

            // Secondary inner ring (bloom progress)
            if bloomCount > 0 {
                Circle()
                    .trim(from: 0, to: ringAppear ? CGFloat(bloomCount) / 7.0 : 0)
                    .stroke(
                        ABTheme.blush.opacity(0.6),
                        style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
                    )
                    .frame(width: ringSize - 20, height: ringSize - 20)
                    .rotationEffect(.degrees(-90))
            }

            // Decorative leaf accents around the ring
            leafAccents

            // Small bloom dots on the ring
            bloomDots

            // Fruit dots on outer edge
            fruitDots

            // Center content
            centerContent
        }
        .frame(height: 240)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIn = true
            }
            withAnimation(.easeOut(duration: 1.4).delay(0.3)) {
                ringAppear = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                bloomPulse = true
            }
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                shimmer = true
            }
        }
    }

    // MARK: - Center Content
    private var centerContent: some View {
        VStack(spacing: 6) {
            // Tree icon - transitions through growth stages
            ZStack {
                // Subtle circular background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                ABTheme.sageGreen.opacity(0.08),
                                ABTheme.sageGreen.opacity(0.02),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: treeIconName)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: treeIconColors,
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: ABTheme.sageGreen.opacity(0.2), radius: 6, y: 3)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)
            }

            // Growth stage label
            Text(growthStageName)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundColor(ABTheme.secondaryText)
                .opacity(animateIn ? 1 : 0)

            // Streak indicator
            if streakDays > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("\(streakDays)")
                        .font(.system(.caption2, design: .serif, weight: .bold))
                        .foregroundColor(ABTheme.primaryText)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(ABTheme.warmGoldLight.opacity(0.5))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Leaf Accents
    private var leafAccents: some View {
        let positions: [(angle: Double, size: CGFloat, symbol: String)] = [
            (45, 14, "leaf.fill"),
            (135, 12, "leaf.fill"),
            (225, 11, "leaf.fill"),
            (315, 13, "leaf.fill"),
            (0, 10, "leaf.fill"),
            (180, 10, "leaf.fill"),
        ]
        let visibleCount = max(1, Int(growth * CGFloat(positions.count)))

        return ZStack {
            ForEach(0..<visibleCount, id: \.self) { i in
                let pos = positions[i]
                let angle = Angle.degrees(pos.angle - 90)
                let radius = ringSize / 2

                Image(systemName: pos.symbol)
                    .font(.system(size: pos.size, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.65, blue: 0.38),
                                ABTheme.sageGreen
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .rotationEffect(.degrees(pos.angle + 45))
                    .offset(
                        x: CoreGraphics.cos(angle.radians) * radius,
                        y: CoreGraphics.sin(angle.radians) * radius
                    )
                    .scaleEffect(animateIn ? 1 : 0)
                    .opacity(animateIn ? 0.7 + growth * 0.3 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7).delay(Double(i) * 0.1 + 0.5),
                        value: animateIn
                    )
            }
        }
    }

    // MARK: - Bloom Dots
    private var bloomDots: some View {
        let count = min(bloomCount, 7)

        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Angle.degrees(Double(i) * (360.0 / 7.0) - 90)
                let radius = (ringSize - 20) / 2

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                bloomColor(for: i),
                                bloomColor(for: i).opacity(0.6)
                            ],
                            center: UnitPoint(x: 0.4, y: 0.35),
                            startRadius: 0,
                            endRadius: 6
                        )
                    )
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .fill(ABTheme.warmGold.opacity(0.8))
                            .frame(width: 4, height: 4)
                    )
                    .shadow(color: bloomColor(for: i).opacity(0.4), radius: 3)
                    .offset(
                        x: CoreGraphics.cos(angle.radians) * radius,
                        y: CoreGraphics.sin(angle.radians) * radius
                    )
                    .scaleEffect(bloomPulse ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(Double(i) * 0.25),
                        value: bloomPulse
                    )
                    .opacity(animateIn ? 1 : 0)
            }
        }
    }

    // MARK: - Fruit Dots
    private var fruitDots: some View {
        let count = min(fruitCount, 12)

        return ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Angle.degrees(Double(i) * (360.0 / 12.0) - 90)
                let radius = ringSize / 2 + 14

                Circle()
                    .fill(fruitColor(for: i))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .fill(Color.white.opacity(0.35))
                            .frame(width: 3, height: 3)
                            .offset(x: -1, y: -1)
                    )
                    .shadow(color: fruitColor(for: i).opacity(0.3), radius: 2)
                    .offset(
                        x: CoreGraphics.cos(angle.radians) * radius,
                        y: CoreGraphics.sin(angle.radians) * radius
                    )
                    .opacity(animateIn ? 1 : 0)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7).delay(Double(i) * 0.08 + 0.8),
                        value: animateIn
                    )
            }
        }
    }

    // MARK: - Tree Icon Logic
    private var treeIconName: String {
        switch growth {
        case 0..<0.15: return "leaf.fill"
        case 0.15..<0.35: return "leaf.fill"
        case 0.35..<0.65: return "tree.fill"
        default: return "tree.fill"
        }
    }

    private var treeIconColors: [Color] {
        switch growth {
        case 0..<0.15:
            return [Color(red: 0.55, green: 0.75, blue: 0.45), ABTheme.sageGreen]
        case 0.15..<0.35:
            return [Color(red: 0.48, green: 0.68, blue: 0.38), ABTheme.sageGreenDark]
        case 0.35..<0.65:
            return [Color(red: 0.42, green: 0.62, blue: 0.35), ABTheme.sageGreenDark]
        default:
            return [Color(red: 0.38, green: 0.58, blue: 0.32), Color(red: 0.25, green: 0.42, blue: 0.22)]
        }
    }

    private var growthStageName: String {
        switch growth {
        case 0..<0.15: return "Seedling"
        case 0.15..<0.35: return "Sprouting"
        case 0.35..<0.65: return "Growing"
        case 0.65..<0.85: return "Flourishing"
        default: return "Full Bloom"
        }
    }

    // MARK: - Color Helpers
    private func bloomColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.95, green: 0.75, blue: 0.80),
            Color(red: 0.98, green: 0.85, blue: 0.88),
            Color(red: 0.90, green: 0.70, blue: 0.78),
            Color(red: 0.95, green: 0.88, blue: 0.80),
            Color(red: 0.88, green: 0.78, blue: 0.90),
            Color(red: 0.98, green: 0.82, blue: 0.82),
            Color(red: 1.00, green: 0.92, blue: 0.85),
        ]
        return colors[index % colors.count]
    }

    private func fruitColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.82, green: 0.30, blue: 0.25),
            Color(red: 0.92, green: 0.58, blue: 0.25),
            Color(red: 0.85, green: 0.32, blue: 0.28),
            Color(red: 0.90, green: 0.52, blue: 0.22),
            Color(red: 0.84, green: 0.34, blue: 0.28),
            Color(red: 0.94, green: 0.60, blue: 0.28),
        ]
        return colors[index % colors.count]
    }
}

// MARK: - PrettyFlower (used by BloomView)
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

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            Text("New User").font(.caption)
            BloomingTreeView(growthLevel: 0.0, bloomCount: 0, fruitCount: 0, streakDays: 0)
                .padding()
                .background(ABTheme.cardBackground)
                .cornerRadius(16)

            Text("Sprouting").font(.caption)
            BloomingTreeView(growthLevel: 0.25, bloomCount: 2, fruitCount: 1, streakDays: 5)
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
