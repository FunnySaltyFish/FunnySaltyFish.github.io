---
title: 深入Jetpack Compose——布局原理与自定义布局（四）
date: 2022-03-10 11:47:16
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

上一篇[文章](https://juejin.cn/post/7068164264363556872)，我们接触了固有特性测量。这一篇，我们将探索`ParentData`

### ParentData

#### 曾经的例子

让我们回忆一下第一篇文章中提到的例子，为了实现如下效果

![左上角的圆角是屏幕边缘](https://web.funnysaltyfish.fun/temp_img/202202121752667.png)

我们当时使用了这样一串修饰符：

```kotlin
Box(modifier = Modifier
            .fillMaxSize()
            .wrapContentSize(align = Alignment.Center)
            .size(50.dp)
            .background(Color.Blue))
```

也就是说，子微件的居中是它自己的`wrapContentSize(align = Alignment.Center)`调整的结果。那么，如果我们现在知道了子微件（小的蓝色方块）被包裹在另一个方块（Box）里，我们能不能让父布局帮忙确定居中位置呢？

答案是可以的！`Box` 在其`content`作用域中提供了`align` 方法，这可以让**子微件自行告知父布局：我需要居中**

```kotlin
@Composable
inline fun Box(
    modifier: Modifier = Modifier,
    // content 提供了 BoxScope
    content: @Composable BoxScope.() -> Unit
) {
    val measurePolicy = rememberBoxMeasurePolicy(contentAlignment, propagateMinConstraints)
    Layout(
        content = { BoxScopeInstance.content() },
        measurePolicy = measurePolicy,
        modifier = modifier
    )
}
```

而 `BoxScope`的源码如下：

```kotlin
@Immutable
interface BoxScope {
    @Stable
    fun Modifier.align(alignment: Alignment): Modifier

    @Stable
    fun Modifier.matchParentSize(): Modifier
}
```

作为接口，在此作用域中，子微件就可以调用`align`告诉父微件自己的align方式了

所以上面的效果这可以这样实现：

```kotlin
@Composable
fun ModifierSample2() {
    // 父元素
    Box(modifier = Modifier
        .width(200.dp)
        .height(300.dp)
        .background(Color.Yellow)){
        // 子元素
        Box(modifier = Modifier
            .align(Alignment.Center)
            .size(50.dp)
            .background(Color.Blue))
    }
}
```

效果是一样的

不像我们之前看到的`布局修饰符`，align是`父级数据修饰符`。本质上，这类由子微件向父布局通信就是由`parentData`实现的。如上面的`align`最终会涉及到如下代码：

```kotlin
override val parentData: Any?
        get() = with(modifier) {
            /**
             * ParentData provided through the parentData node will override the data provided
             * through a modifier
             */
            layoutNode.measureScope.modifyParentData(wrapped.parentData)
        }
```

#### 源码

`ParentDataModifier`源码如下：

```kotlin
/**
 * 一个修饰符[Modifier]，为父布局[Layout]提供数据. 
 * 可在[Layout]的 measurement 和 positioning 过程中通过 [IntrinsicMeasurable.parentData] 读取到.
 * parent data 通常被用于告诉父布局：子微件应该如何测量和定位
 */
interface ParentDataModifier : Modifier.Element {
    /**
     * Provides a parentData, given the [parentData] already provided through the modifier's chain.
     */
    fun Density.modifyParentData(parentData: Any?): Any?
}
```



#### 尝试用用：咸鱼的“地摊”

接下来我们尝试用用它。我们来假想这样一个布局：`小咸鱼的地摊`

- “地摊”里面有一些微件，它们一个一个纵向排列

- 每个子微件都是“付费”的，比如某一个`Box`“售价”100，另一个`Box`“售价”200……以此类推
- 每个子微件会显示自己的价格，而“地摊”会显示总价钱

上述描述换成代码的话就是：每一个子微件通过自定义的`Modifier`定义自身的价格，并把它传递给父布局，父布局计算所有的价格累积在一起，并显示出来。

开始写代码吧。我们先定义一个类，继承自`ParentDataModifier`

```kotlin
// 作者 FunnySaltyFish (http://funnysaltyfish.fun)
class CountNumParentData(var countNum: Int) : ParentDataModifier {
    override fun Density.modifyParentData(parentData: Any?) = this@CountNumParentData
}
```

（为了简单起见，我们将`modifyParentData`这个方法直接返回自身了。在原版`Column`的实现中，这个方法实际类似这样：

```kotlin
override fun Density.modifyParentData(parentData: Any?) =
    ((parentData as? RowColumnParentData) ?: RowColumnParentData()).also {
        it.weight = weight
        it.fill = fill
    }
```

）

然后我们编写一个简单的`Modifier`，返回一个实例

```kotlin
fun Modifier.count(num: Int) = this.then(
        // 这部分是 父级数据修饰符
        CountNumParentData(num)
    )
```

接下来我们复用一下之前的`VerticalLayout`，只不过在里面读取一下`ParentData`而已，部分代码如下

```kotlin
var num = 0
Layout(
    modifier = modifier,
    content = content
) { measurables: List<Measurable>, constraints: Constraints ->
    val placeables = measurables.map {
        if (it.parentData is CountNumParentData) {
            num += (it.parentData as CountNumParentData).countNum
        }
        it.measure(constraints)
    }
    // 省略布局的其他代码
    Log.d(TAG, "CountChildrenNumber: 总价格是：$num")
}
```

最后运行一下这个例子

```kotlin
@Composable
fun CountNumTest() {
    CountChildrenNumber {
        repeat(5) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(randomColor())
                    .count(Random.nextInt(30, 100))
            )
        }
    }
}
```

![image-20220307160129098](https://web.funnysaltyfish.fun/temp_img/202203071601534.png)



对应的总价格输出如下：

![image-20220307160211472](https://web.funnysaltyfish.fun/temp_img/202203071602599.png)

你可能注意到了，上面的Box里面还用文字指明了自己的“售价”，但调用的代码却没用到`Text`。这里的文本又是怎么画的呢？

答案就是刚刚的`count`Modifier，除了作为`父级数据修饰符`外，它还发挥了修饰自身的作用。它的代码完整如下：

```kotlin
fun Modifier.count(num: Int) = this.drawWithContent {
        drawIntoCanvas { canvas ->
            val paint = android.graphics
                .Paint()
                .apply {
                    textSize = 40F
                }
            canvas.nativeCanvas.drawText(num.toString(), 0F, 40F, paint)
        }
        // 绘制 Box 自身内容
        drawContent()
    }
    .then(
        // 这部分是 父级数据修饰符
        CountNumParentData(num)
    )
```

这里用到了绘制时的部分内容，如果你感兴趣的话，后面我还可能介绍一下自定义绘制。嗯，挖了个坑，之后再填吧~

`ParentData`的实际场景主要集中在父布局对子微件的特殊位置和大小的控制上，比如`Box`的`align`，`Column`和`Row`的`align`、`alignBy`、`weight`上。接下来我们来实现一个简化版的`weight`吧

#### 尝试用用：实现简易版weight

为了简易起见，我们实现的`weight`有如下限制：

- 所有子微件都有weight，按比例实现高度分配
- 父布局的宽高是确定的

所以代码的逻辑就是：读取所有`weight`，按比例分配高度就行。

首先类似于`Box`，我们也写一个`VerticalScope`，让我们自定义的weight只能在自定义的布局中使用

```kotlin
interface VerticalScope {
    @Stable
    fun Modifier.weight(weight: Float) : Modifier
}
```

然后再自定义我们的`ParentDataModifier`

```kotlin
class WeightParentData(val weight: Float=0f) : ParentDataModifier {
    override fun Density.modifyParentData(parentData: Any?) = this@WeightParentData
}
```

写一个object，让它实现我们的`VerticalScope`

```kotlin
object VerticalScopeInstance : VerticalScope {
    @Stable
    override fun Modifier.weight(weight: Float): Modifier = this.then(
        WeightParentData(weight)
    )
}
```

接下来，就是具体的`Composable`实现了。注意，在此处，我们的`content`需要加上`VerticalScope.`

```kotlin
@Composable
fun WeightedVerticalLayout(
    modifier: Modifier = Modifier,
    content: @Composable VerticalScope.() -> Unit
)
```

具体实现类似于之前的`VerticalLayout`，不同之处在于我们要获取到各个`WeightParentData`的值并保存下来，计算总的weight。这样就可以按比例分配高度了。

关键代码如下：

```kotlin
val measurePolicy = MeasurePolicy { measurables, constraints ->
    val placeables = measurables.map {it.measure(constraints)}
    // 获取各weight值
    val weights = measurables.map {
        (it.parentData as WeightParentData).weight
    }
    val totalHeight = constraints.maxHeight
    val totalWeight = weights.sum()
    // 宽度：最宽的一项
    val width = placeables.maxOf { it.width }

    layout(width, totalHeight) {
        var y = 0
        placeables.forEachIndexed() { i, placeable ->
            placeable.placeRelative(0, y)
            // 按比例设置大小
            y += (totalHeight * weights[i] / totalWeight).toInt()
        }
    }
}
Layout(modifier = modifier, content = { VerticalScopeInstance.content() }, measurePolicy=measurePolicy)
```

测试一下？我们预备让三个Box按`1:2:7`的高度显示

```kotlin
WeightedVerticalLayout(Modifier.padding(16.dp).height(200.dp)) {
    Box(modifier = Modifier.width(40.dp).weight(1f).background(randomColor()))
    Box(modifier = Modifier.width(40.dp).weight(2f).background(randomColor()))
    Box(modifier = Modifier.width(40.dp).weight(7f).background(randomColor()))
}
```

最终效果如下，可以看到，三个Box正确按照`1:2:7`的比例显示高度

![image-20220310111258869](https://web.funnysaltyfish.fun/temp_img/202203101113984.png)

成功！



### 后续

关于ParentData我们就先看这些。下一篇，我们……等我想想要写啥

本文参考：

- [JetPack Compose 手写一个 Row 布局 | 自定义布局 - 掘金 (juejin.cn)](https://juejin.cn/post/6964010073576177671)
- Android官方视频：[Deep dive into Jetpack Compose layouts](https://www.youtube.com/watch?v=zMKMwh9gZuI)

本文所有代码见：[此处](https://github.com/FunnySaltyFish/JetpackComposeStudy/tree/master/app/src/main/java/com/funny/compose/study/ui/post_layout)，欢迎star~