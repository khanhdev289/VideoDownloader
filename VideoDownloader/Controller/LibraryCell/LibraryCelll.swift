//
//  LibraryCell.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 27/09/2023.
//

import UIKit

class LibraryCell: UITableViewCell {
    
    
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var lbName: UILabel!
    
    @IBOutlet weak var lbSize: UILabel!
    
    @IBOutlet weak var lbTime: UILabel!
    
    @IBOutlet weak var viewBackground: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setupBackground(){
        viewBackground.layer.cornerRadius = 10
        viewBackground.layer.masksToBounds = true
        
        imgAvatar.layer.cornerRadius = 10
        imgAvatar.layer.masksToBounds = true
    }
    
}
