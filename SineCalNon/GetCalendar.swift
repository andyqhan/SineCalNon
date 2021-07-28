//
//  GetCalendar.swift
//  SineCalNon
//
//  Created by Andy Han on 5/16/21.
//

import Foundation
import EventKit

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
    
    func makeBagOfWordsEventTitles(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String) -> Dictionary<String, Int>? {
        // return dictionary of word frequencies for selected events
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = Dictionary<String, Int>()
        for event in events {
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
    func makeBagOfWordsEventTitleStart(forCalendars calendars: [EKCalendar], withStart: Date, withEnd: Date, withRegex reg: String) -> Dictionary<String, Int>? {
        guard let events = getEventsWithTitleRegex(forCalendars: calendars, withStart: withStart, withEnd: withEnd, withRegex: reg) else {
            return nil
        }
        var bagOfWords = Dictionary<String, Int>()
        for event in events {
            let firstWord = String(event.title.split(separator: " ")[0])
            bagOfWords[firstWord] = bagOfWords[firstWord] != nil ? bagOfWords[firstWord]! + 1 : 1
        }
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
    
    func sortDict(_ dict: Dictionary<String, Int>) -> Array<(String, Int)> {
        // return a tuple of the dictionary sorted by the value
        return dict.sorted { $0.1 < $1.1 }
    }
}
