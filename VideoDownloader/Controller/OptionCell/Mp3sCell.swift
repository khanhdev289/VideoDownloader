//
//  Mp3sCell.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 01/10/2023.
//

import UIKit

class Mp3sCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgMp3: UIImageView!
    
    @IBOutlet weak var btnMp3: UIButton!
    
    @IBOutlet weak var lbMp3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupRadius()
    }
    func setupRadius(){
        lbMp3.layer.cornerRadius = 10
        lbMp3.layer.masksToBounds = true
        
        imgMp3.layer.cornerRadius = 20
        imgMp3.layer.masksToBounds = true
    }

}
