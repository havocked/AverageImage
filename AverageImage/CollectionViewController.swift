//
//  ViewController.swift
//  AverageImage
//
//  Created by Nataniel Martin on 12/05/2017.
//  Copyright © 2017 Appstud. All rights reserved.
//

import UIKit
import Photos

enum SortOption {
    case hue
    case hls
}

class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let reuseIdentifier = "Cell"
    private let itemsPerRow: CGFloat = 8
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var images = [UIImage]()
    var sortOption = SortOption.hue
    var removeOverlay: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let barButton = UIBarButtonItem(title: "Switch", style: .done, target: self, action: #selector(switchSort))
        self.navigationItem.rightBarButtonItem = barButton
        
        let leftBarButton = UIBarButtonItem(title: "Toggle", style: .done, target: self, action: #selector(toogle))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchimages(completionHandler: { [weak self] images in
           
            self?.images = images
            self?.sortImages()
            self?.collectionView?.reloadData()
        })
    }
    
    func switchSort() {
        self.sortOption = self.sortOption == .hue ? .hls : .hue
        self.sortImages()
        //self.collectionView?.performBatchUpdates({
            self.collectionView?.reloadData()
        //}, completion: nil)
    }
    
    func toogle() {
        self.removeOverlay = !self.removeOverlay
        self.collectionView?.reloadData()
    }
    
    func sortHLS(img1: UIImage, img2: UIImage) -> Bool {
        let leftColor = img1.averageColor()!
        let rightColor = img2.averageColor()!
        
        var hue1:CGFloat=0, hue2:CGFloat=0
        var sat1: CGFloat=0, sat2: CGFloat=0
        var bri1: CGFloat = 0, bri2: CGFloat = 0
        var alpha1:CGFloat=0, alpha2:CGFloat=0
        
        leftColor.getHue(&hue1, saturation: &sat1, brightness: &bri1, alpha: &alpha1)
        rightColor.getHue(&hue2, saturation: &sat2, brightness: &bri2, alpha: &alpha2)
        
        
        let hls1 = hue1 * 100 + sat1 * 50 + bri1
        let hls2 = hue2 * 100 + sat2 * 50 + bri2
        
        print("hue1: \(hue1), bri1:\(bri1), sat1: \(sat1)")
        print("hue2: \(hue2), bri2:\(bri2), sat2: \(sat2)\n")
        
        print("hls1: \(hls1), hls2: \(hls2)\n\n")
        if hls1 < hls2 {
            return true
        } else {
            return false
        }
    }
    
    func sortHUE(img1: UIImage, img2: UIImage) -> Bool {
        let leftColor = img1.averageColor()!
        let rightColor = img2.averageColor()!
        
        var hue1:CGFloat=0, hue2:CGFloat=0
        var sat1: CGFloat=0, sat2: CGFloat=0
        var bri1: CGFloat = 0, bri2: CGFloat = 0
        var alpha1:CGFloat=0, alpha2:CGFloat=0
        
        leftColor.getHue(&hue1, saturation: &sat1, brightness: &bri1, alpha: &alpha1)
        rightColor.getHue(&hue2, saturation: &sat2, brightness: &bri2, alpha: &alpha2)
        
        let hls1 = bri1 * 5 + sat1 * 2 + hue1
        let hls2 = bri2 * 5 + sat2 * 2 + hue2
        
        print("hue1: \(hue1), bri1:\(bri1), sat1: \(sat1)")
        print("hue2: \(hue2), bri2:\(bri2), sat2: \(sat2)\n")
        
        print("hls1: \(hls1), hls2: \(hls2)\n\n")
        if hue1 < hue2 {
            return true
        } else {
            return false
        }
    }
    
//    func sortRGB(img1: UIImage, img2: UIImage) -> Bool {
//        let leftColor = img1.averageColor()!
//        let rightColor = img2.averageColor()!
//        
//        var red1:CGFloat=0, red1:CGFloat=0
//        var green1: CGFloat=0, green2: CGFloat=0
//        var blue1: CGFloat = 0, blue2: CGFloat = 0
//        var alpha1:CGFloat=0, alpha2:CGFloat=0
//        
//        leftColor.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
//        rightColor.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
//        
//        if hue1 < hue2 {
//            return true
//        } else {
//            return false
//        }
//    }
    
    func sortImages() {
        
        self.images.sort(by: { left, right in
            switch self.sortOption {
            case .hls:
                return self.sortHLS(img1: left, img2: right)
            case .hue:
                return self.sortHUE(img1: left, img2: right)
            }
        })
    }
    
    func fetchimages(completionHandler: @escaping ([UIImage])->()) {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            
            let collection:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions)
            
            guard let assetCollection = collection.firstObject else {
                return
            }
            let photosAsset = PHAsset.fetchAssets(in: assetCollection, options: nil)
            var newImages = [UIImage]()
            photosAsset.enumerateObjects({ (asset, idx, stop) in
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)in
                    guard let result = result else { return }
                    newImages.append(result)
                })
            })
            
            DispatchQueue.main.async {
                completionHandler(newImages)
            }
        }
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCell
        
        //Modify the cell
        let image = self.images[indexPath.row]
        cell.imageView.image = image
        cell.colorImage.backgroundColor = image.averageColor()
        if self.removeOverlay {
            cell.colorImage.isHidden = true
        } else {
            cell.colorImage.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension UIImage {
    
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

