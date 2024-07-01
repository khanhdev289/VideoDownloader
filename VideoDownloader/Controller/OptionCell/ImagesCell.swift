//
//  ImagesCell.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 01/10/2023.
//

import UIKit

class ImagesCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgAvatar: UIImageView!

    @IBOutlet weak var btnSelectImage: UIButton!
    @IBOutlet weak var lbImage: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRadius()    }
    func setupRadius(){
        lbImage.layer.cornerRadius = 10
        lbImage.layer.masksToBounds = true

    }
    
    func setCell(type: MediaType) {
        switch type {
        case .videos:
        break
        case .photos:
            break
        case .mp3:
        break
        }
    }
    
    @IBAction func btnTapOnSelect(_ sender: Any) {
    }
    
}
