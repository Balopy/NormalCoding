import Foundation


/// `SessionTask` protocol represents a task for a request.
public protocol BLSessionTask: class {
    func resume()
    func cancel()
}

/// `URLSessionTask` 扩展
/// 遵循 `BLSessionTask` 协议，方便使用其他代理方法
extension URLSessionTask: BLSessionTask {
    
}

/// `BLSessionAdapter` 协议提供了连接较低层网络后端与 `BLSession` 的接口。
/// `BLURLSessionAdapter` 遵循 `BLSessionAdapter`协议，连接URLSession
public protocol BLSessionAdapter {
    
    
    /// 返回 BLSessionTask对象
    /// - Parameter URLRequest: URLRequest 对象
    /// - Parameter handler: 回调，成功或失败
    func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> BLSessionTask
    
    
    /// 收集 task 网络任务，取消时用
    /// - Parameter handler: 回调，必须在任务后执行
    func getTasks(with handler: @escaping ([BLSessionTask]) -> Void)
}


/// 添加任务缓冲属性 key
private var dataTaskResponseBufferKey = 0
/// 添加任务回调属性，
private var taskAssociatedObjectCompletionHandlerKey = 0

/// `BLURLSessionAdapter` connects `URLSession` with `Session`.
/// 如果你想添加通过实现定义在`URLSessionDelegate`及相关协议中代理方法的URLSession自定义行为，
///
/// 定义一个 `BLURLSessionAdapter` 子类并实现你想要实现的代理方法
///
/// 然而`BLURLSessionAdapter`同样可以实现一些代理方法
///
/// `URLSession(_:task: didCompleteWithError:)` and `URLSession(_:dataTask:didReceiveData:)`, you have to call
/// 如果你想实现他们，调用`super`

open class BLURLSessionAdapter: NSObject, BLSessionAdapter, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    /// 任务回调的返回值，包含三个参数的闭包
    typealias BLHandleCallBack = ((Data?, URLResponse?, Error?) -> Void)
    
    /// 声明 URLSession 类型的实例
    open var urlSession: URLSession!
    
    /// 初始化，返回 BLURLSessionAdapter 对象
    /// - Parameter configuration: 配置
    public init(configuration: URLSessionConfiguration) {
        super.init()
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    /// 创建一个实例对象
    /// 使用`dataTaskWithRequest(_:completionHandler:)`方法创建`URLSessionDataTask`对象
    open func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> BLSessionTask {
        
        /// 创建`URLSessionDataTask`
        let task = urlSession.dataTask(with: URLRequest)
        
        // 关联`task`属性
        setBuffer(NSMutableData(), forTask: task)
        
        // 关联`handler`属性
        setHandler(handler, forTask: task)
        
        return task
    }
    
    ///  在 `URLSession` 中 使用 `getTasksWithCompletionHandler(_:)`合成 URLSessionTask 实例
    open func getTasks(with handler: @escaping ([BLSessionTask]) -> Void) {
        
        urlSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            
            /// 会话数据、上传数据、下载数据
            let allTasks = dataTasks as [URLSessionTask]
                + uploadTasks as [URLSessionTask]
                + downloadTasks as [URLSessionTask]
            
            handler(allTasks.map { $0 })
        }
    }
    
    /// 关联缓冲属性
    /// - Parameter buffer: 缓冲数据
    /// - Parameter task: 任务
    private func setBuffer(_ buffer: NSMutableData, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &dataTaskResponseBufferKey, buffer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func buffer(for task: URLSessionTask) -> NSMutableData? {
        return objc_getAssociatedObject(task, &dataTaskResponseBufferKey) as? NSMutableData
    }
    
    private func setHandler(_ handler: @escaping (Data?, URLResponse?, Error?) -> Void, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey, handler as Any, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    
    /// handler get 方法
    /// - Parameter task: 会话任务
    /// 返回一个参数为元组的闭包
    private func handler(for task: URLSessionTask) -> BLHandleCallBack? {
        return objc_getAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey) as? BLHandleCallBack
    }
    
    // MARK: URLSessionTaskDelegate
    
    /// 实现 urlSession(session:, task:, didCompleteWithError 代理方法
    /// - Parameter session: 会话对象
    /// - Parameter task: 任务
    /// - Parameter error: 错误、异常
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        let bufferForTask = buffer(for: task) as Data?
        
        /// 返回值是一个有三个参数的 闭包
        if let tmpHeadler = handler(for: task) {
            
            /// 给闭包传值
            tmpHeadler(bufferForTask, task.response, error)
        }
    }
    
    // MARK: URLSessionDataDelegate
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer(for: dataTask)?.append(data)
    }
}
