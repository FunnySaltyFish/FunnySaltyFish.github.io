---
title: Jetpack Compose 自定义绘制——高仿Keep周运动数据页面
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2022-06-23 13:33:11
---

废话之前先上图吧，如果不是有人告诉，你可以一眼看出哪个是真哪个是假吗？

![Snipaste_2022-05-29_23-50-49](http://img.funnysaltyfish.fun/i/2022/05/30/629440b27e66d.png)

仿制整个页面（仅仅页面）大概花了我两个小时，不过仅仅是静态的、不可点击的。图有形似而无功能。



### 自定义绘制

Jetpack Compose 自定义绘制的文章其实并不少了，基本代码上和`View`体系基本类似，就是方法上有所差异

详细的内容可以见其他作者的文章，如

- `路很长OoO`的[JetPack-Compose - 自定义绘制 - 掘金 (juejin.cn)](https://juejin.cn/post/6937700592340959269)
- [RugerMc](https://juejin.cn/user/1714893871911502)的[使用 Jetpack Compose 完成自定义绘制 - 掘金 (juejin.cn)](https://juejin.cn/post/6999889489166336007)
- ……

我就不赘述

上述代码中，中间那块数据图就是自己画的（Keep 用的是 `RecyclerView`）。大致上，包括这几个部分

1. 四个浅色矩形和底部文字
2. 三条浅色横线和一条深色横线
3. 中间的深色矩形和底部文字
4. 中间竖线、矩形和底部的小线段

其中1->3的顺序不能更改，因为三条浅色横线在浅色矩形之上，但是在深色矩形之下



#### 浅色矩形

页面上一共4个浅色矩形，观察Keep可知，它们的高度与 **对应数据和运动记录中最长时间之比** 成正比

所以先计算一下最大的数字，找一些变量存储宽高：

```kotlin
// 画布的宽高
val w = size.width
val h = size.height
// 最高的矩形占的高度（3/6)
val maxH = h / 2
// 最大的数字，所有矩形以这个为基准计算高度
val maxNum = listData.maxOf { it.num }

// 以及一个参数
startIndex: Int //最左侧的矩阵对应的index
```

其中列表Bean`ItemData`定义如下：

```kotlin
data class ItemData(val content :String, val num : Int)
```

然后计算对应位置（左上角）和大小（宽高）即可

```kotlin
for (i in 0 until min(5, listData.size - startIndex)){
    val data = listData[startIndex + i]
    if (i != 2){
        // 画四个浅色矩形
        val blockH = data.num.toFloat() / maxNum * maxH
        drawRect(lightColor, Offset(w / 4f * i - blockW / 2, 0.833f * h - blockH), Size(blockW, blockH))
    }
}
```

浅色矩形对应的文字也是类似，不过由于Canvas并不能直接画文字，所以要先获取到`canvas.nativeCanvas`再在它上面`drawText`

```kotlin
for(...){
	// 浅色矩形下方的文字
	paint.color = Color.Gray.toArgb()
	drawIntoCanvas {
	    FunnyCanvasUtils.drawCenterText(it.nativeCanvas, data.content, w / 4f * i , h * 7 / 8 + 2f,  rect, paint)
	}
}   
```

这里用到了一个方法`drawCenterText`就是让文字以给定的`x,y`为`横向中心点，纵向baseline`为基准进行绘制，感兴趣的可以看源码（见文末），此处不在赘述



### 画横线

画线的方法就是`drawLine`，给出两个`Offset`分别表示起点和终点即可。唯一注意的是，由于要画虚线，所以要设置`pathEffect = PathEffect.dashPathEffect`并给出一个二元数组（表示线长、间隔）

```kotlin
// 三条浅色横线
for (i in 2 until 5){
    drawLine(Color.Black.copy(alpha = 0.5f), Offset(0f, h * i / 6), Offset(w, h * i / 6), pathEffect = PathEffect.dashPathEffect(
        floatArrayOf(10f,10f)))
}
```



其余的就不赘述了，本质上就是计算着不同位置，画不同的东西而已。可以自行见源码



### 其他内容

至于图片上的其他部分，则是这样组成的：

最上面一部分直接就是图片（哈哈）

<img src="http://img.funnysaltyfish.fun/i/2022/05/30/629448b4976f0.png" alt="image-20220530123148596" style="zoom: 50%;" />

这一行是一个`Row`，两端对齐

<img src="http://img.funnysaltyfish.fun/i/2022/05/30/629448d93b8bd.png" alt="image-20220530123225279" style="zoom:50%;" />

这一行也是一个`Row`，以文本`baseline`对齐

<img src="http://img.funnysaltyfish.fun/i/2022/05/30/629449036ed36.png" alt="image-20220530123307519" style="zoom:50%;" />

下面是`Row`套三个`Column`

<img src="http://img.funnysaltyfish.fun/i/2022/05/30/6294492d1dae3.png" alt="image-20220530123349099" style="zoom:50%;" />





### 后续

暂时就是这样，Jetpack Compose 的 布局和绘制到此5篇（前几篇见我的文章），下一篇我会发个很好玩儿的内容，是Layout的蜜汁用法，敬请期待。

如果你对 Jetpack Compose 开发完整项目有兴趣，鄙人毛遂自荐下自己的开源项目[FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件，支持多引擎、插件化~ ](https://github.com/FunnySaltyFish/FunnyTranslation)



本文所有代码见[此处](https://github.com/FunnySaltyFish/JetpackComposeStudy)
