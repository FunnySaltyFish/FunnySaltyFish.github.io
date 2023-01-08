---
title: Jetpack Compose 十几行代码快速模仿即刻点赞数字切换效果
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2023-01-08 13:32:27
---

## 缘由

四点多刷掘金的时候，看到这样一篇文章：
[自定义View模仿即刻点赞数字切换效果](https://juejin.cn/post/7179181214530551867)，作者使用自定义绘制的技术完成了数字切换的动态效果，也就是如图：
<p align=center><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c5acfd2b4fed4d93b799a9541a3b5dad~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="原效果" width="50%" /></p>

<p align=center><img src="https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/380763a2f0494f9aa12bfe11f62bb2a7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?" alt="作者模仿的效果" width="50%" /></p>
<p align=center><small>两图分别为即刻的效果和作者的实现</small></p>

不得不说，作者模仿的很像，自定义绘制玩的炉火纯青，非常优秀。不过，即使是这样简单的动效，使用 View 体系实现起来仍然相对麻烦。对上文来说，作者使用的 Kotlin 代码也达到了约 **170** 行。  


## Composable
如果换成 Compose 呢？作为声明式框架，在处理这类动画上会不会有奇效？

答案是肯定的！下面是最简单的实现：

```kotlin
Row(modifier = modifier) {
    text.forEach {
        AnimatedContent(
            targetState = it,
            transitionSpec = {
                slideIntoContainer(AnimatedContentScope.SlideDirection.Up) with
                        fadeOut() + slideOutOfContainer(AnimatedContentScope.SlideDirection.Up)
            }
        ) { char ->
            Text(text = char.toString(), modifier = modifier.padding(textPadding), fontSize = textSize, color = textColor)
        }
    }
}
```
你没看错，这就是 Composable 对应的简单模仿，核心代码不过十行。它的大致效果如下：

![20221221_174919.gif](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/23203905faa0424a9a7f949ba91439fd~tplv-k3u1fbpfcp-watermark.image?)

能看到，在数字变化时，相应的动画效果已经非常相似。当然他还有小瑕疵，比如在 99 - 100 时，最后一位的 0 没有初始动画；比如在数字减少时，他的动画方向应该相反。但这两个问题都是可以加点代码解决的，这里核心只是思路


## 原理
与上文作者将**每个数字当做一个整体**对待不同，我将**每一位独立处理**。观察图片，动画的核心在于每一位有差异时要做动画处理，因此将每一位单独处理能更好的建立状态。

Jetpack Compose 是声明式 UI，状态的变化自然而然就导致 UI 的变化，我们所需要做的只是在 UI 变化时加个动画就可以。而刚好，对于这种内容的改变，Compose 为我们提供了开箱即用的微件：`AnimatedContent`

### AnimatedContent
此 Composable 签名如下：
```
@Composable
fun <S> AnimatedContent(
    targetState: S,
    modifier: Modifier = Modifier,
    transitionSpec: AnimatedContentScope<S>.() -> ContentTransform = {
        ...
    },
    contentAlignment: Alignment = Alignment.TopStart,
    content: @Composable() AnimatedVisibilityScope.(targetState: S) -> Unit
)
```
重点在于 `targetState`，在 content 内部，我们需要获取到用到这个值，根据值的不同，呈现不同的 UI。`AnimatedContent` 会在 `targetState` 变化使自动对上一个 Composable 执行退出动画，并对新 Composable 执行进入动画 *（有点幻灯片切换的感觉hh）*，在这里，我们的动画是这样的：
```kotlin
slideIntoContainer(AnimatedContentScope.SlideDirection.Up) 
with
fadeOut() + slideOutOfContainer(AnimatedContentScope.SlideDirection.Up)
```                        
上半部分的 `slideIntoContainer` 会执行进入动画，方向为自下向上；后半部分则是退出动画，由向上的路径动画和淡出结合而来。中缀函数 `with` 连接它们。这也体现了 Kotlin 作为一门现代化语言的优雅。

关于 Compose 的更多知识，可以参考 Compose 中文社区的大佬们共同维护的 [Jetpack Compose 博物馆](https://jetpackcompose.cn/)。


## 代码
本文的所有代码如下：
```Kotlin
import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material.Text
import androidx.compose.material.TextButton
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@OptIn(ExperimentalAnimationApi::class)
@Composable
fun NumberChangeAnimationText(
    modifier: Modifier = Modifier,
    text: String,
    textPadding: PaddingValues = PaddingValues(horizontal = 8.dp, vertical = 12.dp),
    textSize: TextUnit = 24.sp,
    textColor: Color = Color.Black
) {
    Row(modifier = modifier) {
        text.forEach {
            AnimatedContent(
                targetState = it,
                transitionSpec = {
                    slideIntoContainer(AnimatedContentScope.SlideDirection.Up) with
                            fadeOut() + slideOutOfContainer(AnimatedContentScope.SlideDirection.Up)
                }
            ) { char ->
                Text(text = char.toString(), modifier = modifier.padding(textPadding), fontSize = textSize, color = textColor)
            }
        }
    }
}

@Composable
fun NumberChangeAnimationTextTest() {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        var text by remember { mutableStateOf("103") }
        NumberChangeAnimationText(text = text)

        Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
            // 加一 和 减一
            listOf(1, -1).forEach { i ->
                TextButton(onClick = {
                    text = (text.toInt() + i).toString()
                }) {
                    Text(text = if (i == 1) "加一" else "减一")
                }
            }
        }
    }
}
```
这个示例也被收录到了我的 [JetpackComposeStudy: 本人 Jetpack Compose 主题文章所包含的示例，包括自定义布局、部分组件用法等](https://github.com/FunnySaltyFish/JetpackComposeStudy) 里，感兴趣的可以去那里查看更多代码。

<p align=center><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/642c25df4215468f886c305df42ccc61~tplv-k3u1fbpfcp-watermark.image?" alt="Screenshot_1671617400.png" width="50%" /></p>