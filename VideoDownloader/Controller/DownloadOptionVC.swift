//
//  DownloadOptionVC.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 27/09/2023.
//

import UIKit
import Alamofire
import SDWebImage
import AVFoundation
import ObjectMapper
import Photos
import AVKit


enum MediaType {
    case videos, photos, mp3
}


class DownloadOptionVC: BaseViewControler, UIDocumentPickerDelegate {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var viewBackground: UIView!
    
    @IBOutlet weak var btnDownload: UIButton!
    

    var dataToPass: String?
    
    
    var listModel: [MediaModel] = [MediaModel]()
    let playerViewController = AVPlayerViewController()
    
    @IBOutlet weak var collectView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            setupRadius()
            getDataFromApi()
            //        addBlurEffect()
            setupCollView()
            tapViewToBack()
    }
    func tapViewToBack(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }

    
    func getDataFromApi(){
//        guard let link = dataToPass else { return }
        let link = dataToPass ?? ""
//        let parameters = String(format: "link=%@&content=&type=public&web=tiktok", link)
        let parameters = "link=\(link)&content=&type=public&web=tiktok"
           let postData = parameters.data(using: .utf8)
           startAnimating()
           guard let url = URL(string: "https://getvidfb.com/downloader") else {
               print("Invalid URL")
               return
           }
           
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.httpBody = postData
           request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            print(request)
           let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
               if let error = error {
                   print("Error: \(error)")
                   self.stopAnimating()
                   return
               }
               
               guard let data = data else {
                   print("No data received")
                   self.stopAnimating()
                   return
               }
               
               do {
                   if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                       print(json)
                       
                       if let model = ApiResponse(JSON: json) {
                           self.listModel = model.media
                           DispatchQueue.main.async {
                               self.collectView.reloadData()
                               self.stopAnimating()
                           }
                       }
                   } else {
                       let responseString = String(data: data, encoding: .utf8)
                       print(responseString ?? "Empty response")
                       self.stopAnimating()
                   }
               } catch {
                   print("Error parsing JSON: \(error)")
               }
           }
           
           task.resume()
    }
    func setupCollView(){
        collectView.dataSource = self
        collectView.delegate = self

        let nib = UINib(nibName: "ImagesCell", bundle: nil)
        collectView.register(nib, forCellWithReuseIdentifier: "imagesCell")
        let nib2 = UINib(nibName: "VideosCell", bundle: nil)
        collectView.register(nib2, forCellWithReuseIdentifier: "videosCell")
        let nib3 = UINib(nibName: "Mp3sCell", bundle: nil)
        collectView.register(nib3, forCellWithReuseIdentifier: "mp3sCell")
    }
    func setupRadius(){
        btnDownload.layer.cornerRadius = 20
        btnDownload.layer.masksToBounds = true
        
        viewBackground.layer.cornerRadius = 5
        viewBackground.layer.masksToBounds = true
        
    }



    func addBlurEffect() {
          let blurEffect = UIBlurEffect(style: .dark)
          let blurView = UIVisualEffectView(effect: blurEffect)
          blurView.frame = view.bounds
          view.addSubview(blurView)
          view.sendSubviewToBack(blurView)
          view.bringSubviewToFront(viewBackground)
      }
    @IBAction func tapOnCancel(_ sender: Any) {
        dismiss(animated: true)
    }
    func createItem(img: String, name: String, size: String ){
        let newItem = DownloadItem(context: context)
        newItem.img = img
        newItem.name = name
        newItem.size = size
        newItem.time = Date()
        
        do{
            try context.save()
        }catch{
            //error
        }
    }
    func deleteItem(item: DownloadItem){
        context.delete(item)
        do{
            try context.save()
        }catch{
            //error
        }
    }
    
    @IBAction func tapOnDownload(_ sender: Any) {
        startAnimating()
        var itemsToDownload: [MediaModel] = []
        for model in listModel {
            if model.isSelectImages || model.isSelectVideos || model.isSelectMp3s {
                itemsToDownload.append(model)
            }
        }
        
        let dispatchGroup = DispatchGroup()

        for item in itemsToDownload {
            if item.isSelectImages {
                if let imageURLString = item.images?.first, let imageURL = URL(string: imageURLString) {
                    let session = URLSession.shared
                    let task = session.dataTask(with: imageURL) { (data, response, error) in
                        if error == nil, let imageData = data {
                            if let image = UIImage(data: imageData) {
                                let imageName = imageURL.lastPathComponent
                                if let jpegData = image.jpegData(compressionQuality: 0.9) {
                                    self.createItem(img: imageURLString, name: imageName, size: "\(jpegData.count)")
                                    PHPhotoLibrary.shared().performChanges({
                                        _ = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: jpegData)!)
                                    }) { (success, error) in
                                        if success {
                                            print("Hình ảnh đã được lưu thành công.")
                                            
                                        } else {
                                            print("Lỗi khi lưu hình ảnh: \(error?.localizedDescription ?? "")")
                                        }
                                        dispatchGroup.leave()
                                    }
                                }
                            }
                        } else {
                            print("Error loading image: \(error?.localizedDescription ?? "")")
                            dispatchGroup.leave()
                        }
                    }
                    task.resume()
                    dispatchGroup.enter()
                }
            }

            if item.isSelectVideos {
                guard let videoURLString = item.videos?.first, let videoURL = URL(string: videoURLString) else {
                    print("Không tìm thấy URL video hợp lệ")
                    return
                }

                DispatchQueue.global(qos: .background).async {
                    if let urlData = NSData(contentsOf: videoURL) {
                        let galleryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let uniqueName = "\(Date().timeIntervalSince1970).mp4"
                        let filePath = "\(galleryPath)/\(uniqueName)"
                        let videoName = uniqueName

                        urlData.write(toFile: filePath, atomically: true)
                        self.createItem(img: filePath, name: videoName, size: "\(urlData.count)")

                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                        }) { success, error in
                            if success {
                                print("Video đã được lưu thành công vào thư viện ảnh.")
                            } else {
                                print("Lỗi khi lưu video: \(error?.localizedDescription ?? "")")
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
                dispatchGroup.enter()
            }

            if item.isSelectMp3s, let mp3URLString = item.mp3s?.first, let mp3URL = URL(string: mp3URLString) {
                let session = URLSession.shared
                let task = session.dataTask(with: mp3URL) { (data, response, error) in
                    if let error = error {
                        print("Lỗi khi tải MP3: \(error.localizedDescription)")
                        return
                    }

                    if let data = data {
                        let timestamp = Int(Date().timeIntervalSince1970)
                        let fileName = "\(timestamp).mp3"
                        print(fileName)

                        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                            return
                        }

                        let fileURL = documentsUrl.appendingPathComponent(fileName)

                        do {
                            try data.write(to: fileURL, options: .atomic)
                            print("MP3 đã được tải và lưu tại: \(fileURL.path)")
                            
                            DispatchQueue.main.async {
                                let documentPicker = UIDocumentPickerViewController(url: fileURL, in: .exportToService)
                                documentPicker.delegate = self
                                self.present(documentPicker, animated: true, completion: nil)
                                self.createItem(img: fileURL.path, name: fileName, size: "\(data.count)")
                                dispatchGroup.leave()
                            }
                        } catch {
                            print("Lỗi khi lưu MP3: \(error.localizedDescription)")
                            dispatchGroup.leave()
                        }
                    }
                }
                task.resume()
                dispatchGroup.enter()
            }

        }
        dispatchGroup.notify(queue: .main) {
            self.stopAnimating()
            self.showDownloadSuccessAlert()
        }
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        DispatchQueue.main.async {
            self.showDownloadSuccessAlert()
        }
    }
}

