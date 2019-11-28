//
//  Request.swift
//  Protocol&NetWorking
//
//  Created by 王春龙 on 2019/11/19.
//  Copyright © 2019 王春龙. All rights reserved.
//

import Foundation


/// 请求相关数据，全部放在协议里；
/// 在使用时，需要网络请求时，新建一个类，遵循协议，实现相关的属性、方法
public protocol BLRequest {
    
    associatedtype Response
    // 域名
    var baseUrl: URL { get }
    // method
    var method: HTTPMethod { get }
    
    /// 接口地址
    var path: String { get }
    
    /// 参数
    var parameters: Any? { get }
    /// 实际参数，可能为空
    var queryParameters: [String : Any]? { get }
    /// 请求体实际参数
    var bodyParameters: BLBodyParameters? { get }
    /// 请求头
    var headerFields: [String: String] { get }
    
    ///    数据解析，一般搞成JSON 数据
    var dataParser: BLDataParser { get }
    

    /// 拦截由`BLRequest.buildURLRequest()`创建的请求，如果异常，BLSession.send()抛出Error
    func interceptRequest(urlRequest: URLRequest) throws -> URLRequest
    
    
    
 
    /**
     @abstract     响应数据
     
     @param object:     要处理的数据模型，比如Model
     
     @param urlResponse:     请求响应信息，
    
     @abstract     表示对 HTTP URL加载。它是NSURLResponse的一个专门化为访问特定于HTTP的信息提供便利协议的响应。
     
      @discussion
     <NSHTTPURLResponse: 0x600000e08780> { URL: https://www.bjhdwx.cn/app/live/info?courseId=30&userId=0 } { Status Code: 200, Headers {
     Connection =     (
     "keep-alive"
     );
     "Content-Length" =     (
     3646
     );
     "Content-Type" =     (
     "application/json;charset=UTF-8"
     );
     Date =     (
     "Fri, 22 Nov 2019 07:15:18 GMT"
     );
     Server =     (
     Tengine
     );
     "Set-Cookie" =     (
     "route=15142f159f45ad56ce6afe0a001f9993;Path=/"
     );
     } }
     */
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response
    
    
    
    /**
     @abstract 拦截请求响应（HTTPURLResponse、Any），如果异常，BLSession.send()抛出Error
    
     @abstract the result of `Session.send()` turns `.failure(.responseError(error))`.
    
     @abstract The default implementation of this method is provided to throw `ResponseError.unacceptableStatusCode`
     
     @abstract if the HTTP status code is not in `200..<300`.
     */
    func interceptResponse(object: Any, urlResponse: HTTPURLResponse) throws -> Any
    
}

public extension BLRequest {
    
    var parameters: Any? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        
        /// 有值，且是 query parameters
        guard let parameters = parameters as? [String: Any], method.prefersQueryParameters else {
            return nil
        }
        return parameters
    }
    
    
    var bodyParameters: BLBodyParameters? {
        guard let parameters = parameters, !method.prefersQueryParameters else {
            return nil
        }
        
        return BLJSONBodyParameters(JSONObject: parameters)
    }
    
    var headerFields: [String: String] {
        return [:]
    }
    
    /// 创建对象
    var dataParser: BLDataParser {
        return BLJSONDataParser(readingOptions: .allowFragments)
    }
    
    func interceptRequest(urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }
    
    
    func interceptResponse(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        
        guard 200..<300 ~= urlResponse.statusCode else {
            throw BLResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
    
    
    /// 建立请求
    func buildURLRequest() throws -> URLRequest {
        
        let url = path.isEmpty ? baseUrl : baseUrl.appendingPathComponent(path)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            
            throw BLRequestError.invalidBaseURL(baseUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        
        /// 写法同  if a & b { }
        if let queryParameters = queryParameters, !queryParameters.isEmpty
        {
            components.percentEncodedQuery = BLURLEncodedSerialization.string(from: queryParameters)
        }
        
        // 判断请求体参数
        if let bodyParameters = bodyParameters {
            
            //设置可接收内容格式
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")
            
            switch try bodyParameters.buildEntity()
            {
            case .data(let data):
                urlRequest.httpBody = data
                
            case .inputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }
        
        urlRequest.url = components.url
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
        
        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        return try interceptRequest(urlRequest: urlRequest)
    }
    
    
    /// 建议响应
    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Response {
        
        let parseObject = try dataParser.parse(data: data)
        
        let passedObject = try interceptResponse(object: parseObject, urlResponse: urlResponse)
        
        return try response(from: passedObject, urlResponse: urlResponse)
    }
}
