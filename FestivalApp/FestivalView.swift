//
//  FestivalView.swift
//  iOS14 SwiftUI Tests
//
//  Created by Patrick Wynne on 4/26/21.
//

import SwiftUI

let festivalJSON = """
{
  "fest" : {
    "days" : "10, 11, 17, 18",
    "year" : "2021",
    "shows" : [
      {
        "id" : 1,
        "showName" : "The Duelist",
        "stageName" : "Queen",
        "description" : "Comedy Sword Play",
        "time" : [
          1619659651,
          1619660251,
          1619661031,
          1619664702
        ],
        "isFavorite" : false,
        "oneNight" : false
      },
      {
        "id" : 2,
        "showName" : "The Bilge Pumps",
        "stageName" : "Queen",
        "description" : "Pirate Comedy Band",
        "time" : [
          1619659651,
          1619660251,
          1619661031,
          1619664648
        ],
        "isFavorite" : false,
        "oneNight" : false
      },
      {
        "id" : 3,
        "showName" : "Whiskey Bay Rovers",
        "stageName" : "Compass Rose Pirate Pub",
        "description" : "Shanty Band",
        "time" : [
          1619659651,
          1619660251,
          1619661031,
          1619664637
        ],
        "isFavorite" : false,
        "oneNight" : false
      },

      {
        "id" : 16,
        "showName" : "Bayou Cirque",
        "stageName" : "Washing Well Stage",
        "description" : "Circus Acrobatics",
        "time" : [
          1619664631
        ],
        "isFavorite" : false,
        "oneNight" : false
      }
    ]
  }
}
"""

struct FestivalView: View {
    
    //so we don't have to keep typing [ShowOffset:[Show]]
    typealias ShowDict = [ShowOffset:[ShowDisplay]]
    
    @State private var festival: Fest2? = nil
    
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
    func sectionHeader(for section: String) -> some View {
        Text(section).bold() //.textCase(.uppercase)
    }
    
    func showRow(from show: ShowDisplay) -> some View {
        VStack {
            HStack {
                Text(show.showName)
                Spacer()
                Text(getSystemTimeAsString(time: show.time))
                Image(systemName: "info.circle")
            }
            HStack {
                Text(show.stageName)
                    .font(.caption)
                Spacer()
            }
        }
    }
    
    func showsSections(for section: ShowOffset, showList: [ShowDisplay]) -> some View {
        let shows: [ShowDisplay]
        if section == .future {
            //sort by time
            shows = showList.sorted {
                if $0.displayTime == $1.displayTime {
                    return $0.showName < $1.showName
                }
                return $0.displayTime < $1.displayTime
            }
        } else {
            //sort by showName
            shows = showList.sorted {
                if $0.showName == $1.showName {
                    return $0.displayTime < $1.displayTime
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
    
    //main View body
    var body: some View {
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
            }
        }
        .onAppear(perform: loadJSON)
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
                        displayDict[ShowOffset.getOffsetFromMinutes(from: minutes), default: []].append(ShowDisplay(from: show, at: time))
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
    
    //    func getShowOffset(date: Double) -> ShowOffset {
    //        let minutes = getMinutes(date: date)
    //        return ShowOffset.getOffsetFromMinutes(from: minutes)
    //    }
    
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
