//
//  ViewController.m
//  BLAssociation
//
//  Created by 王春龙 on 2019/11/5.
//  Copyright © 2019 王春龙. All rights reserved.
//

#import "ViewController.h"
#import "BLFather+Category.h"

@interface ViewController ()
    @property(nonatomic, strong) BLFather *father;
    
    @end

@implementation ViewController
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self function];
   
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"global";

    NSBlockOperation *operation = [self blockOperation];
    [queue addOperation:operation];
    
    sleep(5);
    NSLog(@"-----------主线程----------");
    
    @autoreleasepool {
        for (int i = 0; i < 100000; i ++ ) {
            BLFather *father = [BLFather new];
            NSLog(@"%@", [father description]);
        }
    }
    
    
    
    
    
    
    
}
    
- (NSBlockOperation *)blockOperation {
   

    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"Start executing block1, mainThread: %@, currentThread: %@", [NSThread mainThread], [NSThread currentThread]);
        sleep(3);
        NSLog(@"Finish executing block1");
    }];
    
    [blockOperation addExecutionBlock:^{
        NSLog(@"Start executing block2, mainThread: %@, currentThread: %@", [NSThread mainThread], [NSThread currentThread]);
        sleep(3);
        NSLog(@"Finish executing block2");
    }];
    
    [blockOperation addExecutionBlock:^{
        NSLog(@"Start executing block3, mainThread: %@, currentThread: %@", [NSThread mainThread], [NSThread currentThread]);
        sleep(3);
        NSLog(@"Finish executing block3");
    }];

    return blockOperation;
}

- (void) function {
        
        __weak NSString *courseName=  @"马列主义";
        __weak NSString *author=  @"老师";
        __weak NSString *sister=  @"小劳逸结合";
        _father = [BLFather new];
        _father.courseName = courseName;
        _father.author = author;
        _father.sister = sister;
        
        NSLog(@"%@\n%@\n%@", _father.courseName, _father.author, _father.sister);
        
        _father = nil;
}
    
@end
