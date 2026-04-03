// Zentime/Views/Components/AddSessionSheet.swift
import SwiftUI
import SwiftData

struct AddSessionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: AppMode = .focus
    @State private var scheduledTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        return calendar.nextDate(after: now, matching: DateComponents(minute: 0), matchingPolicy: .nextTime) ?? now
    }()
    @State private var durationMinutes: Int = 25
    @State private var showPermissionAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add Session")
                .font(ZentimeTheme.headlineFont)
                .foregroundStyle(ZentimeTheme.primaryText)
                .padding(.top, 24)

            // Mode picker
            VStack(alignment: .leading, spacing: 8) {
                Text("MODE")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ZentimeTheme.secondaryText)
                    .tracking(1)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(AppMode.allCases) { mode in
                            ModeChip(mode: mode, isSelected: selectedMode == mode)
                                .onTapGesture {
                                    HapticManager.selection()
                                    selectedMode = mode
                                    durationMinutes = mode.defaultFocusMinutes
                                }
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }

            // Time picker
            VStack(alignment: .leading, spacing: 8) {
                Text("TIME")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ZentimeTheme.secondaryText)
                    .tracking(1)

                DatePicker("Session Time", selection: $scheduledTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .colorScheme(.dark)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ZentimeTheme.glassBackground)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ZentimeTheme.glassBorder, lineWidth: 0.5))
                    )
            }

            // Duration stepper
            VStack(alignment: .leading, spacing: 8) {
                Text("DURATION")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(ZentimeTheme.secondaryText)
                    .tracking(1)

                HStack {
                    Button {
                        if durationMinutes > 5 { durationMinutes -= 5; HapticManager.impact(.light) }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(ZentimeTheme.primaryText)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(ZentimeTheme.glassBackground).overlay(Circle().stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)))
                    }
                    .disabled(durationMinutes <= 5)

                    Text("\(durationMinutes) min")
                        .font(ZentimeTheme.bodyFont)
                        .foregroundStyle(ZentimeTheme.primaryText)
                        .frame(width: 80)
                        .multilineTextAlignment(.center)

                    Button {
                        if durationMinutes < 120 { durationMinutes += 5; HapticManager.impact(.light) }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(ZentimeTheme.primaryText)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(ZentimeTheme.glassBackground).overlay(Circle().stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)))
                    }
                    .disabled(durationMinutes >= 120)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ZentimeTheme.glassBackground)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(ZentimeTheme.glassBorder, lineWidth: 0.5))
                )
            }

            Spacer()

            // Add button
            Button {
                saveSession()
            } label: {
                Text("Add Session")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: ZentimeTheme.buttonCornerRadius).fill(Color.white))
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, ZentimeTheme.spacing)
        .background(Color.black.ignoresSafeArea())
        .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enable notifications in Settings to receive session reminders.")
        }
    }

    private func saveSession() {
        let now = Date()
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: scheduledTime)
        var targetComponents = calendar.dateComponents([.year, .month, .day], from: now)
        targetComponents.hour = timeComponents.hour
        targetComponents.minute = timeComponents.minute
        targetComponents.second = 0
        let finalDate = calendar.date(from: targetComponents) ?? scheduledTime

        let session = ScheduledSession(
            mode: selectedMode.rawValue,
            scheduledDate: finalDate,
            durationMinutes: durationMinutes
        )
        modelContext.insert(session)

        if notificationService.isAuthorized {
            notificationService.scheduleSessionReminder(
                notificationID: session.notificationID,
                mode: selectedMode.title,
                scheduledDate: finalDate
            )
            HapticManager.notification(.success)
            dismiss()
        } else {
            Task {
                await notificationService.requestPermission()
                if notificationService.isAuthorized {
                    notificationService.scheduleSessionReminder(
                        notificationID: session.notificationID,
                        mode: selectedMode.title,
                        scheduledDate: finalDate
                    )
                } else {
                    showPermissionAlert = true
                }
                HapticManager.notification(.success)
                dismiss()
            }
        }
    }
}

// MARK: - ModeChip

struct ModeChip: View {
    let mode: AppMode
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: mode.iconName)
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? Color.black : ZentimeTheme.primaryText)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isSelected ? Color.white : ZentimeTheme.glassBackground)
                        .overlay(Circle().stroke(ZentimeTheme.glassBorder, lineWidth: 0.5))
                )

            Text(mode.title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(isSelected ? ZentimeTheme.primaryText : ZentimeTheme.secondaryText)
                .lineLimit(1)
        }
        .frame(width: 64)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}
