---
title: 入坑 Jetpack Compose ：写一个简单的计算器
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2023-01-08 13:29:37
---

> 本文是一个综合的Compose小例子，涉及动画、自定义布局、列表等主题。本文并非教程，只是展示展示Compose开发应用是什么感觉，并试图拉人入坑。如果你还没接触过，不妨进来扫一扫代码，读一读单词，感受感受~  
> 本文所展示的思路仅为个人想法，并不代表最优解，也欢迎一起探讨

## 前言

8月份的时候，我关注了 fundroid 大佬的公众号，看到历史推文中有[这么一篇](https://mp.weixin.qq.com/s/D--utSqNksFhhEXrDT1S_w)，内容是Compose学习挑战赛，要求为“**实现一个计算器 App**”。正好自己对Compose有过一点经验 *（这个可以点开头像看[历史文章](https://juejin.cn/user/2673613109214333/posts)）*，抱着试试看的态度，我花大概**4-5h**完成并提交了作品。  
尽管作品比较简单，但结果还是~~不错的~~（*补充：看了看评论区大佬的图，发现这是个参与纪念奖 hhh）*：几天前，我收到了Google发来的这封邮件：

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9d1cdc9e46224a0a818fd5c9878c6e88~tplv-k3u1fbpfcp-watermark.image?)

~~既然文章都写完了，那还是厚着脸皮留着吧~~  
所以就简单介绍下吧，或许也可以当做非常入门的小案例，说不定能帮到些人、拉入点坑。  
本文源码地址见文末


## 效果

![Screenrecorder.gif](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7acc12aec6de445caeaa6cfb964ee5e2~tplv-k3u1fbpfcp-watermark.image?)  
可以看到，尽管开发的时间并不长，但是基本的小功能也还是有的。计算的时候也会有点简单的小动画，还适配了横屏的布局。  
顺带一提，由于Compose天然的特性，项目还自动适配了深色模式，如下：

![Screenshot.jpg](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/72c21e9403cb4c7693a0d65c3061c804~tplv-k3u1fbpfcp-watermark.image?)

## 实现
以竖屏的布局为例，它主要包括这几个部分

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7fbd6075d66f4ef098893381808316f1~tplv-k3u1fbpfcp-watermark.image?)

或许我们可以分别叫它们：**历史记录区、表达式区和输入区**

