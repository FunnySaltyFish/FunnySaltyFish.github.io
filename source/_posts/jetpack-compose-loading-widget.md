---
title: Jetpack Compose 通用加载微件的实现
date: 2021-12-23 11:10:07
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

加载数据在Android开发中应该算是非常频繁的操作了，因此简单在Jetpack Compose中实现一个通用的加载微件

效果如下：

**加载中（转圈圈）**


| 加载中 | 加载完成 |
| --- | --- |
| ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cfe7e51a5b5d4cf4b24f75246def758d~tplv-k3u1fbpfcp-zoom-1.image) | ![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d2ef0a17ff4f47bb85222d3c08b88295~tplv-k3u1fbpfcp-zoom-1.image) |



另外加载失败后显示失败并可以点击重试

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/66aa4f07ba6f49d7893431ec23f8a814~tplv-k3u1fbpfcp-watermark.image?)

#### 实现

实现这个微件其实非常简单，无非就是根据不同的状态加载不同页面

##### 加载状态Bean

首先把加载的状态抽象出来，写个数据类

```
 sealed class LoadingState<out R> {
     object Loading : LoadingState<Nothing>()
     data class Failure(val error : Throwable) : LoadingState<Nothing>()
     data class Success<T>(val data : T) : LoadingState<T>()
 ​
     val isLoading
         get() = this is Loading
     val isSuccess
         get() = this is Success<*>
 }
```

此处借鉴了朱江大佬写的玩安卓Compose版本，在此感谢

##### 微件

然后就是加载了。考虑到加载一般耗时，所以用协程。

写成微件大概就是下面这个样子

```
 private const val TAG = "LoadingWidget"
 ​
 /**
  * 通用加载微件
  * @author [FunnySaltyFish](https://blog.funnysaltyfish.fun/)
  * @param modifier Modifier 整个微件包围在Box中，此处修饰此Box
  * @param loader  加载函数，返回值为正常加载出的结果
  * @param loading 加载中显示的页面，默认为转圈圈
  * @param failure 加载失败显示的页面，默认为文本，点击可以重新加载（retry即为重新加载的函数）
  * @param success 加载成功后的页面，参数[T]即为返回的结果
  */
 @Composable
 fun <T> LoadingContent(
     modifier: Modifier = Modifier,
     loader : suspend ()->T,
     loading : @Composable ()->Unit = { DefaultLoading() },
     failure : @Composable (error : Throwable, retry : ()->Unit)->Unit = { error, retry->
         DefaultFailure(error, retry)
     },
     success : @Composable (data : T?)->Unit
 ) {
     var key by remember {
         mutableStateOf(false)
     }
     val state : LoadingState<T> by produceState<LoadingState<T>>(initialValue = LoadingState.Loading, key){
         value = try {
             Log.d(TAG, "LoadingContent: loading...")
             LoadingState.Success(loader())
         }catch (e: Exception){
             LoadingState.Failure(e)
         }
     }
     Box(modifier = modifier){
         when(state){
             is LoadingState.Loading -> loading()
             is LoadingState.Success<T> -> success((state as LoadingState.Success<T>).data)
             is LoadingState.Failure -> failure((state as LoadingState.Failure).error){
                 key = !key
                 Log.d(TAG, "LoadingContent: newKey:$key")
             }
         }
     }
 }
```

基于produceState加载并保存数据，然后根据不同的加载状态显示不同的页面。  
官方对此函数的翻译如下：
```kotlin
/**
 * Return an observable [snapshot][androidx.compose.runtime.snapshots.Snapshot] [State] that
 * produces values over time from [key1].
 *
 * [producer] is launched when [produceState] enters the composition and is cancelled when
 * [produceState] leaves the composition. If [key1] changes, a running [producer] will be
 * cancelled and re-launched for the new source. [producer] should use [ProduceStateScope.value]
 * to set new values on the returned [State].
 *
 * The returned [State] conflates values; no change will be observable if
 * [ProduceStateScope.value] is used to set a value that is [equal][Any.equals] to its old value,
 * and observers may only see the latest value if several values are set in rapid succession.
 *
 * [produceState] may be used to observe either suspending or non-suspending sources of external
 * data, for example:
 *
 * @sample androidx.compose.runtime.samples.ProduceState
 *
 * @sample androidx.compose.runtime.samples.ProduceStateAwaitDispose
 */
```
翻译过来就是：
```kotlin
/**
 * 返回一个可观察的[snapshot][androidx.compose.runtime.snapshots.Snapshot] [State] 对象，它的值由[key1]随时间变化产生.
 *
 * [producer] 在 [produceState] 进入 composition 后会被启动，当[produceState] 离开 composition 时被取消. 如果 [key1] 改变, 当前正在运行的 [producer] 将被取消并根据新来源重启. 
 * [producer] 应当使用 [ProduceStateScope.value] ，在返回的 [State] 中设置 value 的值.
 *
 * 返回的 [State] 与 value 一致; 如若新的值与旧value相等[Any.equals] ，则此变化不会被观察到
 * 如果在短时间内多个新值被赋予，则观察着可能仅能观察到最新的值
 *
 * [produceState] 可被用在 suspending / non-suspending 的外部数据来源中，如:
 *
 * @sample androidx.compose.runtime.samples.ProduceState
 *
 * @sample androidx.compose.runtime.samples.ProduceStateAwaitDispose
 */
```
除开数据加载外，上面的代码也给出了几个默认页面。分别有默认的加载页面（转圈圈）和默认的错误页面（点击重试）

```
 @Composable
 fun DefaultLoading() {
     CircularProgressIndicator()
 }
 ​
 @Composable
 fun DefaultFailure(error: Throwable, retry : ()->Unit) {
     Text(text = stringResource(id = R.string.loading_error), modifier = Modifier.clickable(onClick = retry))
 }
```

此微件使用起来也很简单直接

```
 LoadingContent(
     modifier = Modifier.align(CenterHorizontally) ,
     loader = (vm.sponsorService::getAllSponsor) 
 ) { list ->
     list?.let{
         Column {
             SponsorList(it)
             Text("加载完成")
         }
     }
}
```

完整代码在这里：  
加载微件：[FunnyTranslation/LoadingWidget.kt](https://github.com/FunnySaltyFish/FunnyTranslation/blob/compose/translate/src/main/java/com/funny/translation/translate/ui/widget/LoadingWidget.kt)  
使用示例：[FunnyTranslation/ThanksScreen.kt](https://github.com/FunnySaltyFish/FunnyTranslation/blob/d747a153a8ec0ed4c14ad9b2156f93aac1401380/translate/src/main/java/com/funny/translation/translate/ui/thanks/ThanksScreen.kt)

这只是一个简单方案，由衷欢迎各位探讨。  

最后再自荐一下我的开源项目（就是上面那个链接），Jetpack Compose实现的翻译软件。不妨点个star，万一什么地方有用呢（逃~

参考资料：
[【开源项目】简单易用的Compose版StateLayout,了解一下~ - 掘金 (juejin.cn)](https://juejin.cn/post/7010382907084636168)

#### 后记
在于掘金用户@[Petterp](https://juejin.cn/user/3491704662136541) 探讨后，他给出了一个可定制化程度更高、适用范围更广的实现。大家可以参见：[链接](https://juejin.cn/post/7042110419439190024)