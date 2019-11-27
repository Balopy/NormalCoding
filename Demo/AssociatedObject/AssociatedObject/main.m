

#import <Foundation/Foundation.h>
#import "BLFather.h"
#import "BLFather+Category.h"
#import "BLSon.h"


#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Weverything"
static BOOL different (int a, int b) {
    return a - b;
}
#pragma clang diagnostic pop



static size_t const count = 1000;
static size_t const iterations = 10000;

extern uint64_t dispatch_benchmark(size_t count, void (^block)(void));

void swizzleMethod(void);
void benchMarkMethod(void);
void checkEqualMethod (void);
void encode_Method (void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        swizzleMethod();
//        benchMarkMethod();
//        checkEqualMethod();
        encode_Method();
    }
    return 0;
}


/**
 方法替换
 */
void swizzleMethod (void) {
    
    id son = [BLSon new];
    [son performSelector:@selector(foo)];
    [son performSelector:@selector(other)];
    [son performSelector:@selector(abc)];
    __weak NSString *courseName=  @"马列主义";
    __weak NSString *author=  @"老师";
    __weak NSString *sister=  @"小劳逸结合";
    BLFather *father = [BLFather new];
    father.courseName = courseName;
    father.author = author;
    father.sister = sister;
    
    NSLog(@"%@\n%@\n%@", father.courseName, father.author, father.sister);
    
    father = nil;
    
}

/**
 用于检测，代码的执行效率，纳秒级
 */
void benchMarkMethod (void) {
    
    CFTimeInterval startTime = CFAbsoluteTimeGetCurrent();
    {
        for (size_t i = 0; i < iterations; i++) {
            @autoreleasepool {
                NSMutableArray *mutableArray = [NSMutableArray array];
                for (size_t j = 0; j < count; j++) {
                    id object = @"🐷";
                    
                    [mutableArray addObject:object];
                }
            }
        }
    }
    CFTimeInterval endTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"Total Runtime: %g s", endTime - startTime);
    
    
    uint64_t t_0 = dispatch_benchmark(iterations, ^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (size_t i = 0; i < count; i++) {
                id object = @"🐷";
                [mutableArray addObject:object];
            }
        }
    });
    NSLog(@"[[NSMutableArray array] addObject:] Avg. Runtime: %llu ns", t_0);
    
    uint64_t t_1 = dispatch_benchmark(iterations, ^{
        @autoreleasepool {
            NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:count];
            for (size_t i = 0; i < count; i++) {
                id object = @"🐷";
                [mutableArray addObject:object];
            }
        }
    });
    NSLog(@"[[NSMutableArray arrayWithCapacity] addObject:] Avg. Runtime: %llu ns", t_1);
    
}

void checkEqualMethod (void) {
   
    NSMutableArray *one = [NSMutableArray arrayWithObjects:@"0909", @"3223", @"323", nil];
    NSArray *two = [NSArray arrayWithObjects:@"0909", @"3223", @"323", nil];

    NSLog(@"%p, %@", one, one);
    NSLog(@"%p, %@", two, two);
    NSLog(@"%d", [one isEqualToArray:two]);
    NSLog(@"%d", [one isEqualTo:two]);
    NSLog(@"%d", one == two);

    
//    NSString *one = [NSString stringWithFormat:@"1234566"];
//
//    NSString *two = @"1234566";
//
//    NSLog(@"-%p  -%p   -%d", one, two, [one isEqual:two]);
//    NSLog(@"+%d", [one isEqualToString:two]);
//    NSLog(@"=%d", (one == two));
}

void encode_Method (void) {

        NSString *temp = @"";
        for (NSUInteger i = 32; i > 0; --i) {
            NSString *letter = [NSString stringWithFormat:@"%c", arc4random_uniform(26) + 'a'];

           temp = [temp stringByAppendingString:letter];
        }
 
    NSLog(@"%@", temp);

    
}
