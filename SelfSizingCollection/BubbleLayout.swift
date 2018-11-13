//
//  BubbleLayout.swift
//  SelfSizingCollection
//
//  Created by Kemal Can Kaynak on 20.12.2017.
//  Copyright © 2017 Kariyer.net. All rights reserved.
//

import UIKit

open class BubbleLayout: UICollectionViewFlowLayout {
    
    private final var didLayoutSet = false
    
    final var alignment: layoutAlignment = .left {
        didSet {
            if !didLayoutSet {
                didLayoutSet.toggle()
                invalidateLayout()
            }
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?.map { $0.representedElementKind == nil ? layoutAttributesForItem(at: $0.indexPath)! : $0 }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let currentItemAttributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes, let collectionView = self.collectionView else { return nil }
        
        let sectionInset = getSectionInsetForSection(at: indexPath.section)
        
        guard indexPath.item != 0 else {
            alignment == .left ? currentItemAttributes.leftAlignFrame(sectionInset) : currentItemAttributes.rightAlignFrame(collectionView.width)
            return currentItemAttributes
        }
        
        guard let previousFrame = layoutAttributesForItem(at: IndexPath(item: indexPath.item - 1, section: indexPath.section))?.frame else { return nil }
        
        let interSectFrame = getIntersectFrame(collectionView, sectionInset, currentItemAttributes)
        guard previousFrame.intersects(interSectFrame) else {
            alignment == .left ? currentItemAttributes.leftAlignFrame(sectionInset) : currentItemAttributes.rightAlignFrame(collectionView.width)
            return currentItemAttributes
        }
        
        currentItemAttributes.frame.origin.x = startPositionForItem(previousFrame, indexPath, currentItemAttributes: currentItemAttributes)
        return currentItemAttributes
    }
    
    func getMinimumInteritemSpacingForSection(at section: NSInteger) -> CGFloat {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView!, layout: self, minimumInteritemSpacingForSectionAt: section) ?? minimumInteritemSpacing
    }
    
    func getSectionInsetForSection(at index: NSInteger) -> UIEdgeInsets {
        return (collectionView?.delegate as? UICollectionViewDelegateFlowLayout)?.collectionView?(collectionView!, layout: self, insetForSectionAt: index) ?? sectionInset
    }
}

// MARK: - Intersect Frame -

extension BubbleLayout {
    
    fileprivate final func getIntersectFrame(_ collectionView: UICollectionView, _ sectionInset: UIEdgeInsets, _ currentItemAttributes: UICollectionViewLayoutAttributes) -> CGRect {
        if alignment == .left {
            return CGRect(x: sectionInset.left, y: currentItemAttributes.frame.origin.y + 10, width: collectionView.width - sectionInset.left - sectionInset.right, height: currentItemAttributes.frame.size.height)
        }
        return CGRect(x: 0, y: currentItemAttributes.frame.origin.y, width: collectionView.width, height: currentItemAttributes.frame.size.height)
    }
    
    fileprivate final func startPositionForItem(_ previousFrame: CGRect, _ indexPath: IndexPath, currentItemAttributes: UICollectionViewLayoutAttributes) -> CGFloat {
        if alignment == .left {
            return previousFrame.origin.x + previousFrame.size.width + getMinimumInteritemSpacingForSection(at: indexPath.section)
        }
        return previousFrame.origin.x - getMinimumInteritemSpacingForSection(at: indexPath.section) - currentItemAttributes.frame.size.width
    }
}

// MARK: - Layout Attributes -

extension UICollectionViewLayoutAttributes {
    
    final func leftAlignFrame(_ sectionInset: UIEdgeInsets) {
        frame.origin.x = sectionInset.left
    }
    
    final func rightAlignFrame(_ width: CGFloat) {
        frame.origin.x = width - frame.size.width - 10
    }
}

extension BubbleLayout {
    enum layoutAlignment {
        case left
        case right
    }
}
