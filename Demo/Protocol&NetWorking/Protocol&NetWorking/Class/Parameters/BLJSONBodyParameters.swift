import Foundation

/// 序列化HTTP体的JSON对象，并声明其内容类型为JSON。
public struct BLJSONBodyParameters: BLBodyParameters {
   
    /// 要序列化的JSON对象。
    public let JSONObject: Any
    
    /// 序列化的写入选项。
    public let writingOptions: JSONSerialization.WritingOptions
    
    /// 用JSON对象和写入选项初始化
    /// - Parameter JSONObject: 要序列化的JSON对象
    /// - Parameter writingOptions: 写入选项
    public init(JSONObject: Any, writingOptions: JSONSerialization.WritingOptions = []) {
        self.JSONObject = JSONObject
        self.writingOptions = writingOptions
    }
    
    // MARK: - BodyParameters
    
    /// 发送数据类型，默认json。此属性的值将设置为“Accept”HTTP头字段。
    public var contentType: String {
        return "application/json"
    }
    
    
    /// 响应数据，返回序例化后的（JSON）数据，判断是否是JSON格式的数据，如果不是，抛出异常
    public func buildEntity() throws -> BLRequestBodyEntity {
      
        // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
        guard JSONSerialization.isValidJSONObject(JSONObject) else {
            throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
        }
        
        return .data(try JSONSerialization.data(withJSONObject: JSONObject, options: writingOptions))
    }
}
