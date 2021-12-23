---
title: Jetpack Compose LazyColumn列表项动画
date: 2021-12-23 11:13:59
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---


具体包括：列表项数据顺序变更时的轮换动画、添加/删除列表项时的小动画、侧滑删除动画

不废话，本文主要介绍的就是一个修饰符：`Modifier.animateItemPlacement()`。该修饰符首次出现于Jetpack Compose **1.1.0-beta03**版本（此版本于2021年11月17日发布），目前尚处于试验性阶段。但它能实现的效果是非常有趣的。



### 顺序变更 动画

简单看一个例子：

```kotlin
var list by remember { mutableStateOf(listOf("A", "B", "C", "D", "E")) }
  LazyColumn {
      item {
          Button(onClick = { list = list.shuffled() }) {
              Text("打乱顺序")
          }
      }
      items(items = list, key = { it }) {
          Text("列表项：$it", Modifier.animateItemPlacement())
      }
  }
```



运行效果如下：

![Jetpack Compose-shuffle](https://gitee.com/funnysaltyfish/blog-drawing-bed/raw/master/img/202112181030545.gif)

实现此效果如此简单！



### 侧滑删除动画

在Jetpack Compose中，实现侧滑删除需要用到`SwipeToDismiss`微件

简单例子如下：

*数据类：*

```kotlin
data class Student(val id:Int, val name:String)
```

*微件*

```kotlin
var studentList by remember {
        mutableStateOf( (1..100).map { Student(it, "Student $it") } )
    }
    LazyColumn(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        items(studentList, key = {item: Student -> item.id }){ item ->
            // 侧滑删除所需State
            val dismissState = rememberDismissState()
            // 按指定方向触发删除后的回调，在此处变更具体数据
            if(dismissState.isDismissed(DismissDirection.StartToEnd)){
                studentList = studentList.toMutableList().also {  it.remove(item) }
            }
            SwipeToDismiss(
                state = dismissState,
                // animateItemPlacement() 此修饰符便添加了动画
                modifier = Modifier.fillMaxWidth().animateItemPlacement(),
                // 下面这个参数为触发滑动删除的移动阈值
                dismissThresholds = { direction ->
                    FractionalThreshold(if (direction == DismissDirection.StartToEnd) 0.25f else 0.5f)
                },
                // 允许滑动删除的方向
                directions = setOf(DismissDirection.StartToEnd),
                // "背景 "，即原来显示的内容被划走一部分时显示什么
                background = {
                    /*保证观看体验，暂时省略此处内容*/
                }
            ) {
                // ”前景“ 显示的内容
                /*省略一部分不重要修饰*/
                Text(item.name, Modifier.padding(8.dp), fontSize = 28.sp)
            }
        }
    }
```





效果如下：

![Jetpack Compose-swipeToDismiss](https://gitee.com/funnysaltyfish/blog-drawing-bed/raw/master/img/202112181049286.gif)



*上述代码来自于 [android - SwipeToDismiss inside LazyColumn with animation - Stack Overflow](https://stackoverflow.com/questions/70066048/swipetodismiss-inside-lazycolumn-with-animation/70073933#70073933)*



### 其他

`animateItemPlacement`修饰符仅在LazyColumn和LazyRow中有效，并且必须**指定key**参数。除重排外，由更改`alignment`或者`arrangement`引起的位置改变也会被添加动画。

此修饰符有一个可选参数：`animationSpec: FiniteAnimationSpec<IntOffset>`，你可以修改此参数以更改动画效果。



### 后记

这篇文章其实很早之前就想写了，但是一直拖到现在。其实文章写的东西说白了就是介绍个API，但是这个API很有用，而且目前也没有中文资料，于是我就写了。做点自己的贡献吧。

文章所有代码均可在[此处](https://github.com/FunnySaltyFish/JetpackComposeStudy/tree/master/app/src/main/java/com/funny/compose/study/ui/posta)找到，除上述提到的还放了一个Google的官方例子。有兴趣的可以看看。