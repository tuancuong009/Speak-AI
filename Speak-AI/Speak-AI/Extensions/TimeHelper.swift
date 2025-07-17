//
//  TimeHelper.swift
//  Speak-AI
//
//  Created by QTS Coder on 19/3/25.
//

import Foundation

class TimeHelper{
    static let shared = TimeHelper()
    
    func convertTimeToSecond(_ value: Int) -> String
    {
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: value)
        var hour = ""
        var muti = ""
        var second = ""
        if h > 0 {
            if h > 10
            {
                hour = "\(h)"
            }
            else{
                hour = "0\(h)"
            }
            
        }
        if m < 10
        {
            muti = "0\(m)"
        }
        else{
            muti = "\(m)"
        }
        if s < 10
        {
            second = "0\(s)"
        }
        else{
            second = "\(s)"
        }
        if hour.isEmpty
        {
            return muti + ":" + second
        }
        else{
            return  hour + ":" + muti + ":" + second
        }
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func formatTime(_ timestamp: Double?) -> String {
        guard let timestamp = timestamp else { return "" }
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" 
        return formatter.string(from: date)
    }
}
