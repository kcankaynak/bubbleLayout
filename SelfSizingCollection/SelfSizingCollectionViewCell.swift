//
//  SelfSizingCollectionViewCell.swift
//  SelfSizingCollection
//
//  Created by Kemal Can Kaynak on 21.12.2017.
//  Copyright © 2017 Kariyer.net. All rights reserved.
//

import UIKit

class SelfSizingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 226/255, green: 225/255, blue: 224/255, alpha: 1.0).cgColor
    }
    
    final func startJiggling() {
        
        let leftJiggle = CGAffineTransform(rotationAngle: degreesToRadians(x: 1.0))
        let rightJiggle = CGAffineTransform(rotationAngle: degreesToRadians(x: -1.0))
        
        self.transform = leftJiggle
        
        UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .repeat, .autoreverse], animations: {
            self.transform = rightJiggle
        }, completion: nil)
        
        buttonView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        buttonView.alpha = 1
        
        UIView.animate(withDuration: 0.15, animations: {
            self.buttonView.transform = .identity
        })
    }

    final func stopJiggling() {
        self.layer.removeAllAnimations()
        self.transform = .identity
        
        UIView.animate(withDuration: 0.15, animations: {
            self.buttonView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }, completion: { finished in
            if finished {
                self.buttonView.alpha = 0
            }
        })
    }
    
    private final func degreesToRadians(x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
}
