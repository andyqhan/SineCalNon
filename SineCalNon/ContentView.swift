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

struct ContentView: View {
    @ObservedObject var searchOptions: SearchOptions
    
    @State var bagOfWordsTitle = Array<(String, Int)>()
    @State var bagOfWordsTitleStart = Array<(String, Int)>()
    
    
    func refresh() {
        print("refresh called")
        bagOfWordsTitle = calendarData.sortDict(calendarData.makeBagOfWordsEventTitleStart(forCalendars: searchOptions.selectedCalendars, withStart: searchOptions.startDate, withEnd: searchOptions.endDate, withRegex: searchOptions.regex) ?? [:], dropThreshold: searchOptions.dropThreshold)
        //print(bagOfWordsTitle)
    }
    
    var body: some View {
        GeometryReader { geo in
            List() {
                BarChartView(data: ChartData(values: bagOfWordsTitle), title: "Frequency of words in calendar event titles", form: CGSize(width: geo.size.width, height: geo.size.height))
            }
            .onChange(of: searchOptions.key) { _ in
                print("onChange of searchOptions.key")
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
