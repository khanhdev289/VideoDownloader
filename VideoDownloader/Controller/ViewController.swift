//
//  ViewController.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 27/09/2023.
//
import UIKit
import Alamofire
import SDWebImage
import AVFoundation


class ViewController: BaseViewControler {
    
    
    @IBOutlet weak var tfLink: UITextField!

    @IBOutlet weak var btnPaste: UIButton!
    
    @IBOutlet weak var btnDownload: UIButton!
    
    @IBOutlet weak var viewStep: UIView!
    

    @IBOutlet weak var imgTest: UIImageView!
    
    var arr = [Data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRadius()
        setupNavication()
        tfLink.text = "https://www.tiktok.com/@tannercolson/video/7279139547303267614?is_from_webapp=1&sender_device=pc"
//        tfLink.text = "https://www.tiktok.com/@nhh.gaming5/video/7286664679907216647"
//        tfLink.text = ""
        
    }
    func setupNavication(){
        let titleLabel = UILabel()
        titleLabel.text = "VideoDownloader"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        
        let icon = UIImage(named:"icondownload")
        
        let btnSaveLibrary = UIButton(type: .custom)
        btnSaveLibrary.setImage(icon, for: .normal)
        btnSaveLibrary.addTarget(self, action: #selector(tapOnSaveLibrary), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnSaveLibrary)
                
    }
    @objc func tapOnSaveLibrary(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "downloadLibraryVC")
        vc.modalPresentationStyle = .overFullScreen
        navigationController?.pushViewController(vc, animated: true)
//        present(vc, animated: true)
        
//        let sb = UIStoryboard(name: "Main", bundle: nil)
//        let vc = sb.instantiateViewController(identifier: "downloadOptionVC")
//        vc.modalPresentationStyle = .overFullScreen
//        present(vc, animated: true)
    }
    func postAndGetDataFromSever() {
     
        guard let link = tfLink.text, !link.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Please enter your link", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        
    }
    
    @IBAction func tapOnDownload(_ sender: Any) {
        guard let url = tfLink.text,
              !url.isEmpty else {
            self.postAndGetDataFromSever()
            return
        }

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "downloadOptionVC") as DownloadOptionVC
        vc.dataToPass = url
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    
    @IBAction func tapOnPaste(_ sender: Any) {
        let pasteboardString = UIPasteboard.general.string
        tfLink.text = pasteboardString
        
    }
    func setupRadius(){
        btnPaste.layer.cornerRadius = 5
        btnPaste.layer.borderColor = UIColor.white.cgColor
        btnPaste.layer.borderWidth = 1
        
        btnDownload.layer.cornerRadius = 5
        btnDownload.layer.masksToBounds = true
        
        viewStep.layer.cornerRadius = 10 
        viewStep.layer.masksToBounds = true
    }


}

