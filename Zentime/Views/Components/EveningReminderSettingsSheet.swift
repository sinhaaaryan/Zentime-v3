// Zentime/Views/Components/EveningReminderSettingsSheet.swift
import SwiftUI

struct EveningReminderSettingsSheet: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.dismiss) private var dismiss

    @State private var reminderDate: Date = Date()

    var body: some View {
        VStack(spacing: 24) {
            Text("Evening Reminder")
                .font(ZentimeTheme.headlineFont)
                .foregroundStyle(ZentimeTheme.primaryText)
                .padding(.top, 24)

            Text("You'll get a notification at this time each evening to plan your focus sessions.")
                .font(ZentimeTheme.captionFont)
                .foregroundStyle(ZentimeTheme.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            DatePicker("Reminder Time", selection: $reminderDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .colorScheme(.dark)

            Button {
                let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
                notificationService.updateEveningReminderTime(
                    hour: components.hour ?? 21,
                    minute: components.minute ?? 30
                )
                HapticManager.notification(.success)
                dismiss()
            } label: {
                Text("Save")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: ZentimeTheme.buttonCornerRadius).fill(Color.white))
            }

            Spacer()
        }
        .padding(.horizontal, ZentimeTheme.spacing)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            let (hour, minute) = notificationService.savedEveningReminderTime()
            var components = DateComponents()
            components.hour = hour
            components.minute = minute
            reminderDate = Calendar.current.date(from: components) ?? Date()
        }
    }
}
