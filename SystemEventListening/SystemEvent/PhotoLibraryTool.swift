//
//  PhotoImageTool.swift
//  SystemEvent
//
//  Created by yanyw on 2019/11/13.
//  Copyright © 2019 闫跃文. All rights reserved.
//  获取相册最新照片

import Foundation
import UIKit
import Photos

class PhotoLibraryTool: NSObject {

// MARK: - 单例
    // 禁止外部调用init初始化方法
    private override init() {
        super.init()
    }
    // 提供唯一单例创建
    @objc class func shareTool() -> PhotoLibraryTool {
        // 结构体创建
        struct onceSingleton {
            static var singleton = PhotoLibraryTool()
        }
        return onceSingleton.singleton
    }
    
    
// MARK: - public Method
    @objc func screenShotRecentlyAdded(resultHandler: @escaping (UIImage?) -> Swift.Void) {

        guard let screenshotCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject else {
            return
        }

        let options = PHFetchOptions()
        options.wantsIncrementalChangeDetails = true
        options.predicate = NSPredicate(format: "creationDate > %@", NSDate().addingTimeInterval(-30))
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        guard let screenshot = PHAsset.fetchAssets(in: screenshotCollection, options: options).firstObject else {
            
            return
        }
        
        PHImageManager.default().requestImage(for: screenshot, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: nil) { (image, infoDic) in
            
            resultHandler(image)
        }
    }
}
