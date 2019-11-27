
Objective-C 的 Runtime 是一个运行时库(Runtime Library)，它是一个主要使用 C 和汇编写的库，为 C 添加了面相对象的能力并创造了 Objective-C。我们使用时，runtime是一套由c/c++以及汇编语言写成的api， runtime 创建了所有需要的结构体，让 Objective-C 的面相对象编程变为可能。


当我们编写c/c++语言时，如果函数不存在，编译器会马上报错，而在Object-C中，执行一个方法，并不会报错，直到你真正执行这个方法时，才会报出unrecognized selector错误，这就是OC中的运行时体现。

OC对象和消息发送

对象的本质是结构体，方法的本质是发送消息，Class 如果你查看一个类的runtime信息，你会看到这个…

typedef struct objc_class *Class;
typedef struct objc_object {
Class isa;
} *id;

objc_object 只有一个指向类的 isa 指针，就是我们说的术语 “isa pointer”（isa 指针）。
当我们发送一个消息给对象时，通过这个 isa 指针，Runtime 检查并且查看它的类是什么，能否响应这些消息。
最后我么看到了 id 指针。默认情况下 id 指针除了告诉我们它们是 Objective-C 对象外没有其他用了。当你有一个 id 指针，然后你就可以问这个对象是什么类的，看看它是否响应一个方法，等等，然后你就可以在知道这个指针指向的是什么对象后执行更多的操作了。


什么是 Objective-C 类？在 Objective-C 中的一个类实现看起来像这样：

struct objc_class {
Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
Class _Nullable super_class                              OBJC2_UNAVAILABLE;
const char * _Nonnull name                               OBJC2_UNAVAILABLE;
long version                                             OBJC2_UNAVAILABLE;
long info                                                OBJC2_UNAVAILABLE;
long instance_size                                       OBJC2_UNAVAILABLE;
struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;


通过观察lookUpImpOrForward的实现，我们同样可以证实，方法的查询逻辑为对象中没有，就从父类中查找，执行顺序为：
// Try this class's cache.
// Try this class's method lists.
// Try superclass caches and method lists.
// No implementation found. Try method resolver once.
// No implementation found, and method resolver didn't help.
// Use forwarding.
这里发现，自己和父类里面都没有找到IMP时，会通过_class_resolveMethod


## _objc_msgForward消息转发做了如下几件事：
### 1.调用resolveInstanceMethod:方法，允许用户在此时为该Class动态添加实现。如果有实现了，则调用并返回。如果仍没实现，继续下面的动作。

### 2.调用forwardingTargetForSelector:方法，尝试找到一个能响应该消息的对象。如果获取到，则直接转发给它。如果返回了nil，继续下面的动作。

### 3.调用methodSignatureForSelector:方法，尝试获得一个方法签名。如果获取不到，则直接调用doesNotRecognizeSelector抛出异常。

### 4.调用forwardInvocation:方法，将地3步获取到的方法签名包装成Invocation传入，如何处理就在这里面了。

上面这4个方法均是模板方法，开发者可以override，由runtime来调用。最常见的实现消息转发，就是重写方法3和4，吞掉一个消息或者代理给其他对象都是没问题的。
