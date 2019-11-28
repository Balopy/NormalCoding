//
//  BLSession.swift
//  Protocol&NetWorking
//
//  Created by 王春龙 on 2019/11/21.
//  Copyright © 2019 王春龙. All rights reserved.
//

import Foundation

private var taskRequestKey = 0

open class BLSession {
    
    /// 适配器
    public let adapter: BLSessionAdapter
    
    /// 队列
    public let callBackQueue: BLCallbackQueue
    
    
    /// 实例化 BLSession 对象
    public init(adapter: BLSessionAdapter, callBackQueue: BLCallbackQueue = .main) {
        
        self.adapter = adapter
        self.callBackQueue = callBackQueue
    }
    
    // 创建一个私有的单例
    private static let privateShare: BLSession = {
        
        let configure = URLSessionConfiguration.default
        let adapter = BLURLSessionAdapter(configuration: configure)
        
        return BLSession(adapter: adapter)
    }()
    
    
    /// 创建一个公开的 BLSession 对象，供外部调用，
    /// 好处是，不需要考虑内部实现，尽管调用即可
    open class var share: BLSession {
        return privateShare
    }
    
    //MARK: 类方法
    //    在正式编译中不会影响编译结果，忽略无返回值警告
    @discardableResult
    open class func send<TmpRequset: BLRequest>(request: TmpRequset, clallBackQueue: BLCallbackQueue? = nil, handler: @escaping (Result<TmpRequset.Response, BLSessionTaskError>) -> Void = { _ in }) -> BLSessionTask?{
        
        return share.send(request, callbackQueue: clallBackQueue, handler: handler)
    }
    
    /// Calls `cancelRequests(with:passingTest:)` of `sharedSession`.
    open class func cancelRequests<TmpRequest: BLRequest>(with requestType: TmpRequest.Type, passingTest test: @escaping (TmpRequest) -> Bool) {
        
        share.cancelRequests(with: requestType, passingTest: test)
    }
    
    
    //MARK:实例方法
    @discardableResult
    open func send<TmpRequest: BLRequest>(_ request: TmpRequest, callbackQueue: BLCallbackQueue? = nil, handler: @escaping (Result<TmpRequest.Response, BLSessionTaskError>) -> Void = { _ in }) -> BLSessionTask? {
        
        let callbackQueue = callbackQueue ?? self.callBackQueue
        
        let urlRequest: URLRequest
        do {
            urlRequest = try request.buildURLRequest()
        } catch
        {
            callbackQueue.execute {
                handler(.failure(.requestError(error)))
            }
            return nil
        }
        
        let task = adapter.createTask(with: urlRequest) { data, urlResponse, error in
            let result: Result<TmpRequest.Response, BLSessionTaskError>
            
            switch (data, urlResponse, error) {
                
            case (_, _, let error?):
                result = .failure(.connectionError(error))
                
            case (let data?, let urlResponse as HTTPURLResponse, _):
                
                do {
                    result = .success(try request.parse(data: data as Data, urlResponse: urlResponse))
                } catch
                {
                    result = .failure(.responseError(error))
                }
                
            default:
                result = .failure(.responseError(BLResponseError.nonHTTPURLResponse(urlResponse)))
            }
            
            callbackQueue.execute {
                handler(result)
            }
        }
        
        setRequest(request, forTask: task)
        task.resume()
        
        return task
    }
    
    
    
    
    /// 取消息请请求，通过测试即可取消
    /// - parameter requestType: The request type to cancel.
    /// - parameter test: The test closure that determines if a request should be cancelled or not.
    open func cancelRequests<TmpRequest: BLRequest>(with requestType: TmpRequest.Type, passingTest test: @escaping (TmpRequest) -> Bool = { _ in true }) {
        
        adapter.getTasks { [weak self] tasks in
            
            return tasks.filter { task in
                
                //如果请求存在，正常添加，如果不存在，过滤掉
                if let request = self?.requestForTask(task) as TmpRequest?
                {
                    return test(request)
                } else
                {
                    return false
                }
            }.forEach { $0.cancel() }
        }
    }
    
    //MARK: 添加属性
    private func setRequest<TmpRequest: BLRequest>(_ request: TmpRequest, forTask task: BLSessionTask) {
        objc_setAssociatedObject(task, &taskRequestKey, request, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    private func requestForTask<Request: BLRequest>(_ task: BLSessionTask) -> Request? {
        return objc_getAssociatedObject(task, &taskRequestKey) as? Request
    }
}

