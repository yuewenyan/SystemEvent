//
//  SystemSettingTool.swift
//  SystemEvent
//
//  Created by yanyw on 2019/11/21.
//  Copyright © 2019 闫跃文. All rights reserved.
//

import Foundation
import UIKit

class SystemSettingTool: NSObject {
    
    /// 跳转的模版
    func jumpAppSetting() {

        UIApplication.shared.open(NSURL.init(string: UIApplication.openSettingsURLString)! as URL, options: [:], completionHandler: nil)
    }
    
}