extension DownloadOptionVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
       

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let indexItem = indexPath.item        
        switch indexItem {
        case 0:
            let cellImage = collectionView.dequeueReusableCell(withReuseIdentifier: "imagesCell", for: indexPath) as! ImagesCell
//            cell.setCell(type: .photos)
            if let imageURLString = listModel.first?.images?.first {
                if let imageURL = URL(string: imageURLString) {
                    let session = URLSession.shared
                    let task = session.dataTask(with: imageURL) { (data, response, error) in
                        if error == nil, let imageData = data {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData) {
                                    if let squareImage = self.cropImageToSquareWithRadius(image, radius: 20) {
                                        cellImage.imgAvatar.image = squareImage
                                        print("Hiển thị image thành công")
                                    }
                                }
                            }
                        } else {
                            print("Error loading image: \(error?.localizedDescription ?? "")")
                        }
                    }
                    task.resume()
                }
            }
                   cellImage.btnSelectImage.setImage(UIImage(named: "uncheckbox"), for: .normal)
                   cellImage.btnSelectImage.setImage(UIImage(named: "checkbox"), for: .selected)
                   cellImage.btnSelectImage.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
            cellImage.btnSelectImage.isSelected = listModel.first?.isSelectImages ?? false

                return cellImage
            
        case 1:
            if let cellVideo = collectionView.dequeueReusableCell(withReuseIdentifier: "videosCell", for: indexPath) as? VideosCell {
                
                if let videoURLString = listModel.first?.videos?.first,
                   let videoURL = URL(string: videoURLString) {
                    if let thumbnailImage = getThumbnailImage(forUrl: videoURL) {
                        if let squareImage = cropImageToSquareWithRadius(thumbnailImage, radius: 20) {
                                        cellVideo.imgVideo.image = squareImage
                                        print("Hiển thị video thành công")
                                    }
                    }
                }
                cellVideo.btnSelectVideo.setImage(UIImage(named: "uncheckbox"), for: .normal)
                cellVideo.btnSelectVideo.setImage(UIImage(named: "checkbox"), for: .selected)
                cellVideo.btnSelectVideo.addTarget(self, action: #selector(videoButtonTapped(_:)), for: .touchUpInside)
                cellVideo.btnSelectVideo.isSelected = listModel.first?.isSelectVideos ?? false
                return cellVideo
            }
            
        case 2:
            let cellMp3 = collectionView.dequeueReusableCell(withReuseIdentifier: "mp3sCell", for: indexPath) as! Mp3sCell
            if let mp3URLString = listModel.first?.mp3s?.first,
               let mp3URL = URL(string: mp3URLString) {
                if let thumbnailMp3 = getThumbnailImage(forUrl: mp3URL) {
                    if cropImageToSquareWithRadius(thumbnailMp3, radius: 20) != nil{
                        cellMp3.imgMp3.image = thumbnailMp3
                        print("Hiển thị mp3 thành công")
                    }
                }
            }
            cellMp3.btnMp3.setImage(UIImage(named: "uncheckbox"), for: .normal)
            cellMp3.btnMp3.setImage(UIImage(named: "checkbox"), for: .selected)
            cellMp3.btnMp3.addTarget(self, action: #selector(mp3ButtonTapped(_:)), for: .touchUpInside)
            cellMp3.btnMp3.isSelected = listModel.first?.isSelectMp3s ?? false
                return cellMp3


        default:
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
    }
    @objc func imageButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        listModel.first?.isSelectImages = sender.isSelected
    }
    
    @objc func videoButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        listModel.first?.isSelectVideos = sender.isSelected
        

    }
    @objc func mp3ButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        listModel.first?.isSelectMp3s = sender.isSelected
    }

        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 180)
    }

}


