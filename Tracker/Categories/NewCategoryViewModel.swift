//
//  NewCategoryViewModel.swift
//  Tracker
//
//  Created by el on 29.07.2026.
//

import Foundation

final class NewCategoryViewModel {
    
    enum Mode {
        case create
        case edit(originalTitle: String)
    }

    var onButtonStateChanged: ((Bool) -> Void)?
    var onCategorySaved: (() -> Void)?
    
    private let store: TrackerCategoryStore
    private let mode: Mode

    init(
        store: TrackerCategoryStore,
        mode: Mode = .create
    ) {
        self.store = store
        self.mode = mode
    }
    
    var screenTitle: String {
            switch mode {
            case .create:
                return "Новая категория"
            case .edit:
                return "Редактирование категории"
            }
        }

    func titleDidChange(_ text: String?) {

        let title = text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        onButtonStateChanged?(!title.isEmpty)
    }
    
    func saveCategory(title: String) {
        let trimmedTitle = title
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            return
        }

        switch mode {
        case .create:
            store.addCategory(title: trimmedTitle)

        case .edit(let originalTitle):
            store.updateCategory(
                oldTitle: originalTitle,
                newTitle: trimmedTitle
            )
        }

        onCategorySaved?()
    }
}
