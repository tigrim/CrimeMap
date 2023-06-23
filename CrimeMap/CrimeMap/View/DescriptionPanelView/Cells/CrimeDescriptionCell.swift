//
//  CrimeDescriptionCell.swift
//  CrimeMap
//

import UIKit

final class CrimeDescriptionCell: UICollectionViewCell {
    @IBOutlet private weak var titleLabel: UILabel!

    func configire(title: String) {
        titleLabel.text = title
    }
}
