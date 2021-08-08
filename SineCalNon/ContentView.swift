//
//  ContentView.swift
//  SineCalNon
//
//  Created by Andy Han on 4/28/21.
//

import SwiftUI
import EventKit
import SwiftUICharts


struct ContentView: View {
    @ObservedObject var searchOptions: SearchOptions
    @EnvironmentObject var chartData: SearchedChartData
    
    @State var yaxis = YAxis.frequency
    @State var xaxis = XAxis.boWFirst
    
    @State var data = ChartData(values: [("", 0)])
    
    func refresh() {
        print("refresh called with yaxis \(yaxis) and xaxis \(xaxis)")
        //data = ChartData(values: calendarData.getData(for: searchOptions, xaxis: xaxis, yaxis: yaxis))
        
        //print(self.data)
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
            TabView {
                BarChartView(data: ChartData(values: calendarData.getData(for: searchOptions, xaxis: .boWFirst, yaxis: yaxis)), title: "First word", form: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), dropShadow: false)
                    .tabItem {
                        Text("First word")
                    }
                BarChartView(data: ChartData(values: calendarData.getData(for: searchOptions, xaxis: .boWAll, yaxis: yaxis)), title: "All words", form: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), dropShadow: false)
                    .tabItem {
                        Text("All words")
                    }
                BarChartView(data: ChartData(values: calendarData.getData(for: searchOptions, xaxis: .months, yaxis: yaxis)), title: "Months", form: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), dropShadow: false)
                    .tabItem {
                        Text("Months")
                    }
                BarChartView(data: ChartData(values: calendarData.getData(for: searchOptions, xaxis: .daysOfMonth, yaxis: yaxis)), title: "Days of month", form: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), dropShadow: false)
                    .tabItem {
                        Text("Days of month")
                    }
                BarChartView(data: ChartData(values: calendarData.getData(for: searchOptions, xaxis: .daysOfWeek, yaxis: yaxis)), title: "Days of week", form: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), dropShadow: false)
                    .tabItem {
                        Text("Days of week")
                    }
                BarChartView(data: ChartData(values: calendarData.getData(for: searchOptions, xaxis: .hours, yaxis: yaxis)), title: "Hours", form: CGSize(width: geo.size.width - 30, height: geo.size.height - 30), dropShadow: false)
                    .tabItem {
                        Text("Hours")
                    }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
        //ContentView(searchOptions: searchOptions)
//    }
//}
