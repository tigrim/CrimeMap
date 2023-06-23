//
//  SectionCollectionReusableView.swift
//  CrimeMap
//

import UIKit

final class SectionCollectionReusableView: UICollectionReusableView {
    @IBOutlet private weak var titleLabel: UILabel!

    func configure(title: String) {
        titleLabel.text = title
    }
}
