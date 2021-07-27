//
//  SineCalNonApp.swift
//  SineCalNon
//
//  Created by Andy Han on 4/28/21.
//

import SwiftUI
import EventKit

class SearchOptions: ObservableObject {
    @Published var regex = ""  // user input in text field
    @Published var selectedCalendarsMask = [Bool]()  // same indices as state var calendars. true if selected by picker
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var availableCalendars = [EKCalendar]()
}


@main
struct SineCalNonApp: App {
    //@State var calendars = [EKCalendar]()  // array of calendars in ekEventStore
    @StateObject var searchOptions = SearchOptions()
    
    init() {
        calendarData.requestAccessToCalendar()
    }
    
    let pubCalendarAccess = NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: calendarData.eventStore)

    private func loadData() {
        searchOptions.availableCalendars = calendarData.getCalendars()
        // initialize mask as all false
        searchOptions.selectedCalendarsMask = (0...searchOptions.availableCalendars.count).compactMap({_ in false })
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                Sidebar(searchOptions: searchOptions)
            }
            ContentView().onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: calendarData.eventStore), perform: { _ in
                loadData()
            })
        }
    }
}
