//
//  MixPanelHelper.swift
//  Speak-AI
//
//  Created by QTS Coder on 13/8/25.
//

import UIKit
import Mixpanel

enum EventMixpanel: String{
    case App_Launched
    case Onboarding_Completed
    case Paywall_Viewed
    case Subscription_Started
    case Recording_Started
    case Recording_Saved
    case Transcription_Completed
    case AI_Action_Used
    case Content_Shared
    case PDF_Exported
    case Note_Deleted
    case Folder_Created
    case Get_Pro_CTA_Clicked
    case Create_Note_Record_Audio
    case Create_Note_Upload_Video
    case Create_Note_Upload_Audio
    case Limit_CTA_Clicked
    case Transcription_Language_Selected
    case Save_Transcribe_Later_Clicked
    case Error_Occurred
}


final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    private var tempProperties: Properties = [:]
    private init() { }
    
    func initialize() {
        Mixpanel.initialize(token: ConfigSettings.PROJECT_MIX_PANEL, trackAutomaticEvents: true)
        Mixpanel.mainInstance().loggingEnabled = true
    }
    
    func trackEvent(_ event: EventMixpanel, properties: Properties? = nil) {
        Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
    }
    
    func trackEventTmp(event: EventMixpanel) {
        Mixpanel.mainInstance().track(event: event.rawValue, properties: tempProperties)
    }
    
    func identifyUser(id: String) {
        let key = "mixpanel_identified_user"
        if UserDefaults.standard.string(forKey: key) == id {
            return
        }
        Mixpanel.mainInstance().identify(distinctId: id)
        UserDefaults.standard.set(id, forKey: key)
    }
    
    /// Set toàn bộ user properties lên Mixpanel
    func setUserProperties(_ properties: Properties) {
        Mixpanel.mainInstance().people.set(properties: properties)
    }
    
    func setProperty(key: String, value: MixpanelType) {
        tempProperties[key] = value
    }
    
    func setProperties(_ props: Properties) {
        for (key, value) in props {
            tempProperties[key] = value
        }
    }
    
    func clearProperties() {
        tempProperties.removeAll()
    }
    
}
