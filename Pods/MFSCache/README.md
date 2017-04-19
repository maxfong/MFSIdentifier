# MFSCache
我们的应用都包含了大量的数据，使用缓存可以让应用程序更快速的响应数据展示、用户输入，使程序高效的运行；

MFSCache是一套简单缓存数据的机制，使用方式、性能效率都非常不错，增加缓存生命周期、缓存空间、支持更多的数据类型、数据加密、全局对象（伪单例）、快速缓存、分级、移除缓存；


# 安装  

### CocoaPods

```
编辑Pofile
pod 'MFSCache', '2.0.0'
```

```
安装
pod install
```

更多关于[CocoaPods](https://cocoapods.org/)

### Carthage
```
编辑Cartfile
github "maxfong/MFSCache" >= 2.0.0
```

```
安装
carthage update
```

更多关于[Carthage](https://github.com/Carthage/Carthage)

**使用Framework，工程Other Linker Flags需添加-ObjC**

# 说明
### 使用方式
setObject：forKey：和objectForKey：，KEY值各模块自己定义，推荐使用前缀，例：@”module.home.page”<br/>
公共部分的KEY可以统一定义，如用户定位的城市、用户需要存储的信息；

### 缓存的生命周期
通过-setObject:forKey:duration:保存的对象具有时效性，超过duration秒数的对象无法获取到，返回nil；<br/>
Tip：过期的对象会异步从磁盘中删除；

### 缓存空间
通过+defaultManager获取的cacheManager实例对应共用的一块空间，如果需要使用不同的空间，使用-initWithSuiteName：创建不同的cacheManager实例；<br/>
例：不同的用户订单数据不同，使用-initWithSuiteName：初始化的cacheManager对象使用memberId作为suiteName，给用户生成不同空间，相同的KEY可存储数据在不同的空间，空间之间的数据无法互通

### 数据类型
存储对象支持NSString, NSURL, NSData, NSNumber, NSDictionary, NSArray, NSNull, 自定义实体类（NSObject），有无法满足的新类型在issues中提出或者自定义添加；

### 数据加密
区别于NSUserDefault的存储方式，MFSCacheManager存储磁盘的所有数据都是AES加密，使用MFS的默认密匙，单纯的得到缓存文件无法查看，保证安全性；

### 全局对象（伪单例）
新增-setTempObject:forKey:，供保存App生命周期内需要全局使用的对象，临时对象存储在内存中，不序列化，不占用硬盘空间；<br/>
Tip：相同的空间，-objectForKey使用相同的KEY获取对象，会优先获取全局临时对象，后获取缓存对象；

### 快速缓存
缓存过一次的对象会自动加载到内存中，再次读取会直接从内存获取对象，减少文件消耗；内存过多会自动释放这部分内存，再次获取再执行相同的步骤；

### 分级
MFSCacheManager管理的缓存分为3级，永久、默认、定时，在缓存使用-setObject:forKey:保存的对象里，会调用-setObject:forKey:duration:方法，duration默认为0，生成默认缓存，使用自定义的存储-setObject:forKey:duration:，duration小于0（负数）表示存储了一个永久对象，duration大于0表示存储了一个定时对象；

### 移除缓存
实例方法-removeObjectsWithCompletionBlock：会移除对应空间的默认级别的缓存，block回调删除文件的大小，永久级别的缓存不可被-removeObjectsWithCompletionBlock移除，只能在自己的cacheManager实例中，用-removeObjectForKey来移除；<br/>
-removeExpireObjects表示异步检查缓存的生命周期，删除过期的定时缓存，建议App启动调用；<br/>
+removeObjectsWithCompletionBlock:和+ (void)removeExpireObjects表示不区分空间，全部删除默认级别和过期的定时缓存（永久缓存无法被删除）；

### 性能
以5个属性的对象为例，在数组中添加10W次，经过模拟器测试，存储耗时：1.5s，读取耗时：2.8s；<br/>
Tip:已经过尾递归和JSON对象化对比，优化了70%耗损，现在耗时最优；

### 更多
通过-objectForKey：获取的对象修改值不会影响原有的缓存对象，不执行-setObject:forKey:前，每次得到的对象都是重新生成的，值一样，指针地址不一样；<br/>
默认同步执行，线程安全，放心使用；

## 其他
如果您发现任何问题或有啥建议，发个issues，谢谢；

## License
MFSCache is available under the MIT license. See the LICENSE file for more info.
