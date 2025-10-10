//
//  InfoView.swift
//  Flowt
//
//  Created by Wiktor Drab on 30/09/2025.
//

import SwiftUI

struct InfoView: View {
    @ObservedObject var infoVM: InfoViewModel
    @Environment(\.openURL) private var openURL
    @State private var sheen = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    // MARK: - Body
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 22) {
                headerPanel
                quickActionsPanel
                guidelinesPanel
                faqPanel
                creditsPanel
                footerPanel
            }
            .padding(.horizontal)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) { sheen.toggle() }
        }
    }
    
    // MARK: - Panels
    private var headerPanel: some View {
        EdgeLitContainer {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "About Flowt", subtitle: "Game overview")
                    Text("Flowt is a strategic arcade game where you navigate the seas, connect ports, and master the balance of flow.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 12)
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.cyan.opacity(0.35), .teal.opacity(0.30)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .shadow(color: .cyan.opacity(0.5), radius: 12, x: 0, y: 4)
                        .overlay(Circle().stroke(.white.opacity(0.25), lineWidth: 1))
                    Image("FlowtLogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                }
            }
        }
    }
    
    private var quickActionsPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Quick Actions", subtitle: "Legal & Support")
                
                let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
                
                LazyVGrid(columns: columns, spacing: 12) {
                    ActionCard(title: "Privacy Policy", icon: "lock.fill", gradient: [.cyan, .teal]) {
                        showPrivacy = true
                    }
                    ActionCard(title: "Terms of Service", icon: "doc.text.fill", gradient: [.cyan, .teal]) {
                        showTerms = true
                    }
                    ActionCard(title: "Contact Support", icon: "envelope.fill", gradient: [.cyan, .teal]) {
                        if let url = URL(string: "mailto:flowt.apps@gmail.com") { openURL(url) }
                    }
                    ShareLink(
                        items: [URL(string: "https://apps.apple.com/app/flowt/id6753603068?utm_source=share")!],
                        subject: Text("Flowt"),
                        message: Text("A calm, strategic arcade. Try it!"),
                        preview: { (_: URL) in
                            SharePreview("Flowt", image: Image("FlowtLogo"))
                        }
                    ) { ActionCardChrome(title: "Share Flowt", icon: "square.and.arrow.up.fill", gradient: [.cyan, .teal]) }
                    .buttonStyle(.plain)
                }
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)
            }
        }
        .sheet(isPresented: $showTerms) { SafariSheet(url: infoVM.termsURL) }
        .sheet(isPresented: $showPrivacy) { SafariSheet(url: infoVM.privacyURL) }
    }
    
    private var guidelinesPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Community Guidelines", subtitle: "Our code of conduct")
                
                Bullet(text: "Keep avatars & nicknames appropriate for all ages.")
                Bullet(text: "No hate speech, harassment, or explicit content.")
                Bullet(text: "Report abuse via Support — we review and act quickly.")
                
                Divider()
                    .overlay(LinearGradient(colors: [.white.opacity(0.0), .white.opacity(0.25), .white.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.vertical, 2)
                
                Text("We use automated filters to block inappropriate content, which may not be perfect. Repeated violations may result in account removal.")
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
    }
    
    private var faqPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: "FAQ", subtitle: "Helpful answers")
                
                FAQItem(question: "How is my rank calculated?") {
                    Text("Your global rank is based on your highest submitted score. Ties are resolved by earliest submission.")
                }
                FAQItem(question: "Do I need an account to play?") {
                    Text("Yes. An account is required since your results are saved to the global leaderboard.")
                }
                FAQItem(question: "Why was my avatar rejected?") {
                    Text("We automatically filter avatars for safety. If you believe this was a mistake, contact Support and we’ll review.")
                }
                FAQItem(question: "Can I transfer progress to another device?") {
                    Text("Yes. Sign in with the same account and your top scores will sync.")
                }
            }
            .overlay(alignment: .topTrailing) {
                FlowDecoration()
                    .opacity(0.15)
                    .padding(.trailing, 8)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)
            }
        }
    }
    
    private var creditsPanel: some View {
        EdgeLitContainer {
            VStack(alignment: .leading, spacing: 14) {
                SectionHeader(title: "Credits & Tech", subtitle: "What makes Flow tick")

                TechMap(stops: techStops)
                    .frame(height: 80)
            }
        }
    }
    
    private var footerPanel: some View {
        VStack(spacing: 8) {
            Text("Flowt v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
            Text("© 2025 Wiktor Drab. All rights reserved.")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 6)
    }
}

// MARK: - Subviews
private struct ActionCard: View {
    let title: String
    let icon: String
    let gradient: [Color]
    var action: () -> Void
    
    @State private var pressed = false
    @State private var sweep = false
    
    var body: some View {
        Button(action: {
            Task {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { pressed = true }
                try? await Task.sleep(nanoseconds: 120_000_000)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { pressed = false }
                action()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                
                // Animated shine effect
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.clear)
                    .overlay(
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.30), .clear], startPoint: .leading, endPoint: .trailing))
                            .rotationEffect(.degrees(-14))
                            .offset(x: sweep ? 360 : -360)
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(lineWidth: 1.0)
                            .blur(radius: 1.6)
                    )
                
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [gradient.first ?? .cyan, gradient.last ?? .teal].map { $0.opacity(0.5) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 28, height: 28)
                            .shadow(color: (gradient.first ?? .cyan).opacity(0.4), radius: 8, x: 0, y: 2)
                        Image(systemName: icon)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
            .scaleEffect(pressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) { sweep.toggle() }
        }
    }
}

