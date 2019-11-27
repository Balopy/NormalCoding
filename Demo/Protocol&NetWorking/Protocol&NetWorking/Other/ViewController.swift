//
//  ViewController.swift
//  Protocol&NetWorking
//
//  Created by 王春龙 on 2019/11/19.
//  Copyright © 2019 王春龙. All rights reserved.
//

import UIKit


/// 遵循BLRequst 协议，实现相关属性、方法
struct BLTest: BLRequest {
    
    typealias Response = Dictionary
    
    
    var method: HTTPMethod {
        return .get
    }
    var parameters: Any? {
        return ["courseId在￥": 30, "userId": 0]
    }
    
    var path: String {
        return "/app/live/info"
    }
    
    var baseUrl: URL {
        
        return URL(string: "https://www.bjhdwx.cn")!
    }
    
    
    /// 请求数据，把返回到的数据通过回调，给BLSession
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response<String, Any> {
        
        guard let dictionary = object as? [String: AnyObject] else {
            throw BLResponseError.unexpectedObject(object)
        }
        
        return dictionary
    }
}

class ViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let requst = BLTest.init()
//        requst.parameters = ["courseId": 30, "userId": 0]
        
        BLSession.send(request: requst, clallBackQueue: .dispatchQueue(DispatchQueue.global())) { (respose) in
            
            print(respose)
        }
    }
    
    
}


/*
 class BLPerson: NSObject {
 var son: String?
 var father: String?
 var mother: String?
 
 func initObject(son: String, father: String ...) -> String{
 
 let abc = son + father.reduce(""){ $0 + $1 }
 print("\(abc)")
 return abc
 }
 }
 
 extension BLPerson{
 
 func printMother(name: String)  {
 self.mother = name
 }
 }
 
 
 struct House {
 var window: Int
 var room: Int
 
 
 mutating func bidMother(room: Int)  {
 self.room = room
 }
 }
 
 extension House {
 mutating func printMother(room: Int)  {
 self.room = room
 }
 }
 
 */
