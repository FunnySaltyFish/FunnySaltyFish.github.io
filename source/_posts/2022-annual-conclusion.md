---
title: 一条咸鱼的2022 | 掘金 & 开源 & 项目
date: 2023-01-08 13:33:28
tags: [年终总结]
categories: [年终总结]
cover: /images/bg_me.jpg
---

Hi 各位好，我是咸鱼。第一次尝试动笔，总结过去的一年，也算一种奇妙的感受吧。

## 咸鱼
我的 ID 是 “FunnySaltyFish”，直译过来是 “有趣的咸鱼”，或者 “滑稽的咸鱼”。这当然带有一点自嘲的属性。做一条咸鱼代表着我的生活态度：不做计划、没有规划、过一天是一天；但也有另一方面：也不能一直躺着，躺久了这一面就糊了，总该翻翻身，做点什么。于是便想想回忆一下，看看过去一年终究是做了些什么。

## 掘金
如果翻看我的文章列表，第一篇的时间定格在2020年8月。那是我主要混迹于 C\*\*N，偶然间了解到掘金这个平台，于是便随手注册了个账号，丢了两篇文章过来。现在回过头看，那两篇文章都创作于我的高中时期，还是用手机码出来的，字里行间承载着属于年轻人独特的骚气，也算是某种程度的黑历史了（笑）。  
正式开始在掘金写作要到 2021年7月，那时恰逢 Jetpack Compose 发布 Beta 版，我开始接触这一新技术。彼时国内关于这方面的中文资料非常少（可以说是几乎没有），而我又受够了 C\*\*N 漫天垃圾的氛围，于是便跑到之前偶然注册的掘金，想着看一看。令人惊奇的是，我之前随意投稿的两篇文章竟然都被推荐上了首页，获得了远多于 C\*\*N 的阅读量。看着掘金优秀的技术氛围，我开始了在掘金的投稿之路。
回到今年，不算这篇，我一共写下了 22 篇文章。年度报告给我的数据如下：
<p align=center><img src="https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e585529d12754475a622eeb3a51c8421~tplv-k3u1fbpfcp-watermark.image?" alt="2022掘友年度报告_03.png" width="30%" /></p>
<p align=center><small>在年度报告出来后，我又写了一篇，因此数据差了一篇</small></p>