private struct ActionCardChrome: View {
    let title: String
    let icon: String
    let gradient: [Color]
    @State private var sweep = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)

            // Sheen
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.clear)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, .white.opacity(0.30), .clear], startPoint: .leading, endPoint: .trailing))
                        .rotationEffect(.degrees(-14))
                        .offset(x: sweep ? 360 : -360)
                )
                .mask(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(lineWidth: 1.0)
                        .blur(radius: 1.6)
                )

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [gradient.first ?? .cyan, gradient.last ?? .teal].map { $0.opacity(0.5) }, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 28, height: 28)
                        .shadow(color: (gradient.first ?? .cyan).opacity(0.4), radius: 8, x: 0, y: 2)
                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: false)) { sweep.toggle() }
        }
    }
}


private struct Bullet: View {
    let text: String
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(.cyan)
                .frame(width: 6, height: 6)
            Text(text)
                .foregroundStyle(.white.opacity(0.9))
                .font(.subheadline)
            Spacer()
        }
    }
}

private struct FAQItem<Content: View>: View {
    let question: String
    @ViewBuilder var answer: Content
    @State private var open = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            VStack(alignment: .leading, spacing: 8) {
                answer
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.top, 6)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: open ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                    .foregroundStyle(LinearGradient(colors: [.cyan, .teal], startPoint: .leading, endPoint: .trailing))
                    .font(.system(size: 16, weight: .bold))
                Text(question)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
        .tint(.white)
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.05)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.12), lineWidth: 1))
    }
}

private struct TechMap: View {
    let stops: [TechStopData]

    @State private var selected: UUID?
    @State private var t: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let inset: CGFloat = 20
            let lineY: CGFloat = geo.size.height * 0.45
            let usableW = max(1, geo.size.width - inset * 2)
            let step = stops.count > 1 ? usableW / CGFloat(stops.count - 1) : 0

            ZStack {
                Capsule()
                    .fill(LinearGradient(colors: [.cyan.opacity(0.7), .teal.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: usableW, height: 6)
                    .position(x: geo.size.width / 2, y: lineY)
                    .shadow(color: .cyan.opacity(0.35), radius: 10)

                Circle()
                    .fill(.white)
                    .frame(width: 8, height: 8)
                    .shadow(color: .white.opacity(0.8), radius: 6)
                    .offset(
                        x: -usableW / 2 + t * usableW,
                        y: lineY - geo.size.height / 2
                    )
                    .onAppear {
                        withAnimation(.linear(duration: 4).repeatForever(autoreverses: true)) { t = 1 }
                    }

                ForEach(Array(stops.enumerated()), id: \.element.id) { idx, stop in
                    let x = inset + CGFloat(idx) * step
                    PortView(stop: stop, selected: selected == stop.id)
                        .position(x: x, y: lineY)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selected = (selected == stop.id) ? nil : stop.id
                            }
                        }

                    VStack(spacing: 6) {
                        Text(stop.name)
                            .font(.caption2)
                            .fontWeight(selected == stop.id ? .bold : .semibold)
                            .foregroundStyle(.white)
                            .fixedSize()
                        if selected == stop.id {
                            Tooltip(text: stop.description)
                        }
                    }
                    .position(x: x, y: lineY + 32)
                }
            }
        }
    }
}

private struct PortView: View {
    let stop: TechStopData
    let selected: Bool
    @State private var sheen = false

    var body: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [.cyan.opacity(0.55), .teal.opacity(0.55)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: selected ? 46 : 38, height: selected ? 46 : 38)
                .overlay(Circle().stroke(.white.opacity(0.75), lineWidth: selected ? 2 : 1))
                .shadow(color: .cyan.opacity(0.4), radius: selected ? 14 : 8, x: 0, y: 2)

            Image(systemName: stop.icon)
                .font(.system(size: selected ? 18 : 16, weight: .bold))
                .foregroundStyle(.white)

            Circle()
                .stroke(.clear)
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, .white.opacity(0.28), .clear], startPoint: .leading, endPoint: .trailing))
                        .rotationEffect(.degrees(-20))
                        .offset(x: sheen ? 60 : -60)
                )
                .mask(Circle().stroke(lineWidth: 1.2).blur(radius: 1.2))
                .frame(width: selected ? 46 : 38, height: selected ? 46 : 38)
                .onAppear {
                    withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: false)) {
                        sheen.toggle()
                    }
                }
        }
        .contentShape(Circle())
    }
}

private struct Tooltip: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 0.8)
            )
            .foregroundColor(.white)
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Helpers
private var techStops: [TechStopData] {
    [
        .init(name: "Swift", icon: "chevron.left.forwardslash.chevron.right", description: "Core language"),
        .init(name: "SwiftUI", icon: "square.stack.3d.up", description: "UI framework"),
        .init(name: "SpriteKit", icon: "gamecontroller.fill", description: "2D engine"),
        .init(name: "Firebase Auth", icon: "lock.open.fill", description: "Sign-in & identity"),
        .init(name: "Firestore", icon: "tray.full.fill", description: "Realtime database")
    ]
}

private struct TechStopData: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
}

#if DEBUG
#Preview {
    InfoView(infoVM: InfoViewModel())
}
#endif
