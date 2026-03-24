import SwiftUI

// MARK: - Blooming Tree View
/// A beautiful, organic tree that grows flowers and fruit with user consistency.
/// Growth level (0.0-1.0), bloom count (0-7 for weekly), fruit count (0-12 for milestones).
struct BloomingTreeView: View {
    let growthLevel: Double
    let bloomCount: Int
    let fruitCount: Int
    let streakDays: Int

    @State private var animateIn = false
    @State private var bloomPulse = false
    @State private var leafSway = false

    // Tree scales with growth
    private var growth: CGFloat { CGFloat(growthLevel) }
    private var trunkHeight: CGFloat { 50 + growth * 90 }
    private var canopyRadius: CGFloat { 45 + growth * 65 }

    var body: some View {
        ZStack {
            // Ground / soil area
            groundView

            // Root system
            rootsView
                .offset(y: trunkHeight * 0.42)

            // Main trunk with branches
            trunkAndBranches
                .offset(y: 10)

            // Leaf canopy clusters
            canopyView
                .offset(y: -trunkHeight * 0.38 - canopyRadius * 0.35)

            // Flowers scattered on canopy
            flowersView
                .offset(y: -trunkHeight * 0.38 - canopyRadius * 0.35)

            // Fruit hanging from canopy
            fruitView
                .offset(y: -trunkHeight * 0.38 - canopyRadius * 0.15)

            // Streak badge at base
            if streakDays > 0 {
                streakBadge
                    .offset(y: trunkHeight * 0.5 + 38)
            }
        }
        .frame(height: trunkHeight + canopyRadius * 2 + 90)
        .onAppear {
            withAnimation(.easeOut(duration: 1.4)) {
                animateIn = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                bloomPulse = true
            }
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                leafSway = true
            }
        }
    }

    // MARK: - Ground
    private var groundView: some View {
        ZStack {
            // Shadow under tree
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            ABTheme.sageGreenDark.opacity(0.12),
                            ABTheme.sageGreenDark.opacity(0.03),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 90
                    )
                )
                .frame(width: 180, height: 25)
                .offset(y: trunkHeight * 0.48 + 14)

            // Little grass tufts
            ForEach(0..<5, id: \.self) { i in
                GrassTuft()
                    .fill(ABTheme.sageGreen.opacity(0.3 + Double(i) * 0.05))
                    .frame(width: 12, height: 10)
                    .offset(
                        x: CGFloat([-60, -30, 8, 35, 62][i]),
                        y: trunkHeight * 0.48 + CGFloat([10, 12, 9, 11, 10][i])
                    )
                    .opacity(animateIn ? 1 : 0)
            }
        }
    }

    // MARK: - Roots
    private var rootsView: some View {
        ZStack {
            // Organic root system - thicker, more natural curves
            OrganicRoot(
                points: [
                    CGPoint(x: 0, y: -5),
                    CGPoint(x: -18, y: 6),
                    CGPoint(x: -45, y: 15),
                    CGPoint(x: -65, y: 22)
                ]
            )
            .stroke(
                LinearGradient(
                    colors: [trunkBrown, trunkBrown.opacity(0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
            )

            // Sub-root from left root
            OrganicRoot(
                points: [
                    CGPoint(x: -40, y: 14),
                    CGPoint(x: -50, y: 26),
                    CGPoint(x: -52, y: 32)
                ]
            )
            .stroke(trunkBrown.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round))

            OrganicRoot(
                points: [
                    CGPoint(x: 0, y: -5),
                    CGPoint(x: 20, y: 8),
                    CGPoint(x: 50, y: 18),
                    CGPoint(x: 72, y: 24)
                ]
            )
            .stroke(
                LinearGradient(
                    colors: [trunkBrown, trunkBrown.opacity(0.4)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 4, lineCap: .round)
            )

            // Sub-root from right root
            OrganicRoot(
                points: [
                    CGPoint(x: 44, y: 16),
                    CGPoint(x: 55, y: 28),
                    CGPoint(x: 58, y: 34)
                ]
            )
            .stroke(trunkBrown.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineCap: .round))

            // Center downward root
            OrganicRoot(
                points: [
                    CGPoint(x: 0, y: -5),
                    CGPoint(x: -3, y: 10),
                    CGPoint(x: 2, y: 25),
                    CGPoint(x: -1, y: 35)
                ]
            )
            .stroke(
                LinearGradient(
                    colors: [trunkBrown, trunkBrown.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                style: StrokeStyle(lineWidth: 3.5, lineCap: .round)
            )
        }
        .scaleEffect(growth * 0.6 + 0.4)
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Trunk & Branches
    private var trunkAndBranches: some View {
        ZStack {
            // Main trunk - organic tapered shape
            OrganicTrunk()
                .fill(
                    LinearGradient(
                        colors: [
                            trunkBrownDark,
                            trunkBrown,
                            trunkBrownLight,
                            trunkBrown
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 24 + growth * 10, height: trunkHeight)

            // Bark texture lines
            ForEach(0..<Int(3 + growth * 4), id: \.self) { i in
                BarkLine(seed: i)
                    .stroke(trunkBrownDark.opacity(0.25), lineWidth: 0.8)
                    .frame(width: 14 + growth * 6, height: trunkHeight * 0.7)
                    .offset(y: CGFloat(i) * 8 - trunkHeight * 0.15)
            }

            // Left branch
            if growth > 0.2 {
                BranchShape(direction: .left, length: 20 + growth * 25)
                    .stroke(
                        LinearGradient(
                            colors: [trunkBrown, trunkBrown.opacity(0.6)],
                            startPoint: .trailing,
                            endPoint: .leading
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .offset(x: -8, y: -trunkHeight * 0.28)
                    .opacity(animateIn ? 1 : 0)
            }

            // Right branch
            if growth > 0.15 {
                BranchShape(direction: .right, length: 25 + growth * 20)
                    .stroke(
                        LinearGradient(
                            colors: [trunkBrown, trunkBrown.opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                    )
                    .offset(x: 8, y: -trunkHeight * 0.35)
                    .opacity(animateIn ? 1 : 0)
            }

            // Upper small branch
            if growth > 0.5 {
                BranchShape(direction: .left, length: 15 + growth * 12)
                    .stroke(
                        trunkBrown.opacity(0.7),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .offset(x: -5, y: -trunkHeight * 0.42)
                    .opacity(animateIn ? Double(growth) : 0)
            }
        }
        .scaleEffect(y: animateIn ? 1 : 0, anchor: .bottom)
    }

    // MARK: - Canopy
    private var canopyView: some View {
        ZStack {
            // Back layer leaf clusters (darker, bigger)
            ForEach(0..<backLeafClusters.count, id: \.self) { i in
                let cluster = backLeafClusters[i]
                LeafCluster(irregularity: cluster.irregularity)
                    .fill(
                        RadialGradient(
                            colors: [
                                leafGreenMid.opacity(0.7),
                                leafGreenDark.opacity(0.5)
                            ],
                            center: .center,
                            startRadius: 2,
                            endRadius: cluster.size * 0.5
                        )
                    )
                    .frame(width: cluster.size, height: cluster.size * 0.85)
                    .offset(x: cluster.offset.width, y: cluster.offset.height)
                    .rotationEffect(.degrees(leafSway ? cluster.sway : -cluster.sway))
            }

            // Mid layer leaf clusters
            ForEach(0..<midLeafClusters.count, id: \.self) { i in
                let cluster = midLeafClusters[i]
                LeafCluster(irregularity: cluster.irregularity)
                    .fill(
                        RadialGradient(
                            colors: [
                                leafGreen.opacity(0.85),
                                leafGreenMid.opacity(0.6)
                            ],
                            center: UnitPoint(x: 0.4, y: 0.35),
                            startRadius: 1,
                            endRadius: cluster.size * 0.5
                        )
                    )
                    .frame(width: cluster.size, height: cluster.size * 0.8)
                    .offset(x: cluster.offset.width, y: cluster.offset.height)
                    .rotationEffect(.degrees(leafSway ? cluster.sway : -cluster.sway))
            }

            // Front highlight clusters (lighter, smaller)
            ForEach(0..<frontLeafClusters.count, id: \.self) { i in
                let cluster = frontLeafClusters[i]
                LeafCluster(irregularity: cluster.irregularity)
                    .fill(
                        RadialGradient(
                            colors: [
                                leafGreenLight.opacity(0.7),
                                leafGreen.opacity(0.4)
                            ],
                            center: UnitPoint(x: 0.35, y: 0.3),
                            startRadius: 0,
                            endRadius: cluster.size * 0.45
                        )
                    )
                    .frame(width: cluster.size, height: cluster.size * 0.75)
                    .offset(x: cluster.offset.width, y: cluster.offset.height)
                    .rotationEffect(.degrees(leafSway ? cluster.sway * 1.2 : -cluster.sway * 1.2))
            }
        }
        .scaleEffect(animateIn ? 1 : 0.2)
        .opacity(animateIn ? 1 : 0)
    }

    // MARK: - Flowers
    private var flowersView: some View {
        ZStack {
            ForEach(0..<min(bloomCount, 7), id: \.self) { index in
                PrettyFlower(
                    petalColor: flowerColor(for: index),
                    centerColor: flowerCenterColor(for: index),
                    size: 16 + CGFloat(index % 3) * 5,
                    petalCount: [5, 6, 5, 7, 5, 6, 5][index % 7]
                )
                .offset(flowerOffset(index: index))
                .scaleEffect(bloomPulse ? 1.08 : 0.92)
                .opacity(animateIn ? 1 : 0)
                .shadow(color: flowerColor(for: index).opacity(0.3), radius: 4, x: 0, y: 2)
                .animation(
                    .easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.35),
                    value: bloomPulse
                )
            }
        }
    }

    // MARK: - Fruit
    private var fruitView: some View {
        ZStack {
            ForEach(0..<min(fruitCount, 12), id: \.self) { index in
                FruitView(
                    baseColor: fruitColor(for: index),
                    size: 11 + CGFloat(index % 3) * 2
                )
                .offset(fruitOffset(index: index))
                .opacity(animateIn ? 1 : 0)
                .animation(
                    .easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                    value: bloomPulse
                )
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

    // MARK: - Colors
    private var trunkBrown: Color { Color(red: 0.48, green: 0.36, blue: 0.26) }
    private var trunkBrownDark: Color { Color(red: 0.35, green: 0.25, blue: 0.18) }
    private var trunkBrownLight: Color { Color(red: 0.58, green: 0.46, blue: 0.34) }

    private var leafGreen: Color { Color(red: 0.42, green: 0.60, blue: 0.38) }
    private var leafGreenDark: Color { Color(red: 0.28, green: 0.45, blue: 0.26) }
    private var leafGreenMid: Color { Color(red: 0.36, green: 0.54, blue: 0.34) }
    private var leafGreenLight: Color { Color(red: 0.55, green: 0.72, blue: 0.48) }

    // MARK: - Leaf Cluster Data
    private struct ClusterData {
        let size: CGFloat
        let offset: CGSize
        let irregularity: CGFloat
        let sway: Double
    }

    private var backLeafClusters: [ClusterData] {
        let r = canopyRadius
        return [
            ClusterData(size: r * 1.1, offset: CGSize(width: 0, height: 0), irregularity: 0.15, sway: 0.8),
            ClusterData(size: r * 0.7, offset: CGSize(width: -r * 0.45, height: r * 0.1), irregularity: 0.2, sway: 1.0),
            ClusterData(size: r * 0.7, offset: CGSize(width: r * 0.5, height: r * 0.05), irregularity: 0.18, sway: 0.9),
            ClusterData(size: r * 0.6, offset: CGSize(width: 0, height: -r * 0.35), irregularity: 0.22, sway: 1.1),
        ]
    }

    private var midLeafClusters: [ClusterData] {
        let r = canopyRadius
        return [
            ClusterData(size: r * 0.85, offset: CGSize(width: -r * 0.2, height: -r * 0.1), irregularity: 0.17, sway: 1.0),
            ClusterData(size: r * 0.8, offset: CGSize(width: r * 0.25, height: -r * 0.15), irregularity: 0.2, sway: 0.7),
            ClusterData(size: r * 0.55, offset: CGSize(width: -r * 0.4, height: -r * 0.2), irregularity: 0.15, sway: 1.3),
            ClusterData(size: r * 0.55, offset: CGSize(width: r * 0.4, height: -r * 0.18), irregularity: 0.19, sway: 1.2),
        ]
    }

    private var frontLeafClusters: [ClusterData] {
        let r = canopyRadius
        return [
            ClusterData(size: r * 0.5, offset: CGSize(width: -r * 0.15, height: -r * 0.25), irregularity: 0.14, sway: 1.5),
            ClusterData(size: r * 0.45, offset: CGSize(width: r * 0.2, height: -r * 0.08), irregularity: 0.18, sway: 1.1),
            ClusterData(size: r * 0.35, offset: CGSize(width: r * 0.05, height: -r * 0.4), irregularity: 0.16, sway: 1.4),
        ]
    }

    // MARK: - Flower Helpers
    private func flowerColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.95, green: 0.75, blue: 0.80), // soft pink
            Color(red: 0.98, green: 0.85, blue: 0.88), // light blush
            Color(red: 0.90, green: 0.70, blue: 0.78), // rose
            Color(red: 0.95, green: 0.88, blue: 0.80), // peach
            Color(red: 0.88, green: 0.78, blue: 0.90), // lavender
            Color(red: 0.98, green: 0.82, blue: 0.82), // light coral
            Color(red: 1.00, green: 0.92, blue: 0.85), // cream blossom
        ]
        return colors[index % colors.count]
    }

    private func flowerCenterColor(for index: Int) -> Color {
        let colors: [Color] = [
            ABTheme.warmGold,
            Color(red: 0.95, green: 0.85, blue: 0.50),
            Color(red: 0.90, green: 0.78, blue: 0.45),
            ABTheme.warmGold.opacity(0.9),
            Color(red: 0.92, green: 0.82, blue: 0.55),
            ABTheme.warmGold,
            Color(red: 0.88, green: 0.80, blue: 0.48),
        ]
        return colors[index % colors.count]
    }

    private func flowerOffset(index: Int) -> CGSize {
        let r = canopyRadius
        let positions: [CGSize] = [
            CGSize(width: -r * 0.38, height: -r * 0.05),
            CGSize(width: r * 0.32, height: -r * 0.22),
            CGSize(width: -r * 0.05, height: -r * 0.45),
            CGSize(width: -r * 0.28, height: -r * 0.32),
            CGSize(width: r * 0.42, height: r * 0.05),
            CGSize(width: r * 0.1, height: -r * 0.15),
            CGSize(width: -r * 0.42, height: -r * 0.22),
        ]
        return positions[index % positions.count]
    }

    private func fruitColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.85, green: 0.32, blue: 0.28), // red apple
            Color(red: 0.95, green: 0.65, blue: 0.30), // orange
            Color(red: 0.85, green: 0.32, blue: 0.28),
            Color(red: 0.90, green: 0.55, blue: 0.25),
            Color(red: 0.85, green: 0.35, blue: 0.30),
            Color(red: 0.95, green: 0.65, blue: 0.30),
            Color(red: 0.82, green: 0.30, blue: 0.28),
            Color(red: 0.92, green: 0.58, blue: 0.28),
            Color(red: 0.85, green: 0.32, blue: 0.28),
            Color(red: 0.95, green: 0.65, blue: 0.30),
            Color(red: 0.85, green: 0.35, blue: 0.30),
            Color(red: 0.90, green: 0.55, blue: 0.25),
        ]
        return colors[index % colors.count]
    }

    private func fruitOffset(index: Int) -> CGSize {
        let r = canopyRadius
        let positions: [CGSize] = [
            CGSize(width: -r * 0.32, height: r * 0.08),
            CGSize(width: r * 0.35, height: r * 0.12),
            CGSize(width: -r * 0.12, height: r * 0.2),
            CGSize(width: r * 0.2, height: r * 0.18),
            CGSize(width: -r * 0.45, height: -r * 0.02),
            CGSize(width: r * 0.45, height: 0),
            CGSize(width: -r * 0.22, height: -r * 0.1),
            CGSize(width: r * 0.08, height: r * 0.15),
            CGSize(width: -r * 0.38, height: r * 0.15),
            CGSize(width: r * 0.38, height: r * 0.05),
            CGSize(width: 0, height: r * 0.22),
            CGSize(width: r * 0.15, height: -r * 0.05),
        ]
        return positions[index % positions.count]
    }
}

// MARK: - Organic Trunk Shape
struct OrganicTrunk: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        // Tapered trunk - wider at base, narrower at top
        path.move(to: CGPoint(x: w * 0.28, y: 0))  // top left

        // Left side with subtle curves
        path.addCurve(
            to: CGPoint(x: w * 0.1, y: h),
            control1: CGPoint(x: w * 0.25, y: h * 0.3),
            control2: CGPoint(x: w * 0.08, y: h * 0.7)
        )

        // Base
        path.addLine(to: CGPoint(x: w * 0.9, y: h))

        // Right side
        path.addCurve(
            to: CGPoint(x: w * 0.72, y: 0),
            control1: CGPoint(x: w * 0.92, y: h * 0.7),
            control2: CGPoint(x: w * 0.75, y: h * 0.3)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Bark Texture Line
struct BarkLine: Shape {
    let seed: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let startX = w * CGFloat(0.3 + Double(seed % 5) * 0.1)

        path.move(to: CGPoint(x: startX, y: 0))

        let steps = 4
        for step in 1...steps {
            let progress = CGFloat(step) / CGFloat(steps)
            let wobble = CGFloat((seed * 7 + step * 13) % 11) / 11.0 * 6 - 3
            path.addLine(to: CGPoint(x: startX + wobble, y: h * progress))
        }

        return path
    }
}

// MARK: - Branch Shape
enum BranchDirection {
    case left, right
}

struct BranchShape: Shape {
    let direction: BranchDirection
    let length: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sign: CGFloat = direction == .left ? -1 : 1

        path.move(to: CGPoint(x: rect.midX, y: rect.midY))
        path.addCurve(
            to: CGPoint(x: rect.midX + sign * length, y: rect.midY - length * 0.6),
            control1: CGPoint(x: rect.midX + sign * length * 0.3, y: rect.midY - length * 0.1),
            control2: CGPoint(x: rect.midX + sign * length * 0.7, y: rect.midY - length * 0.5)
        )
        return path
    }
}

// MARK: - Organic Root
struct OrganicRoot: Shape {
    let points: [CGPoint]

    func path(in rect: CGRect) -> Path {
        guard points.count >= 2 else { return Path() }
        var path = Path()
        path.move(to: CGPoint(x: rect.midX + points[0].x, y: rect.midY + points[0].y))

        if points.count == 2 {
            path.addLine(to: CGPoint(x: rect.midX + points[1].x, y: rect.midY + points[1].y))
        } else {
            for i in 1..<points.count {
                let curr = points[i]
                let prev = points[i - 1]
                let midX = (prev.x + curr.x) / 2
                let midY = (prev.y + curr.y) / 2

                path.addQuadCurve(
                    to: CGPoint(x: rect.midX + curr.x, y: rect.midY + curr.y),
                    control: CGPoint(x: rect.midX + midX + 3, y: rect.midY + midY)
                )
            }
        }

        return path
    }
}

// MARK: - Leaf Cluster (organic blob shape)
struct LeafCluster: Shape {
    let irregularity: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX
        let cy = rect.midY
        let rx = rect.width / 2
        let ry = rect.height / 2
        let segments = 12

        // Create an organic blob by varying the radius
        let firstAngle = 0.0
        let firstRadius = radius(for: 0, rx: rx, ry: ry)
        path.move(to: CGPoint(
            x: cx + firstRadius.x * cos(firstAngle),
            y: cy + firstRadius.y * sin(firstAngle)
        ))

        for i in 1...segments {
            let angle1 = Double(i - 1) / Double(segments) * 2 * .pi
            let angle2 = Double(i) / Double(segments) * 2 * .pi
            let midAngle = (angle1 + angle2) / 2

            let r2 = radius(for: i % segments, rx: rx, ry: ry)
            let rMid = radius(for: i + segments / 2, rx: rx * 1.05, ry: ry * 1.05)

            path.addQuadCurve(
                to: CGPoint(
                    x: cx + r2.x * cos(angle2),
                    y: cy + r2.y * sin(angle2)
                ),
                control: CGPoint(
                    x: cx + rMid.x * cos(midAngle),
                    y: cy + rMid.y * sin(midAngle)
                )
            )
        }

        path.closeSubpath()
        return path
    }

    private func radius(for index: Int, rx: CGFloat, ry: CGFloat) -> CGPoint {
        // Deterministic wobble based on index
        let wobbles: [CGFloat] = [0.92, 1.05, 0.97, 1.08, 0.94, 1.03, 0.96, 1.06, 0.93, 1.04, 0.98, 1.02]
        let wobble = wobbles[index % wobbles.count]
        let factor = 1.0 + (wobble - 1.0) * irregularity * 3
        return CGPoint(x: rx * factor, y: ry * factor)
    }
}

// MARK: - Grass Tuft
struct GrassTuft: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.2, y: h))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.35, y: 0),
            control: CGPoint(x: w * 0.1, y: h * 0.4)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.5, y: h * 0.15),
            control: CGPoint(x: w * 0.45, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.65, y: 0),
            control: CGPoint(x: w * 0.55, y: 0)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.8, y: h),
            control: CGPoint(x: w * 0.9, y: h * 0.4)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Pretty Flower
