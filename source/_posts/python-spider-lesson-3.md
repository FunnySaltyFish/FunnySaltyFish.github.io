---
title: 学了python不知干啥？爬爬虫！ （3）爬取豆瓣书籍列表（bs4/lxml简单使用）
date: 2021-05-26 16:44:42
tags: [爬虫,Python]
categories: Python爬虫教程
cover: /images/bg_network.jpg
---

爬取豆瓣书籍列表
> 合理爬取，不随意扩大站点压力
> 本文章仅作示例，请勿用作非法用途

该系列的其他篇目：

[系列文章完整目录](https://funnysaltyfish.github.io/2021/05/24/python_spider_lesson_catalog/)

----
 
## 效果

&emsp;&emsp;解析豆瓣书籍列表，包括作者/介绍/评分，如下图

![效果](https://img-blog.csdnimg.cn/20200710091736191.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
## 开始
&emsp;&emsp;和上文一样，我们先去网页端看看我们准备获取的数据
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710091939466.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;随便点进去一个子分类
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710092001416.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;右键——查看框架源代码 *(Edge，其他浏览器请自行对应 )* 
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710092218491.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;哇塞，又是一下子就找到了。
![在这里插入图片描述](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9zczAuYmRzdGF0aWMuY29tLzcwY0Z1SFNoX1ExWW54R2twb1dLMUhGNmhoeS9pdC91PTM3MTE3MjEzMzQsMzMxODY1NTMzMiZmbT0yNiZncD0wLmpwZw?x-oss-process=image/format,png#pic_center)
&emsp;&emsp;接下来，开始爬取！

## 试爬取
&emsp;&emsp;根据前几节课的，我们写一版简单的代码试试
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710092515203.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;执行一下！
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710092553166.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;woc！报错！我们来看看这个418是个什么错误

> 错误描述：经过网上查询得知，418的意思是被网站的反爬程序返回的，网上解释为，418 I’m a teapot
The HTTP 418 I’m a teapot client error response code indicates that the server refuses to brew coffee because it is a teapot. This error is a reference to Hyper Text Coffee Pot Control Protocol which was an April Fools’ joke in 1998.
翻译为：HTTP 418 I’m a teapot客户端错误响应代码表示服务器拒绝煮咖啡，因为它是一个茶壶。这个错误是对1998年愚人节玩笑的超文本咖啡壶控制协议的引用。

好吧，我们又被bang了，但是没关系，我们有乔装术！
## UA伪装
&emsp;&emsp;同上节课一样，我们看一下自己的UA
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710092826689.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
（顺带一提，在这个过程中，我发现了一个豆瓣很有趣的玩意：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710092945695.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
挺神奇的）
&emsp;&emsp;依葫芦画瓢，简单伪装一下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020071009313864.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
真的是非常的amazing啊，搞定了！
## 解析数据
&emsp;&emsp;有了网页，我们开始解析数据。
&emsp;&emsp;前几节课我们一直使用的是纯**正则表达式**，但是既然是学习，我们来整点不一样的
### BeautifulSoup4
&emsp;&emsp;看到这个题目，你会不会以为我打错了？美丽的汤？这是什么玩意？
&emsp;&emsp;事实上我没有打错，bs4是Python爬虫中相当著名的一个包，在解析html时非常易于使用。当然，它也有自己的弊端，例如相较于re，用它解析大量数据速度会慢很多。当然这里并不影响。
&emsp;&emsp;如果想学习bs4的话，可以先访问[这里](http://www.jsphp.net/python/show-24-214-1.html)，看一下它的基本使用。接下来我们就直接开始。
#### 安装

使用pip安装

```powershell
pip install beautifulsoup4
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710093921939.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

#### 使用

```python
from bs4 import BeautifulSoup
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/2020071009401278.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;将获取到的html文本作为参数传入，实例化一个BeautifulSoup对象，使用默认的html解析器
&emsp;&emsp;然后我们使用`find_all`方法找到`href属性中包含subject的所有标签`并且打印试一下
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710094337112.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
amazing啊，一下子就找到了所有！
如法炮制，我们再找一下其他的

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710094738986.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;然而到这里我发现了一个小问题，我们分别提取了 书名、作者、简介，这是这样合在一起似乎不太方便。所以我决定换一种思路，按照豆瓣一本书一本书的爬取，然后再分别提取。
&emsp;&emsp;我们来看看它们的一本书对应的代码是怎么写的

```html
<div class="detail-frame">
<h2>
<a href="https://book.douban.com/subject/35023731/">怪诞故事集</a>
</h2>
<p class="rating">
<span class="allstar00"></span>
<span class="font-small color-lightgray">
</span>
</p>
<p class="color-gray">
                        [波兰] 奥尔加·托卡尔丘克 / 浙江文艺出版社 / 2020-7
                    </p>
<p class="detail">
                        诺奖得主奥尔加·托卡尔丘克小说集，讲述了十个怪诞、疯狂、恐怖和幽默的故事，融合了民间传说、童话、科幻、宗教故事等 
元素来观照波兰历史与人的生活。
                    </p>
</div>
```
&emsp;&emsp;可以看到，每本书都在class="detail-frame"的div里面。按照这个要求，我们重新爬取全部书籍列表。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710094844388.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
接下来分别解析
### 使用lxml
&emsp;&emsp;对于这样的单独提取出来的\<div\>\<\/div\>来说，直接用html解析方式怕是不ok了，那我们怎么办？难道又回到写正则的苦逼日子？
&emsp;&emsp;不要慌，bs4的解析器除了"html.parser"，还可以直接使用lxml。
&emsp;&emsp;什么是lxml？

> lxml是python的一个解析库，支持HTML和XML的解析，支持XPath解析方式，而且解析效率非常高。这个库的主要优点是易于使用，在解析大型文档时速度非常快，归档的也非常好，并且提供了简单的转换方法来将数据转换为Python数据类型，从而使文件操作更容易。
XPath，全称XML Path Language，即XML路径语言，它是一门在XML文档中查找信息的语言，它最初是用来搜寻XML文档的，但是它同样适用于HTML文档的搜索
XPath的选择功能十分强大，它提供了非常简明的路径选择表达式，另外，它还提供了超过100个内建函数，用于字符串、数值、时间的匹配以及节点、序列的处理等，几乎所有我们想要定位的节点，都可以用XPath来选择
XPath于1999年11月16日成为W3C标准，它被设计为供XSLT、XPointer以及其他XML解析软件使用，更多的文档可以访问其官方网站：https://www.w3.org/TR/xpath/

体验一下？
#### 安装
依旧使用pip安装

```powershell
pip install lxml
```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710101034281.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
#### 结合bs4使用

 - 书籍名在 h2标题下
 - 作者信息在 class为color-gray的 p标签下
 - 简介在 class为detail的 p标签下

![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710101228724.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70)
&emsp;&emsp;但是很尴尬的是，这样做在执行到后半部分的时候会报错
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710101228674.png)
&emsp;&emsp;原因是有一部分书籍的 简介 直接放在了 p 标签下，而并没有class属性。这也算是一种特殊情况吧（嘤嘤嘤）
&emsp;&emsp;没有办法，处理一下特殊情况。完美
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200710101736498.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

&emsp;&emsp;最后闲的蛋疼，我们再把评分补上。大功告成！
## 完整源码

```python
#FunnySaltyFish 2020/07/09 完成
#基于Python 3.7.0
import urllib.request as ur
from bs4 import BeautifulSoup
import re


def get_html(url):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36 Edg/83.0.478.61'
    }
    request = ur.Request(url=url, headers=headers)
    html = ur.urlopen(request).read()
    return html.decode('utf-8')


def parse_html(html):
    soup = BeautifulSoup(html, 'html.parser')
    # books_list = soup.find_all(href=re.compile(r"https://book.douban.com/subject/"))
    # authors_list = soup.find_all(class_=re.compile("color-gray"))
    # details_list = soup.find_all(class_=re.compile("detail"))
    # print(books_list)
    # print(authors_list)
    # print(details_list)
    detail_frames = soup.find_all(class_=re.compile("detail-frame"))
    result_list = []
    for each_detail in detail_frames:
        result_list.append(parse_one_book(str(each_detail)))
    return '\n'.join(result_list)


def parse_one_book(detail):
    soup = BeautifulSoup(detail, 'lxml')
    name = soup.div.h2.a.string
    author = soup.find(
        'p', attrs={'class': 'color-gray'}).string.strip()  # 去除无效字符
    rating = soup.find(
        'span', attrs={'class': 'font-small color-lightgray'}).string.strip()
    if len(str(rating)) == 0:
        rating = '暂无评分'

    if soup.find('p', attrs={'class': 'detail'}):
        detail = soup.find(
            'p', attrs={'class': 'detail'}).string.strip()  # 去除无效字符
    else:
        detail = soup.find(
            'p', attrs={'class': 'color-gray'}).find_next().string.strip()
    result = f"-->%s (%s) 评分：%s:\n   %s" % (name, author, rating, detail)
    return result


if __name__ == "__main__":
    html = get_html('https://book.douban.com/latest')
    result = parse_html(html)
    print(result)

```
## 其他
 - 我的水平不高，所讲之处难免有所漏洞，还望指正