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
        // now filter for regex match
        let filteredMatches = matches.filter { $0.title?.range(of: reg, options: .regularExpression) != nil }
        print(filteredMatches)
        return filteredMatches
    }

}
