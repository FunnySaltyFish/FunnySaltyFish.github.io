---
title: Jetpack Compose 输入法的弹出与隐藏
date: 2021-10-29 13:14:43
tags: [Jetpack Compose]
cover: /images/bg_jetpack_compose.jpeg
---

*本文基于Jetpack Compose1.0.4*

Jetpack Compose 提供了 `SoftwareKeyboardController`用于控制软键盘的显示与隐藏，可在Composable中通过`LocalSoftwareKeyboardController.current`获取

### 使用

#### 隐藏

```kotlin
val keyboard = LocalSoftwareKeyboardController.current
// ...
onClick = {
    keyboard?.hide()
}
```

该操作会试图关闭软键盘，如果因为各种原因软键盘暂时无法关闭，则此操作会被忽略



#### 打开

打开软键盘涉及到焦点的获取

```kotlin
// 以下代码均在 @Composable 函数中
// 焦点请求器
val focusRequester = remember {
    FocusRequester()
}
// 为需要获取焦点的TextField添加此Modifier
BasicTextField(
    modifier = Modifier
        .fillMaxWidth()
        .focusRequester(focusRequester)
)
// 请求焦点
Button(onClick = {
    focusRequester.requestFocus()
    keyboard?.show()
})
```

该操作会试图打开软键盘，如果因为各种原因软键盘暂时无法被打开，则此操作会被忽略



### 关于此系列

此系列**并非完整的系列教程，仅针对Jetpack Compose使用中的具体场景给出对应最小化代码**。目前Jetpack Compose中文资料非常少，希望我能在这方面做出自己的贡献。

- 如果要参阅完整项目，可以看我开源的

[FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件，支持多引擎、插件化~ | Jetpack Compose+MVVM+协程+Room (github.com)](https://github.com/FunnySaltyFish/FunnyTranslation/)

- 获取系列最新更新：[FunnySaltyFish's Blog - FunnySaltyFish的小站](https://funnysaltyfish.github.io/)