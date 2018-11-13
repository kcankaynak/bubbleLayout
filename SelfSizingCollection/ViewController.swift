//
//  ViewController.swift
//  SelfSizingCollection
//
//  Created by Kemal Can Kaynak on 20.12.2017.
//  Copyright © 2017 Kariyer.net. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var selfSizingCollectionView: UICollectionView!
    
    fileprivate final var labelArray = ["HTML", "CSS", "Adope Photoshop", "Product & Project Management", "Product Research & Marketing", "C#.net", "Software Engineering",
                                        "MSSQL DB", "Vue.js", "Javascript", "Core.net", "Microsoft IIS", "Android", "Java",
                                        "Kotlin", "iOS", "Swift", "Mobile Software Development", "We ♥ some kind of 😄", "Technology Nerd"]
    
    fileprivate final var isCollectionViewJiggling: Bool = false {
        didSet {
            if isCollectionViewJiggling {
                if let recognizers = selfSizingCollectionView.gestureRecognizers {
                    if !recognizers.contains(longPressGesture) {
                        selfSizingCollectionView.addGestureRecognizer(longPressGesture)
                    }
                } else {
                    selfSizingCollectionView.addGestureRecognizer(longPressGesture)
                }
            } else {
                selfSizingCollectionView.removeGestureRecognizer(longPressGesture)
            }
        }
    }
    
    final var visibleCells: [SelfSizingCollectionViewCell] {
        return selfSizingCollectionView.visibleCells as! [SelfSizingCollectionViewCell]
    }
    
    lazy var editButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction))
        return barButton
    }()
    
    lazy var doneButton: UIBarButtonItem = {
        let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        return barButton
    }()
    
    lazy var longPressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        gesture.minimumPressDuration = 0.5
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButton
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let bubbleLayout = selfSizingCollectionView.collectionViewLayout as? BubbleLayout else { return }
        bubbleLayout.alignment = .left
    }
}

// MARK: - Start Jiggling -

extension ViewController {
    
    fileprivate final func startJiggling() {
        visibleCells.forEach({ $0.startJiggling() })
        isCollectionViewJiggling = true
    }
}

// MARK: - Stop Jiggling -

extension ViewController {
    
    fileprivate final func stopJiggling() {
        visibleCells.forEach({ $0.stopJiggling() })
    }
}

// MARK: - Handle Long Press -

extension ViewController {
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            guard let selectedIndexPath = selfSizingCollectionView.indexPathForItem(at: gesture.location(in: self.selfSizingCollectionView)) else {
                break
            }
            selfSizingCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            stopJiggling()
        case .changed:
            selfSizingCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            selfSizingCollectionView.endInteractiveMovement()
            selfSizingCollectionView.performBatchUpdates({ }, completion: { finished in
                if finished {
                    self.startJiggling()
                }
            })
        default:
            selfSizingCollectionView.cancelInteractiveMovement()
        }
    }
}

// MARK: - Bar Actions -

extension ViewController {
    
    @objc func editAction() {
        startJiggling()
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = self.doneButton
        }
    }
    
    @objc func doneAction() {
        stopJiggling()
        isCollectionViewJiggling = false
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem = self.editButton
        }
    }
}

// MARK: - Label Size Calculation -

extension ViewController {
    
    fileprivate final func calculateLabelSize(index: Int) -> CGSize {
        return (labelArray[index] as NSString).size(withAttributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)])
    }
}

// MARK: - UICollectionView Data Source -

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let selfSizingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelfSizingCollectionViewCell", for: indexPath) as! SelfSizingCollectionViewCell
        selfSizingCell.testLabel.text = labelArray[indexPath.row]
        selfSizingCell.containerView.cornerRadius = (calculateLabelSize(index: indexPath.row).height + 12) / 2
        selfSizingCell.deleteButton.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
        return selfSizingCell
    }
}

// MARK: - UICollectionView Delegate -

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isCollectionViewJiggling {
            delete(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isCollectionViewJiggling {
            startJiggling()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if isCollectionViewJiggling {
            startJiggling()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return isCollectionViewJiggling
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let title = labelArray.remove(at: sourceIndexPath.item)
        labelArray.insert(title, at: destinationIndexPath.item)
    }
}

// MARK: - UICollectionView Flow Layout Delegate -

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let labelSize = calculateLabelSize(index: indexPath.row)
        return CGSize(width: labelSize.width + 30, height: labelSize.height + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -3
    }
}

// MARK: - Update Layout After Ordering -

extension BubbleLayout {

    open override func invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths indexPaths: [IndexPath], previousIndexPaths: [IndexPath], movementCancelled: Bool) -> UICollectionViewLayoutInvalidationContext {
        return super.invalidationContextForEndingInteractiveMovementOfItems(toFinalIndexPaths: indexPaths, previousIndexPaths: previousIndexPaths, movementCancelled: movementCancelled)
    }
    
    open override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attributes = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        attributes.alpha = 0.75
        return attributes
    }
}

// MARK: - Delete Action -

extension ViewController {
    
    @objc func deleteAction(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: selfSizingCollectionView)
        if let indexPath = selfSizingCollectionView.indexPathForItem(at: point) {
            delete(at: indexPath)
        }
    }
    
    fileprivate final func delete(at indexPath: IndexPath) {
        selfSizingCollectionView.performBatchUpdates({
            self.labelArray.remove(at: indexPath.item)
            self.selfSizingCollectionView.deleteItems(at: [indexPath])
        }, completion: nil)
    }
}
