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
    }
    
    var sources: String {
        return "\(eventStore.sources)"
    }
    
    init() {
        //requestAccessToCalendar()
    }
    
    mutating func loadCalendars() {
        calendars = eventStore.calendars(for: EKEntityType.event)
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

}
