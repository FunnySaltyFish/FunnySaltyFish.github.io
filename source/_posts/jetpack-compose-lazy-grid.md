---
title: Jetpack Compose LazyGrid全解
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2022-06-23 13:34:07
---

本文参考自谷歌官方视频[Lazy layouts in Compose - YouTube](https://www.youtube.com/watch?v=1ANt65eoNhQ)，基于`Compose 1.2.0-beta02`（截止发文时最新版本）

---

### 前言

前段时间Compose发布了`1.2.0`beta版本，最大的变化之一莫过于`LazyLayout`去除了实验性标志。所以接下来，咱们不妨一起看看`LazyGrid`的用法~~（嗯？这和上一句有关系吗）~~

`LazyGrid`包含两种微件：`LazyVerticalGrid`和`LazyHorizontalGrid`。两者内部均由`LazyLayout`实现（包括`LazyColumn`和`LazyRow`也是由`LazyLayout`实现的）。不过今天我们不去考虑底层的`LazyLayout`，单纯着眼于Grid们

为行文方便，此处仅以`LazyVerticalGrid`为例。



### 基本使用

最简单的使用如下所示：

```kotlin
@Composable
fun SimpleLazyGrid(){
    LazyVerticalGrid(
        modifier = Modifier.fillMaxWidth(),
        // 固定两列
        columns = GridCells.Fixed(2) ,
        content = {
            items(12){
                RandomColorBox(modifier = Modifier.height(200.dp))
            }
        }
    )
}
```

其中用到的`RandomColorBox`仅仅是Box加上随机颜色的背景，唯一注意的是对于LazyLayout，因为涉及到重组过程，所以如果需要记住这个Color（重组时颜色不变），则需要使用`rememberSaveable`，其余不再赘述

上面的效果如下

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/62885f44ef1d5.png" alt="image-20220521114045882" style="zoom:33%;" />

简单的网格布局就实现了



### 添加间隙

要为子元素之间添加空隙也很简单，指定一下`arrangemnt`为`spacedBy`即可

```kotlin
	//...
	horizontalArrangement = Arrangement.spacedBy(12.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
```

效果如下

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/6288635e4aa70.png" alt="image-20220521115822198" style="zoom:33%;" />

当然也可以添加整体的外边距，设置`contentPadding = PaddingValues()`即可，如下：

```kotlin
contentPadding = PaddingValues(12.dp)
```

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/628863a93e591.png" alt="image-20220521115937301" style="zoom:33%;" />



### 适应大小

上述情况实际上会根据最大宽度来调整，在横屏状态下就可能会惨不忍睹（比如你加载有图片的情况）

所以除了固定列数外，还可以固定宽度，由Compose自动确定要放几列。这个也很简单，就是设置`columns`参数为`Adaptive`即可

```kotlin
// 固定宽度，自适应列数
columns = GridCells.Adaptive(200.dp) ,
```

效果如下：

横屏

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/628864cc103b5.png" alt="image-20220521120428237" style="zoom:33%;" />

竖屏

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/6288650f1b531.png" alt="image-20220521120535282" style="zoom:33%;" />

可以看到，我们指定的`200.dp`是最小值，由于能够容纳一个又无法容纳两个，Compose为我们自动调整为了只放一个，占满全部剩余宽度。



### 异形与自定义

#### 某些元素占满全部宽度

`item`和`items`均有`span`参数，设置此参数即可设定当前元素会占据几格

对于下面的代码：

```kotlin
// 固定列数
columns = GridCells.Fixed(3) ,
content = {
    item(span = {
        // 占据最大宽度
        GridItemSpan(maxLineSpan)
    }){
        RandomColorBox(modifier = Modifier.height(50.dp))
    }
    items(12){
        RandomColorBox(modifier = Modifier.height(200.dp))
    }
},
```

最上面那个元素就会占据一行，如下：

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/628868661e391.png" alt="image-20220521121950200" style="zoom:33%;" />



上面用到的`maxLineSpan`即为当前行的最大Span，除此之外，还有另一个值`maxCurrentLineSpan`，二者之间关系如下

![image-20220521124749563](http://img.funnysaltyfish.fun/i/2022/05/21/62886ef54dec5.png)



#### 更复杂的自定义

`columns`其实可以自定义，比方说，我们需要让一行中三个元素，宽度分别为**1:2:1**，那其实可以这样写。具体细节请参考下面的源码，返回的值即为各元素的宽度组成的`List`

```kotlin
// 自定义实现1:2:1
columns = object  : GridCells {
    override fun Density.calculateCrossAxisCellSizes(
        availableSize: Int,
        spacing: Int
    ): List<Int> {
        // 总共三个元素，所以其实两个间隔
        // |元素|间隔|元素|间隔|元素|
        // 计算一下所有元素占据的空间
        val availableSizeWithoutSpacing = availableSize - 2 * spacing
        // 小的两个大小即为剩余空间（总空间-间隔）/4
        val smallSize = availableSizeWithoutSpacing / 4
        // 大的那个就是除以2呗
        val largeSize = availableSizeWithoutSpacing / 2
        return listOf(smallSize, largeSize, smallSize)
    }
}
```



效果如下

<img src="http://img.funnysaltyfish.fun/i/2022/05/21/62886c7ee0b67.png" alt="image-20220521123719082" style="zoom:33%;" />

其余的效果大家就发挥想象啦

如果你想对排列方式也自定义，可以自己实现`Arrangement.Vertical`，视频中有给出例子(18:51左右)。这里感觉用处不大，不赘述了



### 一些提示 For LazyLayout

1. 不要设置大小为0的控件

   这类问题主要在异步加载的场景中，可能加载之前你会将原本的大小设置为0（就是什么也没有）。在这种情况下，Compose在初始时将测量所有内容（因为他们高度为0，所以都在屏幕内），之后当数据加载完后，Compose又会重新重组。

   相反，你应当**尽量保证数据加载前后item整体大小不变**（如手动设置高度、使用placeholder等），以帮助LazyLayout正确计算哪些会被显示在屏幕上

   

2. 避免嵌套同方向的可滚动微件

   避免使用如下代码（其实你这么用会直接报错）

   ```kotlin
   Column(modifier = Modifier.verticalScroll()) {
   	LazyColumn(/*这里不设置高度*/)
   }
   ```

   而应当改为：

   ```kotlin
   LazyColumn {
       item { Header() }
       items(){ }
       item{ Footer() }
   }
   ```



3. 谨慎将多个子微件放到同一`item`中

   即谨慎写出类似下面的代码

   ```kotlin
   LazyColumn {
       item {
           // 两个微件放在同一item里
           RandomColorBox(modifier = Modifier.size(40.dp))
           RandomColorBox(modifier = Modifier.size(40.dp))
       }
   }
   ```

   在这种情况下，Compose尽管可以按顺序渲染出这些子微件，但同一个`item`下的微件**会被当作一个整体。如果某一部分可见，则其与部分也会被一起重组和绘制**，可能会影响性能。在最严重情况下，整个`LazyColumn`仅包含一个`item`，那就完全失去了`Lazy`的特性。另一个问题是对于`scrollToItem()`这类方法，它们的index在计算时是按`item`而不是所有内部子元素排列的，也就是说，对于下面的例子，尽管总共有4个微件，但算index的时候只有0/1/2三个而已。

![image-20220521163154088](http://img.funnysaltyfish.fun/i/2022/05/21/6288a3811fe95.png)

​    不过也有些情况倒是推荐这么用，比如在`item`中包含微件本身和`Divider`。一是二者本身语义上就相关联，Divider也不该影响index；二是Divider较小，不影响性能



4. 使用Type

如果你的列表项有多种不同的类型，可以在`item`或`items`方法中指定`contentType`，这有助于Compose在重组时选择相同Type的微件进行复用，可以提高性能。

```kotlin
contentType = { data.type }
```



### Google画的饼

参考的视频中Google其实画了些饼

1. 瀑布流布局正在开发中
2. item添加和删除的动画也正在开发中

目前`RecyclerView`对应的瀑布流布局`Compose`中还没有对应实现，我试图用`VerticalLazyGrid`实现然并不行，它摆放的时候会确保每行高度一样……目前的开源库都是多个`LazyColumn`并排实现的伪效果。所以还是等吧



### 后记

本文所有代码见：[FunnySaltyFish/JetpackComposeStudy: Jetpack Compose学习分享 (github.com)](https://github.com/FunnySaltyFish/JetpackComposeStudy)

受限于本人水平，如有错误，敬请指正。