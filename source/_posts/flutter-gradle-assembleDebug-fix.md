---
title: Flutter卡在Running ‘gradle assembleDebug‘最完整解决
date: 2021-05-27 22:03:41
tags: [Flutter,bug修复]
categories: Bug Fix
cover: /images/bg_bug.png
---

## 前言
结合csdn+博客园+github+Stack Overflow+自己尝试，解决该问题！
今天突发奇想试一下flutter，按照网上教程配置完后（flutter doctor）全部合格，运行却卡在了Running ‘gradle assembleDebug'。打开任务管理器，AS的网络占用相当之低，一会就为0。找了各种方法，最后搞出了这一套
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124455645.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)

## 准备

 - 准备一个可以完成编译和运行的Android项目（项目A）
 - 打开你的Flutter项目（项目B）
 - Flutter的安装目录

## 多处修改

打开A项目的build.gradle，记住里面的gradle版本号
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124455504.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
继续打开此项目的app/build.gradle，记住如下数据
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124738217.png)
继续打开此项目的gradle/wrapper/gradle-wrapper.properties,记住最下面的url


![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124455515.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
打开B项目
修改compile sdk与A相同
修改build.gradle，包括如下四个地方
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124455513.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731125121188.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)

```python
maven { url 'https://maven.aliyun.com/repository/google' }
maven { url 'https://maven.aliyun.com/repository/jcenter' }
maven { url 'http://maven.aliyun.com/nexus/content/groups/public' }

```

（第一处地方请根据Android Studio提示来，没提示就不用改）

继续打开该项目下的gradle/wrapper/gradle-wrapper.properties，修改url与A项目相同

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124455511.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)


接下来打开`Flutter安装目录`
\flutter\packages\flutter_tools\gradle\resolve_dependencies.gradle
修改如下
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731124442683.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)

```python
maven {
    url "https://storage.flutter-io.cn/download.flutter.io"
}
```

继续打开安装目录下\flutter\packages\flutter_tools\gradle\flutter.gradle
修改如下地方
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020073112572950.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
其中第三个地方

```java
private static final String MAVEN_REPO      = "https://storage.flutter-io.cn/download.flutter.io";
```


修改完成！
## 运行命令
在AS中打开Flutter项目，首先**Tools-flutter-flutter clean**
完成后，在终端中**分三次输入**

```bash
cd android
./gradlew clean
./gradlew build
```
（上面的命令如果提示 .不是有效命令 ，去除./即可）

期间会下载一些东西，等待即可
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731130322788.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200731130322790.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)

完成
## 运行项目
直接debug项目，几秒钟之内完成运行！！！！！！！！

完结撒花！
若对您有帮助，请在评论区回复！！！！！！
