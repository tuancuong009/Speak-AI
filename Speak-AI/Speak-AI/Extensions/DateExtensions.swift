//
//  DateExtensions.swift
//

import Foundation

class DateConstants {
        
    static var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "UTC")!
        return calendar
    }()
}

extension Date {
    
    func addYear(_ numYears: Int) -> Date {
        var components = DateComponents()
        components.year = numYears
        return DateConstants.calendar.date(byAdding: components, to: self)!
    }
    
    func yearAgo(_ numYears: Int) -> Date {
        return addYear(-numYears)
    }
    
    func addMonth(_ numMonth: Int) -> Date {
        var components = DateComponents()
        components.month = numMonth
        
        return DateConstants.calendar.date(byAdding: components, to: self)!
    }
    
    func monthAgo(_ numMonth: Int) -> Date {
        return addMonth(-numMonth)
    }
    
    var firstDayOfWeek: Date {
        var beginningOfWeek = Date()
        var interval = TimeInterval()
        
        _ = DateConstants.calendar.dateInterval(of: .weekOfYear, start: &beginningOfWeek, interval: &interval, for: self)
        return beginningOfWeek
    }
    
    func addWeeks(_ numWeeks: Int) -> Date {
        var components = DateComponents()
        components.weekOfYear = numWeeks
        
        return DateConstants.calendar.date(byAdding: components, to: self)!
    }
    
    func weeksAgo(_ numWeeks: Int) -> Date {
        return addWeeks(-numWeeks)
    }
    
    func addDays(_ numDays: Int) -> Date {
        var components = DateComponents()
        components.day = numDays
        
        return DateConstants.calendar.date(byAdding: components, to: self)!
    }
    
    func daysAgo(_ numDays: Int) -> Date {
        return addDays(-numDays)
    }
    
    func addHours(_ numHours: Int) -> Date {
        var components = DateComponents()
        components.hour = numHours
        
        return DateConstants.calendar.date(byAdding: components, to: self)!
    }
    
    func hoursAgo(_ numHours: Int) -> Date {
        return addHours(-numHours)
    }
    
    func addMinutes(_ numMinutes: Double) -> Date {
        return self.addingTimeInterval(60 * numMinutes)
    }
    
    func minutesAgo(_ numMinutes: Double) -> Date {
        return addMinutes(-numMinutes)
    }
    
    var startOfDay: Date {
        let calendar = DateConstants.calendar
        return calendar.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        let calendar = DateConstants.calendar
        var components = DateComponents()
        components.day = 1
        return calendar.date(byAdding: components, to: self.startOfDay)!.addingTimeInterval(-1)
    }
    
    var startOfMonth: Date {
        let calendar = DateConstants.calendar
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
        let calendar = DateConstants.calendar
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return calendar.date(byAdding: components, to: startOfMonth)!
    }
    
    var zeroBasedDayOfWeek: Int? {
        let comp = DateConstants.calendar.component(.weekday, from: self)
        return comp - 1
    }
    
    func hoursFrom(_ date: Date) -> Double {
        return Double(DateConstants.calendar.dateComponents([.hour], from: date, to: self).hour!)
    }
    
    func daysBetween(_ date: Date) -> Int {
        let calendar = DateConstants.calendar
        let components = calendar.dateComponents([.day], from: self.startOfDay, to: date.startOfDay)
        
        return components.day!
    }
    
    var percentageOfDay: Double {
        let totalSeconds = self.endOfDay.timeIntervalSince(self.startOfDay) + 1
        let seconds = self.timeIntervalSince(self.startOfDay)
        let percentage = seconds / totalSeconds
        return max(min(percentage, 1.0), 0.0)
    }
    
    var numberOfWeeksInMonth: Int {
        let calendar = DateConstants.calendar
        let weekRange = (calendar as NSCalendar).range(of: NSCalendar.Unit.weekOfYear, in: NSCalendar.Unit.month, for: self)

        return weekRange.length
    }
    
    func toDateString(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = DateConstants.calendar
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        return formatter.string(from: self)
    }
    
    func convertToServerDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 10*3600)
        return formatter.string(from: self)
    }
    
    func compareWith(_ date: Date) -> ComparisonResult {
        return DateConstants.calendar.compare(self, to: date, toGranularity: .month)
    }
    
    func dateInsideMonth(_ checkDate: Date?) -> Bool {
        guard let checkDate = checkDate else { return true }
        let range = self.startOfMonth...self.endOfMonth
        return range.contains(checkDate)
    }
    
    func dateInsideDay(_ checkDate: Date?) -> Bool {
        guard let checkDate = checkDate else { return false }
        let range = self.startOfDay...self.endOfDay
        return range.contains(checkDate)
    }
    
    func isSameDay(_ checkingDate: Date?) -> Bool {
        guard let checkingDate = checkingDate else { return false }
        let sameDay = DateConstants.calendar.isDate(self, equalTo: checkingDate, toGranularity: .day)
        return sameDay
    }
    
    func elapsedTime() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        if let year = interval.year, year > 0 {
            if year == 1 {
                return "\(year) Year ago"
            }
            return "\(year) Years ago"
            
        } else if let month = interval.month, month > 0 {
            if month == 1 {
                return "\(month) Month ago"
            }
            return "\(month) Months ago"
            
        } else if let day = interval.day, day > 0 {
            if day == 1 {
                return "\(day) Day ago"
            }
            return "\(day) Days ago"
            
        } else if let hour = interval.hour, hour > 0 {
            if hour == 1 {
                return "\(hour) Hour ago"
            }
            return "\(hour) Hours ago"
        }
        
        return self.toDateString("MMM dd, yyyy")
    }
    
    func recommendationsElapsedTime() -> String {
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self, to: Date())
        if let day = interval.day, day > 0 {
            if day == 1 {
                return "Yesterday, \(self.toDateString("h:mm a"))"
            }
            return self.toDateString("MMM dd, yyyy")
        } else if let hour = interval.hour, hour > 0 {
            if hour == 1 {
                return "\(hour) hour ago"
            }
            return "\(hour) hours ago"
        } else if let minute = interval.minute, minute > 0 {
            if minute == 1 {
                return "\(minute) minute ago"
            }
            return "\(minute) minutes ago"
        }
        
        return self.toDateString("MMM dd, yyyy")
    }
}
