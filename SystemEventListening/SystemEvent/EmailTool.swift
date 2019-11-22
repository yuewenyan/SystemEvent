//
//  EmailTool.swift
//  SystemEvent
//
//  Created by yanyw on 2019/11/21.
//  Copyright © 2019 闫跃文. All rights reserved.
//

import Foundation
import MessageUI

class EmailTool: NSObject {
    
    func sendEmail(subject : String, recipients : [String], ccRecipients : [String], bccRecipients : [String], body : String) -> AnyObject? {
        
        // 判断能否发送邮件
        
        guard MFMailComposeViewController.canSendMail() else {
            
            print("不能发送邮件")
            return nil
        }
        
        let mailVC = MFMailComposeViewController()
        
        mailVC.mailComposeDelegate = self // 代理
        
        mailVC.setSubject(subject) // 主题
        
        mailVC.setToRecipients(recipients) // 收件人
        
        mailVC.setCcRecipients(ccRecipients) // 抄送
        
        mailVC.setBccRecipients(bccRecipients) // 密送
        
        mailVC.setMessageBody(body, isHTML: false) // 内容，允许使用html内容
        
//        // 添加文件
//        if let image = UIImage(named: "qq") {
//
//            if let data = image.pngData() {
//
//                mailVC.addAttachmentData(data, mimeType: "image/png", fileName: "qq")
//            }
//        }
        
        return mailVC
    }
}



extension EmailTool : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // 关闭 MFMailComposeViewController

        controller.dismiss(animated: true, completion: nil)
               
        guard error == nil else { // 错误拦截

            print(error as Any)
            return
        }

        switch result {

        case .cancelled:
            print("Mail Result: 删除草稿")
        case .saved:
            print("Mail Result: 存储草稿")
        case .sent:
            print("Mail Result: 发送成功")
        case .failed:
            print("Mail Result: 发送失败")
        default:
            print("Mail Result: 未知情况")
        }
    }
}
