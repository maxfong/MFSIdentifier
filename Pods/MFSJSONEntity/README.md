# MFSJSONEntity
JSON和Object互转是App开发中最常用的功能之一;<br/>

####MFSJSONEntity的特点：

* NSObject的类别；
* 比较轻量；
* 转换功能全；

####实体对象属性类型支持：

* NSString
* NSArray
* NSDictionary
* NSNull 
* 值基本类型

#安装
####编译静态Framework
```
git clone https://github.com/maxfong/MFSJSONEntity.git
```
选择 <b>lipoFramework</b> Target 编译即可

####引用framework
```
#import <MFSJSONEntity/MFSJSONEntity.h>
```

#####使用framework需Other Linker Flags添加-ObjC；

###CocoaPods

```
编辑Pofile
pod 'MFSJSONEntity', '1.0.1'
```

```
安装
pod install
```

更多关于[CocoaPods](https://cocoapods.org/).

#使用

###Object -> Dictionary（当前类属性键值对）
```
Person *person = Person.new;
person.name = @"max";
person.age = 99;
NSDictionary *personDict = [person propertyDictionary];
NSLog(@"Person:%@", personDict);
```

###Dictionary -> Object（支持多层嵌套）
```
NSString *JSONString = @"{\"name\":\"max\",\"age\":98}";
NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
Person *obj = [Person objectWithDictionary:dictionary];
NSLog(@"person:%@, name:%@, age:%ld", obj, obj.name, obj.age);
```

###属性列表（可自定义父类）
```
NSArray *propertys = [Person propertyNames];
NSLog(@"Person propertys:%@", propertys);
```

#其他
如果您发现任何问题或有啥建议，发个issues，谢谢；


#License

MFSJSONEntity is available under the MIT license. See the LICENSE file for more info.
