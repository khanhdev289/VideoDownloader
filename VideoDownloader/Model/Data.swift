//
//  Data.swift
//  VideoDownloader
//
//  Created by Duy Khanh on 28/09/2023.
//

import Foundation
import ObjectMapper

class MediaModel: Mappable {
    var images: [String]?
    var videos: [String]?
    var mp3s: [String]?
    
    var isSelectImages: Bool = false
    var isSelectVideos: Bool = false
    var isSelectMp3s: Bool = false

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        images    <- map["images"]
        videos    <- map["videos"]
        mp3s    <- map["mp3s"]
    }
}

class ApiResponse: Mappable {
    var statusCode: Int = 0
    var media: [MediaModel] = [MediaModel]()

    required init?(map: Map) {

    }

    // Mappable
    func mapping(map: Map) {
        statusCode    <- map["statusCode"]
        media         <- map["media"]
    }
}
