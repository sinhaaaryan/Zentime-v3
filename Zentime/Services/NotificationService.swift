// Zentime/Services/NotificationService.swift
import Foundation
import UserNotifications

@Observable
final class NotificationService {
    static let shared = NotificationService()

    private(set) var isAuthorized = false
    private let center = UNUserNotificationCenter.current()
    private let eveningReminderID = "zentime.evening.reminder"

    private init() {}

    // MARK: - Permission

    func requestPermission() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { self.isAuthorized = granted }
            if granted { scheduleEveningReminderIfNeeded() }
        } catch {
            // Permission denied or error — isAuthorized stays false
        }
    }

    // MARK: - Evening Reminder

    /// Schedules the daily evening reminder. Safe to call multiple times —
    /// UNUserNotificationCenter silently replaces any existing request with the same identifier.
    func scheduleEveningReminderIfNeeded() {
        let (hour, minute) = savedEveningReminderTime()
        scheduleEveningReminder(hour: hour, minute: minute)
    }

    func updateEveningReminderTime(hour: Int, minute: Int) {
        UserDefaults.standard.set(hour, forKey: "zentime.eveningReminderHour")
        UserDefaults.standard.set(minute, forKey: "zentime.eveningReminderMinute")
        center.removePendingNotificationRequests(withIdentifiers: [eveningReminderID])
        scheduleEveningReminder(hour: hour, minute: minute)
    }

    func savedEveningReminderTime() -> (hour: Int, minute: Int) {
        let hour = UserDefaults.standard.object(forKey: "zentime.eveningReminderHour") as? Int ?? 21
        let minute = UserDefaults.standard.object(forKey: "zentime.eveningReminderMinute") as? Int ?? 30
        return (hour, minute)
    }

    private func scheduleEveningReminder(hour: Int, minute: Int) {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Time to plan your evening 🌙"
        content.body = "Schedule your focus sessions for tonight."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: eveningReminderID, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Session Reminders

    func scheduleSessionReminder(notificationID: String, mode: String, scheduledDate: Date) {
        let fireDate = scheduledDate.addingTimeInterval(-5 * 60)
        guard fireDate > Date() else { return } // Don't schedule if already past

        let content = UNMutableNotificationContent()
        content.title = "Starting soon: \(mode)"
        content.body = "Your focus session starts in 5 minutes."
        content.sound = .default

        let interval = fireDate.timeIntervalSinceNow
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelSessionReminder(notificationID: String) {
        center.removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
}
