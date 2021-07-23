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

    var body: some View {
        Button(action: {
            calendarData.requestAccessToCalendar()
        }) {
            Text("Request access to calendar")
        }.padding()
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
