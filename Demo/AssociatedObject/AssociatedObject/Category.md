# 深入理解Objective-C：Category

## 可以把类的实现分开在几个不同的文件里面。这样做有几个显而易见的好处，
* a)可以减少单个文件的体积
* b)可以把不同的功能组织到不同的category里
* c)可以由多个开发者共同完成一个类
* d)可以按需加载想要的category 等等。

## 声明私有方法
不过除了apple推荐的使用场景，广大开发者脑洞大开，还衍生出了category的其他几个使用场景：

## 模拟多继承
## 把framework的私有方法公开


extension一般用来隐藏类的私有信息，你必须有一个类的源码才能为一个类添加extension，所以你无法为系统的类比如NSString添加extension。
extension可以添加实例变量，而category是无法添加实例变量的（因为在运行期，对象的内存布局已经确定，如果添加实例变量就会破坏类的内部布局，这对编译型语言来说是灾难性的）。

## category真面目

1)、类的名字（name）
2)、类（cls）
3)、category中所有给类添加的实例方法的列表（instanceMethods）
4)、category中所有添加的类方法的列表（classMethods）
5)、category实现的所有协议的列表（protocols）
6)、category中添加的所有属性（instanceProperties）
typedef struct category_t {
const char *name;
classref_t cls;
struct method_list_t *instanceMethods;
struct method_list_t *classMethods;
struct protocol_list_t *protocols;
struct property_list_t *instanceProperties;
} category_t;




需要注意的有两点：

1)、category的方法没有“完全替换掉”原来类已经有的方法，也就是说如果category和原来类都有methodA，那么category附加完成之后，类的方法列表里会有两个methodA

2)、category的方法被放到了新方法列表的前面，而原来类的方法被放到了新方法列表的后面，这也就是我们平常所说的category的方法会“覆盖”掉原来类的同名方法，这是因为运行时在查找方法的时候是顺着方法列表的顺序查找的，它只要一找到对应名字的方法，就会罢休^_^，殊不知后面可能还有一样名字的方法。


## category和关联对象
#import "MyClass.h"

@interface MyClass (Category1)

@property(nonatomic,copy) NSString *name;

@end

#import "MyClass+Category1.h"
#import <objc/runtime.h>

@implementation MyClass (Category1)

+ (void)load
{
NSLog(@"%@",@"load in Category1");
}

- (void)setName:(NSString *)name
{
objc_setAssociatedObject(self,
"name",
name,
OBJC_ASSOCIATION_COPY);
}

- (NSString*)name
{
NSString *nameObject = objc_getAssociatedObject(self, "name");
return nameObject;
}

@end

但是关联对象又是存在什么地方呢？ 如何存储？ 对象销毁时候如何处理关联对象呢？

我们去翻一下runtime的源码，在objc-references.mm文件中有个方法_object_set_associative_reference：

void _object_set_associative_reference(id object, void *key, id value, uintptr_t policy) {
// retain the new value (if any) outside the lock.
ObjcAssociation old_association(0, nil);
id new_value = value ? acquireValue(value, policy) : nil;
{
AssociationsManager manager;
AssociationsHashMap &associations(manager.associations());
disguised_ptr_t disguised_object = DISGUISE(object);
if (new_value) {
// break any existing association.
AssociationsHashMap::iterator i = associations.find(disguised_object);
if (i != associations.end()) {
// secondary table exists
ObjectAssociationMap *refs = i->second;
ObjectAssociationMap::iterator j = refs->find(key);
if (j != refs->end()) {
old_association = j->second;
j->second = ObjcAssociation(policy, new_value);
} else {
(*refs)[key] = ObjcAssociation(policy, new_value);
}
} else {
// create the new association (first time).
ObjectAssociationMap *refs = new ObjectAssociationMap;
associations[disguised_object] = refs;
(*refs)[key] = ObjcAssociation(policy, new_value);
_class_setInstancesHaveAssociatedObjects(_object_getClass(object));
}
} else {
// setting the association to nil breaks the association.
AssociationsHashMap::iterator i = associations.find(disguised_object);
if (i !=  associations.end()) {
ObjectAssociationMap *refs = i->second;
ObjectAssociationMap::iterator j = refs->find(key);
if (j != refs->end()) {
old_association = j->second;
refs->erase(j);
}
}
}
}
// release the old value (outside of the lock).
if (old_association.hasValue()) ReleaseValue()(old_association);
}


我们可以看到所有的关联对象都由AssociationsManager管理，而AssociationsManager定义如下：

AssociationsManager里面是由一个静态AssociationsHashMap来存储所有的关联对象的。这相当于把所有对象的关联对象都存在一个全局map里面。而map的的key是这个对象的指针地址（任意两个不同对象的指针地址一定是不同的），而这个map的value又是另外一个AssociationsHashMap，里面保存了关联对象的kv对。

void *objc_destructInstance(id obj)
{
if (obj) {
Class isa_gen = _object_getClass(obj);
class_t *isa = newcls(isa_gen);

// Read all of the flags at once for performance.
bool cxx = hasCxxStructors(isa);
bool assoc = !UseGC && _class_instancesHaveAssociatedObjects(isa_gen);

// This order is important.
if (cxx) object_cxxDestruct(obj);
if (assoc) _object_remove_assocations(obj);

if (!UseGC) objc_clear_deallocating(obj);
}

return obj;
}

嗯，runtime的销毁对象函数objc_destructInstance里面会判断这个对象有没有关联对象，如果有，会调用_object_remove_assocations做关联对象的清理工作。