### 输入区  
之所以先看输入区，是因为这是页面的主体部分。从布局来看，整体为均匀的**网格状**。在Compose中，想实现这样的网格布局也有几种选择，比如使用Lazy系列的`LazyGrid`（可以参考我的 [Jetpack Compose LazyGrid使用全解](https://juejin.cn/post/7100120556192104484)）。不过，某种程度上，出于教程的目的，我在这里用的是`自定义布局+For循环`。  

#### 自定义布局？
你可能比较疑惑：这里为啥需要自定义布局？这就要从我自己的数据结构说起了。为了表示按键的布局，我用了个`二维字符数据`
```Kotlin
val symbols = arrayOf(
    charArrayOf('C','(',')','/'),
    charArrayOf('7','8','9','*'),
    charArrayOf('4','5','6','-'),
    charArrayOf('1','2','3','+'),
    charArrayOf('⌫','0','.','=')
)
```
我希望的效果是呢，每个按键都是**正方形**，因此，输入区的**长宽比**需要和**二维数组的行列比**一致。也就是，竖屏的时候**宽度固定，计算高度**；横屏则反过来。  
整个输入区由一个`Box`包裹，因此只需要动态调整它自己的宽高即可。因此，此处使用`Modifier.layout`修饰自己。代码如下：
```kotlin
// 每个正方形的宽度
var l by remember {
    mutableStateOf(0)
}
Box(
    modifier
        .layout { measurable, constraints ->
            val w: Int
            val h: Int
            if (isVertical) {
                // 竖屏的时候宽度固定，计算高度
                w = constraints.maxWidth
                l = w / symbols[0].size
                h = l * symbols.size
            } else {
                // 横屏的时候高度固定，计算宽度
                h = constraints.maxHeight
                l = h / symbols.size
                w = l * symbols[0].size
            }
            val placeable = measurable.measure(
                constraints.copy(
                    minWidth = w, // 宽度最大最小值相同，即为确定值
                    maxWidth = w,
                    minHeight = h, // 高度也是
                    maxHeight = h
                )
            )
            // 调用 layout 摆放自己
            layout(w, h) {
                placeable.placeRelative(0, 0)
            }
        }) {
    /*省略Childen，见下文*/
}
```
如果你没有接触过自定义布局，可以参考如下文章：
- [深入Jetpack Compose——布局原理与自定义布局（一） - 掘金 (juejin.cn)](https://juejin.cn/post/7063451846861406245)
- [深入Jetpack Compose——布局原理与自定义布局（二） - 掘金 (juejin.cn)](https://juejin.cn/post/7063816490021027871)
- [深入Jetpack Compose——布局原理与自定义布局（三） - 掘金 (juejin.cn)](https://juejin.cn/post/7068164264363556872)
- [深入Jetpack Compose——布局原理与自定义布局（四）ParentData - 掘金 (juejin.cn)](https://juejin.cn/post/7073307559792214024)

回到文章，上面已经正确的设置了`Box`的大小，接下来往里面放内容就好。在这里就是简单的**双重for循环**：

```Kotlin
symbols.forEachIndexed { i, array ->
    array.forEachIndexed { j, char ->
        Box(modifier = Modifier
            .offset { IntOffset(j * l, i * l) }
            .size(with(LocalDensity.current) { l.toDp() })
            .padding(16.dp)
            .clickable {
                vm.click(char)
            }) {
            Text(modifier = Modifier.align(Alignment.Center), text = char.toString(), fontSize = 24.sp, color = contentColorFor(backgroundColor = MaterialTheme.colors.background))
        }
    }
}
```
`Box`类似于`View`，是最基本的`@Composable`。在Compose中，各`Composable`的样式由`Modifier`修饰，以链式调用的方式设置。此处使用`.size`修饰符确定了每个按键的大小，`offset`确定了它们的位置（偏移）。这里有趣的地方是，因为`padding`先于`clickable`设置，所以点击的波纹是在`padding`区域内的（这是我希望的效果，不然有点丑）。这也是初学者需要注意的一点：**Modifier的顺序很重要**


### 表达式区域
这个区域很简单，有趣的地方在于，它是有动画的。实现这样的效果或许在`xml`里略显繁琐，但在`Compose`里却相当简单
```kotlin
@Composable
fun CalcText(
    modifier: Modifier,
    formulaTextProvider: () -> String,
    resultTextProvider: () -> String,
) {
    val animSpec = remember {
        TweenSpec<Float>(500)
    }
    Column(modifier = modifier, horizontalAlignment = Alignment.End, verticalArrangement = Arrangement.Bottom) {
        val progressAnim = remember {
            Animatable(1f, 1f)
        } // 进度，1为仅有算式，0为结果
        val progress by remember { derivedStateOf { progressAnim.value } }
        // 根据 progress 的值计算字体大小
        Text(text = formulaTextProvider(), fontSize = (18 + 18 * progress).sp, ...)

        val resultText = resultTextProvider()
        // 根据 progress 的值计算字体大小（与上面那个变化方向相反）
        if (resultText != "") {
            Text(text = resultText, (36 - 18 * progress).sp, ...)
        }

        LaunchedEffect(resultText) {
            if (resultText != "") progressAnim.animateTo(0f, animationSpec = animSpec)
            else progressAnim.animateTo(1f, animationSpec = animSpec)
        }
    }
}
```
对，就这么点！这里的整体思路是，用`Column`（纵向布局）放置两个`Text`，并在`resultText`（也就是计算结果）改变时执行动画，改变二者的字体大小。  
这样的过程类似于`View`体系下的`属性动画`，但在Compose声明式 `UI=f(State)` 的理念下，写出的代码更自然。这或许是Compose开发上的另一有趣之处。

### 历史记录区
这个区域就更简单了，就是个列表呗。对于`View`用户，这时候就要开始`建xml、写ViewHolder、设置Adapter`一条龙了。但在`Compose`下，一切只需要交给`LazyColumn`
```kotlin
LazyColumn(modifier, state = listState) {
    items(vm.histories) { item ->
        Text(modifier = Modifier.fillMaxWidth(), text = item.toString())
    }
    item {
        Spacer(modifier = Modifier.height(16.dp))
    }
}
```
Compose的列表就是这么简单，不用花里胡哨，不用几个文件来回跳。告诉它**数据源**以及**每个item长什么样**就好。  
为了更好看一些，我还顺便给它加上了个Item进入动画：从右往左飞入。代码也很简单
```kotlin
items(vm.histories) { item ->
    // 偏移量
    val offset = remember { Animatable(100f) }
    LaunchedEffect(Unit) {
        offset.animateTo(0f)
    }
    Text(modifier = Modifier
        ...
        .offset { IntOffset(offset.value.toInt(), 0) }
        ...)
}
```

上面的代码里出现了不少`remember`，可以理解为“记住”。Compose的刷新类似于在重新调用函数，于是为了让某个值能被保存下来，就得放在`remember`里。 
`LaunchedEffect`则为副作用的一种，当首次进入`Composition`或括号里的值（key）改变时才执行里面的内容，在这里用于启动动画。

三个部分介绍完，接下来就是把它们合在一起啦


### 合在一起
竖屏状态下，合在一起似乎还有点困难：我们需要**先摆放底部的输入区**，等计算完它的宽高后，再在它上面放上历史记录和表达式。  
要解决这个问题也有挺多方法，比如`Column`+`weight`修饰符应该就可以。同样的，出于教程的目的，我这里还是换了个花里胡哨的做法：自定义布局。
```kotlin
/**
 * 纵向布局，先摆放Bottom再摆放，
 * @param modifier Modifier
 * @param bottom 底部的Composable，单个
 * @param other 在它上面的Composable，单个
 */
@Composable
fun SubcomposeBottomFirstLayout(modifier: Modifier, bottom: @Composable () -> Unit, other: @Composable () -> Unit) {
    SubcomposeLayout(modifier) { constraints: Constraints ->
        var bottomHeight = 0
        val bottomPlaceables = subcompose("bottom", bottom).map {
            val placeable = it.measure(constraints.copy(minWidth = 0, minHeight = 0))
            bottomHeight = placeable.height
            placeable
        }
        // 计算完底部的高度后把剩余空间给other
        val h = constraints.maxHeight - bottomHeight
        val otherPlaceables = subcompose("other", other).map {
            it.measure(constraints.copy(minHeight = 0, maxHeight = h))
        }

        layout(constraints.maxWidth, constraints.maxHeight) {
            // 底部的从 h 的高度开始放置
            bottomPlaceables[0].placeRelative(0, h)
            otherPlaceables[0].placeRelative(0, 0)
        }
    }
}
```
代码中使用到了`SubcomposeLayout`，可以参考`ComposeMuseum`的教程：[SubcomposeLayout | 你好 Compose (jetpackcompose.cn)](https://jetpackcompose.cn/docs/layout/subcomposelayout)

### 计算
由于不是重点，所以本文直接跳过了。代码里直接使用的 [JarvisJin/fin-expr: A expression evaluator for Java. Focus on precision, can be used in financial system. (github.com)](https://github.com/JarvisJin/fin-expr) 。  
如果需要自己实现，可以参考`数据结构-栈`以及`BigDecimal`类

### 状态保存
为了实现横竖屏切换时的状态保存，数据放在了`ViewModel`里。在Compose中，使用`ViewModel`非常简单。只需要引入`androidx.activity:activity-compose:{version}`包并在`@Composable`中如下获得对应`ViewModel`：
```kotlin
val vm: CalcViewModel = viewModel()
```

## 其他
### 状态栏
如果你仔细观察，上面的图中，为了更好的沉浸式，是没有状态栏的。这是借助的[accompanist/systemuicontroller](https://github.com/google/accompanist/tree/main/systemuicontroller) 库。  
`accompanist`是Google官方提供的一系列Compose辅助`library`，帮助快速实现一些常用功能，比如`Pager`、`WebView`、`SwipeToRefresh`等。  
使用起来也很简单：
```kotlin
val systemUiController = rememberSystemUiController()
val isDark = isSystemInDarkTheme()
LaunchedEffect(systemUiController){
    systemUiController.isSystemBarsVisible = false
    // 设置状态栏颜色
    // systemUiController.setStatusBarColor(Color.Transparent, !isDark)
}
```

### 横竖屏判断
此处判断的依据非常简单：当前屏幕的“宽度”。通过最外层的`BoxWithConstraints`获取到的`constraints.maxWidth`做判断依据，代码如下：
```kotlin
BoxWithConstraints(
    Modifier
        .fillMaxSize()
        .background(MaterialTheme.colors.background)) { // 小于720dp当竖屏
    if (constraints.maxWidth / LocalDensity.current.density < 720) {
        CalcScreenVertical(modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 12.dp, vertical = 8.dp))
    } else { // 否则当横屏
        CalcScreenHorizontal(modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 12.dp, vertical = 8.dp))
    }
}
```
通过`if`语句就能展示不同的布局，这也是Compose声明式UI的有趣之处。


## 最后
本文代码：[FunnySaltyFish/ComposeCalculator: A Simple But Not Simple Calculator built by Jetpack Compose (github.com)](https://github.com/FunnySaltyFish/ComposeCalculator)  
（广告）我写的另一个更完整的项目：[FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件，支持多引擎、插件化~ | Jetpack Compose+MVVM+协程+Room (github.com)](https://github.com/FunnySaltyFish/FunnyTranslation)
