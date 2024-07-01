//
//  BaseViewControler.swift
//  Lesson14FireBase
//
//  Created by Duy Khanh on 05/09/2023.
//

import UIKit
import NVActivityIndicatorView
import AVFoundation
import ObjectMapper
import Photos
import AVKit

class BaseViewControler: UIViewController {
    
    let viewIndicator = UIView()
    var loadingIndicator: NVActivityIndicatorView?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupIndicator()
    }
    func setupIndicator(){
        viewIndicator.backgroundColor = .black.withAlphaComponent(0.6)
        roundCorner(views: [viewIndicator], radius: 10)
        view.addSubview(viewIndicator)
        viewIndicator.translatesAutoresizingMaskIntoConstraints = false
        viewIndicator.widthAnchor.constraint(equalToConstant: 60).isActive = true
        viewIndicator.heightAnchor.constraint(equalToConstant: 60).isActive = true
        viewIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        viewIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        viewIndicator.isHidden = true
        
        let frame = CGRect(x: 15, y: 15, width: 30, height: 30)
        loadingIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.lineScale, color: .white, padding: 0)
        viewIndicator.addSubview(loadingIndicator!)
    }
    
    func startAnimating(){
        viewIndicator.isHidden = false
        view.isUserInteractionEnabled = false
        loadingIndicator?.startAnimating()
    }
    func stopAnimating(){
        viewIndicator.isHidden = true
        view.isUserInteractionEnabled = true
        loadingIndicator?.stopAnimating()
    }
    
    func roundCorner(views: [UIView], radius: CGFloat){
        views.forEach { v in
            v.layer.cornerRadius = radius
            v.layer.masksToBounds = true
        }
    }
    func showDownloadSuccessAlert() {
        let alert = UIAlertController(title: "Notification", message: "Download successfully !", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func getThumbnailImage(forUrl url: URL) -> UIImage? {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)

        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        } catch let error {
            print(error)
        }

        return nil
    }
    func cropImageToSquareWithRadius(_ image: UIImage, radius: CGFloat) -> UIImage? {
        let cgImage = image.cgImage
        let width = CGFloat(cgImage!.width)
        let height = CGFloat(cgImage!.height)

        let size = min(width, height)
        let x = (width - size) / 2.0
        let y = (height - size) / 2.0

        let cropRect = CGRect(x: x, y: y, width: size, height: size)
        if let croppedCGImage = cgImage?.cropping(to: cropRect) {
            let croppedImage = UIImage(cgImage: croppedCGImage)
            
            // Tạo một hình vuông với bán kính và áp dụng bán kính
            UIGraphicsBeginImageContextWithOptions(croppedImage.size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()
            let rect = CGRect(origin: .zero, size: croppedImage.size)
            
            context?.addPath(UIBezierPath(roundedRect: rect, cornerRadius: radius).cgPath)
            context?.clip()
            
            croppedImage.draw(in: rect)
            
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return roundedImage
        } else {
            return nil
        }
    }
}
