
import Foundation

/// 回调在哪个队列里执行
public enum BLCallbackQueue {
    /// 主队列表
    case main

    /// 设置的会话队列
    case sessionQueue

    /// 设置的操作队列
    case operationQueue(OperationQueue)

    /// 设置的分发队列
    case dispatchQueue(DispatchQueue)

    public func execute(closure: @escaping () -> Void) {
        switch self {
        case .main:
            DispatchQueue.main.async {   closure()   }

        case .sessionQueue:
            closure()

        case .operationQueue(let operationQueue):
            operationQueue.addOperation {    closure()    }

        case .dispatchQueue(let dispatchQueue):
          
            dispatchQueue.async {   closure()    }
        }
    }
}
