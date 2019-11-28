//
//  BLError.swift
//  Protocol&NetWorking
//
//  Created by 王春龙 on 2019/11/20.
//  Copyright © 2019 王春龙. All rights reserved.
//

import Foundation


/// ' RequestError '表示从' Request '构建' URLRequest '时发生的一个常见错误。

public enum BLRequestError: Error {
    
    ///表示符合“BLRequest”的类型的“baseURL”无效。
    case invalidBaseURL(URL)
    
    ///表示“URLRequest”由“Request”构建。buildURLRequest”是未知的。
    case unexpectedURLRequest(URLRequest)
}




/// ' ResponseError '表示在获取' Request.Response '时发生的一个常见错误
/// 来自原始结果元组(Data?,URLResponse ?、Error?)”。
public enum BLResponseError: Error {
    
    /// 表示会话适配器返回的“URLResponse”未能向下转换为“HTTPURLResponse”。
    case nonHTTPURLResponse(URLResponse?)
    
    /// 显示HTTPURLResponse。状态码'是不可接受的。
    /// 在大多数情况下，“可接受的”表示值在“200..<300”中。
    case unacceptableStatusCode(Int)
    
    /// 表示未知错误。
    case unexpectedObject(Any)
}



///请求任务执行时的错误类型
public enum BLSessionTaskError: Error {
    
    /// 建立连接错误
    case connectionError(Error)
    
    /// 建立请求错误
    case requestError(Error)
    
    /// 响应错误、数据、服务器等
    case responseError(Error)
}
