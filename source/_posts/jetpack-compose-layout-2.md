---
title: 深入Jetpack Compose——布局原理与自定义布局（二）
date: 2022-02-12 21:36:16
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

在上一篇文章[深入Jetpack Compose——布局原理与自定义布局（一） - 掘金 (juejin.cn)](https://juejin.cn/post/7063451846861406245) 中，我们大致了解了Layout过程并简单实现了两个自定义布局。本次让我们将目光转向Modifier和固有特性测量

本文部分参考自Android官方视频：[Deep dive into Jetpack Compose layouts](https://www.youtube.com/watch?v=zMKMwh9gZuI)

### Modifier

#### 本质

关于Modifier的本质，`RugerMc`大佬在[图解 Modifier 实现原理 ，竟然如此简单](https://juejin.cn/post/6986933061845778446)这篇文章中已经解释地非常清楚了，我就不画蛇添足了。不过为了后续行文方便，我还是在此简单说几点：

1. Modifier 是个接口，包含三个直接实现类或接口：`伴生对象 Modifier`、内部子接口`Modifier.Element`和`CombinedModifier`。
2. `伴生对象Modifier`是日常使用最多的，后面两者均为内部实现，实际开发中无需关注
3. `Modifier.xxx()`方法实际上会创建一个`Modifier`接口的实现类的实例。如`Modifier.size()`会创建`SizeModifer`实例

```kotlin
@Stable
fun Modifier.size(size: Dp) = this.then(
    SizeModifier(
        /*省略具体细节*/
    )
)
```

4. `Modifier.xxx().yyy().zzz()`实际上会创建一个Modifier链，内部顺序遵循 xxx -> yyy -> zzz ，由`CombinedModifier`连接。`Modifie接口`提供了`foldIn`/`foldOut`方法允许我们`顺序`/`逆序`遍历到每个Modifier

   这里借上面文章中的一张图来说明：

   ![来源见水印，侵删](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/aa50641cb3364416958bf33aa848bbf4~tplv-k3u1fbpfcp-watermark.awebp)

我们可以简单遍历一下看看，对于下面的例子：

```kotlin
@Composable
fun TraverseModifier() {
    val modifier = Modifier
        .size(40.dp)
        .background(Color.Gray)
        .clip(CircleShape)
    LaunchedEffect(modifier){
        // 顺序遍历Modifier
        modifier.foldIn(0){ index , element : Modifier.Element ->
            Log.d(TAG, "$index -> $element")
            index + 1
        }
    }
}
```

它的输出为：

```bash
0 -> androidx.compose.foundation.layout.SizeModifier@78000000
1 -> Background(color=Color(...), brush=null, alpha = 1.0, shape=RectangleShape)
2 -> SimpleGraphicsLayerModifier(...)
```



#### 作用

接下来，我们看看Modifier是怎么在布局中起作用的

先看一个例子

```kotlin
@Composable
fun ModifierSample1() {
    // 父元素
    Box(modifier = Modifier
        .width(200.dp)
        .height(300.dp)
        .background(Color.Yellow)){
        // 子元素
        Box(modifier = Modifier
            .fillMaxSize()
            .wrapContentSize(align = Alignment.Center)
            .size(50.dp)
            .background(Color.Blue))
    }
}
```

它实际显示的效果如下

![左上角的圆角是屏幕边缘](https://web.funnysaltyfish.fun/temp_img/202202121752667.png)

<center><small>（左上角的圆角是屏幕边缘）</small></center>

我们来逐步看看这到底是怎么发生的。这里我们选择子元素，也就是那个小一点的蓝色Box，来看看它的**measure**和**place**过程。

首先是**measure**。父元素明确了自身大小为200*300，该大小也就是子元素能占据的最大空间。因此

1. 初始：初始约束 **w:0-200, h:0-300**
2. fillMaxSize()：占据最大空间，约束的`min`值更改为与`max`相同，即 **w:200-200, h:300-300**
3. wrapContentSize()：适应内容大小，约束的`min`值重新变回了0，即 **w:0-200, h:0-300**

4. size()：指定了精准大小。约束变为 **w:50-50, h:50-50**
5. background()：对大小约束无影响

最后，在`Modifier`的一顿操作之下，Box会收到一个 **w:50-50, h:50-50** 的约束。到这里走过的状态如下：

![image-20220212180649407](https://web.funnysaltyfish.fun/temp_img/202202121806531.png)

接下来，Box内部的`Layout`微件执行**measure**方法得到了自己的大小：**50*50**。这个大小**反向传回到Modifier链的最后一项，并开始place**。接下来：

1. background()：此处略过
2. size(50.dp)：测得自己的大小：50*50，并据此创建自己的位置指令
3. wrapContentSize()：测得自己的大小：200*300，并知道自己的子元素大小50\*50，且居中放置。据此创建自己的位置指令。
4. fillMaxSize()：解析自己的大小和位置

这个过程很类似于`Layout`微件，区别就是**每个Modifier只有一个子元素**（也就是Modifier链上的下一个元素）。事实上，如果看代码，你也很容易感受到二者的相似之处

拿`wrapContentSize`修饰符的代码举例，其实现类`WrapContentModifier`的`measure`方法如下

```kotlin
fun MeasureScope.measure(
    measurable: Measurable,
    constraints: Constraints
): MeasureResult {
    // 设置约束
    val wrappedConstraints = Constraints(/**/)
    // 测量得到可放置项
    val placeable = measurable.measure(wrappedConstraints)
    val wrapperWidth = placeable.width.coerceIn(constraints.minWidth, constraints.maxWidth)
    val wrapperHeight = placeable.height.coerceIn(constraints.minHeight, constraints.maxHeight)
    // layout函数放置到指定位置并返回结果
    return layout(
        wrapperWidth,
        wrapperHeight
    ) {
        val position = alignmentCallback(
            IntSize(wrapperWidth - placeable.width, wrapperHeight - placeable.height),
            layoutDirection
        )
        placeable.place(position)
    }
}
```

怎么样，是不是很相似？

### 后续

关于Modifier我们就先看这些。下一篇，我们将接触`固有特性测量`这一特性，并改进我们在第一篇文章中实现的纵向布局。

本文所有代码见：[此处](https://github.com/FunnySaltyFish/JetpackComposeStudy/tree/master/app/src/main/java/com/funny/compose/study/ui/post_layout)



