---
title: 深入Jetpack Compose——布局原理与自定义布局（三）
date: 2022-02-24 11:47:16
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

在上一篇[文章]([深入Jetpack Compose——布局原理与自定义布局（二）](https://juejin.cn/post/7063816490021027871))中，我们探索了`Modifier`的本质和原理。这一次我们看看Compose体系中的一个重要特性：`固有特性测量`。


## 固有特性测量

或许不少人已经知道，Compose为了提高测绘性能，强行规定了每个微件只能被测量一次。也就是说，我们不能写出类似下面这样的代码：

```kotlin
val placeables = measurables.map { it.measure(constrains) }
// 尝试测量第二次，直接报错
val placeablesSecond = measurables.map { it.measure(constrains) }
```

### 一个小问题

那么接下来我们看一个小例子。我们想实现一个菜单，菜单里面有几个菜单栏。于是我们写出了类似这样按的代码



![image-20220224133926999](https://web.funnysaltyfish.fun/temp_img/202202241339204.png)

但是效果不怎么样，因为每个`Text`的宽度不一样。看起来有点丑

![image-20220224134059328](https://web.funnysaltyfish.fun/temp_img/202202241340468.png)

你可能会说，要解决这个问题很简单，为每个`Text` 添加修饰符`fillMaxWidth`，让它占满即可。效果如下：

![image-20220224134220288](https://web.funnysaltyfish.fun/temp_img/202202241342424.png)

![image-20220224134255678](https://web.funnysaltyfish.fun/temp_img/202202241342785.png)

但是这样新的问题来了：由于每个`Text`的`Constraint`的`maxWidth`都是最大值，于是咱们的`Column`宽度也是最大值。于是这个菜单占满了全部屏幕空间。这可不妙！

要解决这个问题，我们只需要为`Column`添加这样一个修饰符

```kotlin
Modifier.width(IntrinsicSize.Max)
```

它的宽度就是子微件宽度的最大值啦

![image-20220224134901689](https://web.funnysaltyfish.fun/temp_img/202202241349842.png)

有`Max`应该就有`Min`，咱们试试？

![image-20220224135116580](https://web.funnysaltyfish.fun/temp_img/202202241351729.png)

宽度变窄了！很神奇吗？这就是固有特性测量的功劳。

*（如果你好奇为什么最小宽度是这个，因为子微件是文本，而文本的最小宽度是它每行能容纳一个词时的宽度。在这个例子中，就是Send Feedback分成 Send \n Feedback时Feedback这行字的宽度）*



上面的例子中，`Column`就适配了固有特性测量这一特性。接下来，我们把自己的实现的`VerticalLayout`也来适应一下（VerticalLayout具体实现见第一篇）。



### 适配固有特性测量

让我们重新把目光转向`Layout`

```kotlin
@Composable inline fun Layout(
    content: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    measurePolicy: MeasurePolicy
)
```

之前对于第三个参数，我们是写成了SAM的形式。我们现在再来看看这个`MeasurePolicy`

```kotlin
@Stable
fun interface MeasurePolicy {
    fun MeasureScope.measure(
        measurables: List<Measurable>,
        constraints: Constraints
    ): MeasureResult

    /**
     * The function used to calculate [IntrinsicMeasurable.minIntrinsicWidth]. It represents
     * the minimum width this layout can take, given a specific height, such that the content
     * of the layout can be painted correctly.
     */
    fun IntrinsicMeasureScope.minIntrinsicWidth(
        measurables: List<IntrinsicMeasurable>,
        height: Int
    ): Int

    fun IntrinsicMeasureScope.minIntrinsicHeight(
        measurables: List<IntrinsicMeasurable>,
        width: Int
    ): Int

    fun IntrinsicMeasureScope.maxIntrinsicWidth(
        measurables: List<IntrinsicMeasurable>,
        height: Int
    ): Int
    
    fun IntrinsicMeasureScope.maxIntrinsicHeight(
        measurables: List<IntrinsicMeasurable>,
        width: Int
    ): Int
}
```

`measure`方法是我们之前就用过的，而其余几个拓展函数就是我们要适配 `固有特性测量` 所需要重写的啦。举个栗子，使用 `Modifier.width(IntrinsicSize.Max)` ，则会调用 `maxIntrinsicWidth` 方法，其余同理。

接下来，咱们开干。先挑一个吧

```kotlin
override fun IntrinsicMeasureScope.maxIntrinsicWidth(
    measurables: List<IntrinsicMeasurable>,
    height: Int
): Int {
    TODO("Not yet implemented")
}
```

我们以子微件宽度的最大值作为最大约束

```kotlin
override fun IntrinsicMeasureScope.maxIntrinsicWidth(
    measurables: List<IntrinsicMeasurable>,
    height: Int
): Int {
    var width = 0
    measurables.forEach { 
        val childWidth = it.maxIntrinsicWidth(height)
        if(childWidth > width) width = childWidth
    }
    return width
}
```

效果如下：

![image-20220224143551073](https://web.funnysaltyfish.fun/temp_img/202202241435172.png)

<center>(宽度以单词 Funny 为标准)</center>

**min**的情况也差不多，效果如下：

![image-20220224143833653](https://web.funnysaltyfish.fun/temp_img/202202241438740.png)

<center>(宽度以单词 is 为标准)</center>



完整代码参见Github仓库



### 后续

关于固有特性测量我们就先看这些。下一篇，我们将探索`ParentData`和其它特性，继续我们的布局之旅

本文参考：

- [聊一聊Compose的固有特性测量Intrinsic - 掘金 (juejin.cn)](https://juejin.cn/post/6969021972051132452)
- Android官方视频：[Deep dive into Jetpack Compose layouts](https://www.youtube.com/watch?v=zMKMwh9gZuI)

本文所有代码见：[此处](https://github.com/FunnySaltyFish/JetpackComposeStudy/tree/master/app/src/main/java/com/funny/compose/study/ui/post_layout)