struct PrettyFlower: View {
    let petalColor: Color
    let centerColor: Color
    let size: CGFloat
    let petalCount: Int

    var body: some View {
        ZStack {
            // Petals with gradient
            ForEach(0..<petalCount, id: \.self) { index in
                PetalShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                petalColor,
                                petalColor.opacity(0.6)
                            ],
                            center: UnitPoint(x: 0.5, y: 0.7),
                            startRadius: 0,
                            endRadius: size * 0.4
                        )
                    )
                    .frame(width: size * 0.42, height: size * 0.65)
                    .offset(y: -size * 0.22)
                    .rotationEffect(.degrees(Double(index) * (360.0 / Double(petalCount))))
            }

            // Inner glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            centerColor,
                            centerColor.opacity(0.7)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.2
                    )
                )
                .frame(width: size * 0.32, height: size * 0.32)

            // Center dots (stamen)
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(centerColor.opacity(0.8))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(
                        x: cos(Double(i) * 2.1) * size * 0.08,
                        y: sin(Double(i) * 2.1) * size * 0.08
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Petal Shape
struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: h))

        // Left curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: 0),
            control1: CGPoint(x: w * -0.15, y: h * 0.65),
            control2: CGPoint(x: w * 0.05, y: h * 0.15)
        )

        // Right curve
        path.addCurve(
            to: CGPoint(x: w * 0.5, y: h),
            control1: CGPoint(x: w * 0.95, y: h * 0.15),
            control2: CGPoint(x: w * 1.15, y: h * 0.65)
        )

        path.closeSubpath()
        return path
    }
}

