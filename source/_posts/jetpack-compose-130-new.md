---
title: Jetpack Compose 上新：瀑布流布局、下拉加载、DrawScope.drawText
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2023-01-08 13:31:41
---

不久前，Jetpack Compose 发布了 `1.3.0` 正式版。经过一年多的发展，再回头去看，Compose 终于带来了缺失已久的瀑布流布局以及`DrawScope.drawText`方法。本文就简单介绍一下。  
截止此文写作时，Jetpack Compose 的最新 stable 版本为 `1.3.1`，而查阅 [Compose 与 Kotlin 的兼容性对应关系](https://developer.android.google.cn/jetpack/androidx/releases/compose-kotlin?hl=zh-cn) 文档可知，此版本对应的 Kotlin 版本为 `1.7.10`。如需尝试部分代码，请确保对应版本设置正确。

## BOM
Compose `Bill of Materials` 是 Compose 最近带来的新东西，它能帮你指定 Compose 各种库的版本，确保各个 Compose 相关的库是项目兼容的（但并不引入对应的库）。具体来说，当你在 `build.gradle` 中引入 `BOM` 后
```
// Import the Compose BOM
implementation platform('androidx.compose:compose-bom:2022.10.00')
```
再引入其它 Compose 相关的库就不需要手动指定版本号了，它们会由 `BOM` 指定
```
implementation "androidx.compose.ui:ui"
implementation "androidx.compose.material:material"
implementation "androidx.compose.ui:ui-tooling-preview"
```
`BOM` 指定的版本都是稳定版，你也可以选择覆写部分版本到 `alpha` 版本，如下：
```
// Override Material Design 3 library version with a pre-release version
implementation 'androidx.compose.material3:material3:1.1.0-alpha01'
```
需要注意的是，这样可能会使部分其它的 Compose 库也升级为对应的 `alpha` 版本，以确保兼容性。  
`BOM` 和 库版本 的映射可以在 [Quick start  |  Jetpack Compose  |  Android Developers](https://developer.android.com/jetpack/compose/setup#bom-version-mapping) 找到，目前的两个版本对应如下
Library group                                          | Version in 2022.10.00 | Version in 2022.11.00 |
| ------------------------------------------------------ | --------------------- | --------------------- |
| androidx.compose.animation:animation                   | 1.3.0                 | 1.3.1                 |
| androidx.compose.animation:animation-core              | 1.3.0                 | 1.3.1                 |
| androidx.compose.animation:animation-graphics          | 1.3.0                 | 1.3.1                 |
| androidx.compose.foundation:foundation                 | 1.3.0                 | 1.3.1                 |
| androidx.compose.foundation:foundation-layout          | 1.3.0                 | 1.3.1                 |
| androidx.compose.material:material                     | 1.3.0                 | 1.3.1                 |
| androidx.compose.material:material-icons-core          | 1.3.0                 | 1.3.1                 |
| androidx.compose.material:material-icons-extended      | 1.3.0                 | 1.3.1                 |
| androidx.compose.material:material-ripple              | 1.3.0                 | 1.3.1                 |
| androidx.compose.material3:material3                   | 1.0.0                 | 1.0.1                 |
| androidx.compose.material3:material3-window-size-class | 1.0.0                 | 1.0.1                 |
| androidx.compose.runtime:runtime                       | 1.3.0                 | 1.3.1                 |
| androidx.compose.runtime:runtime-livedata              | 1.3.0                 | 1.3.1                 |
| androidx.compose.runtime:runtime-rxjava2               | 1.3.0                 | 1.3.1                 |
| androidx.compose.runtime:runtime-rxjava3               | 1.3.0                 | 1.3.1                 |
| androidx.compose.runtime:runtime-saveable              | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui                                 | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-geometry                        | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-graphics                        | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-test                            | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-test-junit4                     | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-test-manifest                   | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-text                            | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-text-google-fonts               | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-tooling                         | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-tooling-data                    | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-tooling-preview                 | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-unit                            | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-util                            | 1.3.0                 | 1.3.1                 |
| androidx.compose.ui:ui-viewbinding                     | 1.3.0                 | 1.3.1


## 瀑布流布局
在 Jetpack Compose 1.0 正式版发布一年多后，瀑布流组件终于是姗姗来迟。目前，此组件的用法与 `LazyGrid` 保持了高度一致，而后者我已经在 [Jetpack Compose LazyGrid使用全解](https://juejin.cn/post/7100120556192104484) 做过详细演示。此处不做过多赘述，示例如下：

```kotlin
// 纵向，横向的对应 Horizontal...
LazyVerticalStaggeredGrid(
    // columns 参数类似于 LazyVerticalGrid
    columns = StaggeredGridCells.Fixed(2),
    // 整体内边距
    contentPadding = PaddingValues(8.dp, 8.dp),
    // item 和 item 之间的纵向间距
    verticalArrangement = Arrangement.spacedBy(4.dp),
    // item 和 item 之间的横向间距
    horizontalArrangement = Arrangement.spacedBy(8.dp)
){
    itemsIndexed(pages, key = { _, p -> p.first }){ i, pair ->
        ...
    }
}
```

效果如下

<p align=center><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2daba67892844cb1ac369536e4ba942a~tplv-k3u1fbpfcp-watermark.image?" alt="image.png" width="50%" /></p>

上面的完整代码可以在我的项目 [FunnySaltyFish/JetpackComposeStudy: 本人 Jetpack Compose 主题文章所包含的示例，包括自定义布局、部分组件用法等](https://github.com/FunnySaltyFish/JetpackComposeStudy) 找到，也是乘此机会整理了下之前[文章](https://juejin.cn/column/7024350372680433672)出现的例子，方便查看

## 下拉刷新
### 使用
新增的 `Modifier.pullRefresh` 可以用于下拉刷新的实现。它的签名如下：
```kotlin
fun Modifier.pullRefresh(
    state: PullRefreshState,
    enabled: Boolean = true
) 
```
第一个参数用于存储下拉的进度，第二个代表是否启用。相关联的这个 `State` 自然也有对应的 `remember` 方法用于创建
```
/**
 * 创建一个被 remember 的[PullRefreshState
 *
 * 对 [refreshing] 的更改会更新 [PullRefreshState].
 *
 * @sample androidx.compose.material.samples.PullRefreshSample
 *
 * @param refreshing 布尔值，代表当前是否正在刷新
 * @param onRefresh 刷新时的回调
 * @param refreshThreshold 若超过此阈值，则放手后会触发 [onRefresh]
 * @param refreshingOffset 刷新时指示器的底部位置
 */
@Composable
@ExperimentalMaterialApi
fun rememberPullRefreshState(
    refreshing: Boolean,
    onRefresh: () -> Unit,
    refreshThreshold: Dp = PullRefreshDefaults.RefreshThreshold, // 80.dp
    refreshingOffset: Dp = PullRefreshDefaults.RefreshingOffset, // 56.dp
): PullRefreshState
```

综合使用，示例代码如下
```
@OptIn(ExperimentalMaterialApi::class)
@Composable
fun SwipeToRefreshTest(
    modifier: Modifier = Modifier
) {
    val list = remember {
        List(4){ "Item $it" }.toMutableStateList()
    }
    var refreshing by remember {
        mutableStateOf(false)
    }
    // 用协程模拟一个耗时加载
    val scope = rememberCoroutineScope()
    val state = rememberPullRefreshState(refreshing = refreshing, onRefresh = {     
        scope.launch {
            refreshing = true
            delay(1000) // 模拟数据加载
            list+="Item ${list.size+1}"
            refreshing = false
        }
    })
    Box(modifier = modifier
        .fillMaxSize()
        .pullRefresh(state)
    ){
        LazyColumn(Modifier.fillMaxWidth()){
            // ...
        }
        PullRefreshIndicator(refreshing, state, Modifier.align(Alignment.TopCenter))
    }
}
```

<p align=center><img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7deee01eacec48839e6ac5ef35b0ba9d~tplv-k3u1fbpfcp-watermark.image?" alt="下拉刷新效果.gif" width="50%" /></p>

上面的代码并不难理解，用 `modifier.pullRefresh` 将下拉的相关数值存在 `state` 中，之后 `PullRefreshIndicator` 再使用就行了。二者用 `Box` 堆叠。

### 实现原理
这个控件的源代码也异常简单，最终是基于 `nestedScrollConnection`（嵌套滑动）实现的
```
@ExperimentalMaterialApi
fun Modifier.pullRefresh(
    onPull: (pullDelta: Float) -> Float,
    onRelease: suspend (flingVelocity: Float) -> Unit,
    enabled: Boolean = true
) = Modifier.nestedScroll(PullRefreshNestedScrollConnection(onPull, onRelease, enabled))

```
关于嵌套滑动，`RugerMc` 佬在很早前就写过文章，可以前往 [嵌套滑动（NestedScroll） | 你好 Compose ](https://jetpackcompose.cn/docs/design/gesture/nestedScroll) 阅读。这篇文章里也实现了下拉刷新，并给出了伸缩 `ToolBar` 的实现。  
如果你懒得跳过去，简而言之，通过 `NestedScrollConnection` ，我们可以在滑动开始前/后拿到当前的偏移量、速度等信息，按情况提前消费或放着不管他。针对下拉刷新的情况，我们主要干这两件事：
>1.  当我们手指向下滑时，我们希望滑动手势首先交给子布局中的列表进行处理，如果列表已经滑到顶部说明此时滑动手势事件没有被消费，此时再交由父布局进行消费。父布局可以消费列表消费剩下的滑动手势事件（为加载动画增加偏移）。
>2.  当我们手指向上滑时，我们希望滑动手势首先被父布局消费（为加载动画减小偏移），如果加载动画本身仍未出现时，则不进行消费。然后将剩下的滑动手势交给子布局列表进行消费。

实现起来并不难
```
private class PullRefreshNestedScrollConnection(
    private val onPull: (pullDelta: Float) -> Float,
    private val onRelease: suspend (flingVelocity: Float) -> Unit,
    private val enabled: Boolean
) : NestedScrollConnection {

    override fun onPreScroll(
        available: Offset,
        source: NestedScrollSource
    ): Offset = when {
        !enabled -> Offset.Zero
        // 向上滑动，父布局先处理（收回偏移），走 onPull 回调，并根据处理结果返回被消费掉的 Offset
        source == Drag && available.y < 0 -> Offset(0f, onPull(available.y)) // Swiping up
        else -> Offset.Zero
    }

    override fun onPostScroll(
        consumed: Offset,
        available: Offset,
        source: NestedScrollSource
    ): Offset = when {
        !enabled -> Offset.Zero
        // 向下滑动，如果子布局处理完了还有剩余（拉到顶了还往下拉），就展示偏移
        source == Drag && available.y > 0 -> Offset(0f, onPull(available.y)) // Pulling down
        else -> Offset.Zero
    }

    override suspend fun onPreFling(available: Velocity): Velocity {
        onRelease(available.y)
        return Velocity.Zero
    }
}
```


## DrawScope.drawText 
先前 Compose 的 Canvas 内部，如果需要画文字，就需要 `canvas.nativeCanvas` 先获取到原生的 `android.graphics.Canvas` 再调用对应方法。现在终于有 `drawText` 方法了。  
目前给出了两种共四个 API （分别对应 textLayoutResult 和 textMeasurer 两类参数）

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/91109fb483e94e6aaeca39cea9dd5374~tplv-k3u1fbpfcp-watermark.image?)

接下来让我们尝试使用一下，先试试 `textMeasurer` 参数的
```kotlin
@OptIn(ExperimentalTextApi::class)
@Composable
fun DrawTextTest() {
    val textMeasurer = rememberTextMeasurer(cacheSize = 8)
    Canvas(modifier = Modifier.fillMaxSize()){
        drawText(textMeasurer, "Hello World\n This is a simple text", style = TextStyle(color = Color.Black))
    }
}
```
效果很直接

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/653ea82188be453ebcdf5ec3ded70692~tplv-k3u1fbpfcp-watermark.image?)

读名称可以知道，`TextMeasurer` 负责对文本进行测量，此类的注释大致如下：
> TextMeasurer负责测量整个文本，以便准备绘制。  
应通过 `androidx.compose.ui.rememberTextMeasurer` 在 @Composable 中创建 TextMeasurer 实例，以便从 Composable 上下文中接收到默认值    
文本布局是一项计算成本高昂的任务。因此，该类使用内部的 LRU 缓存保存 layout 输入和输出对，以优化使用相同输入参数时的重复调用。  
尽管大多数输入参数对布局有直接影响，但部分可以在布局过程中被忽略，如颜色、笔刷和阴影，并在最后进行设置。将 TextMeasurer 与适当的 cacheSize 一起使用，在为不影响布局的属性（如颜色）设置动画时，应该会有显著的改进。  
此外，如果需要呈现多个静态文本，您可以按cacheSize提供文本的数量，并缓存它们的layout以供重复调用。请注意，即使对输入参数（如fontSize、maxLines、文本中的一个附加字符）进行轻微更改，也会创建一组不同的输入参数。这将计算新的layout，并将一组新的输入和输出对放置在 LRU 缓存中。旧结果可能会被遗弃。  
……

读读注释，能感觉到这个类存在的意义：**测量文本并做适当的缓存**。那么测量出来的结果自然就是 `TextLayoutResult` 了。事实上，`textMeasurer` 参数对应的函数内部就是帮忙测量了下，得到 `textLayoutResult` 再绘制。
```
@ExperimentalTextApi
fun DrawScope.drawText(
    textMeasurer: TextMeasurer,
    text: String,
    topLeft: Offset = Offset.Zero,
    ...
) {
    val textLayoutResult = textMeasurer.measure(
        text = AnnotatedString(text),
        style = style,
        ...
    )

    withTransform({
        translate(topLeft.x, topLeft.y)
        clip(textLayoutResult)
    }) {
        textLayoutResult.multiParagraph.paint(drawContext.canvas)
    }
}
```

因此，对于复杂的绘制，我们可以先手动测量得到结果后，再根据需要做相关绘制，以实现花里胡哨的效果。[`Halifax`](https://juejin.cn/user/8451824316670) 佬在[Compose把Text组件玩出新高度](https://juejin.cn/post/7140529542665338910#heading-0) 做了大量骚操作，我就不赘述了。

## 参考
- [Android Developers Blog: What’s new in Jetpack Compose (googleblog.com)](https://android-developers.googleblog.com/2022/10/whats-new-in-jetpack-compose.html)
- 其余链接文中已给出

本文涉及到的代码见 [FunnySaltyFish/JetpackComposeStudy: 本人 Jetpack Compose 主题文章所包含的示例，包括自定义布局、部分组件用法等](https://github.com/FunnySaltyFish/JetpackComposeStudy)