在这 22 篇中，16 篇内容都是关于 Jetpack Compose ，毫无疑问占据了最大的块头，占比达 72% 。这之中我自己觉得最有趣的是 [JetpackCompose自定义布局+物理引擎=？](https://juejin.cn/post/7103824524876972046)，成功实现了我高中时萌生的想法，把物理引擎和自定义布局结合在了一起，做出了下面这样的效果 

<p align=center><img src="https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eb2694fea1b14df7b49b4b789b7b7a2b~tplv-k3u1fbpfcp-zoom-in-crop-mark:3024:0:0:0.awebp?" alt="tupian"  width="40%"/></p>

其余的文章大多集中在 Jetpack Compose 入门及以上的知识，比如写了 5 篇的[自定义布局系列](https://juejin.cn/post/7063451846861406245)、一些新功能（如 [LazyGrid](https://juejin.cn/post/7100120556192104484)、[瀑布流](https://juejin.cn/post/7165805186118582308)等）的介绍，还有[两篇](https://juejin.cn/post/7144750071156834312)介绍自己写的开源库，几篇性能优化和调试（已过时，AS提供了）还有其余杂七杂八的。

剩下的文章中，两篇阐述我自己对 Kotlin 优雅代码理解的文章: [写出优雅的Kotlin代码：聊聊我认为的 "Kotlinic"](https://juejin.cn/post/7124676793801392136) 和它的续文是最今年我的文章中阅读量和点赞数最多的，也可能也证明了**偏基础和大众化的文章更容易获得阅读量**。同时也很感谢 @[fundroid](https://juejin.cn/user/3931509309842872) 大佬对此文的肯定，将其收录到了他的公众号 AndroidPub 中。这是我首次获此殊荣。这里也给大家推荐一下这位大佬，写的文章质量都很高。

最后的 4 篇文章，两篇介绍语言的新变化（[Python 3.11.0](https://juejin.cn/post/7159929819365376007) 和 [Kotlin 1.7.0](https://juejin.cn/post/7109486077127327780)），均是来自官方文档和相关**英文**介绍；剩下两篇分别写了写 [Python 的 Type Hint](https://juejin.cn/post/7146579580176842783) 以及 [目标检测的几篇论文](https://juejin.cn/post/7159217471830884360) ，后者改自某门课程的大作业，和我的好友 @Zee（他不在掘金） 共同完成。

总的来说，今年的文章主要以 Jetpack Compose 为主，这也是我这一年主要的技术点。我的大部分文章相对来说都写的是较新的技术，很多直接参考自英文的博客、视频、文档；事实上，创作它们的缘由就是我偶然间读到这些非常不错的英文资料，正好没什么事干，就动笔开始把它们写成中文，并在有时加上自己写的一些代码作为补充。这中间其实有些困难，有些新技术因为没有中文文档，没有对应的中文译文，所以我要尝试自己翻译专有名词。印象比较深的是 Kotlin 1.7.0 的 " T & Any" (definitely non-nullable types)，我很纠结是翻译成 “绝对非空”、“定然非空”、“断然不可空”、“肯定不是空”或者其他乱七八糟的词汇，最后为了不引起歧义，选择了直白的 “明确非空” 写在了文章里，当然后面来看，这个似乎和官方译法有差异，不过应该能表示出它的意思。

就我自己来说，大部分文章的创作时间在 3-6h，这包括写代码、写文章、调格式等，有少数文章写的非常久（图像识别那篇写了3天，Kotlinic 那篇则写了一星期），当然也有一些比较短的，一个多小时就写完了。总的来说，它们质量还算勉强可以。我也很高兴**在 11、12 两月上了两次“掘金一周”**，感谢官方的认可。

今年有很多活动，我自己也参加了不少，比如金石计划等；但每个活动写的文章都不算多。一方面是自己比较懒，另一方面在于，我内心里还是觉得，在掘金写的文章，起码要对文章质量负责，不能为了拿钱、拿东西、拿奖品而水。我相信大家相聚在掘金，有不少原因是因为厌倦了互联网搜索时漫天的C\*\*N抄袭、复制、连格式都粘贴不全的垃圾、厌倦了各内容农场不分质量、不分版权的肆意爬取、厌倦了所谓技术大V贩卖焦虑、营销卖课的商业文章。相较而言，掘金至少是一片技术人的乐园。  

写这段话的时候，我正在看“金石计划（2）”的[开奖表格](https://bytedance.feishu.cn/sheets/shtcnCkiavELP6O3I4DwAQMPxdc)，惊奇的发现“优质挑战-瓜分名单”中竟然有不少不通过的文章，它们的理由包括“一篇分为多篇发”、“非原创”、“非技术文”，甚至还有一长条的“凑字数”，未免令人咂舌。当我参与这个活动投稿时，我在想自己的文章会不会有点水，这里写的是不是有点歧义，这篇文章是否有其他人写过并且写得更好。我秉持着朴素的态度：**“金石”代表着茫茫砂砾中的点点金芒，而不是漫天废纸中的其中一张**。作为 LV4 的创作者，我个人认为，既然要为这广袤的中文互联网留下自己的印记，那还是该留点有价值的；至少不能让后人看着，内心只有骂娘。  

写到这里突然想来句声明：我并非孤高的标榜自己的文章有多么多么好，事实上，它们或许只能算是能看的程度；我也很少会对自己写的东西做逐字逐句的校对和修改，只是确保整体没有大错误 *（以我当时作文的知识水平）*、格式基本正确、基本没有错别字就发了。但至少我骄傲的一点是，到目前为止，**从我来到掘金写的 32 篇文章，每一篇都被推荐了**。也很感谢掘金审核人员对它们的认可，这也是我坚持在掘金作文的原因之一。

## 开源
### 自己的
第二个 Part 就是开源，上文也提到，我今年主要的技术点主要都在 Jetpack Compose ，因此做的也是这方面的内容。毕竟从小心思来说，目前 Jetpack Compose 做的人比较少，说不定做成的概率大一些。目前来看，我写的有关这方面的开源库包括如下的：
- [FunnySaltyFish/ComposeDataSaver: 在Jetpack Compose中优雅完成数据持久化](https://github.com/FunnySaltyFish/ComposeDataSaver)：用于把数据持久化的读/写过程与 State 绑定在一起，今年提交了 28 次 Commit，维护了 6 个版本，目前有 18 个 Star
- [FunnySaltyFish/JetpackComposePhysicsLayout: Jetpack Compose custom layout that simulates physics using JBox2D](https://github.com/FunnySaltyFish/JetpackComposePhysicsLayout) 上文提到的把 物理引擎和 Jetpack Compose 自定义布局结合起来的布局，目前有 9 个 Star
- [FunnySaltyFish/CMaterialColors: Compose Material Colors - All you need to use Material Colors in Jetpack Compose projects! | 在Jetpack Compose中使用MaterialDesign Color](https://github.com/FunnySaltyFish/CMaterialColors) ：非常简单的基础库，包含了所有 Material Design 的颜色，便于在 Jetpack Compose 中使用，目前有 10 个 Star

这么一总结发现也没啥特别的，这些 Star 虽然在大佬严重只是毛毛雨，但对我来说，每一颗都是来之不易，都是陌生人对我项目的认可，这也是我维护它们的动力。  

放一张我稀稀疏疏但是又似乎也不少的 Github 提交图

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/442d4f82674b4f319c080199fe11a7ed~tplv-k3u1fbpfcp-watermark.image?)

### 别人的
除了自己写，我也尝试参与了别的一些开源项目。最感谢的就是 [compose-museum/jetpack-compose-book](https://github.com/compose-museum/jetpack-compose-book) ，这是 Compose 中文社区维护的 Jetpack Compose 中文学习文档，在这里我收获了第一份被 Merge 的 PR。我也为这个项目带去了 Docker-Compose 的部署方式、[自建镜像站](https://compose.funnysaltyfish.fun/docs/) 以及部分文章的更新。开源万岁！

另外为 [leavesCZY/Matisse: 一个用 Jetpack Compose 实现的图片选择框架 ](https://github.com/leavesCZY/Matisse) 尝试提交了份 PR，但很遗憾由于写得不成熟并未合入，之后我陷入了一段时间的忙碌未再补完；为 [cgspine/emo: some android libraries to speed up development.](https://github.com/cgspine/emo) 、Kotlin Android Plugin、Jetpack Compose 提交了几个 Bug。这些零零散散的，写在这里权当记录了。

### 活动
很有幸的是，受 @fundroid 大佬的邀请，我参加了今年 GDG 北京举办的 “谷歌开发者节2022”，并在 Compose Camp 中有幸成为了“评委”。


<p align=center><img src="https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0644b02ca7064d0385a3720b9487e734~tplv-k3u1fbpfcp-watermark.image?" alt="1672385013083.jpg"  width="60%"/></p>

更重要的是有幸在现场见到了几位大佬，同他们做了交谈。尽管技术出众、经验丰富，大佬们也依然保持着平易近人的态度，同大家亲切交流，耐心的解答台下参与者的问题。**我觉得**这估计是技术人间的特有的某种氛围吧，再华丽的吹嘘也比不上手敲出的几行代码，"Talk is cheap, show me your code"。

我也听了两位大佬 @[bennyhuo](https://juejin.cn/user/1187128286120631) 和 @[朱涛的自习室](https://juejin.cn/user/2119514149637032) 分别带来关于 Android项目优化 和 Android XR 元宇宙相关的演讲，学到了不少知识。两位佬在各自领域上的专业也令人佩服。不过感觉比较遗憾的是，鉴于现场演讲台位置的摆放，有部分 PPT 并看不清；另外我**个人感觉**演讲者可以更多一些，每位演讲者的内容做精炼，类似于 Android Developers 发布的 [5 quick animations to make your Compose app stand out](https://www.youtube.com/watch?v=0mfCbXrYBPE&list=PLWz5rJ2EKKc_L3n1j4ajHjJ6QccFUvW1u&index=7) 这一系列视频，以 5 - 20min 的形式简洁、清晰的介绍某个特定主题，这样在总时长不变的情况下或许能更丰富？只是点粗浅的想法，写在这里仅供讨论。


## 项目
### 译站
[FunnySaltyFish/FunnyTranslation: 基于Jetpack Compose开发的翻译软件](https://github.com/FunnySaltyFish/FunnyTranslation) 是我目前坚持维护的小项目，简单来说是一个翻译小软件，也是一个开源项目，发布在了 [酷安 (coolapk.com)](https://www.coolapk.com/apk/com.funny.translation) ，截止写文时有 7899 个下载（以及其他约 1000 次应用内更新的）。自然，对很多大应用来说，这点下载量连零头的零头都不到，对我来说确，这是过去三年的见证。  

译站诞生于我的高中时期，当时脑海里有好几个想法，但碍于学业繁忙，都没有能力实现。某一天，我偶然蹦出了这样的想法：能不能够把一个源文本丢给几家翻译软件进行翻译，并把结果汇总，这样也有助于横向对比。我当时觉得这事儿简单啊，就一个 for 循环的事，可以写！于是，在连续捣鼓了几个周日后，译站的第一版诞生了。

维护到现在，译站的定位其实变成了我学习技术上的练手项目。我相信大家很多有感触，学习技术，总是要动手才学的踏实。对我而言，这个动手的应用就是译站。几年过去，译站也从 `Java+View，Material Design，无后端` 逐渐变成了目前的 `Kotlin+Compose，Material You，有后端`。它也逐渐变成了一个开源项目，希望对那些学习 Jetpack Compose 的同学有所帮助。

说到后端，今年主要的更新也就在后端上。作为个人开发者来说，做应用自然是全揽。从购买服务器、购买域名、配置域名解析，到编写 Flask 代码、nginx 反代，到数据库的配置与连接，再到后面配置 https、cdn、对象存储……属于是学习了很多。到目前，译站的后端有用户系统（包括发注册邮件、找回用户名、找回密码等），支持指纹登录，核心接口做了简单的校验，对某些异常调用有简单的 Limit 处理。诚然以各位观众的目光来看，这些代码很容易、很简单，不用考虑高可用、高并发，与实际生产环境还有天差地别；但对于我来说，看着自己（和 Copilot）敲下的代码一行行完善这个系统，也还是蛮有成就感的。

### 网页
除了维护一个 Android 应用 + 对应的后台外，我今年还因为自身需要，开发并维护着两个网页。一个是可以快速摘要网页链接的 [网页引用生成器](https://web.funnysaltyfish.fun/link2ref/page?source=jj)、另一个则是以神奇方法做论文降重的：[咸鱼的论文降重器](https://web.funnysaltyfish.fun/jc?source=jj)。

### 杂七杂八

除此之外，因为各种原因，我今年甚至还零散地写了些 Vue3+TS 、SpringBoot2  的代码，作为一个业余的开发者，属于是写的很杂了。太凌乱的技术栈也不大好，总归还是要得有自己精通的某项，留给今后加油。二者目前和译站一样，都是免费的为爱发电产品。


 
## 其他呢
上面差不多就是我的年终总结了。你可能会说，不对呀，别人的年终总结说一说找工作、保研、生孩子、买房买车、旅游……怎么你这都没有？  

怎么说呢？我很喜欢乌贼小说《诡秘之主》里的主人公，他是守夜人克莱恩，也是“世界”格尔曼，也是富豪道恩，也是魔术师梅林。或许这样不同的身份有助于帮助自己划清边界。正如开头所言，我是“咸鱼”，所以写写“咸鱼”这一年干的事，别的嘛，限于篇幅就跳过吧（笑）。

## Flag

我没有立过 Flag，今年不如尝试立一下
- 保持健康，健康最重要
- 提高英语水平，尤其是听说方面
- Jetpack Compose 写 10 篇原理性文章
- 总 Github Stars 争取到 300（目前 134）
- 在 Stack Overflow 上多回答问题，争取有一定名气
- 继续维护当前的项目

