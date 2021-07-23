//
//  ContentView.swift
//  SineCalNon
//
//  Created by Andy Han on 4/28/21.
//

import SwiftUI
import EventKit

let calendarData = CalendarData()

struct ContentView: View {
    @State var defaultCalendarEvents = [EKEvent]()
    @State var calendars = [EKCalendar]()
    
    init() {
        calendarData.requestAccessToCalendar()
    }
    
    let pubCalendarAccess = NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: calendarData.eventStore)
    
    private func loadData() {
        calendars = calendarData.getCalendars()
    }

    var body: some View {
        List() {
            Button(action: {
                calendarData.requestAccessToCalendar()
            }) {
                Text("Request access to calendar")
            }.padding()
            
            Button(action: {
                calendars = calendarData.getCalendars()
            }) {
                Text("Get Calendars")
            }
            
            VStack(
                content: {
                    // need to do foreach this way cause defaultCalendarEvents can change
                    ForEach(calendars.indices, id:\.self) { index in
                        Text(calendars[index].title)
                    }
                }
            ).padding()
            
            Button(action: {
                defaultCalendarEvents = calendarData.getDefaultCalendarEvents() ?? []
            }) {
                Text("defaultCalendarEvents")
            }.padding()
            
            VStack(
                content: {
                    // need to do foreach this way cause defaultCalendarEvents can change
                    ForEach(defaultCalendarEvents.indices, id:\.self) { index in
                        Text(defaultCalendarEvents[index].title)
                    }
                }
            ).padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: calendarData.eventStore), perform: { _ in
                    loadData()
                })
        }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
