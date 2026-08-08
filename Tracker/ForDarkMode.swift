//
//  ForDarkMode.swift
//  Tracker
//
//  Created by el on 07.08.2026.
//

import UIKit

extension UIColor {
    
    static let trackerGray = UIColor(
            red: 174 / 255,
            green: 175 / 255,
            blue: 180 / 255,
            alpha: 1
        )

    static let trackerSecondaryBackground = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return .systemGray5
        } else {
            return .systemGray6
        }
    }

    static let trackerBottomButtonBackground = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .dark {
            return .systemGray5
        } else {
            return .black
        }
    }
    
    static let trackerEmojiSelection = UIColor { traits in
        if traits.userInterfaceStyle == .dark {
            return .white
        } else {
            return .systemGray5
        }
    }
}
