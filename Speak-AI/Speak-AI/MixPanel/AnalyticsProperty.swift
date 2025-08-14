//
//  AnalyticsProperty.swift
//  Speak-AI
//
//  Created by QTS Coder on 13/8/25.
//


import Foundation

struct AnalyticsProperty {
    // Device & App Info
    static let appVersion = "app_version"
    static let osVersion = "os_version"
    static let deviceModel = "device_model"

    // Onboarding
    static let onboardingDuration = "onboarding_duration_seconds"

    // Common
    static let source = "source"
    static let planOptionsDisplayed = "plan_options_displayed"

    // Subscription / Plan
    static let planType = "plan_type"
    static let priceUSD = "price_usd"
    static let currency = "currency"
    static let trialUsed = "trial_used"

    // Recording
    static let recording = "recording"
    static let recordingDuration = "recording_duration_seconds"
    static let transcriptionLanguage = "transcription_language"
    static let folderSelected = "folder_selected"
    static let transcribeOption = "transcribe_option"
    static let processingTime = "processing_time_seconds"
    static let success = "success"

    // Actions
    static let actionType = "action_type"
    static let language = "language"
    static let contentType = "content_type"
    static let exportNoteAsPDF = "export_note_as_pdf"

    // Folder
    static let folderName = "folder_name"

    // Errors
    static let errorType = "error_type"
    static let errorMessage = "error_message"
    static let screen = "screen"
}


enum AnalyticsUserProperty {
    static let userId = "User ID"
    static let appVersion = "App Version"
    static let osVersion = "OS Version"
    static let deviceModel = "Device Model"
    static let subscriptionStatus = "Subscription Status"
    static let subscriptionStartDate = "Subscription Start Date"
    static let subscriptionEndDate = "Subscription End Date"
    static let totalRecordings = "Total Recordings"
    static let totalTranscriptions = "Total Transcriptions"
    static let foldersCreated = "Folders Created"
    static let lastActiveDate = "Last Active Date"
    static let firstAppOpenDate = "First App Open Date"
    static let hasCompletedOnboarding = "Has Completed Onboarding"
    static let languagePreference = "Language Preference"
}

