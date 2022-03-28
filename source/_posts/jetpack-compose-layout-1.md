---
title: 深入Jetpack Compose——布局原理与自定义布局（一）
date: 2022-02-12 11:47:16
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

Jetpack Compose 正式版发布也已半年了，对我来说，应用到项目中也很久了<small>（参见本人开源项目：[译站](https://github.com/FunnySaltyFish/FunnyTranslation)）</small>。 目前很多文章还集中于初探上，因此萌生了写作本文的想法，算是为Compose中文资料提供绵薄之力。

本文的内容来自Android官方视频：[Deep dive into Jetpack Compose layouts](https://www.youtube.com/watch?v=zMKMwh9gZuI)



### 总览

Jetpack Compose 中，单个可组合项被显示出来，总体上经历三个过程

**Composition（组合） -> Layout（布局） -> Drawing（绘制）** ，其中Layout阶段又存在两个方面的内容：**Measure（测量） 和 Place（摆放）**

今天我们主要着眼于 Layout 阶段，看看各个 Composable 是如何正确确定各自位置和大小的



### Layout

Layout阶段主要做三件事情：

1. 测量所有子微件的大小
2. 确定自己的大小
3. 正确摆放所有子元素的位置



为简化说明，我们先给出一个简单例子。该例子中，所有元素只需要遍历一次。

如下图的 `SearchResult`微件，它的构成如下：

![image-20220211171231994](https://web.funnysaltyfish.fun/temp_img/202202111712123.png)



现在我们来看看Layout过程在这个例子中是什么情况

#### Measure

1. 请求测量根布局，即`Row`

<img src="https://web.funnysaltyfish.fun/temp_img/202202111715804.png" alt="image-20220211171509751" style="zoom:50%;" />

2. `Row`为了知道自己的大小，就得先知道自己的子微件有多大，于是请求`Image`和`Column`测量它们自己

   1. 对于`Image`，由于它内部没有其他微件，所以它可以完成自身测量过程并返回相关位置指令

   <img src="https://web.funnysaltyfish.fun/temp_img/202202111717527.png" alt="image-20220211171746467" style="zoom: 50%;" />

   2. 接下来是`Column`，因为它内部有两个`Text`，于是请求子微件测量。而对于`Text`，它们也会正确返回自己的大小和位置指令

   <img src="https://web.funnysaltyfish.fun/temp_img/202202111719907.png" alt="image-20220211171934824" style="zoom:50%;" />

   3. 这时 Column 大小和位置指令即可正确确定

3. 最后，`Row`内部所有测量完成，它可以正确获得自己的大小和位置指令

<img src="https://web.funnysaltyfish.fun/temp_img/202202111721514.png" alt="image-20220211172155426" style="zoom:50%;" />

测量阶段到此结束，接下来就是正确的摆放位置了



#### Place

完成测量后，微件就可以根据自身大小**从上至下**执行各子微件的位置指令，从而确定每个微件的正确位置

现在我们把目光转向Composition阶段。大家平时写微件，内部都是由很多更基本的微件组合而来的，而事实上，这些基本的微件还有更底层的组成部分。如果我们展开刚刚的那个例子，它就成了这个样子

<img src="https://web.funnysaltyfish.fun/temp_img/202202111728631.png" alt="image-20220211172838557" style="zoom:50%;" />

在这里，所有的叶节点<small>(即没有子元素的节点)</small>都是`Layout`这个微件

我们来看看这个微件吧



### Layout Composable

此微件的签名如下：

```kotlin
@Composable inline fun Layout(
    content: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    measurePolicy: MeasurePolicy
)
```

我们先看看第三个参数，这是之前从未见过的东西；而它恰恰控制着如何确定微件大小以及它们的摆放策略

那来写个例子吧。我们现在自定义一个简单的纵向布局，也就是低配版Column



#### 自定义布局 - 纵向布局

写个框架

```kotlin
fun VerticalLayout(
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    Layout(
        modifier = modifier,
        content = content
    ) { measurables: List<Measurable>, constrains: Constraints ->
        
    }
}
```

`Measurable`代表可测量的，其定义如下：

```kotlin
interface Measurable : IntrinsicMeasurable {
    /**
     * Measures the layout with [constraints], returning a [Placeable] layout that has its new
     * size. A [Measurable] can only be measured once inside a layout pass.
     */
    fun measure(constraints: Constraints): Placeable
}
```

可以看到，这是个接口，唯一的方法`measure`返回`Placeable`，接下来根据这个Placeable摆放位置。而参数measurables其实也就是传入的子微件形成的列表

而`Constraints`则描述了微件的大小策略，它的部分定义摘录如下：

<img src="https://web.funnysaltyfish.fun/temp_img/202202111748748.png" alt="image-20220211174814661" style="zoom:50%;" />

举个栗子，如果我们想让这个微件想多大就多大（类似match_parent），那我们可以这样写：

<img src="https://web.funnysaltyfish.fun/temp_img/202202111749649.png" alt="image-20220211174939592" style="zoom:50%;" />

如果它是固定大小（比如长宽50），那就是这样写

<img src="https://web.funnysaltyfish.fun/temp_img/202202111750399.png" alt="image-20220211175028341" style="zoom:50%;" />

接下来我们就先获取placeable吧

```kotlin
val placeables = measurables.map { it.measure(constrains) }
```

在这个简单的例子中，我们不对measure的过程进行过多干预，直接测完获得有大小的可放置项

接下来确定我们的`VerticalLayout`的宽、高。对于咱们的布局，它的宽应该容纳的下最宽的孩子，高应该是所有孩子之和。于是得到以下代码：

```kotlin
// 宽度：最宽的一项
val width = placeables.maxOf { it.width }
// 高度：所有子微件高度之和
val height = placeables.sumOf { it.height }
```

最后，我们调用`layout`方法返回最终的测量结果。前两个参数为自身的宽高，第三个lambda确定每个Placeable的位置

```kotlin
layout(width, height){
    var y = 0
    placeables.forEach {
        it.placeRelative(0, y)
        y += it.height
    }
}
```

这里用到了`Placeable.placeRelative`方法，它能够正确处理从右到左布局的镜像转换

一个简单的Column就写好了。试一下？

```kotlin
fun randomColor() = Color(Random.nextInt(255),Random.nextInt(255),Random.nextInt(255))

@Composable
fun CustomLayoutTest() {
    VerticalLayout() {
        (1..5).forEach {
            Box(modifier = Modifier.size(40.dp).background(randomColor()))
        }
    }
}
```

<img src="https://web.funnysaltyfish.fun/temp_img/202202111817149.png" alt="image-20220211181720062" style="zoom:50%;" />

嗯，工作基本正常。

接下来我们实现一个更复杂一点的：简易瀑布流



#### 自定义布局—简易瀑布流

先把基本的框架撸出来，在这里只实现纵向的，横向同理

```kotlin
@Composable
fun WaterfallFlowLayout(
    modifier: Modifier = Modifier,
    content: @Composable ()->Unit,
    columns: Int = 2  // 横向几列 
) {
    Layout(
        modifier = modifier,
        content = content,
    ) { measurables: List<Measurable>, constrains: Constraints ->
        TODO()
    }
}
```

我们加入了参数`columns`用来指定有几列。由于瀑布流宽度是确定的，所以我们需要手动指定宽度

```kotlin
val itemWidth = constrains.maxWidth / 2
val itemConstraints = constrains.copy(minWidth = itemWidth, maxWidth = itemWidth)
val placeables = measurables.map { it.measure(itemConstraints) }
```

在这里我们用新的 `itemConstraints` 对子微件的大小进行约束，固定了子微件的宽度

接下来就是摆放了。瀑布流的摆放方式其实就是看看当前哪一列最矮，就把当前微件摆到哪一列，不断重复就行

代码如下：

```kotlin
@Composable
fun WaterfallFlowLayout(
    modifier: Modifier = Modifier,
    columns: Int = 2,  // 横向几列
    content: @Composable ()->Unit
) {
    Layout(
        modifier = modifier,
        content = content,
    ) { measurables: List<Measurable>, constrains: Constraints ->
        val itemWidth = constrains.maxWidth / columns
        val itemConstraints = constrains.copy(minWidth = itemWidth, maxWidth = itemWidth)
        val placeables = measurables.map { it.measure(itemConstraints) }
        // 记录当前各列高度
        val heights = IntArray(columns)
        layout(width = constrains.maxWidth, height = constrains.maxHeight){
            placeables.forEach { placeable ->
                val minIndex = heights.minIndex()
                placeable.placeRelative(itemWidth * minIndex, heights[minIndex])
                heights[minIndex] += placeable.height
            }
        }
    }
}
```

这里用到了一个自定义的拓展函数`minIndex`，作用是寻找**数组中最小项的索引值**，代码很简单，如下：

```kotlin
fun IntArray.minIndex() : Int {
    var i = 0
    var min = Int.MAX_VALUE
    this.forEachIndexed { index, e ->
        if (e<min){
            min = e
            i = index
        }
    }
    return i
}
```

效果如下（设置列数为3）：

<img src="https://web.funnysaltyfish.fun/temp_img/202202112149060.png" alt="image-20220211214931940" style="zoom:50%;" />



### 后续

本文所有代码见：[此处](https://github.com/FunnySaltyFish/JetpackComposeStudy/tree/master/app/src/main/java/com/funny/compose/study/ui/post_layout)

现在的布局只是简单情况，然而事实上，很多时候往往涉及到其他内容。Modifier 的奥秘也等待我们进一步探索。再叙。
