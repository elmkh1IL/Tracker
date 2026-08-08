//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by el on 05.08.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

@MainActor
final class TrackersViewControllerSnapshotTests: XCTestCase {

    func testViewController() {
        let vc = TrackersViewController()

        let navigationController = UINavigationController(
            rootViewController: vc
        )

        assertSnapshot(
            of: navigationController,
            as: .image
        )
    }
}
