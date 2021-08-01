//
//  Sidebar.swift
//  SineCalNon
//
//  Created by Andy Han on 7/27/21.
//

import SwiftUI
import EventKit
let calendarData = CalendarData()

struct Sidebar: View {
    @ObservedObject var searchOptions: SearchOptions
    @State var dropThreshold: String = "0"
    
    private func validateRegex(_ reg: String) -> Bool {
        // TODO flesh this out
        return true
    }
    
    private func makeSearchCalendarBinding(_ index: Int) -> Binding<Bool> {
        // taken from https://swiftui.diegolavalle.com/posts/on-demand-bindings/
        return .init(
            get: { searchOptions.selectedCalendarsMask[index] },
            set: { searchOptions.selectedCalendarsMask[index] = $0 }
        )
    }
    
    var body: some View {
        List {
            HStack(
                content: {
                    Text("Regex")
                    TextField(
                        "Search for events matching regex...",
                        text: $searchOptions.regex
                    ) { isEditing in
                        // TODO put in like a company thing? or as-you-type results?
                        print("isEditing")
                        print(searchOptions)
                    } onCommit: {
                        // TODO validate regex
                        let forCalendars : [EKCalendar] = (0 ..< searchOptions.availableCalendars.count).compactMap({ searchOptions.selectedCalendarsMask[$0] ? searchOptions.availableCalendars[$0] : nil })
                        if (!validateRegex(searchOptions.regex) || forCalendars.count == 0) {
                            return
                        }
                    }
                    .disableAutocorrection(true)
                }
            )
            DatePicker(
                "Start date",
                selection: $searchOptions.startDate)
            DatePicker(
                "End date",
                selection: $searchOptions.endDate
            )
            VStack(
                content: {
                    // list of calendar toggles for search
                    ForEach(searchOptions.availableCalendars.indices, id:\.self) { index in
                        Toggle(searchOptions.availableCalendars[index].title, isOn: makeSearchCalendarBinding(index))
                    }
                }
            )
            HStack(
                content: {
                    Text("Threshold")
                    TextField(
                        // TODO validate input here
                        "Don't show values below...",
                        text: $dropThreshold
                    ) { isEditing in
                        
                    } onCommit: {
                        print("setting dropThreshold to \(dropThreshold)")
                        searchOptions.dropThreshold = Double(dropThreshold) ?? 0
                    }
                }
            )
            Button(action: {
                print("button pressed")
                searchOptions.key += 1  // we listen for this in ContentView. not very elegant, and not very swifty
            }) {
                Text("Refresh")
            }
            .padding()
        }
        .listStyle(SidebarListStyle())
    }
}
