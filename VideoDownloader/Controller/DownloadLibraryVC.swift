//
//  DownloadLibraryVC.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 27/09/2023.
//

import UIKit
import AVFoundation
import ObjectMapper
import Photos
import AVKit
import AVFAudio
import SwiftAudioPlayer


class DownloadLibraryVC: BaseViewControler{
    
    var player: AVAudioPlayer?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentPlayerViewController: AVPlayerViewController?
    
    var arr = [DownloadItem]()
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavication()
        setupTableView()
        getAllItem()
    }
    func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "LibraryCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "libraryCell")
    }

    
    func getAllItem(){
        do{
           arr = try context.fetch(DownloadItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.arr.reverse()
            }
        }catch{
            //error
        }
    }
    func setupNavication(){
        let icon = UIImage(named:"iconback")
        let btnSaveLibrary = UIButton(type: .custom)
        btnSaveLibrary.setImage(icon, for: .normal)
        btnSaveLibrary.addTarget(self, action: #selector(tapOnBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnSaveLibrary)
        
        title = "Download succefully"
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        navigationItem.largeTitleDisplayMode = .never
    }
    @objc func tapOnBack(){
        navigationController?.popViewController(animated: true)
    }
    func formatFileSize(_ fileSizeString: String) -> String {
        if let fileSize = Int(fileSizeString) {
            let byteInKB: Float = 1024
            let byteInMB: Float = 1024 * byteInKB

            if fileSize > Int(byteInMB) {
                let fileSizeInMB = Float(fileSize) / byteInMB
                return String(format: "%.2f MB", fileSizeInMB)
            } else if fileSize > Int(byteInKB) {
                let fileSizeInKB = Float(fileSize) / byteInKB
                return String(format: "%.2f KB", fileSizeInKB)
            } else {
                return "\(fileSize) bytes"
            }
        } else {
            return "Invalid Size"
        }
    }
}
extension DownloadLibraryVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "libraryCell") as! LibraryCell
        let data = arr[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let formattedDate = dateFormatter.string(from: data.time!)
        cell.lbTime.text = formattedDate
        cell.lbName.text = data.name
        
        let fileSizeInKBorMB = formatFileSize(data.size ?? "0")
        cell.lbSize.text = fileSizeInKBorMB
        
        if let imageUrl = URL(string: data.img!) {
            if data.name!.lowercased().contains(".mp4") {
                cell.imgAvatar.image = UIImage(named: "videoplaceholder")
            } else {
                cell.imgAvatar.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, imageUrl) in
                    if let image = image, error == nil {
                        
                        if let squaredImage = self.cropImageToSquareWithRadius(image, radius: 20) {
                            cell.imgAvatar.image = squaredImage
                        }
                    } else {
                        cell.imgAvatar.image = UIImage(named: "mp3placeholder")
                    }
                })
            }
        }
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = arr[indexPath.row]
        
        if let name = selectedItem.img {
            if selectedItem.name?.lowercased().hasSuffix(".mp4") == true {
                let videoURL = URL(fileURLWithPath: name)
                let player = AVPlayer(url: videoURL)
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                    viewController.present(playerViewController, animated: true) {
                        player.play()
                    }
                }
                self.currentPlayerViewController = playerViewController
            }else if selectedItem.name?.lowercased().hasSuffix(".mp3") == true {
                let mp3URL = URL(fileURLWithPath: name)
                
                let playerItem = AVPlayerItem(url: mp3URL)
                let player = AVPlayer(playerItem: playerItem)
                
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                
                if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                    viewController.present(playerViewController, animated: true) {
                        player.play()
                    }
                }
                self.currentPlayerViewController = playerViewController
            }else {
                if let imageUrl = URL(string: selectedItem.img!) {
                    let imageViewController = UIViewController()
                    let imageView = UIImageView(frame: imageViewController.view.bounds)
                    imageView.contentMode = .scaleAspectFit
                    imageView.sd_setImage(with: imageUrl)
                    imageViewController.view.addSubview(imageView)
                    navigationController?.pushViewController(imageViewController, animated: true)
                }
            }
        }
    }
    func dismissPlayerViewController() {
        currentPlayerViewController?.player?.pause()
        currentPlayerViewController?.player = nil
        currentPlayerViewController?.removeFromParent()
        currentPlayerViewController?.view.removeFromSuperview()
        currentPlayerViewController?.dismiss(animated: true, completion: nil)
        currentPlayerViewController = nil
    }
    
}
