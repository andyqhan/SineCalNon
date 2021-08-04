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
    
    @State var yaxis = YAxis.frequency
    @State var xaxis = XAxis.boWFirst
    
    @State var data = Array<(String, Double)>()
    
    func refresh() {
        print("refresh called with yaxis \(yaxis) and xaxis \(xaxis)")
        data = calendarData.getData(for: searchOptions, xaxis: xaxis, yaxis: yaxis)
        
        print(data)
    }
    
    var body: some View {
        HStack() {
            Picker("Y-axis", selection: $yaxis) {
                Text("Frequency (count)").tag(YAxis.frequency)
                Text("Duration (in hours)").tag(YAxis.duration)
            }
            Picker("X-axis", selection: $xaxis) {
                Text("First word").tag(XAxis.boWFirst)
                Text("All words").tag(XAxis.boWAll)
                Text("Months").tag(XAxis.months)
                Text("Days of month").tag(XAxis.daysOfMonth)
                Text("Days of week").tag(XAxis.daysOfWeek)
                Text("Hours").tag(XAxis.hours)
            }
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
            .onChange(of: xaxis) { _ in
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
