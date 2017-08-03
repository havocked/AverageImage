//
//  ImageCell.swift
//  AverageImage
//
//  Created by Nataniel Martin on 12/05/2017.
//  Copyright © 2017 Appstud. All rights reserved.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.contentMode = .scaleAspectFit
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    
        self.colorImage.backgroundColor = nil
    }
}
