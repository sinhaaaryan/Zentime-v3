// Zentime/Models/CompletedSession.swift
import Foundation
import SwiftData

@Model
final class CompletedSession {
    var id: UUID
    var mode: String
    var completedAt: Date
    var durationMinutes: Int

    init(mode: String, durationMinutes: Int) {
        self.id = UUID()
        self.mode = mode
        self.completedAt = Date()
        self.durationMinutes = durationMinutes
    }
}
