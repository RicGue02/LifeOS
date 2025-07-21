//
//  NotificationManager.swift
//  Life OS
//
//  Created by Ricardo Guerrero Godínez on 21/7/25.
//

import Foundation
import UserNotifications
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            
            if granted {
                await UIApplication.shared.registerForRemoteNotifications()
            }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }
    
    private func checkAuthorizationStatus() {
        Task {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }
    
    func scheduleTaskReminder(for task: Task) async {
        guard isAuthorized,
              let dueDate = task.dueDate,
              dueDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        
        // Set reminder 30 minutes before due date
        let triggerDate = dueDate.addingTimeInterval(-30 * 60)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "task-\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule task reminder: \(error)")
        }
    }
    
    func scheduleHabitReminder(for habit: Habit, at time: Date) async {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to \(habit.name)"
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "habit-\(habit.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule habit reminder: \(error)")
        }
    }
    
    func cancelTaskReminder(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task-\(task.id.uuidString)"]
        )
    }
    
    func cancelHabitReminder(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["habit-\(habit.id.uuidString)"]
        )
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func setupNotificationActions() {
        // Task actions
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_TASK",
            title: "Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_TASK",
            title: "Snooze 30 min",
            options: []
        )
        
        let taskCategory = UNNotificationCategory(
            identifier: "TASK_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        // Habit actions
        let doneAction = UNNotificationAction(
            identifier: "COMPLETE_HABIT",
            title: "Done",
            options: [.foreground]
        )
        
        let skipAction = UNNotificationAction(
            identifier: "SKIP_HABIT",
            title: "Skip Today",
            options: []
        )
        
        let habitCategory = UNNotificationCategory(
            identifier: "HABIT_REMINDER",
            actions: [doneAction, skipAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([taskCategory, habitCategory])
    }
}