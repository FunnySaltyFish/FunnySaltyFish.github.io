---
title: Jetpack Compose 中优雅完成数据持久化
date: 2022-01-25 17:38:56
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

Compose出来也好久了，各种remember和LocalXXX.current也是用得越来越熟。如果能在保持上述写法一致性的情况下完成数据的持久化工作，不是显得挺优雅的吗？  
基于此，我写出了开源库：[ComposeDataSaver: 在Jetpack Compose中优雅完成数据持久化](https://github.com/FunnySaltyFish/ComposeDataSaver)  
简单一瞥：
```kotlin
// booleanExample 初始化值为false
// 之后会自动读取本地数据
var booleanExample by rememberDataSaverState(KEY_BOOLEAN_EXAMPLE, false)
// 直接赋值即可完成持久化
booleanExample = true
```
可还行？


# ComposeDataSaver

项目有以下特点：
-   简洁：近似原生的写法
-   低耦合：抽象接口，不限制底层保存算法实现
-   轻巧：默认不引入除Compose外任何第三方库
-   灵活：支持基本的数据类型和自定义类型

![Example](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7aa3a9c8ae9c4143a84141a36cbd4532~tplv-k3u1fbpfcp-zoom-1.image)

***

## 引入

在`settings.gradle`引入jitpack仓库位置

```bash
dependencyResolutionManagement {
    repositories {
        maven { url "https://jitpack.io" }
    }
}
```

在项目`build.gradle`引入

```bash
dependencies {
        implementation 'com.github.FunnySaltyFish.ComposeDataSaver:data-saver:v1.0.2
'
}
```





## 基本使用

项目使用`DataSaverInterface`接口的实现类来保存数据，因此您需要先提供一个此类对象。

项目默认包含了使用`Preference`保存数据的实现类`DataSaverPreferences`，可如下初始化：

```kotlin
// init preferences
val dataSaverPreferences = DataSaverPreferences().apply {
	setContext(context = applicationContext)
}
CompositionLocalProvider(LocalDataSaver provides dataSaverPreferences){
	ExampleComposable()
}
```

此后在`ExampleComposable`及其子微件内部可使用`LocalDataSaver.current`获取当前实例

对于基本数据类型（如String/Int/Boolean）：

```kotlin
// booleanExample 初始化值为false
// 之后会自动读取本地数据
var booleanExample by rememberDataSaverState(KEY_BOOLEAN_EXAMPLE, false)
// 直接赋值即可完成持久化
booleanExample = true
```

就这么简单！



## 自定义存储框架

我们提供了基于 [MMKV](https://github.com/Tencent/MMKV) 或者 [DataStorePreference](https://developer.android.google.cn/jetpack/androidx/releases/datastore) 的简单实现

### MMKV

1. 在上述依赖基础上，额外添加

```bash
// if you want to use mmkv
implementation "com.github.FunnySaltyFish.ComposeDataSaver:data-saver-mmkv:v1.0.2"
implementation 'com.tencent:mmkv:1.2.12'
```

2. 如下初始化

```kotlin
MMKV.initialize(applicationContext)
val dataSaverMMKV = DataSaverMMKV().apply {
    setKV(newKV = MMKV.defaultMMKV())
}

CompositionLocalProvider(LocalDataSaver provides dataSaverMMKV){
    // ...
}
```

---

### DataStorePreference

1. 在上述依赖基础上，额外添加

```bash
// if you want to use DataStore
implementation "com.github.FunnySaltyFish.ComposeDataSaver:data-saver-data-store-preferences:v1.0.2"
def data_store_version = "1.0.0"
implementation "androidx.datastore:datastore:$data_store_version"
implementation "androidx.datastore:datastore-preferences:$data_store_version"
```

2. 如下初始化

```kotlin
val Context.dataStore : DataStore<Preferences> by preferencesDataStore("dataStore")
val dataSaverDataStorePreferences = DataSaverDataStorePreferences().apply {
	setDataStorePreferences(applicationContext.dataStore)
}

CompositionLocalProvider(LocalDataSaver provides dataSaverDataStorePreferences){
    // ...
}
```

---

### 其他存储框架

只需要实现`DataSaverInterface`类，并重写`saveData`和`readData`方法分别用于保存数据和读取数据

```kotlin
interface DataSaverInterface{
    fun <T> saveData(key:String, data : T)
    fun <T> readData(key: String, default : T) : T
}
```

然后将LocalDataSaver提供的对象更改为您自己的类实例

```kotlin
val dataStore = DataSaverDataStore()
CompositionLocalProvider(LocalDataSaver provides dataStore){
	ExampleComposable()
}
```

后续相同使用即可。



## 保存自定义类型

默认的`DataSaverPreferences`并不提供自定义类型的保存（当尝试这样做时会报错）。尽管不建议持久化实体类，但您仍可以这样做。您可以选择以下方式实现这一目标。

1. 重写自己的`DataSaverInterface`实现类（见上）并实现相关的保存方法
2. 将实体类序列化为其他基本类型（如String）再储存

对于第二种方式，您需要为对应实体类添加转换器以实现保存时自动转换为String。方法如下：

```kotlin
@Serializable
data class ExampleBean(var id:Int, val label:String)
// ------------ //

// 在初始化时调用registerTypeConverters方法注册对应转换方法
// 该方法接收两个参数：实体类Class和对应的转换方法（Lambda表达式）
registerTypeConverters(ExampleBean::class.java) {
    val bean = it as ExampleBean
    Json.encodeToString(bean)
}
```

完整例子见[示例项目](/app/src/main/java/com/funny/composedatasaver/ExampleActivity.kt)



## 更多设置

1. 如果在某些情况下你不想频繁持久化保存，可设置`rememberDataSaverState`的`autoSave`参数为`false`，此时对象的赋值操作将不会执行持久化操作，您在需要保存的位置手动保存：`LocalDataSaver.current.saveData()`

## 后续
新项目，希望大家喜欢。觉得好用不妨来个Star？！  
虎年快到了，提前祝各位万事顺利、虎虎生风！  
最后复读一下地址：[FunnySaltyFish/ComposeDataSaver: 在Jetpack Compose中优雅完成数据持久化 (github.com)](https://github.com/FunnySaltyFish/ComposeDataSaver)
