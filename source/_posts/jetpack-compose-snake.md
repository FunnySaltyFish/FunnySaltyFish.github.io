---
title: Jetpack Compose + MVI 实现一个简易贪吃蛇
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2023-04-14 10:20:03
---

本文基于 Jetpack Compose 框架，采用 MVI 架构实现了一个简单的贪吃蛇游戏，展示了 MVI 在 Jetpack Compose 中的形式，并基于 CompositionLocal 实现了简单的换肤功能（可保存至本地）

点此下载 demo：[app-debug.apk](https://github.com/FunnySaltyFish/JetpackComposeSnake/blob/master/app-debug.apk)


## 运行效果
<p align=center><img src="https://img.funnysaltyfish.fun/i/2023/08/14/64d99a64ceaeb.webp" width="50%" /></p>


| ![start_game.jpg](http://img.funnysaltyfish.fun/i/2023/08/14/64d998eb950ee.jpeg) | ![lost_game.jpg](http://img.funnysaltyfish.fun/i/2023/08/14/64d998fc918b2.jpeg) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |


## 环境

- Gradle 8.0，**这需要 Java17 及以上版本**
- Jetpack Compose BOM: 2023.03.00
- Compose 编译器版本：1.4.0


## 什么是 MVI
<p align=center><img src="http://img.funnysaltyfish.fun/i/2023/08/14/64d99abf71829.png" alt="image"  /></p>

<center>MVI 示例，图源 <a href="https://juejin.cn/post/6950196093367877663">此文章</a> </center>



MVI 是 Model-View-Intent 的缩写，是一种架构模式，它的核心思想是将 UI 的状态抽象为一个单一的数据流，这个数据流由 View 发出的 Intent 作为输入，经过 Model 处理后，再由 View 显示出来。
具体到本项目，View 是贪吃蛇的游戏界面，Model 是游戏的逻辑，Intent 是用户和系统的操作，比如开始游戏、更改方向等。

- **View层**：基于 Compose 打造，所有 UI 元素都由代码实现 
- **Model层**：ViewModel 维护 State 的变化，游戏逻辑交由 reduce 处理 
- **V-M通信**：通过 State 驱动 Compose 刷新，事件由 Action 分发至 ViewModel

ViewModel 基本结构如下：

```kotlin
class SnakeGameViewModel : ViewModel() {
    // snakeState，UI 观察它的变化来展示不同的画面  
    val snakeState = mutableStateOf(
        SnakeState(
            snake = INITIAL_SNAKE,
            size = 400 to 400,
            blockSize = Size(20f, 20f),
            food = generateFood(INITIAL_SNAKE.body)
        )
    )

    // 分发 GameAction
    fun dispatch(gameAction: GameAction) {
        snakeState.value = reduce(snakeState.value, gameAction)
    }

    // 根据不同的 gameAction 做不同的处理，并返回新的 snakeState（通过 copy）
    private fun reduce(state: SnakeState, gameAction: GameAction): SnakeState {
        val snake = state.snake
        return when (gameAction) {
            GameAction.GameTick -> state.copy(/*...*/)
            GameAction.StartGame -> state.copy(gameState = GameState.PLAYING)
            //  ...
        }
    }
}
```

完整代码见：[SnakeGameViewModel.kt](https://github.com/FunnySaltyFish/JetpackComposeSnake/blob/master/app/src/main/java/com/funny/compose/snake/ui/SnakeGameViewModel.kt)



## UI
由于代码的逻辑均交给了 ViewModel，所以 UI 层的代码量非常少，只需要关注 UI 的展示即可。

```kotlin
@Composable
fun ColumnScope.Playing(
    snakeState: SnakeState,
    snakeAssets: SnakeAssets,
    dispatchAction: (GameAction) -> Unit
) {
    Canvas(
        modifier = Modifier
            .fillMaxSize()
            .square()
            .onGloballyPositioned {
                val size = it.size
                dispatchAction(GameAction.ChangeSize(size.width to size.height))
            }
            .detectDirectionalMove {
                dispatchAction(GameAction.MoveSnake(it))
            }
    ) {
        drawBackgroundGrid(snakeState, snakeAssets)
        drawSnake(snakeState, snakeAssets)
        drawFood(snakeState, snakeAssets)
    }
}
```

上面的代码使用 `Canvas` 作为画布，通过自定义的 `square` 修饰符使其长宽相等，通过 `drawBackgroundGrid`、`drawSnake`、`drawFood` 绘制游戏的背景、蛇和食物。
完整代码见：[SnakeGame.kt](https://github.com/FunnySaltyFish/JetpackComposeSnake/blob/master/app/src/main/java/com/funny/compose/snake/ui/SnakeGame.kt)



## 游戏逻辑

### 蛇的定义
我们定义一个类 `Snake` 用于表示蛇，在这里，出于实现上的便捷，我们假定蛇的身体由“一个个方块”组成，且相邻两个方块之间是紧挨着的（转弯的时候不会有弧度）。`Snake` 类的定义如下：
```kotlin
@Stable
data class Snake(val body: LinkedList<Point>, val direction: MoveDirection) {
    val head: Point
        get() = body.first
    
    ...
}
```

蛇的身体由双向链表组成，这样方便在移动的时候修改位置；具体来说，从 index 0 -> index N-1 分别表示蛇的头和其余身体。它还额外有一个变量 `direction` 表示当前的移动方向。



### 移动
贪吃蛇的主体逻辑，最困难的地方在于蛇的移动。举个栗子，假设蛇向右移动一步，则：

![image-20230414104225560](http://img.funnysaltyfish.fun/i/2023/04/14/6438bd9db35af.png)

观察上图，我们可以发现，其实真正变化的只有两个地方：
1. 蛇的尾部“消失”
2. 在蛇的移动方向上，新增一个方块，成为新的蛇头

![image-20230414104503643](http://img.funnysaltyfish.fun/i/2023/04/14/6438c105f235b.png)

因此，蛇的移动可以写成：

```kotlin
fun move(pos: Point) = this.copy(body = this.body.apply {
    body.removeLast()
    body.addFirst(pos)
})
```

那么吃了食物呢？在那种情况下，蛇的身体会“生长”一节。

![image-20230414104746820](http://img.funnysaltyfish.fun/i/2023/04/14/6438c10a5722f.png)

仔细观察上图，我们发现，其实蛇的“生长”相比“移动”，就是少了一个“去掉尾巴”的过程。代码可以表示成：

```kotlin
fun grow(pos: Point) = this.apply {
    body.addFirst(pos)
}
```



### 不断移动

明确了“蛇”的生长和移动，接下来的游戏就简单了，我们只需要让蛇每一段时间移动（或生长）一次，就完成了让蛇动起来的目标。

在 Composable 中，利用 `LaunchedEffect` 和 `while` 循环就可以完成

```kotlin
val vm: SnakeGameViewModel = viewModel()
val snakeState by vm.snakeState

LaunchedEffect(key1 = snakeState.gameState) {
    if (snakeState.gameState != GameState.PLAYING) return@LaunchedEffect
    while (true) {
        vm.dispatch(GameAction.GameTick)
        delay(snakeState.getSleepTime())
    }
}
```

`snakeState.getSleepTime()` 和蛇的长度负相关，蛇越长，`sleep` 时间越短，达到加快速度的效果



## 主题

本项目自带了一个简单的主题示例，设置不同的主题可以更改蛇的颜色、食物的颜色等
| ![assets1.jpg](http://img.funnysaltyfish.fun/i/2023/08/14/64d999bb5aa1d.jpeg) | ![assets2.jpg](http://img.funnysaltyfish.fun/i/2023/08/14/64d999c29e376.jpeg) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |

*看起来区别不大，但是主要目的在于演示 CompositionLocal 的基本用法*

主题功能的实现基于 `CompositionLocal`，具体介绍可以参考 [官方文档：使用 CompositionLocal 将数据的作用域限定在局部 ](https://developer.android.google.cn/jetpack/compose/compositionlocal?hl=zh-cn)。简单来说，父 Composable 使用它，所有子 Composable 中都能获取到对应值，我们所熟悉的 `MaterialTheme` 就是通过它实现的。
具体实现如下：

### 定义类

我们先定义一个密闭类，表示我们的主题

```kotlin
sealed class SnakeAssets(
    val foodColor: Color= MaterialColors.Orange700,
    val lineColor: Color= Color.LightGray.copy(alpha = 0.8f),
    val headColor: Color= MaterialColors.Red700,
    val bodyColor: Color= MaterialColors.Blue200
) {
    object SnakeAssets1: SnakeAssets()

    object SnakeAssets2: SnakeAssets(
        foodColor = MaterialColors.Purple700,
        lineColor = MaterialColors.Brown200.copy(alpha = 0.8f),
        headColor = MaterialColors.Blue700,
        bodyColor = MaterialColors.Pink300
    )
}
```

上面的 `MaterialColors` 来自库 [FunnySaltyFish/CMaterialColors： 在 Jetpack Compose 中使用 Material Design Color](https://github.com/FunnySaltyFish/CMaterialColors)



### 使用

我们需要先定义一个 `ProvidableCompositionLocal`，在这里，因为主题的变动频率相对较低，因此选用 `staticCompositionLocalOf` 。之后，在 `SnakeGame` 外面通过 `provide` 中缀函数指定我们的 Assets

```kotlin
internal val LocalSnakeAssets: ProvidableCompositionLocal<SnakeAssets> = staticCompositionLocalOf { SnakeAssets.SnakeAssets1 }

// ....

val snakeAssets by ThemeConfig.savedSnakeAssets
CompositionLocalProvider(LocalSnakeAssets provides snakeAssets) {
    SnakeGame()
}
```

只需要改变 `ThemeConfig.savedSnakeAssets` 的值，即可全局更改主题样式啦



### 保存配置到本地（持久化）

我们希望用户选择的主题能在下一次打开应用时仍然生效，因此可以把它保存到本地。这里借助的是开源库 [FunnySaltyFish/ComposeDataSaver: 在Jetpack Compose中优雅完成数据持久化](https://github.com/FunnySaltyFish/ComposeDataSaver)。通过它，可以用类似于 `rememberState` 的方式轻松做到这一点

框架自带了对于基本数据类型的支持，不过由于要保存 `SnakeAssets` 这个自定义类型，我们需要提前注册下类型转换器。

```kotlin
class App: Application() {
    override fun onCreate() {
        super.onCreate()
        DataSaverUtils = DataSaverPreferences(this)

        // SnakeAssets 使我们自定义的类型，因此先注册一下转换器，能让它保存时自动转化为 String，读取时自动从 String 恢复成 SnakeAssets
        DataSaverConverter.registerTypeConverters(save = SnakeAssets.Saver, restore = SnakeAssets.Restorer)
    }

    companion object {
        lateinit var DataSaverUtils: DataSaverInterface
    }
}
```

然后在 `ThemeConfig` 中创建一个 `DataSaverState` 即可

```kotlin
val savedSnakeAssets: MutableState<SnakeAssets> = mutableDataSaverStateOf(DataSaverUtils ,key = "saved_snake_assets", initialValue = SnakeAssets.SnakeAssets1)
```

之后，对 `savedSnakeAssets` 的赋值都会自动触发 `异步的持久化操作`，下次打开应用时也会自动读取。



## 其他

项目还附带了一份 Python 的 Pygame 实现的版本，见仓库的  `python_version` 文件夹，运行 `main.py` 即可

还有一点有趣的事情，当我把 AS 升级到 F（火烈鸟）RC 版本时，发现新建项目时，已经把 Material3 的 Compose 模板放到了第一位了。Google 官方对于推行 Jetpack Compose 的态度，看起来还是很高涨的。所以，各位开发者们，学起来吧！

![image.png](http://img.funnysaltyfish.fun/i/2023/08/14/64d999d4d75c1.png)

## 源码
- https://github.com/FunnySaltyFish/JetpackComposeSnake


## 参考

- [爷童回！Compose + MVI 打造经典版的俄罗斯方块 - 掘金 ](https://juejin.cn/post/6950196093367877663)
- [100 行写一个 Compose 版华容道 - 掘金](https://juejin.cn/post/7000908871292157989)

## 额外感谢
Github Copilot、ChatGPT
