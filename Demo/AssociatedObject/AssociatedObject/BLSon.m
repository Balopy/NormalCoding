//
//  BLSon.m
//  AssociatedObject
//
//  Created by 王春龙 on 2019/10/31.
//  Copyright © 2019 王春龙. All rights reserved.
//

#import "BLSon.h"
#import <objc/runtime.h>

@implementation BLSon
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray = @[@"iiii"];
    }
    return self;
}
/*
 如果当前对象调用了一个不存在的方法
 Runtime会调用resolveInstanceMethod:来进行动态方法解析
 我们需要用class_addMethod函数完成向特定类添加特定方法实现的操作
 返回NO，则进入下一步forwardingTargetForSelector:
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel {

    NSLog(@"1: 方法不存在，进入2");
    NSLog(@"2: 方法不存在，进入3:");
    
    NSString *selector = NSStringFromSelector(sel);
    
    Class class = [self class];
    if ([selector isEqualToString:@"foo"]) {
        class_addMethod(class, sel, (IMP)fooMethod, "v@:@");
        return false;
    }
    
    return true;
}

void fooMethod () {
    
    NSLog(@"这是个新方法");
}

void otherMethod () {
    
    NSLog(@"这是个other方法");
}



/*
 在消息转发机制执行前，Runtime 系统会再给我们一次重定向的机会
 通过重载forwardingTargetForSelector:方法来替换消息的接受者为其他对象
 返回nil则进步下一步forwardInvocation:
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    NSLog(@"2: 方法不存在，进入3:");
    
    NSString *selector = NSStringFromSelector(aSelector);
    
    Class class = [self class];
    if ([selector isEqualToString:@"other"]) {
        class_addMethod(class, aSelector, (IMP)otherMethod, "v@:@");
        return [BLSon new];
    }
    
    return [super forwardingTargetForSelector:aSelector];
}

/*
 获取方法签名进入下一步，进行消息转发
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
  
    NSLog(@"3: 方法不存在，进入4:");

    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
   
    if (!methodSignature) {
   
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:*"];
    }
    return methodSignature;
}


/*
 消息转发
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation {
   
    SEL sel = anInvocation.selector;
  
    BLFather *father = [BLFather new];
    
    NSLog(@"4: 方法不存在，进入5:");
    
    if ([father respondsToSelector:sel])
    {
        [anInvocation invokeWithTarget:father];
    }
    //    这里可以添加一些操作，用于定位异常，或自定义替换方法
    //    else {
    //        [anInvocation doesNotRecognizeSelector:sel];
    //    }
}

- (void)dealloc
{
    NSArray *tmp = self.dataArray;
    NSLog(@"销毁");

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [tmp class];
        NSLog(@"销毁了没有");
        
    });
}

@end
