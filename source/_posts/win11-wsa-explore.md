---
title: 在win11安装WSA并直接调试App
date: 2021-10-21 17:38:48
tags: [探索,Android]
cover: /images/bg_win_wsa.png
---

2021年10月20日，微软”千呼万唤始出来“地发布了对WSA的初步支持，win11具备了原生运行android apk的能力

废话之前，先上图

![](https://web.funnysaltyfish.fun/temp_img/202110211723184.png)

此窗口可正常拖动、缩放大小，在任务栏独立显示

![](https://web.funnysaltyfish.fun/temp_img/202110211724861.png)

目前（2021年10月21日）该功能还是预览阶段。

话不多说，开搞



### 安装WSA

**此部分整理自酷安，在此感谢各位大佬**

首先需要确保你的计算机是**win11**最新版本且处于**beta**预览通道



1. 打开WSA 微软商店链接： [这里](https://www.microsoft.com/store/productId/9P3395VX91NR)

![](https://web.funnysaltyfish.fun/temp_img/202110211724051.png)

目前仅有美区支持，故选择确定

登录微软账号后获取子应用并安装

![](https://web.funnysaltyfish.fun/temp_img/202110211725505.png)

2. 复制打开后的的链接，到 [安装包抓包网址](https://store.rg-adguard.net/) 输入上述商店链接，右边要选择**Slow**通道

(选择Slow通道是因为目前仅有Beta有)

![image-20211021160930124](https://web.funnysaltyfish.fun/temp_img/202110211725673.png)

3. 找到最下面名为
   "MicrosoftCorporationII.WindowsSubsystemForAndroid_\*\*\*_msixbundle" 的包进行下载

![image-20211021161024423](https://web.funnysaltyfish.fun/temp_img/202110211725898.png)



4. 下载完毕后以**管理员身份**运行powershell，输入命令安装：

```bash
add-appxpackage d:\...(刚刚下载文件的路径)
```

这时候进度条可能不会变化，耐心等待即可

- 如果安装有问题：缺少框架，在上述页面下载Microsoft.UI.Xaml.2.6_2.62108.18004.0_x64__8wekyb3d8bbwe.BlockMap，进行命令行安装

5. 在菜单栏找到刚刚安装的Windows SubSystem for Android，打开

6. 点击右上角的图标，选择刚刚下载的文件

   ![](https://web.funnysaltyfish.fun/temp_img/202110211725630.png)

- 如果说未虚拟化，在`设置-应用-可选功能-更多windows功能` 开启 **虚拟机平台**并重启

  ![image-20211021161623272](https://web.funnysaltyfish.fun/temp_img/202110211725774.png)

![image-20211021161651293](https://web.funnysaltyfish.fun/temp_img/202110211725363.png)

然后就可以打开这个子系统了



### 安装应用

打开刚刚安装的Windows Subsystem for Android，开启开发人员模式并刷新下面的ip地址

![](https://web.funnysaltyfish.fun/temp_img/202110211725181.png)

打开cmd，使用adb连接

```bash
adb connect 127.0.0.1:58526
```

这个ip是上面显示出来的ip

![](https://web.funnysaltyfish.fun/temp_img/Snipaste_2021-10-21_15-34-38.png)

连接成功后，就可以用adb安装软件了

```bash
adb install APK路径
```

安装完后可以在菜单看见安装的应用

![image-20211021162540434](https://web.funnysaltyfish.fun/temp_img/202110211725576.png)



### 调试

都连接到ADB了，打开Android Studio就能调试了

![](https://web.funnysaltyfish.fun/temp_img/202110211725493.png)



#### 缺点

这种方式有几个缺点

- 应用dpi和窗口大小比较奇怪
- Android系统为11，如果你需要Android12的适配还是得模拟器
- 功能上不如AS自带的模拟器全



#### 优点

当然也有优点

- 占用内存小

  ![](https://web.funnysaltyfish.fun/temp_img/202110211725987.png)

- 更流畅
- 无需额外模拟器
- 可自由拉伸窗口，检测屏幕适配情况



