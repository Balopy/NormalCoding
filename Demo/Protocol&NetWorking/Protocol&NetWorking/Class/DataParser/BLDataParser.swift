//
//  BLDataParser.swift
//  Protocol&NetWorking
//
//  Created by 王春龙 on 2019/11/20.
//  Copyright © 2019 王春龙. All rights reserved.
//

import Foundation


/// 请求头格式，及返回数据解析
public protocol BLDataParser {
   
    /// http 请求头格式
    var contentType: String? { get }

    /// 解析数据，把返回数据 Json或Xml化
    /// - Throws: `Error` 解析失败
    func parse(data: Data) throws -> Any
}


/// 将数据转成Json
public class BLJSONDataParser: BLDataParser {
   
    /// 读取JSON数据和创建对象的选项
    public let readingOptions: JSONSerialization.ReadingOptions
    
    
    /// 初始化，返回 BLJSONDataParser 对象
    /// - Parameter readingOptions: 读取JSON数据和创建对象的选项
    public init(readingOptions: JSONSerialization.ReadingOptions) {
        self.readingOptions = readingOptions
    }
    
    
    // MARK: - BLDataParser
    
    /// HTTP请求的“Accept” 报头字段的值。
    public var contentType: String? {
        return "application/json"
    }
    

    /// 解决 data 为 Any类型数据，如字典、数组等。
    /// -抛出:'NSError'，'JSONSerialization'失败。
    public func parse(data: Data) throws -> Any {
        guard data.count > 0 else {
            return [:]
        }
        
        return try JSONSerialization.jsonObject(with: data, options: readingOptions)
    }
}
