//
//  GetCalendar.swift
//  SineCalNon
//
//  Created by Andy Han on 5/16/21.
//

import Foundation
import EventKit

enum YAxis: String, CaseIterable, Identifiable {
    // What the y-axis can measure. This is distinct from what the x-axis tracks, which right now is just bags of words (either regex match on the whole title or just first word). In future, x-axis can also be time durations (like months?) or something. Maybe make it totally custom and hardcoded.
    case frequency
    case duration

    var id: String { self.rawValue }
}

enum XAxis: String, CaseIterable, Identifiable {
    // What the x-axis can measure
    case boWFirst  // a bag of words of the first word
    case boWAll  // bag of words of all words (space-separated)
    
    case months
    case daysOfMonth
    case daysOfWeek
    case hours
    
    var id: String { self.rawValue }
}

struct CalendarData {
    
    let eventStore = EKEventStore()
    
    var calendars: [EKCalendar]?
    
    func requestAccessToCalendar() {
        //eventStore.reset()
        switch(EKEventStore.authorizationStatus(for: EKEntityType.event)) {
        case EKAuthorizationStatus.authorized:
            print("already authorized")
        case EKAuthorizationStatus.denied:
            print("already denied")
        case EKAuthorizationStatus.notDetermined:
            print("auth status not determined")
            eventStore.requestAccess(to: EKEntityType.event) { granted, error in
                if let unwrappedError = error {
                    print("Error \(unwrappedError)")
                } else if !granted {
                    print("Not granted access")
                } else {
                    print("Granted access")
                    print("authorizationStatus: \(EKEventStore.authorizationStatus(for: EKEntityType.event))")
                }
            }
        case EKAuthorizationStatus.restricted:
            print("restricted")
        @unknown default:
            print("unknown EKAuthorizationStatus case")
        }
        
        
    }
    
    var sources: String {
        return "\(eventStore.sources)"
    }
    
    init() {
        //requestAccessToCalendar()
    }
    
