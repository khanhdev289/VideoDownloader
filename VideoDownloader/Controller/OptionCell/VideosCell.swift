//
//  VideosCell.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 01/10/2023.
//

import UIKit

class VideosCell: UICollectionViewCell {
    

    @IBOutlet weak var imgVideo: UIImageView!
    
    @IBOutlet weak var btnSelectVideo: UIButton!
    
    @IBOutlet weak var lbVideo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupRadius()
    }
    
    func setupRadius(){
        lbVideo.layer.cornerRadius = 10
        lbVideo.layer.masksToBounds = true
        
        imgVideo.layer.cornerRadius = 20
        imgVideo.layer.masksToBounds = true
    }
}
