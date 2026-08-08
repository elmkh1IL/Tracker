//
//  TrackerFilters.swift
//  Tracker
//
//  Created by el on 05.08.2026.
//
import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all:
            return String(localized: "filter.all")

        case .today:
            return String(localized: "filter.today")

        case .completed:
            return String(localized: "filter.completed")

        case .uncompleted:
            return String(localized: "filter.uncompleted")
        }
    }
}
