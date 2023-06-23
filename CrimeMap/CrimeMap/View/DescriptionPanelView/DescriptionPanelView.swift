//
//  DescriptionPanelView.swift
//  CrimeMap
//

import UIKit

final class DescriptionPanelView: UIView {
    typealias DataSource = UICollectionViewDiffableDataSource<AnyHashable, AnyHashable>
    typealias Snapshot = NSDiffableDataSourceSnapshot<AnyHashable, AnyHashable>

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.backgroundColor = .clear
            collectionView.register(CrimeDescriptionCell.nib,
                                    forCellWithReuseIdentifier: CrimeDescriptionCell.reuseIdentifier)
            collectionView.register(SectionCollectionReusableView.nib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionCollectionReusableView.reuseIdentifier)
            collectionView.contentInset = .init(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
    @IBOutlet private var fromTextField: UITextField!
    @IBOutlet private var tillTextField: UITextField!
    @IBOutlet private var clearButton: UIButton! {
        didSet {
            clearButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet private var resultLabel: UILabel!

    var onSearchAction: ((String, String) -> Void)? = nil
    var onClearAction: (() -> Void)? = nil
    var onCloseAction: (() -> Void)? = nil

    private let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

    private var contentSections: [[CrimeSection: [CrimeEvent]]] = []
    private var activeSections: [CrimeSection] = []

    private lazy var fromDatePicker = UIDatePicker()
    private lazy var tillDatePicker = UIDatePicker()
    private lazy var dataSource = makeDataSource()
    private lazy var descriptionDataSource = DescriptionDataSource()

    func configure(count: Int) {
        addDatePicker()
        updateResult(count: count)
    }

    func update(item: Crime, count: Int) {
        collectionView.collectionViewLayout = descriptionDataSource.collectionViewLayout()
        contentSections.removeAll()
        if let events = item.event {
            contentSections.append([CrimeSection.event: events.map { CrimeEvent(title: $0) }])
        }
        if let objectStatus = item.objectStatus {
            contentSections.append([CrimeSection.status: objectStatus.map { CrimeEvent(title: $0) }])
        }
        if let affectedType = item.affectedType {
            contentSections.append([CrimeSection.affectedType: affectedType.map { CrimeEvent(title: $0) }])

        }
        if item.affectedNumber != "0" {
            contentSections.append([CrimeSection.affectedNumber: [CrimeEvent(title: item.affectedNumber)]])
        }
        if let qualification = item.qualification {
            contentSections.append([CrimeSection.qualification: qualification.map { CrimeEvent(title: $0) }])
        }
        updateResult(count: count)
        updateSnapshot()
    }

    func updateResult(count: Int) {
        resultLabel.text = "Всього результатів: \(count)"
    }

    private func fromToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: UIScreen.main.bounds.size.width,
                                                 height: 44.0))
        let doneButton = UIBarButtonItem(title: "Готово",
                                         style: .done,
                                         target: self,
                                         action: #selector(onSelectDoneFromDatePicker))
        doneButton.tintColor = .black
        let cancelButton = UIBarButtonItem(title: "Скасувати",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelDatePicker))
        cancelButton.tintColor = .red
        toolbar.items = [doneButton, spaceButton, cancelButton]
        return toolbar
    }

    private func tillToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0,
                                                 y: 0.0,
                                                 width: UIScreen.main.bounds.size.width,
                                                 height: 44.0))
        let doneButton = UIBarButtonItem(title: "Готово",
                                         style: .done,
                                         target: self,
                                         action: #selector(onSelectDoneTillDatePicker))
        doneButton.tintColor = .black
        let cancelButton = UIBarButtonItem(title: "Скасувати",
                                           style: .plain,
                                           target: self,
                                           action: #selector(cancelDatePicker))
        cancelButton.tintColor = .red
        cancelButton.tintColor = .red
        toolbar.items = [doneButton, spaceButton, cancelButton]
        return toolbar
    }

    private func addDatePicker() {
        let locale = Locale(identifier: "uk")
        fromDatePicker.datePickerMode = .date
        fromDatePicker.date = AnnotationService.shared.getMinDate() ?? Date()
        fromDatePicker.locale = locale
        tillDatePicker.datePickerMode = .date
        tillDatePicker.date = AnnotationService.shared.getMaxDate() ?? Date()
        tillDatePicker.locale = locale

        fromTextField.inputAccessoryView = fromToolbar()
        fromTextField.inputView = fromDatePicker
        fromTextField.text = AnnotationService.shared.minDateString

        tillTextField.inputAccessoryView = tillToolbar()
        tillTextField.inputView = tillDatePicker
        tillTextField.text = AnnotationService.shared.maxDateString
    }

    private func search() {
        guard let from = fromTextField.text,
              !from.isEmpty,
              let till = tillTextField.text,
              !till.isEmpty else {
                  return
              }
        onSearchAction?(from, till)
    }

    private func updateSnapshot() {
        var snapshot = Snapshot()
        let sections = contentSections.map { Array($0.keys)[0] }
        snapshot.appendSections(sections)
        sections.forEach { section in
            let items = contentSections.compactMap { $0[section] }.first
            snapshot.appendItems(items ?? [], toSection: section)
        }
        dataSource.apply(snapshot)
    }

    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            self?.descriptionDataSource.cellProvider(for: collectionView, indexPath: indexPath, item: item)
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath -> UICollectionReusableView? in
            guard let self else {
                return nil
            }
            guard kind == UICollectionView.elementKindSectionHeader else {
                return nil
            }
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionCollectionReusableView.reuseIdentifier,
                for: indexPath
            ) as? SectionCollectionReusableView
            let sections = self.contentSections.map { Array($0.keys)[0] }
            let section = sections[indexPath.section]
            view?.configure(title: section.localizedString)
            return view
        }

        return dataSource
    }

    @objc private func onSelectDoneFromDatePicker() {
        fromTextField.text = DateFormatter.shotFormatter.string(from: fromDatePicker.date)
        endEditing(true)
        search()
    }

    @objc private func onSelectDoneTillDatePicker() {
        tillTextField.text = DateFormatter.shotFormatter.string(from: tillDatePicker.date)
        endEditing(true)
        search()
    }

    @objc private func cancelDatePicker(){
        endEditing(true)
    }

    @IBAction private func clearDateFields(_ sender: UIButton? = nil) {
        if fromTextField.text != AnnotationService.shared.minDateString
            || tillTextField.text != AnnotationService.shared.maxDateString {
            onClearAction?()
            fromTextField.text = AnnotationService.shared.minDateString
            tillTextField.text = AnnotationService.shared.maxDateString
        }
        endEditing(true)
    }

    @IBAction private func onCloseButtonTap(_ sender: UIButton? = nil) {
        onCloseAction?()
    }
}
