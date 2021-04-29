//
//  Model.swift
//  FestivalApp
//
//  Created by Patrick Wynne on 4/28/21.
//

import Foundation

struct Festival: Codable {
    let fest: Fest2
}

struct Fest2: Codable {
    let days, year: String
    let shows: [Show]
}

struct Show: Codable, Identifiable {
    let id = UUID() //added to help SwiftUI tell shows apart
    let showID: Int //renamed so as to not conflict with above
    let showName, stageName, description: String
    let times: [Double] //renamed to make better sense
    let isFavorite, oneNight: Bool
    
    //added so we can change the names in our struct
    enum CodingKeys: String, CodingKey {
        case showID = "id"
        case showName, stageName, description
        case times = "time"
        case isFavorite, oneNight
    }
    
    //make a DateFormatter as a static member of the struct type
    // so we can use it without having to recreate it every time
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        formatter.timeStyle = .short
        return formatter
    }()
    
    //this will return a String like "6:50 PM"
    static func displayTime(_ time: Double) -> String {
        let fullDate = Date(timeIntervalSince1970: time)
        return Self.formatter.string(from: fullDate)
    }
}

//created a custom init to build a Show from an existing Show
// but with a single time
//this is used when we create the showsDict dictionary
extension Show {
    init(from show: Show, at time: Double) {
        showID = show.showID
        showName = show.showName
        stageName = show.stageName
        description = show.description
        times = [time]
        isFavorite = show.isFavorite
        oneNight = show.oneNight
    }
}

struct ShowDisplay: Identifiable {
    let id = UUID()
    let showID: Int
    let showName, stageName, description: String
    let time: Double
    let isFavorite, oneNight: Bool
    let displayTime: String
    
    //make a DateFormatter as a static member of the struct type
    // so we can use it without having to recreate it every time
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        formatter.timeStyle = .short
        return formatter
    }()
    
//    var displayTime: String {
//        let fullDate = Date(timeIntervalSince1970: time)
//        return Self.formatter.string(from: fullDate)
//    }

    init(from show: Show, at time: Double) {
        showID = show.showID
        showName = show.showName
        stageName = show.stageName
        description = show.description
        self.time = time
        isFavorite = show.isFavorite
        oneNight = show.oneNight
        
        displayTime = Self.formatter.string(from: Date(timeIntervalSince1970: self.time))
    }
}

//enum to help us sort our shows into sections based
// on time offset
enum ShowOffset: Int, CaseIterable {
    case next15Mins
    case next30Mins
    case next45Mins
    case future
    
    var label: String {
        switch self {
        case .next15Mins: return "Shows starting soon"
        case .next30Mins: return "Upcoming shows"
        case .next45Mins: return "Future Shows"
        case .future: return "Far Future shows"
        }
    }
    
    static func getOffsetFromMinutes(from minutes: Int) -> ShowOffset {
        switch minutes {
        case ...15: return .next15Mins
        case ...30: return .next30Mins
        case ...45: return .next45Mins
        default: return .future
        }
    }
}

