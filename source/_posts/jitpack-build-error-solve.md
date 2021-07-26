---
title: Jitpack.io ERROR No build artifacts found一路踩坑的解决【Gradle 7.0+,Kotlin 1.5+】
date: 2021-07-26 18:15:04
tags: ["Jitpack"]
cover: /images/bg_jitpack.png
---

前段时间上传我的项目[CMaterialColors](https://github.com/FunnySaltyFish/CMaterialColors/)到Jitpack时一直出现错误，最早报出的错误是：

> Found artifact: com.funny.cmaterialcolors:release:1.0.0
Found artifact: com.funny.cmaterialcolors:release:
2021-06-15T08:52:13.4704949Z
Exit code: 0
ERROR: No build artifacts found

实话说当时非常无语，经过几次失败的尝试后我决定去看看完整的报错日志，然后发现了中间其实就有报错：

> An exception occurred applying plugin request [id: 'com.android.application']
> Failed to apply plugin 'com.android.internal.application'.
   > Android Gradle plugin requires Java 11 to run. You are currently using Java 1.8.
     You can try some of the following options:
       - changing the IDE settings.
       - changing the JAVA_HOME environment variable.
       - changing `org.gradle.java.home` in `gradle.properties`.


意思是要去修改默认的Java编译环境，查阅Jitpack官方英文[文档](https://github.com/jitpack/jitpack.io/blob/master/BUILDING.md)，找到了如下解决措施：
> You can create a jitpack.yml file in the root of your repository and override the build commands:

```yml
jdk:
  - openjdk9
```
翻译成中文就是：
- 在**项目根目录**创建文件`jitpack.yml`
- 在里面添加上述文本即可指定编译用的Java版本

于是，在解决完了这个问题后，我怀着信心满满的心情再次提交，而这一次……
然并卵，错误还是存在……

老实说这个错误真是非常迷惑的。我又尝试了一些方法，均未果。然后没办法，继续回去看文档呗。
我项目里面用的是`maven-publish`插件，官方文档说执行的命令是

> ./gradlew build publishToMavenLocal

然后在终端里面试了试，发现居然报错了！
然后又是按对应的报错改Bug，直到本地可以正常执行此命令
改完之后信心满满的提交，结果新的错误产生了……

```bash
Could not resolve compiler classpath. Check if Kotlin Gradle plugin repository is configured in project ':app'.

FAILURE: Build failed with an exception.

* What went wrong:
Could not determine the dependencies of task ':app:compileReleaseKotlin'.
> Could not resolve all files for configuration ':app:kotlinCompilerClasspath'.
   > Cannot resolve external dependency org.jetbrains.kotlin:kotlin-compiler-embeddable:1.5.10 because no repositories are defined.
     Required by:
         project :app
```

我TM！！！
网上搜根本搜不到对应的解决措施，没办法一点点改呗。
又试了几次，还是不行。
这时想到了一个办法，我开始去翻Github，找与我的项目使用的依赖库相似的项目（kotlin 1.5，Gradle 7.0，Compose 1.0.0-rc01），然后对照它的项目文件一个个看。
最后找到了差异，我的`lib/build.gradle`里面少写了这一行：

```bash
// kotlin
implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"
```

终于，在版本都累加到`1.0.21`后，我终终终终终于提交成功了！
![终于](https://img-blog.csdnimg.cn/9fdcfa0d460e44bea18538ff9999a8cf.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

那一刻，真的，难以言表！！！

最后吐个槽，各位博主大大抄袭文章能不能有个限度，nm各个文章都在用着早已被废弃的插件，jdk11的问题都没得人指出。简直了。。。

**如果你需要参考对应文件，可以点击这个开源库：[CMaterialColors](https://github.com/FunnySaltyFish/CMaterialColors/)**