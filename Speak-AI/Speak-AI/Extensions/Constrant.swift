//
//  Constrant.swift


import UIKit
let APP_DELEGATE = UIApplication.shared.delegate as! AppDelegate
struct FONT_APP{
    static let Regular = "Inter-Regular"
    static let Light = "Inter-Light"
    static let Medium = "Inter-Medium"
    static let Bold = "Inter-Bold"
    static let Semibold = "Inter-Semibold"
}

struct  KeyDefaults{
    static let Onboading = "Onboading"
    static let AllFoders = "AllFoders"
    static let newFolder = "newFolder"
    static let UnititledNote = "UnititledNote"
    static let languageSpeak = "languageSpeak"
    static let countFreeSpeak = "countFreeSpeak"
}


struct ConfigSettings{
    static let TITLE_FEEDBACK = "Feedback - \(ConfigSettings.APP_NAME)"
    static let TITLE_REPORT_BUG = "Bug Report - \(ConfigSettings.APP_NAME)"
    static let EMAIL = "forgoodapps.10@gmail.com"
    static let APP_ID = "6742455322"
    static let APP_NAME = "Speak-AI"
    static let TERMS = "https://sites.google.com/view/tu-speakai/home"
    static let PRIVACY = "https://sites.google.com/view/pp-speakai"
}


struct ConfigAssemblyAI{
    static let URL = "https://api.assemblyai.com"
    static let API = "2e76c2664d1d47d68da362cfb20bd534"
}


struct FILE_NAME{
    static let records = "records"
}


struct NotificationDefineName{
    static let NEW_RECORD = "NEW_RECORD"
    static let SEARCH_HOME = "SEARCH_HOME"
    static let EDIT_TEXT = "EDIT_TEXT"
}


struct MESSAGE_APP{
    static let NO_INTERNET = "No Internet Connection"
}


struct INAPP_PURCHASE {
    static let weekly = "com.app.speak.ai.weekly"
    static let montly = "com.app.speak.ai.monthly"
    static let yearly = "com.app.speak.ai.yearly"
}

struct MSG_ERROR{
    static let MSG_PURCHASE_CANCEL = "Purchase Canceled".localized()
    static let MSG_PURCHAE_ERROR = "Something Went Wrong".localized()
}
