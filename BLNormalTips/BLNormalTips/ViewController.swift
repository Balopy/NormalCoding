//
//  ViewController.swift
//  BLNormalTips
//
//  Created by 王春龙 on 2019/11/7.
//  Copyright © 2019 王春龙. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cyan = BLColor.init(red: 0x00, green: 0xFF, blue: 0xFF)
        let yellow = BLColor.init(red: 0xFF, green: 0x0F, blue: 0x00)
        
        let result = (cyan.hashValue == yellow.hashValue)
        print(result)
        
        
        
    }
}


extension ViewController {
    
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }
    
    var descriptiveName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }
        
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.DescriptiveName, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            }
        }
    }
}