// MARK: - Fruit View
struct FruitView: View {
    let baseColor: Color
    let size: CGFloat

    var body: some View {
        ZStack {
            // Fruit body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            baseColor.opacity(0.9),
                            baseColor,
                            baseColor.opacity(0.7)
                        ],
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
                .offset(x: -size * 0.12, y: -size * 0.15)

            // Tiny stem
            RoundedRectangle(cornerRadius: 0.5)
                .fill(Color(red: 0.4, green: 0.3, blue: 0.2))
                .frame(width: 1.5, height: size * 0.3)
                .offset(y: -size * 0.55)

            // Tiny leaf on stem
            Ellipse()
                .fill(Color(red: 0.35, green: 0.55, blue: 0.3))
                .frame(width: size * 0.25, height: size * 0.12)
                .rotationEffect(.degrees(-30))
                .offset(x: size * 0.1, y: -size * 0.5)
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 40) {
            Text("Seedling").font(.caption)
            BloomingTreeView(growthLevel: 0.1, bloomCount: 1, fruitCount: 0, streakDays: 1)

            Text("Growing").font(.caption)
            BloomingTreeView(growthLevel: 0.5, bloomCount: 4, fruitCount: 3, streakDays: 14)

            Text("Full Bloom").font(.caption)
            BloomingTreeView(growthLevel: 1.0, bloomCount: 7, fruitCount: 12, streakDays: 100)
        }
        .padding()
    }
    .background(ABTheme.background)
}
