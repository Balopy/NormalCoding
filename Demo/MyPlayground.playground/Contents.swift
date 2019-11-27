//: A MapKit based Playground

import Foundation


//let tempArr = stride(from: 20, through: 1, by: -1)
//
//
//print("start")
//
//tempArr.map {
//
//    print("1: \($0)")
//
//}
//print("end")

//let timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
//timer.schedule(deadline: .now(), repeating: 1)
//
//var tempArr: [String] = ["1212121"]
//var count = 0
//
//timer.setEventHandler {
//    DispatchQueue.main.async {
//        count += 1
//        print("\(count)")
//
//        tempArr.append("*****")
//        print("\(tempArr)")
//    }
//}
//timer.resume()

//var keyValues: Array<(String, String)> = []
//
//var signer = ""
//
//for _ in 0 ... 4 {
//
//    let temp = ("\(arc4random()%1000)", "\(arc4random()%1000)")
//    keyValues.append(temp)
//}
//
//print(keyValues)
//
//keyValues.sort {
//    $0 < $1
//}
//
//print(keyValues)
//
//keyValues.map {
//    signer += "&\($0.0)"
//    signer += $0.1
//}
//
//signer = String(signer.dropFirst())
//
//signer += "ABC"


/*

    let dict = ["dfafasf": 1, "232312": 2, "dfas": 3]

var commonParame = ["2342345": 90, "090090": 8, "90908765678765789": 30]


dict.forEach { (key, value) in
    
    commonParame[key] = value
}

print(dict)
print(commonParame)
*/


var hashText = "12345"

if hashText.count > 4 {

    let temp = hashText.dropLast(5)
    let temp1 = hashText.dropFirst(5);
    let temp2 = hashText.suffix(5)
    let temp3 = hashText.prefix(5)
    
    print(temp)
    print(temp1)
    print(temp2)
    print(temp3)

    print(hashText)
}
