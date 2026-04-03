// Zentime/Views/Components/FocusActivityGridView.swift
import SwiftUI
import SwiftData

enum ActivityRange: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

struct FocusActivityGridView: View {
    @Query private var allCompleted: [CompletedSession]
    @State private var selectedRange: ActivityRange = .month
    @State private var selectedDay: Date? = nil
    @State private var showDaySheet = false

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Focus Activity")
                    .font(ZentimeTheme.headlineFont)
                    .foregroundStyle(ZentimeTheme.primaryText)
                Spacer()
                // Range toggle
                HStack(spacing: 4) {
                    ForEach(ActivityRange.allCases, id: \.self) { range in
                        Button(range.rawValue) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedRange = range
                            }
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(selectedRange == range ? ZentimeTheme.primaryText : ZentimeTheme.secondaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedRange == range ? Color.white.opacity(0.18) : Color.white.opacity(0.06))
                        )
                    }
                }
            }

            // Grid
            let days = daysForRange(selectedRange)
            let columns = columnsForRange(selectedRange)
            let maxCount = days.map { sessionCount(for: $0) }.max() ?? 1

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: columns), spacing: 4) {
                ForEach(days, id: \.self) { day in
                    ActivityCell(
                        date: day,
                        sessionCount: sessionCount(for: day),
                        maxCount: max(maxCount, 4)
                    )
                    .onTapGesture {
                        if sessionCount(for: day) > 0 {
                            selectedDay = day
                            showDaySheet = true
                        }
                    }
                }
            }

            // Legend
            HStack(spacing: 6) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundStyle(ZentimeTheme.secondaryText)
                ForEach([0.0, 0.25, 0.50, 0.75, 1.0], id: \.self) { intensity in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(cellColor(intensity: intensity))
                        .frame(width: 12, height: 12)
                }
                Text("More")
                    .font(.system(size: 10))
                    .foregroundStyle(ZentimeTheme.secondaryText)
                Spacer()
                let todayCount = sessionCount(for: Date())
                Text("Today: \(todayCount) session\(todayCount == 1 ? "" : "s")")
                    .font(.system(size: 10))
                    .foregroundStyle(ZentimeTheme.secondaryText)
            }
        }
        .padding(ZentimeTheme.spacing)
        .background(
            RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                .fill(ZentimeTheme.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                        .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                )
        )
        .sheet(isPresented: $showDaySheet) {
            if let day = selectedDay {
                DaySessionsSheet(date: day, sessions: sessionsOnDay(day))
                    .presentationDetents([.medium])
                    .presentationBackground(Color.black.opacity(0.95))
            }
        }
    }

    // MARK: - Helpers

    private func daysForRange(_ range: ActivityRange) -> [Date] {
        let today = calendar.startOfDay(for: Date())
        switch range {
        case .week:
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }
        case .month:
            return (0..<35).compactMap { calendar.date(byAdding: .day, value: -34 + $0, to: today) }
        case .year:
            return (0..<364).compactMap { calendar.date(byAdding: .day, value: -363 + $0, to: today) }
        }
    }

    private func columnsForRange(_ range: ActivityRange) -> Int {
        switch range {
        case .week: return 7
        case .month: return 7
        case .year: return 13 // 13 columns × 28 rows = 364 days (simplified year view for mobile)
        }
    }

    private func sessionCount(for date: Date) -> Int {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return 0 }
        return allCompleted.filter { $0.completedAt >= start && $0.completedAt < end }.count
    }

    private func sessionsOnDay(_ date: Date) -> [CompletedSession] {
        let start = calendar.startOfDay(for: date)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [] }
        return allCompleted.filter { $0.completedAt >= start && $0.completedAt < end }
            .sorted { $0.completedAt > $1.completedAt }
    }

    private func cellColor(intensity: Double) -> Color {
        if intensity == 0 { return Color.white.opacity(0.06) }
        return Color.green.opacity(0.25 + intensity * 0.75)
    }
}

// MARK: - ActivityCell

struct ActivityCell: View {
    let date: Date
    let sessionCount: Int
    let maxCount: Int

    private let calendar = Calendar.current

    private var isToday: Bool { calendar.isDateInToday(date) }
    private var isFuture: Bool { date > Date() }

    private var intensity: Double {
        guard sessionCount > 0 else { return 0 }
        return min(Double(sessionCount) / Double(max(maxCount, 4)), 1.0)
    }

    private var fillColor: Color {
        if isFuture || sessionCount == 0 { return Color.white.opacity(0.06) }
        return Color.green.opacity(0.25 + intensity * 0.75)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(fillColor)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(
                        isToday ? Color.white.opacity(0.8) : (isFuture ? Color.white.opacity(0.15) : Color.clear),
                        style: isFuture ? StrokeStyle(lineWidth: 0.5, dash: [3, 2]) : StrokeStyle(lineWidth: 1.5)
                    )
            )
            .shadow(color: isToday ? Color.white.opacity(0.3) : Color.green.opacity(sessionCount > 0 ? 0.2 : 0), radius: isToday ? 4 : 2)
            .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - DaySessionsSheet

struct DaySessionsSheet: View {
    let date: Date
    let sessions: [CompletedSession]

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(dateString)
                .font(ZentimeTheme.headlineFont)
                .foregroundStyle(ZentimeTheme.primaryText)
                .padding(.top, 20)

            Text("\(sessions.count) session\(sessions.count == 1 ? "" : "s") completed")
                .font(ZentimeTheme.captionFont)
                .foregroundStyle(ZentimeTheme.secondaryText)

            ForEach(sessions) { session in
                HStack {
                    if let mode = AppMode(rawValue: session.mode) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 16))
                            .foregroundStyle(Color.green.opacity(0.8))
                            .frame(width: 32, height: 32)
                            .background(Circle().fill(Color.green.opacity(0.12)))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(AppMode(rawValue: session.mode)?.title ?? session.mode)
                            .font(ZentimeTheme.bodyFont)
                            .foregroundStyle(ZentimeTheme.primaryText)
                        Text("\(session.durationMinutes) min")
                            .font(ZentimeTheme.captionFont)
                            .foregroundStyle(ZentimeTheme.secondaryText)
                    }
                    Spacer()
                    Text(session.completedAt, style: .time)
                        .font(ZentimeTheme.captionFont)
                        .foregroundStyle(ZentimeTheme.secondaryText)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(ZentimeTheme.glassBackground))
            }
            Spacer()
        }
        .padding(.horizontal, ZentimeTheme.spacing)
    }
}
