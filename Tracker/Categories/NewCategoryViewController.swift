//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by el on 29.07.2026.
//

import UIKit

final class NewCategoryViewController: UIViewController {

    private enum Constants {
        static let maxCategoryTitleLength = 38
    }
    
    private let viewModel: NewCategoryViewModel
    private let initialTitle: String?

    init(
        viewModel: NewCategoryViewModel,
        initialTitle: String? = nil
    ) {
        self.viewModel = viewModel
        self.initialTitle = initialTitle
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        setupViews()
        setupConstraints()
        bind()
        
        textField.text = initialTitle
        viewModel.titleDidChange(initialTitle)
    }
    
    private func configureAppearance() {

        view.backgroundColor = .systemBackground
        title = viewModel.screenTitle
        navigationItem.hidesBackButton = true
    }
    
    private let textField: UITextField = {

        let textField = UITextField()

        textField.placeholder = String(localized: "category.name.placeholder")

        textField.backgroundColor = .trackerSecondaryBackground
        textField.layer.cornerRadius = 16

        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always

        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()
    
    private let doneButton: UIButton = {

        let button = UIButton(type: .system)

        button.setTitle(String(localized: "common.done"), for: .normal)

        button.setTitleColor(.white, for: .normal)

        button.backgroundColor = .trackerGray

        button.layer.cornerRadius = 16

        button.isEnabled = false

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private func setupViews() {

        view.addSubview(textField)
        view.addSubview(doneButton)
        textField.delegate = self

        textField.addTarget(
            self,
            action: #selector(textFieldDidChange),
            for: .editingChanged
        )

        doneButton.addTarget(
            self,
            action: #selector(doneButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func bind() {
        
        viewModel.onButtonStateChanged = { [weak self] isEnabled in
            
            guard let self else {
                return
            }
            
            self.doneButton.isEnabled = isEnabled
            
            if isEnabled {
                self.doneButton.backgroundColor = .label
                
                self.doneButton.setTitleColor(
                    .systemBackground,
                    for: .normal
                )
            } else {
                self.doneButton.backgroundColor = .trackerGray
                
                self.doneButton.setTitleColor(
                    .white,
                    for: .normal
                )
            }
        }
        
        viewModel.onCategorySaved = { [weak self] in
            
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func textFieldDidChange() {
        
        viewModel.titleDidChange(textField.text)
    }
    
    @objc
    private func doneButtonTapped() {

        guard let text = textField.text else {
            return
        }

        viewModel.saveCategory(title: text)
    }
}

extension NewCategoryViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)

        return updatedText.count <= Constants.maxCategoryTitleLength
    }
}
