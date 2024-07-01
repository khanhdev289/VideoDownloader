//
//  DownloadItem+CoreDataProperties.swift
//  
//
//  Created by Duy Khanh on 09/11/2023.
//
//

import Foundation
import CoreData
import UIKit


extension DownloadItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DownloadItem> {
        return NSFetchRequest<DownloadItem>(entityName: "DownloadItem")
    }

    @NSManaged public var img: String?
    @NSManaged public var name: String?
    @NSManaged public var size: String?
    @NSManaged public var time: Date?

}
