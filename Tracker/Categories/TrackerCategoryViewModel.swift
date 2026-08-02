import Foundation

final class TrackerCategoryViewModel {
    
    var onCategoriesChanged: (() -> Void)?
    var onCategorySelected: ((TrackerCategory) -> Void)?
    
    private let store: TrackerCategoryStore
    private var selectedCategoryTitle: String?
    
    init(
        store: TrackerCategoryStore,
        selectedCategory: TrackerCategory? = nil
    ) {
        self.store = store
        self.selectedCategoryTitle = selectedCategory?.title
        self.store.delegate = self
    }
    
    var numberOfCategories: Int {
        store.categories.count
    }
    
    var isEmpty: Bool {
        numberOfCategories == 0
    }
    
    func category(at index: Int) -> TrackerCategory {
        store.category(at: index)
    }
    
    func selectCategory(at index: Int) {
        
        let category = store.category(at: index)
        
        selectedCategoryTitle = category.title
        onCategoriesChanged?()
        onCategorySelected?(category)
    }
    
    func addCategory(title: String) {
        store.addCategory(title: title)
    }
    
    func isCategorySelected(at index: Int) -> Bool {
        
        store.category(at: index).title == selectedCategoryTitle
    }
    
    func editCategory(
        at index: Int,
        newTitle: String
    ) {
        let oldCategory = store.category(at: index)
        
        let trimmedTitle = newTitle
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            return
        }
        
        store.updateCategory(
            oldTitle: oldCategory.title,
            newTitle: trimmedTitle
        )
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        if selectedCategoryTitle == category.title {
            selectedCategoryTitle = nil
        }
        
        store.deleteCategory(title: category.title)
    }
}

extension TrackerCategoryViewModel: TrackerCategoryStoreDelegate {

    func didUpdate() {
        onCategoriesChanged?()
    }
}
