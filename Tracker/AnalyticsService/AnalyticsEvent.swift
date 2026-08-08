//
//  AnalyticsEvent.swift
//  Tracker
//
//  Created by el on 06.08.2026.
//

import Foundation
import OSLog
import AppMetricaCore

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsScreen: String {
    case main = "Main"
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

final class AnalyticsService {

    static let shared = AnalyticsService()

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Tracker",
        category: "Analytics"
    )

    private init() {}

    func report(
        event: AnalyticsEvent,
        screen: AnalyticsScreen,
        item: AnalyticsItem? = nil
    ) {
        var parameters: [AnyHashable: Any] = [
            "event": event.rawValue,
            "screen": screen.rawValue
        ]

        if let item {
            parameters["item"] = item.rawValue
        }

        log(parameters: parameters)

        AppMetrica.reportEvent(
            name: event.rawValue,
            parameters: parameters
        ) { [weak self] error in
            self?.logger.error(
                """
                Не удалось отправить событие AppMetrica: \
                \(error.localizedDescription, privacy: .public)
                """
            )
        }
    }

    private func log(parameters: [AnyHashable: Any]) {
        let description = parameters
            .map { key, value in
                "\(key)=\(value)"
            }
            .sorted()
            .joined(separator: ", ")

        logger.info(
            "AppMetrica event: \(description, privacy: .public)"
        )
    }
}
