import SwiftUI

// MARK: - Trigger Button

struct ThemeSwitcherButton: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var showPicker = false

    var body: some View {
        Button {
            HapticManager.selection()
            showPicker = true
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(themeManager.currentPrototype.accentColor)
                    .frame(width: 8, height: 8)
                Text(themeManager.currentPrototype.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(ZentimeTheme.secondaryText)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ZentimeTheme.glassBackground)
                    .overlay(
                        Capsule()
                            .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            ThemePickerSheet()
                .environment(themeManager)
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Picker Sheet

struct ThemePickerSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Choose Style")
                .font(ZentimeTheme.headlineFont)
                .foregroundStyle(ZentimeTheme.primaryText)
                .padding(.horizontal, 24)
                .padding(.top, 28)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PrototypeTheme.allCases) { theme in
                        ThemeSwatch(
                            theme: theme,
                            isSelected: themeManager.currentPrototype == theme
                        )
                        .onTapGesture {
                            HapticManager.impact(.light)
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                themeManager.currentPrototype = theme
                            }
                            dismiss()
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.08, blue: 0.08).ignoresSafeArea())
    }
}

// MARK: - Swatch

struct ThemeSwatch: View {
    let theme: PrototypeTheme
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 12)
                    .fill(theme.backgroundColor)

                // Mini ring arc preview
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.10), lineWidth: 5)
                        .frame(width: 44, height: 44)

                    Circle()
                        .trim(from: 0, to: 0.72)
                        .stroke(
                            theme.swatchGradient,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? theme.accentColor : Color.white.opacity(0.12),
                        lineWidth: isSelected ? 2 : 0.5
                    )
            )
            .scaleEffect(isSelected ? 1.06 : 1.0)

            Text(theme.displayName)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(isSelected ? .white : Color.gray)
                .padding(.top, 6)
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
