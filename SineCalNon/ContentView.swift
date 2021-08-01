//
//  ContentView.swift
//  SineCalNon
//
//  Created by Andy Han on 4/28/21.
//

import SwiftUI
import EventKit
import SwiftUICharts
//import BarChart

enum YAxis: String, CaseIterable, Identifiable {
    // What the y-axis should measure. This is distinct from what the x-axis tracks, which right now is just bags of words (either regex match on the whole title or just first word). In future, x-axis can also be time durations (like months?) or something. Maybe make it totally custom and hardcoded.
    case frequency
    case duration

    var id: String { self.rawValue }
}

struct ContentView: View {
    @ObservedObject var searchOptions: SearchOptions
    
    @State var yaxis = YAxis.frequency
    
    @State var data = Array<(String, Double)>()
    
    func refresh() {
        print("refresh called with yaxis \(yaxis)")
        switch yaxis {
        case .frequency:
            data = calendarData.sortDict(calendarData.makeBagOfWordsEventTitleStart(forCalendars: searchOptions.selectedCalendars, withStart: searchOptions.startDate, withEnd: searchOptions.endDate, withRegex: searchOptions.regex) ?? [:], dropThreshold: searchOptions.dropThreshold)
        case .duration:
            data = calendarData.sortDict(calendarData.makeBagOfWordDurationEventTitleStart(forCalendars: searchOptions.selectedCalendars, withStart: searchOptions.startDate, withEnd: searchOptions.endDate, withRegex: searchOptions.regex) ?? [:], dropThreshold: searchOptions.dropThreshold, convertToHours: true)
        }
        
        print(data)
    }
    
    var body: some View {
        Picker("Y-axis", selection: $yaxis) {
            Text("Frequency").tag(YAxis.frequency)
            Text("Duration").tag(YAxis.duration)
        }
        GeometryReader { geo in
            List() {
                BarChartView(data: ChartData(values: data), title: "Frequency of words in calendar event titles", form: CGSize(width: geo.size.width - 30, height: geo.size.height), dropShadow: false)
            }
            .onChange(of: searchOptions.key) { _ in
                print("onChange of searchOptions.key")
                refresh()
            }
            .onChange(of: yaxis) { _ in
                refresh()
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
        //ContentView(searchOptions: searchOptions)
//    }
//}
