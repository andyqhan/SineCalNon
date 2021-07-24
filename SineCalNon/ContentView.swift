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
    @State var calendars = [EKCalendar]()  // array of calendars in ekEventStore
    
    @State var searchRegex = ""  // user input in text field
    @State var searchSelectedCalendarsMask = [Bool]()  // same indices as state var calendars. true if selected by picker
    @State var searchStartDate = Date()
    @State var searchEndDate = Date()
    
    init() {
        calendarData.requestAccessToCalendar()
    }
    
    let pubCalendarAccess = NotificationCenter.default.publisher(for: .EKEventStoreChanged, object: calendarData.eventStore)
    
    private func makeSearchCalendarBinding(_ index: Int) -> Binding<Bool> {
        // taken from https://swiftui.diegolavalle.com/posts/on-demand-bindings/
      return .init(
        get: { searchSelectedCalendarsMask[index] },
        set: { searchSelectedCalendarsMask[index] = $0 }
      )
    }
    
    private func loadData() {
        calendars = calendarData.getCalendars()
        // initialize mask as all false
        searchSelectedCalendarsMask = (0...calendars.count).compactMap({_ in false })
    }
    
    private func validateRegex(_ reg: String) -> Bool {
        // TODO flesh this out
        if (reg.count != 0) {
            return true
        } else {
            return false
        }
    }

    var body: some View {
        List() {
            HStack(content: {
                TextField(
                        "Search for events matching regex...",
                         text: $searchRegex
                    ) { isEditing in
                        // TODO put in like a company thing? or as-you-type results?
                        print("isEditing")
                    } onCommit: {
                        // TODO validate regex
                        let forCalendars : [EKCalendar] = (0 ..< calendars.count).compactMap({ searchSelectedCalendarsMask[$0] ? calendars[$0] : nil })
                        if (!validateRegex(searchRegex) || forCalendars.count == 0) {
                            return
                        }
                        calendarData.getEventsWithTitleRegex(forCalendars: forCalendars, withStart: searchStartDate, withEnd: searchEndDate, withRegex: searchRegex)
                    }
                    .disableAutocorrection(true)
                DatePicker(
                    "Start date",
                    selection: $searchStartDate)
                DatePicker(
                    "End date",
                    selection: $searchEndDate
                )
                VStack(
                    content: {
                        // need to do foreach this way cause defaultCalendarEvents can change
                        ForEach(calendars.indices, id:\.self) { index in
                            Toggle(calendars[index].title, isOn: makeSearchCalendarBinding(index))
                        }
                    }
                ).padding()
            })
            
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
