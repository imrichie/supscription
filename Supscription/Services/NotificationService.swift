//
//  NotificationService.swift
//  Supscription
//
//  Created by Ricardo Flores on 4/20/25.
//

import AppKit
import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}
    
    // MARK: - Request Permission
    func requestPermissionIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                #if DEBUG
                print("[Notifications] Permission granted: \(granted)")
                #endif
            } catch {
                #if DEBUG
                print("[Notifications] Failed to request permission: \(error.localizedDescription)")
                #endif
            }
            
        case .denied:
            #if DEBUG
            print("[Notifications] Notifications are denied. Suggest enabling in System Settings.")
            #endif
            await showNotificationSettingsAlert()
            
        case .authorized:
            #if DEBUG
            print("[Notifications] Already authorized.")
            #endif
            return
            
        case .provisional:
            #if DEBUG
            print("[Notifications] Provisional authorization—used on iOS, but handled for completeness.")
            #endif

        case .ephemeral:
            #if DEBUG
            print("[Notifications] Ephemeral authorization—used on iOS, but handled for completeness.")
            #endif

        @unknown default:
            #if DEBUG
            print("[Notifications] Unknown authorization status.")
            #endif
            return
        }
    }
    
    // MARK: - Show alert to open system preferences
    @MainActor
    private func showNotificationSettingsAlert() {
        let alert = NSAlert()
        alert.messageText = "Notifications Are Turned Off"
        alert.informativeText = "To get reminders about upcoming subscription cancellations, please enable notifications in System Settings."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    // MARK: - Schedule Notification
    func scheduleCancelReminder(for subscription: Subscription) {
        guard let reminderDate = subscription.cancelReminderDate else { return }
        
        let now = Date()
        let normalizedDate = reminderDate.normalizedToMorning()

        let content = UNMutableNotificationContent()
        content.title = "Cancellation Reminder"
        content.body = notificationBody(for: subscription)
        content.sound = .default
        content.userInfo = ["subscriptionID": subscription.id.uuidString]
        content.threadIdentifier = "cancelReminder"
        content.summaryArgument = subscription.accountName
        
        let trigger: UNNotificationTrigger
        
        if normalizedDate <= now {
            // Fire in 10 seconds if selected date is now or in the past
            #if DEBUG
            print("[Notifications] Reminder set for today or earlier. Firing in 10 seconds.")
            #endif
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        } else {
            // Schedule for 9 AM on a future day
            let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: normalizedDate)
            #if DEBUG
            print("[Notifications] Scheduling reminder for future date: \(normalizedDate)")
            #endif
            trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: "cancelReminder_\(subscription.id.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            #if DEBUG
            if let error = error {
                print("[Notifications] Failed to schedule: \(error.localizedDescription)")
            } else {
                print("[Notifications] Scheduled reminder for \(subscription.accountName) at \(normalizedDate)")
            }
            #endif
        }
    }
    
    // MARK: - Remove Notification
    func removeNotification(for subscription: Subscription) {
        let identifier = "cancelReminder_\(subscription.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        #if DEBUG
        print("[Notifications] Removed notification for \(subscription.accountName)")
        #endif
    }
    
    // MARK: - Dynamic Body Text
    private func notificationBody(for subscription: Subscription) -> String {
        let date = subscription.cancelReminderDate ?? Date()
        let relativeString = date.formatted(.relative(presentation: .named))
        return "You planned to cancel \(subscription.accountName) \(relativeString)."
    }
    
    // MARK: - Testing
    #if DEBUG
    func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "This is a test notification fired immediately."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(
            identifier: "testNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Notifications] Test notification failed: \(error.localizedDescription)")
            } else {
                print("[Notifications] Test notification scheduled.")
            }
        }
    }
    #endif
}
