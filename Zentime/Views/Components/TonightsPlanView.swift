// Zentime/Views/Components/TonightsPlanView.swift
import SwiftUI
import SwiftData

struct TonightsPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService

    @Query(sort: \ScheduledSession.scheduledDate) private var allScheduled: [ScheduledSession]
    @State private var showAddSheet = false
    @State private var showReminderSettings = false

    private var todaysSessions: [ScheduledSession] {
        let calendar = Calendar.current
        let now = Date()
        guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) else { return [] }
        // Lower bound is `now` (not startOfDay) — intentionally hides past-time sessions
        // so the list only shows upcoming sessions for the rest of tonight.
        return allScheduled.filter { $0.scheduledDate >= now && $0.scheduledDate <= endOfDay }
    }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    private var reminderTimeLabel: String {
        let (hour, minute) = notificationService.savedEveningReminderTime()
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return Self.timeFormatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Tonight's Plan")
                    .font(ZentimeTheme.headlineFont)
                    .foregroundStyle(ZentimeTheme.primaryText)
                Spacer()
                Button {
                    HapticManager.impact(.light)
                    showAddSheet = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Add")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(ZentimeTheme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ZentimeTheme.glassBackground)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(ZentimeTheme.glassBorder, lineWidth: 0.5))
                    )
                }
            }

            // Session list or empty state
            if todaysSessions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "moon.stars")
                        .font(.system(size: 28))
                        .foregroundStyle(ZentimeTheme.secondaryText.opacity(0.5))
                    Text("Plan your evening focus sessions")
                        .font(ZentimeTheme.captionFont)
                        .foregroundStyle(ZentimeTheme.secondaryText.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(todaysSessions) { session in
                    ScheduledSessionRow(session: session)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                deleteSession(session)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }

            // Evening reminder footer
            Button {
                showReminderSettings = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 10))
                    Text("Evening reminder at \(reminderTimeLabel) · tap to change")
                        .font(.system(size: 11))
                }
                .foregroundStyle(ZentimeTheme.secondaryText.opacity(0.5))
                .frame(maxWidth: .infinity)
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
        .sheet(isPresented: $showAddSheet) {
            AddSessionSheet()
                .environment(notificationService)
                .presentationDetents([.large])
                .presentationBackground(Color.black.opacity(0.97))
        }
        .sheet(isPresented: $showReminderSettings) {
            EveningReminderSettingsSheet()
                .environment(notificationService)
                .presentationDetents([.medium])
                .presentationBackground(Color.black.opacity(0.97))
        }
    }

    private func deleteSession(_ session: ScheduledSession) {
        notificationService.cancelSessionReminder(notificationID: session.notificationID)
        modelContext.delete(session)
        HapticManager.impact(.medium)
    }
}

// MARK: - ScheduledSessionRow

struct ScheduledSessionRow: View {
    let session: ScheduledSession

    private var mode: AppMode? { AppMode(rawValue: session.mode) }

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }()

    private var reminderTimeLabel: String {
        let reminderDate = session.scheduledDate.addingTimeInterval(-5 * 60)
        return Self.timeFormatter.string(from: reminderDate)
    }

    private var scheduledTimeLabel: String {
        return Self.timeFormatter.string(from: session.scheduledDate)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: mode?.iconName ?? "bolt.fill")
                .font(.system(size: 16))
                .foregroundStyle(ZentimeTheme.primaryText)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(ZentimeTheme.glassBackground)
                        .overlay(Circle().stroke(ZentimeTheme.glassBorder, lineWidth: 0.5))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(mode?.title ?? session.mode)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(ZentimeTheme.primaryText)
                Text("\(scheduledTimeLabel) · \(session.durationMinutes) min")
                    .font(.system(size: 12))
                    .foregroundStyle(ZentimeTheme.secondaryText)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 9))
                Text(reminderTimeLabel)
                    .font(.system(size: 11))
            }
            .foregroundStyle(ZentimeTheme.secondaryText.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.04))
        )
    }
}
