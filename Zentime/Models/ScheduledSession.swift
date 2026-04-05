// Zentime/Models/ScheduledSession.swift
import Foundation
import SwiftData

@Model
final class ScheduledSession {
    var id: UUID
    var mode: String           // AppMode.rawValue
    var scheduledDate: Date    // exact clock time the session is scheduled for
    var durationMinutes: Int
    var notificationID: String // UNNotificationRequest identifier for the 5-min reminder
    var createdAt: Date

    init(mode: String, scheduledDate: Date, durationMinutes: Int) {
        self.id = UUID()
        self.mode = mode
        self.scheduledDate = scheduledDate
        self.durationMinutes = durationMinutes
        self.notificationID = "zentime.session.\(UUID().uuidString)"
        self.createdAt = Date()
    }
}
