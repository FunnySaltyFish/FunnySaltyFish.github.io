---
title: 学了python不知干啥？爬爬虫！（1）爬取网络图片
tags: [爬虫,Python]
categories: Python爬虫教程
date: 2021-05-26 08:00:00
cover: /images/bg_network.jpg
---

> 生活就像淋浴：方向转错，水深火热 ——意林

## 引言
------
各位玩python的，相比对“爬虫”这个字眼并不陌生。啥？你不知道？对啦，就是需要一个不知道的……

那么，咱们的第一件事就是……  

------
## ~~概念~~      
上来一手概念，恐怕这是**最劝退**的了
咱们还是先来看看它能干啥吧

------ 
## 这只虫，能干嘛？  

 - 不打开网页，下载图片啦
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191228232539627.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
 - 不打开网页，看看小说啦
![看小说](https://img-blog.csdnimg.cn/2019122823221987.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
 - 或者保存点贴吧贴子啦，图片啦
![百度贴吧](https://img-blog.csdnimg.cn/20191228232308841.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
 - 等等……
 
什么，你说：那我要这玩意儿干嘛？我打开网页不是更快吗？
同志，男人不能一味追求快……不对，是有些事情你打开网页也不好干……
例如：
 - 获取某乎所有用户年龄组成、性别比例（诶？怎么有点像生物）
 - 获取某地区程序员平均工资
 - …
但是，这些，**爬虫都可以干！**
那么，让我们愉快的开始吧！
------
## 环境  
author：FunnySaltyFish
python：3.6
win7 x86

------
## 搞张图片
首先，让我们打开百度图片，这样搜索:
![搜索](https://img-blog.csdnimg.cn/20191228233355354.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)  
然后在你看到的这张可爱的图片上，单击右键——复制图片地址
![在这里插入图片描述](https://img-blog.csdnimg.cn/20191228233456609.png#pic_center)
*（此处使用的是360毒瘤浏览器，是的没错，360。不推荐你使用这玩意儿。其他浏览器应该也有此功能，找到类似的就好）*
*（如果你是手机编程党，比如我，推荐使用via。这款0.5M的浏览器却十分强大，包括了后面的教程中我们要使用到的网页源码查看和网页调试【安装插件的情况下】）*
接下来，我们肝代码！

## 代码
直接上！

```python
import urllib.request as ur
def save_pic():
    #打开网页
    url = 'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=95902427,199603518&fm=26&gp=0.jpg'
    #读取
    html=ur.urlopen(url).read()
    #print(html)
    #以二进制保存
    with open("D:\projects\something_download\pic.jpg",'wb+') as f:
        f.write(html)

if __name__ == "__main__":
    save_pic()
```
短？没错，就是这么短！
我们来看看这个代码干了些什么

```python
import urllib.request as ur
```
1.很明显，这玩意就是一个导库

> urllib是Python自带的标准库，无需安装，直接可以使用。
提供了如下功能：
-网页请求
-响应获取
-代理和cookie设置
-异常处理
-URL解析

简而言之，这是python官方提供的简单易上手但功能强大的库
至于它的功能，嘿嘿，我们就先不多扯了，后面再慢慢看。先往下看

```python
    #打开网页
    url = 'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=95902427,199603518&fm=26&gp=0.jpg'
    #读取
    html=ur.urlopen(url).read()
```
此处的url就是刚刚复制的图片地址，而后面的urlopen就是打开这个url啦
它的用法如下：

```python
urlopen(url, data, timeout)   
#第一个参数url即为需要打开的URL，为必选项。
#第二个参数data默认状态为空，先不管它
#第三个timeout是设置超时时间，默认为socket._GLOBAL_DEFAULT_TIMEOUT。

#执行 urlopen 方法之后，返回一个response对象。返回信息便保存在这里面。
```
通过read()可以读取到里面的内容 *（读者也可以试试不加read直接打印会输出什么）* 
由于我们获得的链接是图片直链，此处返会的便直接是图片的原始编码。接下来，只需保存就好啦！

```python
    #以二进制保存
    with open("D:\projects\something_download\pic.jpg",'wb+') as f:
        f.write(html)
```
执行后，相应文件夹即会出现对应图片  

------
  
  

#### 有点麻烦，换个方法？
其实，如果单单保存一张图片的话，urllib为我们提供好了一个方法
我们来试一下

```python
def save_pic2():
    url = 'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=95902427,199603518&fm=26&gp=0.jpg'
    ur.urlretrieve(url,"D:\projects\something_download\pic2.jpg")
```
运行结果和刚刚相同

> urllib模块提供的urlretrieve()函数。urlretrieve()方法直接将远程数据下载到本地。

```python

urlretrieve(url, filename=None, reporthook=None, data=None)

#参数filename指定了保存本地路径（如果参数未指定，urllib会生成一个临时文件保存数据。）
#参数reporthook是一个回调函数，当连接上服务器、以及相应的数据块传输完毕时会触发该回调，我们可以利用这个回调函数来显示当前的下载进度。
#参数data指post导服务器的数据，该方法返回一个包含两个元素的(filename, headers) 元组，filename 表示保存到本地的路径，header表示服务器的响应头

#懒得打字了，这里来源：https://blog.csdn.net/fengzhizi76506/article/details/59229846
#倾删
```
好啦，我们的小虫虫就下载完成了！  

------
## 所以，爬虫是啥
如果让现在的我们概括这个问题，我们应该可以这样想象：
* 互联网是一张大网（它也确实很大），爬虫就是上面的一只只蜘蛛，沿着网的触须蔓延开来，在互联网上搜索的我们感兴趣的资源（比如这张图片），然后按照我们的意愿对它进行一定操作（如我们的保存）。爬取、数据处理、保存等操作便完成了一次爬取。
* 事实上，搜索引擎就是一个巨大的爬虫，它通过一定的方法遍历搜索范围内的所有节点（如你喜欢看片……片子，你可能就会走遍你附近的所有影院），并将它们按一定的索引（比如你的口味）建成一个巨大的数据库（比如记在小本本上）。然后，当用户需要搜索需求（比如你饥渴了）时，就可以按照这个索引（如你编好的小本本）用特定的方法找到对应的资源。
 *（实际上，网络爬虫的概念并不那么简单，感兴趣的可以阅读[这里](https://baike.baidu.com/item/%E7%BD%91%E7%BB%9C%E7%88%AC%E8%99%AB/5162711)看一看）*

## 其他

 - 你可以试着用这样的方法保存其他图片，然后不出意外，有些地方的图片你一定会遇到问题。我们之后再扯
 - 爬虫的应用场景很广泛，绝对不止保存图片。下一次，我们将尝试读取网页进行操作，敬请期待
 - 我的水平不高，所讲之处难免有所漏洞，还望指正

## 后续
- [系列文章完整目录](https://funnysaltyfish.github.io/2021/05/24/python_spider_lesson_catalog/)
