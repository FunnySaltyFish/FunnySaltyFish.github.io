---
title: Jetpack Compose 性能优化参考：编译指标
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2023-01-08 13:21:12
---

本文译自：<https://chris.banes.dev/composable-metrics/>  
原标题：Composable Metrics  
译：FunnySaltyFish

本文为文章《[如何在 Jetpack Compose 中调试重组](https://juejin.cn/post/7110208846051672095)》中附录的文章，译者同样进行了翻译。限于译者水平，不免有谬误之可能，如有错误，欢迎指正。  

***

当一个团队开始使用 [Jetpack Compose](https://developer.android.com/jetpack/compose) 时，他们中的大多数人最终会发现少了一块拼图：如何测量可组合项（Composable）的性能。

在 Jetpack Compose [1.2.0](https://developer.android.com/jetpack/androidx/releases/compose-compiler#version_12_2)中，Compose 编译器添加了一个新功能，它可以在构建时输出各种与性能相关的指标，让我们能够窥视幕后，看看潜在的性能问题在哪些地方。在这篇博文中，我们将探索新的指标，看看我们能找到什么。

在开始阅读之前需要了解的一些事项：

-   最终写完后的结果显示，这是一篇*很长* 的博文，涵盖了 Compose 的许多工作原理。所以阅读这篇文章可能得花点时间。

<!---->

-   本文仅仅设立了一些预期，到结尾也没有真正做成什么“明显的成效”😅。但是，希望您能更好地了解您在设计上的选择将如何影响 Compose 的工作方式。

<!---->

-   如果您没有立即理解这里的所有内容，请不要感到难过——这是一个*高级* 主题！如果您有什么疑惑，我已尝试列出相关资源以供进一步阅读。

<!---->

-   我们在这里捣鼓的一些事情可以被认为是“细微优化”。与任何涉及优化的任务一样：**首先profile（分析）和test（测试）！** 新的[JankStats 库](https://developer.android.com/studio/profile/jankstats)是一个很好的切入点。如果您在真实设备上的性能没有问题，那么在这上面您可能无需做太多事情。

有了这个，让我们开始吧......🏞

## **启用指标**

我们的第一步是通过一些编译器标志启用新的编译器指标。对于大多数应用程序，在所有模块上启用它的最简单方法是使用全局 开/关 开关。

在您的根目录`build.gradle`中，您可以粘贴以下内容：

```
 subprojects {
     tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile).configureEach {
         kotlinOptions {if (project.findProperty("myapp.enableComposeCompilerReports") == "true") {
                 freeCompilerArgs += ["-P","plugin:androidx.compose.compiler.plugins.kotlin:reportsDestination=" +
                         project.buildDir.absolutePath + "/compose_metrics"]
                 freeCompilerArgs += ["-P","plugin:androidx.compose.compiler.plugins.kotlin:metricsDestination=" +
                         project.buildDir.absolutePath + "/compose_metrics"]}}}
 }
```

每当您在`myapp.enableComposeCompilerReports`属性被启用的情况下运行 Gradle 构建时，这都会启用必要的 Kotlin 编译器标志，如下所示：

```
 ./gradlew assembleRelease -Pmyapp.enableComposeCompilerReports=true
```

一些注意事项：

-   **请在release版本上运行它，这很重要。** 我们稍后会看到为什么。

<!---->

-   您可以根据需要重命名该`myapp.enableComposeCompilerReports`属性。

<!---->

-   您可能会发现您需要同时使用 `--rerun-tasks` 选项运行上述命令，以确保 Compose 编译器即使在有缓存的情况下也正常运行。

相应指标和结果报告将被写入每个模块的构建目录中的`compose_metrics`文件夹。一般情况来说，它将位于`<module_dir>/build/compose_metrics`. 如果您打开其中一个文件夹，您会看到如下内容：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/786759026ff14b3ba046091c5e93d16e~tplv-k3u1fbpfcp-zoom-1.image)

Compose 编译器指标的输出

*注意：从技术上讲，报告 (* *`module.json`* *) 和指标（其他 3 个文件）是单独启用的。我已将它们合并为一个标志并将它们设置为输出到同一目录以方便使用。如果需要，您可以拆分它们。*


## **解释报告**

如上所示，每个模块有 4 个文件输出：

-   `module-module.json`，其中包含一些整体统计数据。

<!---->

-   `module-composables.txt`，其中包含每个函数声明的详细输出。

<!---->

-   `module-composables.csv`，这是文本文件的表格版本

<!---->

-   `module-classes.txt`，其中包含从可组合项引用的类的稳定性信息。

这篇博文不会深入探讨所有文件的内容。为此，我建议通读“解释 Compose 编译器指标”文档，也是本篇的参考文档：

> [androidx/compiler-metrics.md at androidx-main · androidx/androidx](https://github.com/androidx/androidx/blob/androidx-main/compose/compiler/design/compiler-metrics.md)

相反，我将依次过一下上面文档中“注意事项”部分中列出的信息的要点👑 [，](https://chris.banes.dev/composable-metrics/Things%20To%20Look%20Out%20For)并看看我的[Tivi 应用程序](https://github.com/chrisbanes/tivi)的某个模块是个什么情况。

我要研究的`ui-showdetails`模块是包含“显示详细信息”页面的所有 UI 的模块。它是我在 [2020 年 4 月](https://github.com/chrisbanes/tivi/commit/28629cf397f2c62b80a0eb74954439066ee4356e) 转成 Jetpack Compose 的首批模块之一，所以我确信还有一些需要改进的地方！

好的，所以首先要注意的是...

## 是`restartable`**但不是**`skippable` 的函数

首先，让我们定义术语 “*可重启（restartable）* ” 和 “*可跳过（skippable）* ”。

在学习 Compose 时，您会学习到[重组](https://developer.android.com/jetpack/compose/mental-model#recomposition)——它是 Compose 工作方式的基础：

> *重组是当输入改变时再次调用你的可组合函数的过程。当函数的输入发生变化时会发生这种情况。当 Compose 基于新输入进行重构时，它只调用可能已更改的函数或 lambda，并跳过其余部分。*

### **可重启**

“*可重启*”的函数是重组的基础。当 Compose 检测到函数输入发生变化时， 它便使用新输入*重新启动*（重新invoke）此函数。

更进一步地看看 Compose 的工作原理，可重启的函数标志着composition“范围”的边界。[Snapshot](https://dev.to/zachklipp/introduction-to-the-compose-snapshot-system-19cn) (比如 `MutableState`)被读取到的“范围”很重要，因为它定义了在 快照（snapshot）更改时被重新运行的代码块。理想情况下，快照更改将尽可能仅触发最近的 函数/lambda 重启，使得被重新运行的代码最少化。如果宿主代码块无法重启，则 Compose 需要遍历树以找到最近的祖先可重启的“范围”。这可能意味着很多函数需要重新运行。实际上，几乎所有`@Composable`函数都可以重启。

### **可跳过**

如果 Compose 发现自上次调用以来参数未更改，则它可以完全跳过调用此函数，则可组合函数是“*可跳过的”。* 这对于“顶级”可组合项的性能尤为重要，因为它们往往位于 `Composable树`的最上面一部分。如果 Compose 可以跳过“顶级”调用，则也不需要调用其之下任何函数。

在实践中，我们的目标是让尽可能多的可组合项可跳过，以允许 Compose '*智能重组'。*

蛋疼的事情是，参数值是否*发生变化* 是怎么定义的——我们需要引入另外两个术语：稳定性（Stablility）和不变性（Immutability）。

### **稳定性（Stablility）和不变性（Immutability）**

可重启和可跳过是 **Compose 函数** 的属性，而不变性和稳定性是**对象实例**的属性，尤指传递给可组合函数的对象。

**不可变**的对象意味着“所有public属性和字段在构造实例后都不会更改”。这个特征意味着 Compose 可以很容易地检测到两个实例之间的“变化”。

另一方面，**稳定**的对象不一定是不可变的。一个稳定的类可以保存可变数据，但所有可变数据都需要在发生变化时通知 Compose，以便在必要时进行重组。

当 Compose 检测到所有函数参数都是稳定或不可变时，它可以在运行时启用许多优化，这也正是函数能够被跳过的关键。Compose 会尝试自动推断一个类是不可变的还是稳定的，但有时它无法正确推断。当发生这种情况时，我们可以在类上使用`@Immutable`和`@Stable`注解

简要解释了这些术语后，让我们开始探索指标数据。

### **探索指标数据**

我们将从`module.json`文件开始以了解整体统计信息：

```
 {
     "skippableComposables": 64,
     "restartableComposables": 76,
     "readonlyComposables": 0,
     "totalComposables": 76
 }
```

我们可以看到该模块包含 76 个可组合项：它们都是*可重启* 的，其中 64 个是*可跳过* 的，剩下 12 个则是*可重启* 但不可 *跳过* 的函数。

现在我们需要找出具体的对应关系。我们有两种方法可以做到这一点：查看`composables.txt`文件，或者导入`composables.csv`文件并将其当做电子表格查看。我们稍后会查看文本文件，所以现在让我们看一下电子表格。

将 CSV 导入您选择的电子表格工具后，您将得到如下结果：

（原作者附的链接失效了……）

在过滤Composable列表后（工作表上有一个“不可跳过”的过滤视图），我们可以轻松找到不可跳过的函数：

```
 ShowDetails()
 ShowDetailsScrollingContent()
 PosterInfoRow()
 BackdropImage()
 AirsInfoPanel()
 Genres()
 RelatedShows()
 NextEpisodeToWatch()
 InfoPanels()
 SeasonRow()
```

### **使函数可跳过**

现在我们的工作是依次查看上述的每一个函数，并确定它们不可跳过的原因。如果我们回到文档，它上面这样写到：

> *如果您看到一个可重启但不可跳过的函数，这并不总是一件坏事；反之，有时，这告诉我们该做做下面这两件事之一：* *1。通过确保函数的所有参数稳定来使函数可跳过* *2. 通过* *`@NonRestartableComposable`* *将函数标记为不可重启函数*

现在，我们将专注于第一件事。所以让我们继续查看`composables.txt`文件，并找到不可跳过的Composable之一：`AirsInfoPanel()`：

```
 restartable scheme("[androidx.compose.ui.UiComposable]") fun AirsInfoPanel(
   unstable show: TiviShow
   stable modifier: Modifier? = @static Companion
 )
```

我们可以看到该函数有 2 个参数：`modifier`参数是 'stable' (👍)，但`show`参数是 'unstable' (👎)，这很可能就是导致 Compose 确定该函数不可跳过的原因。但是现在问题变成了：为什么 Compose 编译器会认为`TiviShow`是不稳定的？它只是一个只包含不可变数据的数据类而已啊。🤔

### **classes.txt**

理想情况下，我们应该参考此处引用的`module-classes.txt`文件以深入了解该类被推断为不稳定的原因。不幸的是，该文件的输出似乎零零散散的。在某些模块中，我可以看到必要的输出；但对于有些模块，它甚至可能是个空文件（这个模块就是）。

不过，我们可以换个不同模块的示例看看。它看起来就蛮有用的：

```
 unstable class WatchedViewState {
   unstable val user: TraktUser?
   stable val authState: TraktAuthState
   stable val isLoading: Boolean
   stable val isEmpty: Boolean
   stable val selectionOpen: Boolean
   unstable val selectedShowIds: Set<Long>
   stable val filterActive: Boolean
   stable val filter: String?
   unstable val availableSorts: List<SortOption>
   stable val sort: SortOption
   unstable val message: UiMessage?
   <runtime stability> = Unstable
 }
```

从`classes.txt`输出的判断来看，Compose 编译器似乎只能推断 启用了 compose的模块下的类 的不变性和稳定性。Tivi 中的大多数Model类都构建在标准的 Kotlin 模块中（即没有包含 Android 或 Compose），然后在整个应用程序中使用。对于从外部库（比如`ViewModel`）使用的类，我们也有类似的情况。

不幸的是，如果没有额外的工作，我们现在似乎无法解决这个问题。理想情况下，Compose 使用的注释（比如`@Stable`）将能被分离到一个纯 Kotlin 库中，允许我们在更多地方使用它们（如有必要，甚至可以是 Java 库）。

### **把类包装一下**

如果您发现您的可组合项成了性能上的绊脚石，且启用可跳过性是实现无卡顿的关键时，您可以将被错误推断的、实际稳定的对象包装起来，例如：

```
 @Stable
 class StableHolder<T>(val item: T) {operator fun component1(): T = item
 }
 ​
 @Immutable
 class ImmutableHolder<T>(val item: T) {operator fun component1(): T = item
 }
```

缺点是您需要在可组合声明中这样使用它们：

```
 @Composable
 private fun AirsInfoPanel(
     show: StableHolder<ShowUiModel>,
     modifier: Modifier = Modifier,
 )
```

不过，我们可以更进一步，探索许多团队推荐的模式：UI 相关的 Model 类。

### **UI** **Model 类**

这些 Model 类是针对每个“屏幕”构建的，包含显示 UI 所需的最少信息。通常，您`ViewModel`会将数据层模型映射到这些 UI 模型中，以便您的 UI 易于使用。更重要的是，它们可以直接写在您的可组合项旁边，这意味着 Compose 编译器可以推断出它需要的所有内容；或者即使其他所有方法都没用，我们也可以根据需要添加`@Immutable`or `@Stable`。

这正是我在以下PR中实现的：

> <https://github.com/chrisbanes/tivi/pull/910>

在我的数据层（比如数据库啥的）中，我们不再直接使用`TiviShow`作为模型，而是将显示数据映射到仅包含 UI 所需的必要信息的`ShowUiModel` 中。

不幸的是，这还不足以让 Compose 编译器推断`ShowUiModel`为可跳过 😔：

```
 restartable scheme("[androidx.compose.ui.UiComposable]") fun AirsInfoPanel(
   unstable show: ShowUiModel
   stable modifier: Modifier? = @static Companion
 )
```

同样不幸的是，指标中没有任何明显的东西可以说明为什么该类会被推断为不稳定。在查看了`composables.txt`文件的其余部分后，我注意到另一个函数也被认为是不稳定的：

```
 restartable scheme("[androidx.compose.ui.UiComposable]") fun Genres(   
   unstable genres: List<Genre>
 )
```

我的新`ShowUiModel`类是一个数据类，它包含许原始类型和枚举类，但一个属性略有不同，因为它包含枚举列表：`genre: List<Genre>`. 似乎 Compose 编译器不把List当做稳定的（[public issue](https://issuetracker.google.com/issues/199496149)）。

我发现强制让 Compose 认为`ShowUiModel`是稳定的唯一方法是：使用`@Immutable`或`@Stable`注解。因为其所有属性均不可变，所以我使用`@Immutable`，

```
 @Immutable
 internal data class ShowUiModel(// ...
 )
```

之后，`AirsInfoPanel()`终于被认为是可以跳过的了😅：

```
 restartable skippable scheme("[androidx.compose.ui.UiComposable]") fun AirsInfoPanel(
   stable show: ShowUiModel
   stable modifier: Modifier? = @static Companion
 )
```

### 再看看

在干完这些之后，您可能会认为我们在模块的整体统计数据方面做出了很大的改变。不幸的是，事实并非如此：

```
 {
     "skippableComposables": 66,
     "restartableComposables": 76,
     "readonlyComposables": 0,
     "totalComposables": 76,
     "knownStableArguments": 890,
     "knownUnstableArguments": 30,"unknownStableArguments": 1
 }
```

作为提醒，我们是 从*64 个*可跳过的组合开始的。这意味着我们将这个数字增加了...... **2**——到*66* 🙃。

> *大型应用程序足以包含数百个* *UI* *模块，这使得在每个模块中创建 UI 模型是不现实的。*

还有一些其他有趣的统计数据。Compose 已认为有 890 个稳定的可组合函数参数（这很好），但仍有**30**个被 Compose 视为不稳定。

在检查了那些“不稳定”的参数后，我发现几乎所有的参数都可以安全地用作不可变的State。这个问题似乎和之前一样，但有其他问题：大多数类型来自外部库。

对于来自外部库的简单数据类，我们*可以* 像以前一样那么干，并将它们映射到本地 UI 模型类（虽然这很费力）。然而，大多数应用程序最终会发现有些类无法在本地轻松映射。在`ui-showdetails`模块中，我有些来自 [ThreeTen-bp](https://www.threeten.org/threetenbp/) 的时间相关的类:`OffsetDateTime`和`LocalDate`. 我不是特别想在本地重写日期/时间库！

请注意，我们谈论的还仅仅是**一个module**的snapshot。Tivi 是一个相当小的应用程序，但它仍然包含 12 个 UI 模块。大型应用程序可以包含数百个 UI 模块，这使得在每个模块中创建本地 UI 模型是不现实的。正如我们在这篇博文开头提到的那样，您只需要在您已确定性能存在问题的地方才考虑这一点。

### 换条路走

到这时我才重新回去看文档，并开始看第二个建议：

> *通过将函数标记为* *`@NonRestartableComposable`*

乍一看，这个建议更像是一种权宜之计（或末路之策），而不是像第一个建议那样去修复类稳定性。让我们看看注释的文档是怎么说的：

> *此注解 [防止] 那些允许函数跳过或重启的代码被生成。这对于 直接调用另一个可组合函数、自身几乎不做什么、并且本身不太可能失效的小函数 来说可能是可取的。*

如果我们往回想想，我们的目标是让 Composable *可重启* **和** *可跳过*，所以仅读这个注释并不太够。不过，Compose Metrics 指南提供了更多信息：

> *如果Composable函数不直接读取任何State变量，那么 [使用这个注解] 是个好主意，[因为] 此重启作用域不太可能被使用。*

那么这个注释对我们有帮助吗？是也不是。此注解似乎让 Compose 编译器完全忽略了所有可组合函数的自动重启，从而否定了让我们的函数*可重启* 和*可跳过* 的初衷。我相信这意味着任何状态更改都需要 Compose Runtime 找到祖先重启范围，这就是为什么上面的文档说要避免它们用于读取State的函数。

那么接下来干嘛呢？写就近的 UI Model 类需要添加大量的东西，因此对于很多团队来说，这条路不大可行。不过，我倒确实在 [Compose Issue Tracker](https://issuetracker.google.com/issues/216791427)上找到了一个我非常喜欢的解决方案：允许将函数的参数标记为`@Stable`. 这将使得开发人员能够对Composable函数的参数强制指定稳定性/不变性，即使对于外部参数类型也是如此：

```
@Composable
fun AirsInfoPanel(
    @Stable show: TiviShow,
    modifier: Modifier = Modifier,
)
```

目前，它还**不能用**。

## **`@dynamic`** **的默认参数表达式**

从 Metrics 文档中，要注意的第二件事是`@dynamic`的默认参数表达式。大量Composable使用默认参数来提供灵活的 API。我最近写了一篇关于 Slot API 的文章，它就依赖于默认参数值：

https://chris.banes.dev/slotting-in-with-compose-ui/

默认参数的值可以是可组合的，或者不可组合的。使用可组合代码中的值意味着您正在调用的代码可能是*可重启* 的，并且返回值可以变化。这就是我们所指的`@dynamic`默认参数。如果默认参数值是`@dynamic`，则调用方函数也可能需要重启，这就是应避免意外的`@dynamic`的原因。

编译指标将非`@dynamic`参数值称为`@static`，它可能构成您在`composables.txt`文件中找到的绝大多数内容。但也一些例外情况下，`@dynamic`是必要的：

> ### *您正在显式读取可观察的dynamic变量*

关于这一点，您最常见的情况是在Composable上使用`MaterialTheme.blah`做默认值。这里我们有一个Composable，它有 3 个被标记为dynamic的参数。

```
restartable skippable scheme("[androidx.compose.ui.UiComposable]") fun TopAppBarWithBottomContent(
  stable backgroundColor: Color = @dynamic MaterialTheme.colors.primarySurface
  stable contentColor: Color = @dynamic contentColorFor(backgroundColor, $composer, 0b1110 and $dirty shr 0b1111)
  stable elevation: Dp = @dynamic AppBarDefaults.TopAppBarElevation
)
```

前两个参数`backgroundColor`和`contentColor`是dynamic（动态）的，因为我们在间接读取挂在`MaterialTheme`上的 composition locals . 由于主题是相对静态的（理论上来说），返回值实际上不应该经常改变，所以它是动态的也问题不大。

但是对于`elevation`参数，我就不大确定为什么它被标记为动态的了。它使用来自 Material 提供的 `AppBarDefaults`.`TopAppBarElevation` 属性的值，该属性定义为：

```
object AppBarDefaults {
    val TopAppBarElevation = 4.dp
}
```

`dp`属性被标记为`@Stable`，并且`Dp`类被标记为`@Immutable`。所以从我读到的情况来看，这可能是个bug？

我在另一个函数上也发现了类似的问题：

```
restartable skippable scheme("[androidx.compose.ui.UiComposable]") fun SearchTextField(
  stable keyboardOptions: KeyboardOptions? = @dynamic Companion.Default
  keyboardActions: KeyboardActions? = @dynamic KeyboardActions()
)
```

`keyboardOptions`指的是`KeyboardOptions`(一个单例) 的伴生对象，并`keyboardActions`在创建一个新的空`KeyboardActions`实例，我读着感觉这两个实例都应该被推断为`@static`。

与这篇博文的第一部分类似，我不确定我们在这里可以做些什么来影响 Compose 编译器。我们可以将`@Stable和@Immutable`添加到我们自己的类中，但从`dp`上面的示例来看，这似乎并不总是有效。

### **为啥要在release下？**

在这篇博文的开头，我们提到您需要在release版本上启用 Compose Compiler 指标。当您在debug模式下构建应用程序时，Compose 编译器会启用许多功能来加快开发。其中之一是[Live Literals](https://developer.android.com/jetpack/compose/tooling#live-edit-literals)，它使 Android Studio 能在不重新编译Composable的情况下“注入”某些参数值的新值。

为了做到这一点，Compose 编译器将某些默认参数替换为另一些生成后的代码。然后，Android Studio 可以调用这些代码来设置新值。最终效果是生成的 Live Literal 代码将导致您的默认参数为`@dynamic`，即使它们实际上并不是动态的。

您可以在下面看到一个示例。红色（译注：这里没颜色，以 - 开头的行）是`debug`模式输出，绿色（译注：同，+ 开头的行）来自`release`构建。release模式下，参数`expanded`变成了`@static`。

```
--- debug.txt        2022-04-06 14:43:16.000000000 +0100
+++ release.txt        2022-04-06 14:43:24.000000000 +0100
@@ -1,11 +1,11 @@
 restartable skippable scheme("[androidx.compose.ui.UiComposable, [androidx.compose.ui.UiComposable], [androidx.compose.ui.UiComposable], [androidx.compose.ui.UiComposable]]") fun ExpandableFloatingActionButton(
   stable text: Function2<Composer, Int, Unit>
   stable onClick: Function0<Unit>
   stable modifier: Modifier? = @static Companion
   stable icon: Function2<Composer, Int, Unit>
-  stable shape: Shape? = @dynamic MaterialTheme.shapes.small.copy(CornerSize(LiveLiterals$ExpandingFloatingActionButtonKt.Int$arg-0$call-CornerSize$arg-0$call-copy$param-shape$fun-ExpandableFloatingActionButton()))
+  stable shape: Shape? = @dynamic MaterialTheme.shapes.small.copy(CornerSize(50))
   stable backgroundColor: Color = @dynamic MaterialTheme.colors.secondary
   stable contentColor: Color = @dynamic contentColorFor(backgroundColor, $composer, 0b1110 and $dirty shr 0b1111)
   stable elevation: FloatingActionButtonElevation? = @dynamic FloatingActionButtonDefaults.elevation(<unsafe-coerce>(0.0f), <unsafe-coerce>(0.0f), <unsafe-coerce>(0.0f), <unsafe-coerce>(0.0f), $composer, 0b1000000000000000, 0b1111)
-  stable expanded: Boolean = @dynamic LiveLiterals$ExpandingFloatingActionButtonKt.Boolean$param-expanded$fun-ExpandableFloatingActionButton()
+  stable expanded: Boolean = @static true
 )
```

## **我刚刚学到了啥？**

到这会儿，您可能会认为您刚刚花了大约 30 分钟，阅读我的文章、光看我指出了许多可能的问题……好吧您大概也是对的 😅。但是我仍然认为这里有一些团队可以采取的行动：

-   开始[分析和跟踪性能统计信息](https://developer.android.com/studio/profile)。没有这个，任何的性能优化都是在摸黑瞎走。

<!---->

-   尽早更新到 Compose 的新版本！这将让您能尝试并获得性能上的更新（并报告可能的退步）。

<!---->

-   寻找那些被标记为`@Composable`的小的功能函数或lambda表达式. 这些往往会返回一个值（而不是更新 UI），并且往往只是为了可以引用 composition locals （根据我的经验，`LocalContext`是一个常见的罪魁祸首）才被标记为Composable。您可以通过[传入依赖项](https://developer.android.com/jetpack/compose/state#state-hoisting)轻松地拿掉这个Composable注解。

## **最后的想法**

正如我在上面提到的，我认为这些新指标向前迈进了 ✨ 惊人的 ✨ 一步，可以看到我们的Composable实际被推断出的内容。

我指出的问题实际上是一件*好事*，并表明这些指标和输出是有效的。如果没有这些，我们将完全不知道会被推断出什么来，也没法看到推断的结果何时不完全符合预期。有了这些信息，在Compose[问题跟踪器](https://chris.banes.dev/composable-metrics/goo.gle/compose-feedback)上创建问题就变得更加容易。

这些指标现在显然非常原始，但在知道 Compose + Android Studio 工具团队有多出色的前提下，我确信一个相应的 Android Studio GUI 版本不会等太久的。我期待着看到团队把让它成为现实！

***

*感谢* *[Yoali](https://twitter.com/yoali_sb)* *、* *[Taylor](https://twitter.com/1taylorsandusky)* *、* *[Nacho](https://twitter.com/mrmans0n)* *和* *[Ben](https://twitter.com/bentrengrove)* *的审阅*🙌

(原文结束)
