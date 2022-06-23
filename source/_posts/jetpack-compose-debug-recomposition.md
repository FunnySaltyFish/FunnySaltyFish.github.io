---
title: 如何在 Jetpack Compose 中调试重组
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2022-06-23 13:36:00
---

本文是 Compose 相关的偏进阶文章，给出了一些可用于 Compose 调试的方法，并阐释了一些性能优化方面的小细节。

本文译自 [How can I debug recompositions in Jetpack Compose?](https://www.jetpackcompose.app/articles/how-can-I-debug-recompositions-in-jetpack-compose)

原作者：https://twitter.com/vinaygaba

译：[FunnySaltyFish](https://github.com/FunnySaltyFish)



---

自从 Jetpack Compose 的第一个稳定版本上线以来，已经过去了好几个月*（译注：本文写于2022年4月）*。多家公司已经使用了 Compose 来参与构建他们的 Android 应用程序，成千上万的 Android 工程师每天都在使用 Jetpack Compose 。

虽然已经有大量的文档可以帮助开发人员接受这种新的编程模式，但仍有这么个概念让许多人摸不着头脑。它就是`Recomposition`，Compose 赖以运作的基础。

> 重组是在输入更改时再次调用可组合函数的过程。当函数的输入发生更改时，它便会发生。当 Compose 基于新输入进行重组时，它仅调用可能已更改的函数或 lambda，并跳过其余部分。通过跳过所有未更改参数的函数或 lambda，Compose 可以有效地进行重组。

如果您不熟悉此主题，我将[在本文中](https://www.jetpackcompose.app/articles/donut-hole-skipping-in-jetpack-compose#recomposition)详细介绍 `Recomposition`。对于大多数用例，除非传入的参数变了，否则我们不希望重新调用可组合函数（此处从简表示）。Compose 编译器在这方面也非常聪明，当它有足够的可用信息时（例如，所有原始值类型的参数在设计上都是`Stable`的），它会尽最大努力来做些对使用者无感的优化；当信息没那么多时，Compose 允许您通过使用 [@Stable](https://developer.android.com/reference/kotlin/androidx/compose/runtime/Stable) 和 [@Immutable](https://developer.android.com/reference/kotlin/androidx/compose/runtime/Immutable) 注解提供元数据，以帮助 Compose 编译器正确做出决定。

从理论上讲，这一切都是有道理的，但是，如果开发人员有办法了解他们的可组合函数是如何重组的，那将大有裨益。这类功能目前呼声很高，不过要使Android Studio 快捷地为您提供此信息，还有一吨的工作要做。如果你像我一样迫不及待，你可能也想知道在能正式上手工具前，要想在 Jetpack Compose 中调试重组，咱可以做些什么。毕竟嘛，重组在性能上起着重要作用——不必要的重组可能会导致 UI 卡顿。



# 打日志

调试重组的最简单方法是使用良好的 log 语句来查看正在调用哪些可组合函数以及调用它们的频率。这感觉上很直白，但注意这个坑 ： 我们希望仅在发生重组时才触发这些日志语句。这听起来像是 `SideEffect` 的用武之地。[SideEffect ](https://developer.android.com/jetpack/compose/side-effects#sideeffect-publish)是一个可组合的函数，每当成功的 Composition/ Recomposition 后便会被重新调用。[Sean McQuillan](https://www.jetpackcompose.app/articles/how-can-I-debug-recompositions-in-jetpack-compose) 编写了如下代码片段，您可以使用它来调试您的重组。这只是一个框架，您可以根据需要进行调整。

```kotlin
class Ref(var value: Int)

// 注意，此处的 inline 会使下列函数实际上直接内联到调用处
// 以确保 logging 仅在原始调用位置被调用
@Composable
inline fun LogCompositions(tag: String, msg: String) {
    if (BuildConfig.DEBUG) {
        val ref = remember { Ref(0) }
        SideEffect { ref.value++ }
        Log.d(tag, "Compositions: $msg ${ref.value}")
    }
}
```

实战如下：

```kotlin
@Composable
fun MyComponent() {
    val counter by remember { mutableStateOf(0) }

    LogCompositions(TAG, "MyComposable function")

    CustomText(
        text = "Counter: $counter",
        modifier = Modifier
            .clickable {
                counter++
            },
    )
}

@Composable
fun CustomText(
    text: String,
    modifier: Modifier = Modifier,
) {
    LogCompositions(TAG, "CustomText function")

    Text(
        text = text,
        modifier = modifier.padding(32.dp),
        style = TextStyle(
            fontSize = 20.sp,
            textDecoration = TextDecoration.Underline,
            fontFamily = FontFamily.Monospace
        )
    )
}
```

在运行此示例时，我们注意到每次计数器的值更改时，两者都会重组。`MyComponent``CustomText`

![示例：打印日志语句](https://www.jetpackcompose.app/articles/donut-hole-skipping/donut-hole-skipping-example-1.gif)



# 在运行时对重组可视化

Google Play 团队是Google首批利用 Jetpack Compose 的内部团队之一。他们与 Compose 团队密切合作，甚至[编写了一份case study](https://android-developers.googleblog.com/2022/03/play-time-with-jetpack-compose.html)，描述了他们迁移到 Compose 的经验。该帖子的宝藏之一是他们开发的可视化重组`Modifier`。您可以[在此处](https://github.com/android/snippets/blob/master/compose/recomposehighlighter/src/main/java/com/example/android/compose/recomposehighlighter/RecomposeHighlighter.kt)找到修饰符的代码。为了方便，我在下面添加了该代码段；但不要夸我啊，它是由Google Play团队开发的。

```kotlin
/*
 *  Copyright 2022 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the
 * License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package com.example.android.compose.recomposehighlighter

import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.composed
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.platform.debugInspectorInfo
import androidx.compose.ui.unit.dp
import androidx.compose.ui.util.lerp
import kotlin.math.min
import kotlinx.coroutines.delay

/**
 * A [Modifier] that draws a border around elements that are recomposing. The border increases in
 * size and interpolates from red to green as more recompositions occur before a timeout.
 */
@Stable
fun Modifier.recomposeHighlighter(): Modifier = this.then(recomposeModifier)

// Use a single instance + @Stable to ensure that recompositions can enable skipping optimizations
// Modifier.composed will still remember unique data per call site.
private val recomposeModifier =
    Modifier.composed(inspectorInfo = debugInspectorInfo { name = "recomposeHighlighter" }) {
        // The total number of compositions that have occurred. We're not using a State<> here be
        // able to read/write the value without invalidating (which would cause infinite
        // recomposition).
        val totalCompositions = remember { arrayOf(0L) }
        totalCompositions[0]++

        // The value of totalCompositions at the last timeout.
        val totalCompositionsAtLastTimeout = remember { mutableStateOf(0L) }

        // Start the timeout, and reset everytime there's a recomposition. (Using totalCompositions
        // as the key is really just to cause the timer to restart every composition).
        LaunchedEffect(totalCompositions[0]) {
            delay(3000)
            totalCompositionsAtLastTimeout.value = totalCompositions[0]
        }

        Modifier.drawWithCache {
            onDrawWithContent {
                // Draw actual content.
                drawContent()

                // Below is to draw the highlight, if necessary. A lot of the logic is copied from
                // Modifier.border
                val numCompositionsSinceTimeout =
                    totalCompositions[0] - totalCompositionsAtLastTimeout.value

                val hasValidBorderParams = size.minDimension > 0f
                if (!hasValidBorderParams || numCompositionsSinceTimeout <= 0) {
                    return@onDrawWithContent
                }

                val (color, strokeWidthPx) =
                    when (numCompositionsSinceTimeout) {
                        // We need at least one composition to draw, so draw the smallest border
                        // color in blue.
                        1L -> Color.Blue to 1f
                        // 2 compositions is _probably_ okay.
                        2L -> Color.Green to 2.dp.toPx()
                        // 3 or more compositions before timeout may indicate an issue. lerp the
                        // color from yellow to red, and continually increase the border size.
                        else -> {
                            lerp(
                                Color.Yellow.copy(alpha = 0.8f),
                                Color.Red.copy(alpha = 0.5f),
                                min(1f, (numCompositionsSinceTimeout - 1).toFloat() / 100f)
                            ) to numCompositionsSinceTimeout.toInt().dp.toPx()
                        }
                    }

                val halfStroke = strokeWidthPx / 2
                val topLeft = Offset(halfStroke, halfStroke)
                val borderSize = Size(size.width - strokeWidthPx, size.height - strokeWidthPx)

                val fillArea = (strokeWidthPx * 2) > size.minDimension
                val rectTopLeft = if (fillArea) Offset.Zero else topLeft
                val size = if (fillArea) size else borderSize
                val style = if (fillArea) Fill else Stroke(strokeWidthPx)

                drawRect(
                    brush = SolidColor(color),
                    topLeft = rectTopLeft,
                    size = size,
                    style = style
                )
            }
        }
    }
```

使用此修饰符实际上是直白明了 —— 只需将 `recomposeHighlighter` 修饰符加到要跟踪其重组的可组合项的修饰符链上即可。修饰符在其附加到的可组合体周围绘制一个框，并使用颜色和边框宽度来表示可组合中发生的重组量。

| 边框颜色   | 重组次数 |
| ---------- | -------- |
| 蓝         | 1        |
| 绿         | 2        |
| 黄色到红色 | 3+       |

让我们来看看它在实际使用时的样子。我们的示例有一个简单的可组合函数，该函数具有一个按钮，该按钮在单击计数器时递增计数器。我们在两个地方使用`recomposeHighlighter` 修饰符 -——`MyButtonComponent`本身和``MyTextComponent`，它是按钮的内容。

```kotlin
@Composable
fun MyButtomComponent(
    modifier: Modifier = Modifier.recomposeHighlighter()
) {
    var counter by remember { mutableStateOf(0) }

    OutlinedButton(
        onClick = { counter++ },
        modifier = modifier,
    ) {
        MyTextComponent(
            text = "Counter: $counter",
            modifier = Modifier.clickable {
                counter++
            },
        )
    }
}

@Composable
fun MyTextComponent(
    text: String,
    modifier: Modifier = Modifier,
) {
    Text(
        text = text,
        modifier = modifier
            .padding(32.dp)
            .recomposeHighlighter(),
    )
}
```

在运行此示例时，我们注意到按钮和按钮内的文本最初都有一个蓝色的边界框。这很合理，因为这是第一次重组，它对应于我们使用`recomposeHighlighter()`修饰符的两个地方。当我们单击按钮时，我们注意到边界框仅围绕按钮内的文本，而不是按钮本身。这是因为 Compose 在重组方面很聪明，它不需要重组整个按钮 —— 只需重组计数器值更改时依赖的那个 Composable 即可。

![img](https://www.jetpackcompose.app/articles/debug-recomposition/recompose-highlighter-demo.gif)

*`recomposeHighlighter`实战*



使用此修饰符，我们能够可视化可组合函数中如何发生重组。这是一个非常强大的工具，我能想象出基于此拓展的巨大潜力。



# Compose编译器指标

前两种调试重组的方法非常有用，并且依赖于观察和可视化。但是，如果我们有一些更确凿的证据来证明Compose编译器如何解释我们的代码，那不是相当nice？这些感觉起来就像魔法一样，毕竟我们经常不知道编译器是否按照我们想要的方式在解释。

事实证明，Compose 编译器确实有一种机制，能给出关于此信息的详细报告。我上个月发现了它，这让我大吃一惊🤯。这还有[一些文档](https://github.com/androidx/androidx/blob/androidx-main/compose/compiler/design/compiler-metrics.md)，我强烈建议大家阅读。

启用此报告非常简单 ：您只需在启用 Compose 的模块的`build.gradle`文件中添加这些编译器参数：

```groovy
compileKotlin {
    // Compose Compiler Metrics
    freeCompilerArgs += listOf(
        "-P",
        "plugin:androidx.compose.compiler.plugins.kotlin:metricsDestination=<directory>"
    )

    // Compose Compiler Report
    freeCompilerArgs += listOf(
        "-P",
        "plugin:androidx.compose.compiler.plugins.kotlin:reportsDestination=<directory>"
    )
}
```

~~让我们更深入地了解一下这些指标告诉我们什么。~~在我写这篇博文的时候，工程师[克里斯·巴恩斯（Chris Banes](https://twitter.com/chrisbanes)）发布了[一篇博客文章](https://chris.banes.dev/composable-metrics/)，描述了这些编译器指标，他提供的信息与我希望涵盖的信息完全相同。所以我认为丢个链接到该博客文章会更好些，因为他已经写的很好，更详细地解释了它。

这些指标包括每个类以及已配置模块中的可组合函数的详细信息。它主要关注对重组方式有直接影响的稳定性（译注：Stable相关）。

我着实很想强调一些在我尝试时让我感到 surprised 的事情，我相信它也会让绝大多数人感到讶异的。

**注意：**我鼓励您至少浏览一下[此文档](https://github.com/androidx/androidx/blob/androidx-main/compose/compiler/design/compiler-metrics.md)，这样本文其余部分才有意义。对那里面已经提到的信息，我不再赘述。



## 如果你使用的类所在模块没有启用compose，则Compose 编译器将无法推断其稳定性

让我们看一个示例，以了解这意味着什么，以及 Compose 编译器报告如何帮助我发现这种细微差别 -

```kotlin
data class ArticleMetadata(
    val id: Int,
    val title: String,
    val url: String
)
```

我们有一个名为`ArticleMetadata` 的简单数据类。由于它的所有属性都是原始值，因此 Compose 编译器将能够非常轻松地推断其稳定性。值得指出的是，此类是在**未启用 Compose**的模块中定义的。

由于这是一个简单的数据类，因此我们直接在可组合函数中用它。此函数定义在启用了 Jetpack Compose **的其他模块中**。

```kotlin
@Composable
fun ArticleCard(
    articleMetadata: ArticleMetadata,
    modifier: Modifier = Modifier,
) { .. }
```

当我们运行 Compose Compiler Metrics 时，以下是我们在 Compose 插件生成的其中一个文件 （`composables.txt`） 中找到的内容 -

```kotlin
restartable fun ArticleCard(
  unstable articleMetadata: ArticleMetadata
  stable modifier: Modifier? = @static Companion
)
```

我们看到可组合函数`ArticleCard`是可重新启动的，但不是可跳过的。这意味着Compose 编译器将无法执行智能优化，例如在参数未更改时跳过此函数的执行。有时这是出于实际选择，但在这种情况下，如果参数没有更改，我们肯定希望跳过此函数的执行。 🤔

我们看到此行为的原因是，我们使用的是未启用 compose 的模块中的类。这阻止了 Compose 编译器智能地推断稳定性，因此它将此参数视为`unstable` ，这会影响了此可组合的重组方式。

有两种方法可以解决此问题：

1. 向数据类所在的模块添加 compose 支持
2. 在启用 Compose 的模块中转换为其他类（例如 UI Model 类），并使可组合函数将其作为参数。



## List 参数无法被推断为 Stable，即使它的元素都是原始值

让我们看一下另一个可组合函数，我们想要分析其指标

```kotlin
@Composable
fun TagsCard(
    tagList: List<String>,
    modifier: Modifier = Modifier,
)
```

当我们运行 Compose Compiler Metrics 时，我们看到的是 -

```kotlin
restartable fun TagsCard(
  unstable tagList: List<String>
  stable modifier: Modifier? = @static Companion
)
```

Uh oh！ `TagsCard`具有与上一个示例相同的问题 —— 此函数可重新启动但不可跳过😭 。这是因为参数`tagList`不是 Stable 的—— 即使它是原始值类型（`String`）的 List，Compose 编译器也不会将 List 推断为稳定类型。这可能是因为 List 是一个接口，其实现可以是可变的，也可以是不可变的。

解决此问题的一种方法是使用包装类并适当地对其进行注解，以使 Compose 编译器明确了解其稳定性。

```kotlin
@Immutable
data class TagMetadata(
    val tagList: List<String>,
)


@Composable
fun TagsCard(
    tagMetadata: TagMetadata,
    modifier: Modifier = Modifier,
)
```

当我们再次运行 Compose Compiler Metrics 时，我们看到编译器能够正确推断出此函数的稳定性🎉

```kotlin
restartable skippable fun TagsCard(
  stable tagMetadata: TagMetadata
  stable modifier: Modifier? = @static Companion
)
```

由于这类用例相当常见，所以我很喜欢 Chris Banes 在[博客文章](https://chris.banes.dev/composable-metrics/)中提出的可重用的包装类片段。（就是我贴的这段）



# 总结

正如您从本文中看到的，有好几种方法可以在 Jetpack Compose 中调试重组。您可能希望3种机制都来点，来在代码库中调试 Composable 函数。尤其是因为对大多数团队，这种构建Android应用程序的新方法还是刚刚发车的阶段。我着实很希望在 Android Studio 本身中对调试 Composable 提供一流的支持，但在那之前，您也有一些选择😉，我鼓励大家使用我在本文中展示的其中一些选项 - 我相信您会像我一样找到一些惊喜。

我希望我今天能够教你一些新的东西。还有更多文章正在筹备中，我很高兴与你们分享。如果您感兴趣，并想尽早访问它们，可以考虑注册下面的链接。下次见喽！

