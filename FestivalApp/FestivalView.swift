//
//  FestivalView.swift
//  iOS14 SwiftUI Tests
//
//  Created by Patrick Wynne on 4/26/21.
//

import SwiftUI

struct FestivalView: View {
    
    //so we don't have to keep typing [ShowOffset:[Show]]
    typealias ShowDict = [ShowOffset:[Show]]
    
    @State private var festival: Fest2? = nil
    
    //set the every parameter to however often (in seconds) you want
    // this timer to fire
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    //this is used to update the main view whenever the timer fires
    //we initialize it to the current time when the View is created
    @State private var listID = Date().timeIntervalSince1970
    
    //since it's expensive to create DateFormatters, we
    // don't want to do it every time we call getSystemTimeAsString
    // so we create it once here and store it as a property
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        formatter.timeStyle = .short
        return formatter
    }()
    
    //component Views
    func showsSections(for section: ShowOffset, showList: [Show]) -> some View {
        let shows: [Show]
        if section == .future {
            //sort by time
            shows = showList.sorted {
                //if two shows have the same time, sort them by name
                if $0.times[0] == $1.times[0] {
                    return $0.showName < $1.showName
                }
                return $0.times[0] < $1.times[0]
            }
        } else {
            //sort by showName
            shows = showList.sorted {
                //if two shows have the same name, sort them by time
                if $0.showName == $1.showName {
                    return $0.times[0] < $1.times[0]
                }
                return $0.showName < $1.showName
            }
        }
        
        return Section(header: sectionHeader(for: section.label)) {
            ForEach(shows) { show in
                showRow(from: show)
            }
            .padding()
        }
    }
    
    func sectionHeader(for section: String) -> some View {
        Text(section).bold() //.textCase(.uppercase)
    }
    
    func showRow(from show: Show) -> some View {
        VStack {
            HStack {
                Text(show.showName)
                Spacer()
                Text(getSystemTimeAsString(time: show.times[0]))
                NavigationLink(destination: Text(show.showName)) {
                    Image(systemName: "info.circle")
                }
            }
            HStack {
                Text(show.stageName)
                    .font(.caption)
                Spacer()
            }
        }
    }
    
    //main View body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Upcoming Shows")
                        .font(.largeTitle)
                        .bold()
                    Divider()
                }
                
                let showDict = generateShowsDict()
                ForEach(ShowOffset.allCases, id: \.self) { key in
                    if let showList = showDict[key] {
                        showsSections(for: key, showList: showList)
                    }
                }.id(listID)
            }
            .navigationBarHidden(true)
            .onAppear(perform: loadJSON)
            .onReceive(timer) { input in
                //update the id of the ForEach loop to force a refresh
                listID = input.timeIntervalSince1970
            }
        }
    }
    
    func loadJSON() {
        let fest = Bundle.main.decode(Festival.self, from: "FestivalJSON.txt")
        festival = fest.fest
    }
    
    func generateShowsDict() -> ShowDict {
        var displayDict: ShowDict = [:]
        
        if let festival = festival {
            let shows = festival.shows
            
            //cen be done as nested for loops...
            for show in shows {
                for time in show.times {
                    let minutes = getMinutes(date: time)
                    if minutes >= 0 {
                        displayDict[ShowOffset.getOffsetFromMinutes(from: minutes), default: []].append(Show(from: show, at: time))
                    }
                }
            }
            
            //or functionally with reduce(into:_:)
            //displayDict = shows.reduce(into: [:]) { resultDict, currentShow in
            //    currentShow.times.forEach { time in
            //        let minutes = getMinutes(date: time)
            //        if minutes >= 0 {
            //            resultDict[ShowOffset.getOffsetFromMinutes(from: minutes), default: []].append(ShowDisplay(from: currentShow, at: time))
            //        }
            //    }
            //}
            
            //AFAIK there is no real difference between the two in performance
        }
        
        return displayDict
    }
    
    func getMinutes(date: Double) -> Int {
        let now = Date()
        let showTime = Date(timeIntervalSince1970: date)
        let diffs = Calendar.current.dateComponents([.minute], from: now, to: showTime)
        return  diffs.minute ?? 0
    }
    
    //changed parameter type because Show.times is [Double]
    func getSystemTimeAsString(time: Double) -> String {
        //don't need to do this:
        //  let fullDate = Date(timeIntervalSince1970: TimeInterval(Int(time)!))
        //because TimeInterval is a typealias for Double and
        // time is already a Double
        let fullDate = Date(timeIntervalSince1970: time)
        return formatter.string(from: fullDate)
    }
}
