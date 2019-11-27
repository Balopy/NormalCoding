//
//  BLFather+Category.m
//  AssociatedObject
//
//  Created by 王春龙 on 2019/10/31.
//  Copyright © 2019 王春龙. All rights reserved.
//

#import "BLFather+Category.h"
#import <objc/runtime.h>

@implementation BLFather (Category)

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class class = [self class];
        
        SEL originSector = @selector(description);
        SEL swizzleSector = @selector(swizzleDescrip);
        
        Method origMethod = class_getClassMethod(class, originSector);
        Method swizzleMethod = class_getClassMethod(class, swizzleSector);
        
        
        /*! 注意，交换方法分两种情况：
         1. 目标类，实现了父类方法，使用`method_exchangeImplementations()`，
         2. 目标类，没有实现父类方法。使用`class_replaceMethod()` 会把原
         
         * class_addMethod() 判断originalSEL是否在子类中实现，如果只是继承了父类的方法，没有重写，那么直接调用method_exchangeImplementations，则会交换父类中的方法和当前的实现方法。此时如果用父类调用originalSEL，因为方法已经与子类中调换，所以父类中找不到相应的实现，会抛出异常unrecognized selector.
         
         * 当class_addMethod() 返回YES时，说明子类未实现此方法(根据SEL判断)，此时class_addMethod会添加（名字为originalSEL，实现为replaceMethod）的方法。此时在将replacementSEL的实现替换为originMethod的实现即可。
         
         * 当class_addMethod() 返回NO时，说明子类中有该实现方法，此时直接调用method_exchangeImplementations交换两个方法的实现即可。
         
         * 注：如果在子类中实现此方法了，即使只是单纯的调用super，一样算重写了父类的方法，所以class_addMethod() 会返回NO。
         
         ————————————————
         
         */
        //判断
        
        /// 是否添加过 自定义方法      需要添加方法的类，  要添加方法的名称(选择器)，  新方法的实现，     描述方法的类型
        BOOL isAddMethod = class_addMethod(class, originSector, method_getImplementation(swizzleMethod), method_getTypeEncoding(swizzleMethod));// NO 表示originSector 未在子类实现，添加 swizzle 方法， true，表示实现了
        
        if (isAddMethod)
        {
            class_replaceMethod(class, swizzleSector, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        } else
        {
            method_exchangeImplementations(origMethod, swizzleMethod);
        }
    });
    
}


+ (NSString *) swizzleDescrip {
    return @"这是被我替换了";
}

-(void)setCourseName:(NSString *)courseName {
    objc_setAssociatedObject(self, @selector(courseName), courseName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)courseName {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setAuthor:(NSString *)author {
    objc_setAssociatedObject(self, @selector(author), author, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)author {
    return objc_getAssociatedObject(self, _cmd);
}


- (void)setSister:(NSString *)sister {
    objc_setAssociatedObject(self, @selector(sister), sister, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)sister {
    return objc_getAssociatedObject(self, _cmd);
}


@end
