//
//  BLBodyParameters.swift
//  Protocol&NetWorking
//
//  Created by 王春龙 on 2019/11/20.
//  Copyright © 2019 王春龙. All rights reserved.
//

import UIKit


/// `BLRequestBodyEntity` represents entity of HTTP body.

/// 请求体
public enum BLRequestBodyEntity {
   
    /// Expresses entity as `Data`. The associated value will be set to `URLRequest.httpBody`.
    /// body放header的方法，2M以下没问题，超过2M会导致请求延迟，超过 10M 就直接 Request timeout。而且无法解决Body 为二进制数据的问题，因为Header里都是文本数据。
    case data(Data)

    /// Expresses entity as `InputStream`. The associated value will be set to `URLRequest.httpBodyStream`.
    /// 放数据流，大数据
    case inputStream(InputStream)
}


/// 提供请求体，解析HTTP响应体，及可接收的 内容类型
public protocol BLBodyParameters {
   
    /// 发送内容类型。此属性的值将设置为“Accept”HTTP头字段。
    var contentType: String { get }

    /// 建议数据，返回序例化后的（JSON）数据
    func buildEntity() throws -> BLRequestBodyEntity
}
