import Foundation

/// url 的转码、加密、拼接等



/// 把字符串中包含的特殊字符，进行 %%% 转码
private func escape(_ string: String) -> String {
    // Reserved characters defined by RFC 3986
    // Reference: https://www.ietf.org/rfc/rfc3986.txt
   
    let generalDelimiters = ":#[]@"
    let subDelimiters = "!$&'()*+,;="
    let reservedCharacters = generalDelimiters + subDelimiters

    var allowedCharacterSet = CharacterSet()
    allowedCharacterSet.formUnion(.urlQueryAllowed)
    allowedCharacterSet.remove(charactersIn: reservedCharacters)
  
    let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    return escaped ?? ""

    /**
     * 对每个字符进行转码，限定长度为 50
     let batchSize = 50
     var index = string.startIndex
     
     var escaped = ""
     
     while index != string.endIndex {
     
     let startIndex = index
     
     let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex) ?? string.endIndex
     
     let range = startIndex..<endIndex
     
     let substring = String(string[range])
     
     escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? substring
     
     index = endIndex
     }
     
     return escaped
     */
}


/// 解码
/// - Parameter string: 需要解码的字符串
private func unescape(_ string: String) -> String {
    return CFURLCreateStringByReplacingPercentEscapes(nil, string as CFString, nil) as String
}


/// 把 Data、String 数据解析为 URLEncode
/// 返回转码后的字典

public final class BLURLEncodedSerialization {
  
    public enum Error: Swift.Error {
        case cannotGetStringFromData(Data, String.Encoding)
        case cannotGetDataFromString(String, String.Encoding)
        case cannotCastObjectToDictionary(Any)
        case invalidFormatString(String)
    }

    
    /// 把 data 转换为字典
    /// - Parameter data: Data 数据
    /// - Parameter encoding: 编码类型
    /// - Throws: URLEncodedSerialization.Error

    public static func object(from data: Data, encoding: String.Encoding) throws -> [String: String] {
     
        /// data 转换为字符串
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.cannotGetStringFromData(data, encoding)
        }

        var dictionary = [String: String]()
        

        for pair in string.components(separatedBy: "&") {
          
            let contents = pair.components(separatedBy: "=")

            guard contents.count == 2 else {
                throw Error.invalidFormatString(string)
            }

            dictionary[contents[0]] = unescape(contents[1])
        }

        return dictionary
    }

    
    /// 根据对象 Object，转化为data类型
    /// - Parameter object: 对象，一般为字典
    /// - Parameter encoding: 编码类型
    /// - Throws: URLEncodedSerialization.Error
    public static func data(from object: Any, encoding: String.Encoding) throws -> Data {
       
        guard let dictionary = object as? [String: Any] else {
            throw Error.cannotCastObjectToDictionary(object)
        }

        let string = self.string(from: dictionary)
       
        guard let data = string.data(using: encoding, allowLossyConversion: false) else {
            throw Error.cannotGetDataFromString(string, encoding)
        }

        return data
    }

    
    /// 根据字典返回拼接后的字典
    /// - Parameter dictionary: 参数字典
    /// - 格式 id=0&name=a&age=18
    public static func string(from dictionary: [String: Any]) -> String {
       
        let pairs = dictionary.map { key, value -> String in
           
            if value is NSNull {
                return "\(escape(key))"
            }

            let valueAsString = (value as? String) ?? "\(value)"
            return "\(escape(key))=\(escape(valueAsString))"
        }

        return pairs.joined(separator: "&")
    }
}
