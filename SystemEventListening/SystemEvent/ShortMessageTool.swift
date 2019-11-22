//
//  ShortMessageTool.swift
//  SystemEvent
//
//  Created by yanyw on 2019/11/21.
//  Copyright © 2019 闫跃文. All rights reserved.
//

import Foundation
import MessageUI

class ShortMessageTool: NSObject {
    
    
    func showShortMessageCode(textfield : UITextField) -> Bool {
        
        
        if #available(iOS 12.0, *) {  // iOS12开始有的短信验证码读取功能
            //Xcode 10 适配 OneTimeCode
            textfield.textContentType = UITextContentType.oneTimeCode;
            /*
             //非Xcode 10 适配
             textfield.textContentType = UITextContentType(rawValue: "one-time-code");
             */
            textfield.keyboardType = UIKeyboardType.numbersAndPunctuation
            
            return true
        }
        else {
            print("不支持短信验证码自动读取功能")
            return false
        }
    }
    
    /* 程序外调用系统发短信 */
    func showApplicationSendMessage(receiverPhone : String, body : String) {
        
        guard MFMessageComposeViewController.canSendText() else {
            
            print("当前设备不支持发送短信")
            return
        }

        if body.count > 0 {
            let messageUrl = NSURL.init(string: "sms://\(receiverPhone)&body=\(body)")
            UIApplication.shared.open(messageUrl! as URL, options: [:]) { (success) in    }
        }
        else {
            
            let messageUrl = NSURL.init(string: "sms://\(receiverPhone)")
            UIApplication.shared.open(messageUrl! as URL, options: [:]) { (success) in    }
        }
    }
    
    /* 程序内调用系统发短信 */
    func showMessageComposeViewController(phones : NSArray, title : String, body: String, subject: String) -> AnyObject? {
        
        // 判断当前设备是否有发短信功能
        if MFMessageComposeViewController.canSendText() {
            
            let controller = MFMessageComposeViewController()
            
            controller.recipients = phones as? [String]
            controller.navigationBar.tintColor = UIColor.red
            controller.body = body//短信内容
            controller.messageComposeDelegate = self//设置委托
            
            // 能否发送主题
            if MFMessageComposeViewController.canSendSubject() {
                
                controller.subject = subject
            }
            else {
                print("不支持 “主题” 的发送")
            }
            
            // 能否发送附件
            // messageVC.disableUserAttachments() // 禁用添加附件按钮
//            if MFMessageComposeViewController.canSendAttachments() {
//
//                // ① 路径添加
//                if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
//
//                    controller.addAttachmentURL(NSURL(fileURLWithPath: path) as URL, withAlternateFilename: "Info.plist")
//                }
//
//                // ② NSData添加
//                if MFMessageComposeViewController.isSupportedAttachmentUTI("public.png") {
//
//                    // See [Uniform Type Identifiers Reference](https://developer.apple.com/library/ios/documentation/Miscellaneous/Reference/UTIRef/Introduction/Introduction.html)
//
//                    if let image = UIImage(named: "qq") {
//
//                        let data = image.pngData()
//
//                        if data != nil {
//                            // 添加文件
//                            controller.addAttachmentData(data!, typeIdentifier: "public.png", filename: "qq.png")
//                        }
//                    }
//                }
//            }
//            else {
//                print("不支持 附件 发送")
//            }
            
            controller.viewControllers.last?.navigationItem.title = title
            
            return controller
        }
        else {
            print("该设备部支持短信功能, 并作出相应的提醒")
            return nil
        }
    }
}


extension ShortMessageTool: MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            
        print(controller.attachments as Any) // 所有附件
        
        controller.dismiss(animated: true, completion: nil)

        switch result {
            
            case .sent:
                print("短信 --- 发送成功")
            case .failed:
                print("短信 --- 发送失败")
            case .cancelled:
                print("短信 --- 发送取消")
            default:
                print("短信 --- 未知情况")
        }
    }
}

