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
            TextField(
                "Search for events matching regex...",
                text: $searchOptions.regex
            ) { isEditing in
                // TODO put in like a company thing? or as-you-type results?
                print("isEditing")
            } onCommit: {
                // TODO validate regex
                let forCalendars : [EKCalendar] = (0 ..< searchOptions.availableCalendars.count).compactMap({ searchOptions.selectedCalendarsMask[$0] ? searchOptions.availableCalendars[$0] : nil })
                if (!validateRegex(searchOptions.regex) || forCalendars.count == 0) {
                    return
                }
                //wordFreqCar = calendarData.makeBagOfWordsEventTitleStart(forCalendars: forCalendars, withStart: searchStartDate, withEnd: searchEndDate, withRegex: searchRegex) ?? [:]
                //print(calendarData.sortDict(wordFreqCar))
                //wordFreqTitle = calendarData.makeBagOfWordsEventTitles(forCalendars: forCalendars, withStart: searchStartDate, withEnd: searchEndDate, withRegex: searchRegex) ?? [:]
                //print(calendarData.sortDict(wordFreqTitle))
            }
            .disableAutocorrection(true)
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
            ).padding()
        }.listStyle(SidebarListStyle())
    }
}
