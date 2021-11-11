---
title: 基于Jetpack Compose打造一款翻译APP
date: 2021-11-11 23:18:35
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---


#### 前言

[FunnyTranslation](https://www.coolapk.com/apk/com.funny.translation) 是基于Jetpack Compose写成的翻译软件。**它首先是个可以用的软件，其次也是个开源项目。**

开源地址：[FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件，支持多引擎、插件化~ | Jetpack Compose+MVVM+协程+Room (github.com)](https://github.com/FunnySaltyFish/FunnyTranslation)



#### 运行截图

| 图片                                                         | 图片                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="https://gitee.com/funnysaltyfish/blog-drawing-bed/raw/master/img/202111102032441.jpg" alt="Screenshot_2021-11-07-22-37-33-814_com.funny.tran" style="zoom:33%;" /> | <img src="https://gitee.com/funnysaltyfish/blog-drawing-bed/raw/master/img/202111102032313.jpg" alt="Screenshot_2021-11-07-22-39-18-201_com.funny.tran" style="zoom:33%;" /> |
| <img src="https://gitee.com/funnysaltyfish/blog-drawing-bed/raw/master/img/202111102033517.jpg" alt="Screenshot_2021-11-07-22-40-16-339_com.funny.tran" style="zoom:33%;" /> | <img src="https://gitee.com/funnysaltyfish/blog-drawing-bed/raw/master/img/202111102033976.jpg" alt="IMG_20211107_223720" style="zoom:33%;" /> |



上面截图显示的所有UI都是基于Jetpack Compose搭建的



#### 挑点啥说一说

项目开始时觉得没什么，但是真的写起来却发现不少坑。下面简单挑一个例子。



##### 导航栏内容与底部同步

软件的导航栏是基于Row自己定义的，摘录部分如下：



```kotlin
@ExperimentalAnimationApi
@Composable
fun CustomNavigation(
    screens : Array<TranslateScreen>,
    currentScreen: TranslateScreen = screens[0],
    onItemClick: (TranslateScreen) -> Unit
) {
    Row(
        modifier = Modifier
            .background(MaterialTheme.colors.background)
            .padding(start=8.dp,end=8.dp,bottom = 4.dp,top = 2.dp)
            .fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceAround
    ) {
        screens.forEach{ screen->
            CustomNavigationItem(item = screen, isSelected = currentScreen==screen) {
                onItemClick(screen)
            }
        }
    }
}
```

UI实现并不复杂，问题在于用它导航的时候

首先是点击Icon跳转到对应页面，这一部分**理论上**并不复杂，用`navController.navigate(screen.route)`就能达到最简单的效果

然后第一个问题出现了：每次进行navigate的时候，都会重新创建对应的Screen，导致之前页面输入的内容啥的都会被清空；而且每一次点开对应页面就会有一个新的，导致返回的时候需要疯狂点击回退，在不同页面间反复横跳……这肯定不行

怎么办呢？参考官方文档，说是加上`launchSingleTop=true`即可，也就是改成下面这样

```kotlin
navController.navigate(screen.route){
    launchSingleTop = true
}
```

然后……然后居然还是不行！我不得其解，终于在过了几天后找到了有效的写法：

```kotlin
navController.navigate(screen.route){
	//当底部导航导航到在非首页的页面时，执行手机的返回键 回到首页
	popUpTo(navController.graph.startDestinationId){
		saveState = true
	}
    //从名字就能看出来 跟activity的启动模式中的SingleTop模式一样 避免在栈顶创建多个实例
    launchSingleTop = true
    //切换状态的时候保存页面状态
    restoreState = true
}
```

这应该是从一篇博客上看到的，具体哪篇现在也找不到了。在此表示感谢！



上面的问题解决了，新的问题又来了：点击返回键时，导航栏也应该跟着变动，回到主页面。这一部分的需求又该怎么实现呢？

最终在开源项目里面一顿乱翻，终于找到了一个解决方案：在`NavController.OnDestinationChangedListener`回调中使用`hierarchy`进行匹配，让页面内容与底部导航栏始终保持同步。相关代码如下：

```kotlin
	val selectedItem = remember { mutableStateOf<TranslateScreen>(TranslateScreen.MainScreen) }

    DisposableEffect(this) {
        val listener = NavController.OnDestinationChangedListener { _, destination, _ ->
            when {
                destination.hierarchy.any { it.route == TranslateScreen.MainScreen.route } -> {
                    selectedItem.value = TranslateScreen.MainScreen
                }
                // ...省略类似的几个
                destination.hierarchy.any { it.route == TranslateScreen.ThanksScreen.route } -> {
                    selectedItem.value = TranslateScreen.ThanksScreen
                }
            }
        }
        addOnDestinationChangedListener(listener)

        onDispose {
            removeOnDestinationChangedListener(listener)
        }
    }
```

顺便用`BackHandler`实现了退出时二次确认：

```kotlin
BackHandler(enabled = true) {
        if (navController.previousBackStackEntry == null){
            val curTime = System.currentTimeMillis()
            if(curTime - activityVM.lastBackTime > 2000){
                scope.launch { scaffoldState.snackbarHostState.showSnackbar(FunnyApplication.resources.getString(R.string.snack_quit)) }
                activityVM.lastBackTime = curTime
            }else{
                exitAppAction()
            }
        }else{
            Log.d(TAG, "AppNavigation: back")
            //currentScreen = TranslateScreen.MainScreen
        }
    }
```

这部分完整代码在这：[FunnyTranslation/TransActivity.kt at compose · FunnySaltyFish/FunnyTranslation (github.com)](https://github.com/FunnySaltyFish/FunnyTranslation/blob/compose/translate/src/main/java/com/funny/translation/translate/TransActivity.kt)



这样类似的地方在应用开发时还有很多，我相信这里的各位能有同感，就不在这搞吐槽大会了。不过既然尝试了一门新技术，就得做好万事碰壁自己探索的准备。这样也才有点Coder的精神嘛~



#### 然后呢

应用目前还在完善，但基本功能确实可以用了，希望各位不吝赐教。

我在写的时候感觉很多小需求很少有中文资料做整理的，于是自己开了个[专栏](https://juejin.cn/column/7024350372680433672)，希望能把这些记录下来，供后来者参阅。



代码现在有些地方写的不太合理，比如加载数据的部分，确实还需要进一步修改。欢迎参与贡献！

最后再复读一遍地址：https://github.com/FunnySaltyFish/FunnyTranslation

如果觉得项目有用的话，欢迎star~