    func getCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: EKEntityType.event)
    }
    
    func getDefaultCalendarEvents() -> [EKEvent]? {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            print("defaultCalendar: \(defaultCalendar)")
            let evPred = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: [defaultCalendar])
            print("evPred: \(evPred)")
            print("events: \(eventStore.events(matching: evPred))")
            return eventStore.events(matching: evPred)
        }
        print("getDefaultCalendarEvents returning nil")
        return nil
    }
    
    var defaultCalendarEvents: [EKEvent]?
    
    func getData(for searchOptions: SearchOptions, xaxis x: XAxis, yaxis y: YAxis, includeAllDayEvents: Bool = false) -> Array<(String, Double)>{
        // Main entry point function, called from ContentView, that returns whatever data we need
        let calendars = searchOptions.selectedCalendars
        let start = searchOptions.startDate
        let end = searchOptions.endDate
        let reg = searchOptions.regex
        
        guard let xEvents = makeXAxis(xaxis: x, forCalendars: calendars, withStart: start, withEnd: end, withRegex: reg, includeAllDayEvents: includeAllDayEvents) else {
            return Array<(String, Double)>()
        }
        return makeYAxis(forXEvents: xEvents, withYAxis: y, withXAxis: x, withDropThreshold: searchOptions.dropThreshold)
    }
    
    func makeXAxis(xaxis x: XAxis, forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, includeAllDayEvents: Bool = false) -> Array<(String, [EKEvent])>? {
        // Return list of list of EKEvents that fit this xaxis
        switch x {
        case .boWAll:
            return makeXAxisEventTitlesAll(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg, includeAllDayEvents: includeAllDayEvents)
        case .boWFirst:
            return makeXAxisEventTitleStart(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg, includeAllDayEvents: includeAllDayEvents)
        case .months:
            return makeXAxisDateComponents(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg, dateComponents: [.month])
        case .daysOfWeek:
            return makeXAxisDateComponents(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg, dateComponents: [.weekday])
        case .daysOfMonth:
            return makeXAxisDateComponents(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg, dateComponents: [.day])
        case .hours:
            return makeXAxisDateComponents(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg, dateComponents: [.hour])
        }
    }
    
    func makeYAxis(forXEvents x: Array<(String, [EKEvent])>, withYAxis yax: YAxis, withXAxis xax: XAxis, withDropThreshold drop: Double) -> Array<(String, Double)> {
        var output = Array<(String, Double)>()
        var shouldSortByY = false
        if xax == .boWAll || xax == .boWFirst {
            shouldSortByY = true
        }
        
        switch yax {
        case .frequency:
            for (name, events) in x {
                if Double(events.count) > drop {
                    output.append((name, Double(events.count)))
                }
            }
        case .duration:
            for (name, events) in x {
                if toHours(totalDuration(of: events)) > drop {
                    output.append((name, toHours(totalDuration(of: events))))
                }
            }
        }
        
        if shouldSortByY {
            return output.sorted { $0.1 > $1.1 }
        } else {
            return output
        }
    }
    
    func getEventsWithTitleRegex(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String) -> [EKEvent]? {
        // reg is a String and not an NSRegularExpression cause working with that is horrible. downside is that i don't get like init checking for it here — will have to do in caller
        let evPred = eventStore.predicateForEvents(withStart: withStart, end: withEnd, calendars: calendars)
        let matches = eventStore.events(matching: evPred)
        // now filter for regex match, if there is a regex
        if reg == "" {
            return matches
        } else {
            return matches.filter { $0.title?.range(of: reg, options: .regularExpression) != nil }
        }
    }
    
    func makeXAxisEventTitlesAll(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, includeAllDayEvents: Bool = false) -> Array<(String, [EKEvent])>? {
        // return dictionary of word frequencies for selected events
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = [String: [EKEvent]]()
        for event in events {
            if event.isAllDay && !includeAllDayEvents {
                // skip all-day events
                continue
            }
            let titleSplitArr = event.title.split(separator: " ")
            for word in titleSplitArr {
                let word = String(word)
                // TODO add aliases: e.g., hh == hearhere
                if bagOfWords[word] != nil {
                    bagOfWords[word]!.append(event)
                } else {
                    bagOfWords[word] = [event]
                }
            }
        }
        return bagOfWords.map { ($0.key, $0.value) }
    }
    
    func makeXAxisEventTitleStart(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, includeAllDayEvents: Bool = false) -> Array<(String, [EKEvent])>? {
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = [String: [EKEvent]]()
        for event in events {
            if event.isAllDay && !includeAllDayEvents {
                // skip all-day events
                continue
            }
            let firstWord = String(event.title.split(separator: " ")[0])
            if bagOfWords[firstWord] != nil {
                bagOfWords[firstWord]!.append(event)
            } else {
                bagOfWords[firstWord] = [event]
            }
        }
        return bagOfWords.map { ($0.key, $0.value) }
    }
    
    func makeXAxisDateComponents(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, dateComponents: Set<Calendar.Component>, includeAllDayEvents: Bool = false) -> Array<(String, [EKEvent])>? {
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var output = [String: [EKEvent]]()

        let dateFormatter = DateFormatter()
        
        var sortOrder = Array<String>()
        var canSortByNumber = false
        
        if dateComponents == [.month] {
            dateFormatter.dateFormat = "MMMM"
            // TODO this is really hacky and really bad... won't work for non-US locales
            sortOrder = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        } else if dateComponents == [.day] {
            dateFormatter.dateFormat = "dd"
            canSortByNumber = true
        } else if dateComponents == [.hour] {
            dateFormatter.dateFormat = "HH"
            canSortByNumber = true
        } else if dateComponents == [.weekday] {
            dateFormatter.dateFormat = "EEEE"
            sortOrder = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        }
        
        for event in events {
            if event.isAllDay && !includeAllDayEvents {
                continue
            }
            //let component = formatter.string(from: cal.dateComponents(dateComponents, from: event.startDate))!
            let component = dateFormatter.string(from: event.startDate)
            if output[component] != nil {
                output[component]!.append(event)
            } else {
                output[component] = [event]
            }
        }
        
        if canSortByNumber {
            return output.sorted {
                Int($0.0)! < Int($1.0)!
            }
        } else {
            return output.sorted {
                return sortOrder.firstIndex(of: $0.key)! < sortOrder.firstIndex(of: $1.key)!
            }
        }
    }
    
    
    func makeBagOfWordsEventTitles(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, includeAllDayEvents: Bool = false) -> Dictionary<String, Double>? {
        // DEPRECATED
        // return dictionary of word frequencies for selected events
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = Dictionary<String, Double>()
        for event in events {
            if event.isAllDay && !includeAllDayEvents {
                // skip all-day events
                continue
            }
            let titleSplitArr = event.title.split(separator: " ")
            for word in titleSplitArr {
                let word = String(word)
                // TODO add aliases: e.g., hh == hearhere
                bagOfWords[word] = bagOfWords[word] != nil ? bagOfWords[word]! + 1 : 1
            }
        }
        return bagOfWords
    }
    
    // func makeBagOfWordsEventTitleStart: word frequencies of the first word in the title
    func makeBagOfWordsEventTitleStart(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, includeAllDayEvents: Bool = false) -> Dictionary<String, Double>? {
        // DEPRECATED
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = Dictionary<String, Double>()
        for event in events {
            if event.isAllDay && !includeAllDayEvents {
                // skip all-day events
                continue
            }
            let firstWord = String(event.title.split(separator: " ")[0])
            bagOfWords[firstWord] = bagOfWords[firstWord] != nil ? bagOfWords[firstWord]! + 1 : 1
        }
        return bagOfWords
    }
    
    func makeBagOfWordDurationEventTitleStart(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String, includeAllDayEvents: Bool = false) -> Dictionary<String, TimeInterval>? {
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = Dictionary<String, TimeInterval>()
        for event in events {
            if event.isAllDay && !includeAllDayEvents {
                // skip all-day events
                continue
            }
            let firstWord = String(event.title.split(separator: " ")[0])
            let thisInterval = abs(event.endDate.timeIntervalSince(event.startDate))  // TimeInterval is "always in seconds", according to docs
            bagOfWords[firstWord] = bagOfWords[firstWord] != nil ? bagOfWords[firstWord]! + thisInterval : thisInterval
        }
        print("duration bag: \(bagOfWords)")
        return bagOfWords
    }
    
    // func makeBagOfWordsNGram: frequencies of user-decided ngrams
    // func hardTitleFrequency: frequencies of the exact same title
    // func softTitleFrequency: frequencies of titles where the levenshtein distance is <= 1 or 2
    
    func totalDuration(of events: [EKEvent]) -> TimeInterval {
        // return total duration of events in seconds (which is what a TimeInterval is. also TimeInterval is an alias for Double)
        var total = TimeInterval()
        for event in events {
            total += abs(event.endDate.timeIntervalSince(event.startDate))
        }
        return total
    }
    
    func toHours(_ time: TimeInterval) -> Double {
        return time / 60 / 60
    }
    
    /// Sorts a dictionary by value for pasing to a ChartView.
    /// - Parameters:
    ///   - dict: Dictionary of keys and values. Generally will be the output of a makeBagOfWords function
    ///   - dropThreshold: Double. Drop values equal to or below this number (default 0, which means no dropping).
    /// - Returns: Array of tuples (key, value), sorted by the value.
    func sortDictByValue(_ dict: Dictionary<String, Double>, dropThreshold: Double = 0, convertToHours: Bool = false) -> Array<(String, Double)> {
        // TODO make this O(nlogn) like a normal sort function
        var newDict = dict
        
        if convertToHours {
            // convert minutes to hours
            newDict = newDict.mapValues { $0 / 60 / 60 }
        }
        if dropThreshold > 0 {
            // drop values less than the dropThreshold
            newDict = newDict.filter { Double($0.1) > dropThreshold }
        }
        
        return newDict.sorted { $0.1 < $1.1 }
    }
}
