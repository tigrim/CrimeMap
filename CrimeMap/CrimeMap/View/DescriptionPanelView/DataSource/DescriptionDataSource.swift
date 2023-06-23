//
//  DescriptionDataSource.swift
//  CrimeMap
//

import UIKit

final class DescriptionDataSource {
    // MARK: - Cell Configuration
    func cellProvider(for collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell? {
        let reuseIdentifier: String
        reuseIdentifier = CrimeDescriptionCell.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as? CrimeDescriptionCell

        guard let item = item as? CrimeEvent else {
            return nil
        }
        cell?.configire(title: item.title)

        return cell
    }

    // MARK: - FlowLayout
    func collectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
            self?.collectionViewCompositionalLayoutHandler(sectionIndex: sectionIndex, env: env)
        }
    }

    private func collectionViewCompositionalLayoutHandler(sectionIndex: Int, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {

        let section: NSCollectionLayoutSection
        section = NSCollectionLayoutSection(group: otherGroup())
        section.interGroupSpacing = 16

        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 5,
            bottom: 16,
            trailing: 16
        )
        section.boundarySupplementaryItems = [sectionHeaderItem()]

        return section
    }

    private func otherGroup() -> NSCollectionLayoutGroup {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .estimated(50)
        )

        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: size,
            subitem: item,
            count: 1
        )

        return group
    }

    private func sectionHeaderItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerFooterSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(1)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return sectionHeader
    }
}

extension UICollectionReusableView {
    static var reuseIdentifier: String {
        String(describing: self)
    }
}

