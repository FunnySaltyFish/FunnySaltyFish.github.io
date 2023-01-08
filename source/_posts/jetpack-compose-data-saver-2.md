---
title: Compose 数据持久化辅助框架：ComposeDataSaver 的一些新变化
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2023-01-08 13:27:15
---

七个月前，我写了个用于辅助 `Jetpack Compose` 做数据持久化的框架，并把它放到了 [Github](https://github.com/FunnySaltyFish/ComposeDataSaver) 上。在当时，我还写了篇简单的文章介绍：[Jetpack Compose 中优雅完成数据持久化](https://juejin.cn/post/7057075554456961060)。七个月后，我对它进行了大更新。这篇文章，再来推广推广它。

*嘿嘿嘿，不妨看看，说不定有点用呢~*

### 为什么写这个框架

写这个框架是基于这样一个很简单的思想：

我们知道，在Compose中，函数会被反复调用（也就是重组）。所以如果要**记住**一个状态，需要`remember{ }`。也就是这样：

```
 var number by remember{
     mutableStateOf(1)
 } 
 ...
 onClick = { number++ }
```

再进一步呢？如果需要**页面横竖屏切换时**还记住它，我们就需要用到记得更持久一些的`rememberSaveable`。也就是这样

```
 var number by rememberSaveable {
     mutableStateOf(1)
 }
 ...
 onClick = { number++ }
```

诶，那如果再进一步呢？如果想要它在**关闭应用后再打开**还是记得住，怎么办？这时候，`ComposeDataSaver`就出场啦

```
 // number初始化值为1，之后会自动读取本地已保存数据
 var number by rememberDataSaverState("key_number", 1)
 ...
 // 直接赋值即可完成持久化
 onClick = { number++ }
```

怎么样，是不是还不错呢？除了上述展示的基本类型，此次更新，我还带来了对**自定义类型的更好支持**、**对List类型的支持**以及其他**灵活配置的功能**。不妨来看看。

### 它是怎么实现的

框架的原理很简单，整体上，我抽象了数据访问和读取的接口，命名为`DataSaverInterface`，它的定义如下：

```
 /**
  * 此接口用于访问和写入数据，我们提供了基于 Preference, DataStore 和 MMKV 的默认实现（后两者为独立的包，以节省体积） 
  *
  * 省略一些内容，详见源文件注释
  */
 interface DataSaverInterface{
     fun <T> saveData(key:String, data : T)
     fun <T> readData(key: String, default : T) : T
     suspend fun <T> saveDataAsync(key:String, data : T) = saveData(key, data)
 }
```

使用抽象接口的好处显而易见：我们**不限制底层到底是怎么保存和读取**的，甚至你也可以选择保存到本地或者直接传到云端。框架本身提供了基于 Preference, DataStore 和 MMKV 的基本实现（后两者为独立的包，以节省体积）。

而为了能让Compose内部能够获取到这个保存的接口，我采取的方案是：`CompositionLocal`。如果你不了解，可以参考 [官方文档](https://developer.android.google.cn/jetpack/compose/compositionlocal?hl=zh-cn)。简单来说，只要根Composable提供了`DataSaverInterface`，那么它的所有子Composable都能用。具体就是`LocalDataSaver.current`就行 。甚至，如果你闲的慌或者业务需要，你还可以**对不同页面使用不同的存储框架**（只需要多提供几个就好了）。

接下来就是封装一个`State`了。由于`mutableStateOf`的实现`SnapshotMutableStateImpl`是`internal`的，所以没办法直接继承。因此这里采用了`组合`的方式，也就是内部维护了一个`State`，各种读取操作实际会与这个`State`交互，并在**值改变时进行持久化**。为了使用形式的更统一，我写的这个`State`也实现了`MutableState`接口，所以你可以把它当做一个普通的`MutableState`那样用。

```
 val value by rememberDataSaverState("key_number", 1)
 or
 val (value, setValue) = rememberDataSaverState("key_number", 1)
```

如果不在Composable里（比如`ViewModel`中使用），我们也提供了与`mutableState`类似的函数

```
 /**
  * This function READ AND CONVERT the saved data and return a [DataSaverMutableState].
  * Check the example in `README.md` to see how to use it.
  *
  * 此函数 **读取并转换** 已保存的数据，返回 [DataSaverMutableState]
  *
  * @param key String 键
  * @param initialValue T 如果本地还没保存过值，此值将作为初始值；其他情况下会读取已保存值
  * @param savePolicy 管理是否、何时做持久化操作，见 [SavePolicy]
  * @param async 是否异步做持久化
  * @return DataSaverMutableState<T>
  *
  * @see DataSaverMutableState
  */
 inline fun <reified T> mutableDataSaverStateOf(
     dataSaverInterface: DataSaverInterface,
     key: String,
     initialValue: T,
     savePolicy: SavePolicy = SavePolicy.IMMEDIATELY,
     async: Boolean = true
 ): DataSaverMutableState<T>
```

上面的代码中出现了两个有趣的参数：`savePolicy`和`async`，这些都是在此次更新（v1.1.0）中新加入的功能。他们都有默认值，所以你可以无需特别关心；如果你有需要，灵活的配置它们也能满足不同需要。

丢点README的东西过来

#### 控制保存策略

v1.1.0 将原先的 `autoSave` 升级为了 `savePolicy`，以控制是否做、什么时候做数据持久化。`mutableDataSaverStateOf`、`rememberDataSaverState` 均包含此参数，默认为`IMEDIATELY`

该类目前包含下面三种值：

```
 open class SavePolicy {
     /**
      * 默认模式，每次给state的value赋新值时就做持久化
      */
     object IMMEDIATELY : SavePolicy()
 ​
     /**
      * Composable `onDispose` 时做数据持久化，适合数据变动比较频繁、且此Composable会进入onDispose的情况。
      * **慎用此模式，因为有些情况下onDispose不会被回调**
      */
     object DISPOSED: SavePolicy()
 ​
     /**
      * 不会自动做持久化操作，请按需自行调用`state.saveData()`。
      * Example: `onClick = { state.saveData() }`
      */
     object NEVER : SavePolicy()
 }
```

#### 异步保存

v1.1.0 对`DataSaverInterface` 新增了 `suspend fun saveDataAsync` ，用于异步保存。默认情况下，它等同于 `saveData`。对于支持协程的框架（如`DataStore`），使用此实现有助于充分利用协程优势（默认给出的`DataStorePreference`就是如此）。

在`mutableDataSavarStateOf` 和 `rememberMutableDataSavarState` 函数调用处可以设置`async`以启用异步保存，默认为`true`。

### 自定义类型的支持

还记得开始提到，我们这一版加强了对自定义类型的支持。具体来说，库提供了函数`registerTypeConverters`来注册自定义类型的`save`和`restore`方法，之后保存和读取时都会自动做转换。甚至，如果您为 `ExampleBean` 注册了转换器，那么 `List<ExampleBean>` **也将自动得到支持**（通过 `rememberDataSaverListState` ）。

一个例子如下：

在使用相应`remember`前注册一下

```
 // cause we want to save custom bean, we provide a converter to convert it into String
 registerTypeConverters<ExampleBean>(
     save = { bean -> Json.encodeToString(bean) },
     restore = { str -> Json.decodeFromString(str) }
 )
 ​
 @Serializable
 data class ExampleBean(var id:Int, val label:String)
 val EmptyBean = ExampleBean(233,"FunnySaltyFish")
```

然后使用的时候

```
 var beanExample by rememberDataSaverState(KEY_BEAN_EXAMPLE, default = EmptyBean)
 ...
 onClick = {
     beanExample = beanExample.copy(id = beanExample.id+1)
 }
```

还算简洁？

而且，正如已经提到的，`List<ExampleBean>`也同时**自动支持**：

```
 var listExample by rememberDataSaverListState(key = "key_list_example", default = listOf(
     EmptyBean.copy(label = "Name 1"), 
     EmptyBean.copy(label = "Name 2"),
     EmptyBean.copy(label = "Name 3")
 ))
 ...
 onClick = { listExample = listExample.dropLast(1) }
```

当然，上面提到的这些已经给出了示例应用：


![screenshot.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/52043e8e9fc048cc82b52ce2015b76ee~tplv-k3u1fbpfcp-watermark.image?)

点击 [这里就可以下载啦](https://github.com/FunnySaltyFish/ComposeDataSaver/blob/master/demo.apk)

### 写一个库要有库的样子

尽管库不大，但是我仍然秉持着蛮认真的态度完善着它。具体包括：

-   完整、清晰的`README.md`：[FunnySaltyFish/ComposeDataSaver: 在Jetpack Compose中优雅完成数据持久化 | An elegant way to do data persistence in Jetpack Compose](https://github.com/FunnySaltyFish/ComposeDataSaver)

-   丰富的注释：丢两张图吧

-  ![Snipaste_2022-09-18_21-56-29.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2833d274bba1430a93e67ce54953fd6b~tplv-k3u1fbpfcp-watermark.image?)
-  ![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/66385403c8d8499998def3f09b328427~tplv-k3u1fbpfcp-watermark.image?)
-   Debug信息输出：

-   ![Snipaste_2022-09-18_12-41-38.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/26675bfca42f4feabb9149462f90baa2~tplv-k3u1fbpfcp-watermark.image?)
    -   当然这是可以关闭的
    -   ```
         /**
          * 1. DEBUG: 是否输出库的调试信息
          * 2. ...
          */
         object DataSaverConfig {
             var DEBUG = true
             // 省略
         }
        ```

### 欢迎体验

最后嘛，就欢迎体验啦~

Github： [FunnySaltyFish/ComposeDataSaver: 在Jetpack Compose中优雅完成数据持久化 | An elegant way to do data persistence in Jetpack Compose (github.com)](https://github.com/FunnySaltyFish/ComposeDataSaver)

顺带，在这段时间，我也在不断完善着自己的开源项目 [FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件，支持多引擎、插件化~ | Jetpack Compose+MVVM+协程+Room (github.com)](https://github.com/FunnySaltyFish/FunnyTranslation)，最近给它加上了登录注册（基于指纹）、历史记录（Paging3+Room），也适配了 Android 13 的部分特性。它就是使用的此库做的持久化，也欢迎体验。

能来点star就最好啦（笑）