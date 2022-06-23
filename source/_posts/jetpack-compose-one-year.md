---
title: 【杂谈】我用 Jetpack Compose 的这一年
tags:
  - Jetpack Compose
cover: /images/bg_jetpack_compose.jpeg
date: 2022-06-23 13:36:50
---

关于这篇文章，其实本来并没有什么写作计划。触发它诞生的事情是，今天早上，QQ空间给我推了这样一条消息：

![image-20220608164528747](http://img.funnysaltyfish.fun/i/2022/06/08/62a061b06cc63.png)

一年前的今天，我敲下了第一行的`Hello Android for Jetpack Compose`，而到今天，我的个人小项目 [译站](https://github.com/FunnySaltyFish/FunnyTranslation) 早已全面转向 Jetpack Compose 。关于 Compose，我也写了几个简易的开源库、作了几篇小文章。所以今天，不妨来谈谈我接触 Compose 的这一年。

*本文 **不是技术文** ，其中观点仅代表我个人。受限于本人技术水平，难免有误，还望您包容谅解*



### 初

我接触 Compose 的时间应该还算较早，虽然不是最早的一批，但也算是那时的少数（至少我以为）。彼时，Google 发布 **beta** 版本，尚且只有 `AS` 的 `Beta` 版本支持。为了体验，我将一直使用的`AS Stable`切成了`AS Beta`，用默认模板敲出了第一行代码。

我是一个对新技术很感兴趣的人，这可能也是我去学习 Compose 的原因。声明式UI的概念虽然相较`View`很新奇，但鉴于我接触过`Vue`和`Flutter`，所以也还能上手。

上手是可以上手，但奈何资料确实不多，尤其是中文的。对我来说，早期学习 Compose 的资料基本主要来自`Google官网 ` 和 `Youtube` 。看着英文资料和视频，我逐渐学会了使用`Row`和`Column`，学会了要`remember`，学会了几种副作用的使用，学会了`animate*AsState` 和 `animateVisibility`……这段过程中，Youtuber [Philipp Lackner](https://www.youtube.com/c/PhilippLackner) 的 [Creating Your First Jetpack Compose App](https://www.youtube.com/watch?v=cDabx3SjuOY&list=PLQkwcJG4YTCSpJ2NLhDTHhi6XBNfk9WiC) 系列对我帮助很大，在此也遥远的表示感谢。

于是，在漫不经心地刷了些视频和文档后，我对 Compose 有了个大体的认识。于是我也想为中文资料做点力所能及的贡献，于是参考这个[视频](https://www.youtube.com/watch?v=ktOWiLx83bQ&list=PLgCYzUzKIBE_I0_tU5TvkfQpnmrP_9XV8&index=20)和当时的官方教程，写了第一篇关于`Compose`的文章

- 2021/07/29  [Jetpack Compose异步加载图片的实现 - 掘金 (juejin.cn)](https://juejin.cn/post/6990203393964769317)

这篇文章的内容其实现在已经过时了，但在当时，`Compose`中文资料不多的情况下，它的搜索指数居然出乎意料的高。现在你搜索关键词`Jetpack Compose 加载图片`，可能在前几个结果中还能看到它。

写了文章之后，过了几天，我又感觉除了文章外好像没这方面的中文视频。于是我开了个`New App`，尝试录了几个视频介绍一些简单概念

![image-20220608171648685](http://img.funnysaltyfish.fun/i/2022/06/08/62a0690128c40.png)

录了三个之后我鸽了，好吧，这视频的质量实在是不咋滴。没得设备和技术，而且录视频也是个技术活。但是既然学了，肯定要用啊。于是，我把目光转向了我自己的小项目，译站。



### 译站

它是我2020年初写的一款简单的翻译小应用，最早是用`View`实现的。秉持着以用代学的想法，我开始了对这个应用的`Compose`化。

到九月份，我基本实现了它的主页面。

![image-20220608172219346](http://img.funnysaltyfish.fun/i/2022/06/08/62a06a4b9df85.png)

*（忽略这粗犷的 commit ……）*

其实这里要说明的是，Compose 的迁移其实并没那么困难。Android 官方提供了非常棒的工具，允许你在`View`项目中部分使用`Compose`、或者在`Compose`中部分使用`View`。如果你原先的架构合理，`View`和`Model`没有非常强的耦合，那么其实改造起来很容易。`LiveData`或者`Flow`都可以通过`.observeAsState`一键转换成可以在 Compose 中使用的 State（Compose 的 UI 由 State 驱动）。我这里之所以花了那么久，有两个原因：

- 一是我正好在重构代码的全部逻辑，包括一些类的分离、一些流程的改变等。秉持着一不做二不休的想法，我选择了把页面全部用 Compose 重写（而不是只改变一部分），故而比较花时间
- 二是有一些很简单的效果实现起来并没有那么容易，尤其是在中文资料极度匮乏的情况下。出了问题或者想实现什么效果，除了翻官方的网站就是翻 `Github`，这也比较花时间。

总之，在各种折腾下，译站的 Compose 版本也逐渐重构完成了，并在那之后均用<small>（准确来说除了悬浮窗和CodeView）</small> Compose 完成各种 UI 效果。



### 不断学习与博客

其实对我个人来说，开始学习 Compose 的时候有一个很困惑的点：不知道学完基础之后该学啥了。一方面是资料确实不多，而且视频教程也都是围绕着基本控件之类的来讲；二是我自己没有很大的东西去细究 Compose 的实现。于是三天打鱼两天晒网的，在不断更新应用的间隙间，也偶尔地学习一些新东西。

这里很感谢的一份资料是 [RugerMc](https://juejin.cn/user/1714893871911502) 大佬牵头做的 [jetpack-compose-book: Jetpack Compose 基础教程，持续更新 ](https://github.com/compose-museum/jetpack-compose-book) ，很详细的介绍了 Compose 各个方面的使用。对于现在**卖课混杂、培训遍地、营销漫天**的中文互联网社区环境来说，这样无私的技术分享、开源布道的精神真是说得上不多见了。我自己也为这个项目提了绵薄的几个PR。互联网技术的精神应当在于包容、共享、探索、钻研，至少我是这样觉得的。

这段时间，不少大佬们的博客也在惊艳着我，比如[程序员江同学](https://juejin.cn/user/668101431009496/posts)、[fundroid](https://juejin.cn/user/3931509309842872)、[Petterp](https://juejin.cn/user/3491704662136541)、[路很长OoO](https://juejin.cn/user/4019470242152616)等，在我学习 Compose 的路上，他们的文章给了我很大帮助，再次均表示感谢。

对我来说，尽管我是一个很懒的人，但我还是也尝试着写起了 Compose 相关的文章。一是助于自己提升，二是为中文资料做点绵薄贡献。一点点，到现在我也已经写了13篇[关于 Compose 的文章](https://juejin.cn/column/7024350372680433672)了。或许不足为道，但若是有人看到，说，这个不错，对我有帮助，那便足够了。

其中我自己觉得比较好玩的是 [Jetpack Compose 自定义布局+物理引擎 = ？](https://juejin.cn/post/7103824524876972046) 这一篇。在那里，我用 Compose 自定义布局实现了这样的效果

![PhysicsLayout演示_.gif](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eb2694fea1b14df7b49b4b789b7b7a2b~tplv-k3u1fbpfcp-zoom-in-crop-mark:1304:0:0:0.awebp?)



没有用，但很有趣。这个想法出现在我高三的时候，但是一直觉得会很难就一直不想做，直到前几天下定决心做了做。在巨人的肩膀上，花了两天就实现了。感觉也蛮有成就感的。如果您感兴趣，可以在[Github](https://github.com/FunnySaltyFish/JetpackComposePhysicsLayout)查看完整源代码



### 总结

说点正题的话，就我个人而言，我觉得 Compose 开发有以下优劣：

**优**

- 代码即 UI，灵活、迅捷 *（比如  for 循环创建几个控件，if 判断显不显示）*
- 对各种需求高度、统一的封装  *（通过 `LocalXXX` 和 `rememberXXX` 获取和操作各种东西，动画、软键盘、状态栏…… ）*
- 允许逐步迁移  *（ View 体系 和 Compose 体系可良好共存）*
- 字面量热重载  *（对于类似于 大小、字符串 的修改可直接反映到 App 上）*
- 快速的 UI 搭建，无需过多考虑嵌套



但就目前来说，也有些问题

- 部分硬需求尚不完善，比如还没有瀑布流布局等
- 性能（如 滑动列表）上较传统 View（如 RV）仍有差距
- 目前中文资料较为欠缺，部分需求实现需要自己摸索
- 精通难度大（ Compose 编译原理、性能优化等）



如果你是一个希望尝试的同学，我个人推荐这些资料（它们是免费的，如果你想学付费的请自行寻找，我不卖课）：

-  [RugerMc](https://juejin.cn/user/1714893871911502) 大佬牵头做的 [jetpack-compose-book: Jetpack Compose 基础教程，持续更新 ](https://github.com/compose-museum/jetpack-compose-book)
- 上面提到的各位大佬的博客
- 开源项目
  - 官方例子：[android/compose-samples: Official Jetpack Compose samples. (github.com)](https://github.com/android/compose-samples)
  - 官方例子：[android/nowinandroid: A fully functional Android app built entirely with Kotlin and Jetpack Compose (github.com)](https://github.com/android/nowinandroid)
  - Compose 复现的 网易云音乐，很多常用效果里面都实现了。来自掘金的[sskEvan](https://juejin.cn/user/1856402275178407)。[sskEvan/NCMusic: Jetpack Compose仿写网易云音乐 (github.com)](https://github.com/sskEvan/NCMusic)
  - 译站，鄙人的小项目，属于毛遂自荐了：[FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件，支持多引擎、插件化~](https://github.com/FunnySaltyFish/FunnyTranslation)