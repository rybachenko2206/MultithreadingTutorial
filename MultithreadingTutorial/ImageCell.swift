//
//  ImageCell.swift
//  MultithreadingTutorial
//
//  Created by Roman Rybachenko on 4/13/17.
//  Copyright © 2017 Roman Rybachenko. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    
    var image: UIImage? {
        didSet {
            setImage(image: image)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    
    private func setImage(image: UIImage?) {
        imageView.image = image
        if image == nil {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
}
