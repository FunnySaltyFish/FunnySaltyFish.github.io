---
title: 学了python不知干啥？爬爬虫！ （2）爬取网络小说并保存全本
date: 2021-05-26 16:01:38
tags: [爬虫,Python]
categories: Python爬虫教程
cover: /images/bg_network.jpg
---

爬取全本小说并保存到本地！
> 尊重知识产权，建议阅读原版
> 本文章仅作示例，请勿用作非法用途

该系列的其他篇目：
[系列文章完整目录](/2021/05/26/python-spider-lesson-catalog/)

----

## 效果
![全本](https://img-blog.csdnimg.cn/20200502125532646.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
如你所见，这是一个完整的小说文档。尽管小说原网站并没有提供下载功能，但我们爬虫却做到了！那么，让我们开始吧~
## 开始
这篇小说从哪里来？互联网上。我们不妨先去看看网页端效果是怎样的。
打开[这个网页](https://www.e8zw.com/book/416/416756/2235794.html)，你就会看到完整的章节列表、广告和广告……
![这广告……](https://img-blog.csdnimg.cn/20200502130132171.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
让我们随便打开一章，右键——查看源代码，看看这些东西背后到底是什么。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200502130415342.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200502130433115.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
哇，真的是非常的amazing啊，我们居然一下就找到了我们所需要的小说内容！
![在这里插入图片描述](https://imgconvert.csdnimg.cn/aHR0cDovL3BpYy45NjIubmV0L3VwLzIwMTgtNi8yMDE4NjIxMDIxOTg3NTk3MC5qcGc?x-oss-process=image/format,png#pic_center)
但是兄弟，我们怎么才能获得这些源码呢？
走，我们进入下一步！

## 获取网页源码
上节课 *（没看过的请自行查看）* 我们讲过，urllib的`urlopen`函数可以打开一个网页链接，这一次咱们如法炮制，再试一次。

```python
def get_html(url):
    response = ur.urlopen(url)
    html = response.read().decode("utf-8")
    return html
```
然而当你print一下之后，你会发现：

```python
print(get_html(URL))
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200502131611106.png#pic_center)
纳尼？403 Forbidden?服务器把我们拒绝了！
![在这里插入图片描述](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9pMDJwaWNjZG4uc29nb3VjZG4uY29tLzY5ZjFhNTc3YmQwNGI1NTE?x-oss-process=image/format,png#pic_center)
&emsp;&emsp;没错，有些服务器因为不希望过多的机器访问造成过大的服务器压力，于是会对爬虫采取拒绝访问的措施。你可能就要问了：为什么他会知道我是一只爬虫而不是正常访问呢？
&emsp;&emsp;事实上，当访问上述链接时，我们的请求头会有一个`User-Agent`告诉服务器我们是谁。比如说当我们使用浏览器访问时，就会有如下UA:
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200502132405744.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;而当使用urllib时，默认的UA是：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200502132818505.png#pic_center)
&emsp;&emsp;毫无疑问，服务器一看到它，就把我们bang了……
&emsp;&emsp;但方法总比问题多，这个UA事实上是完全可以更换的。于是我们改一改：

```python
def get_html(url):
    head = { # 创造请求头
        "Referer": url,
        "User-Agent": "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
    }
    request = ur.Request(url, headers=head)# 新建一个request，使用我们构造好的head
    response = ur.urlopen(request)# 访问
    html = response.read().decode("utf-8")
    return html
```
&emsp;&emsp;你是否发现了一个问题：这一次我们的urlopen改为了打开request而不是url直链。我们来看看文档是怎么说的：

> urlopen(url, data=None, timeout=<object object at 0x00634920>, *, cafile=None, capath=None, cadefault=False, context=None)
Open the URL url, which can be either a string or a Request object.

&emsp;&emsp;事实上，当你使用字符串作为参数时，python会自动帮你利用url和默认的数据构造一个Request再完成访问。
&emsp;&emsp;那么结果如何呢？我们再跑一次：
![在这里插入图片描述](https://img-blog.csdnimg.cn/2020050213395433.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
当当当当！搞定~

## 提取内容
&emsp;&emsp;有了网页，提取内容就不是什么问题了。通过观察我们可以知道，所有小说内容包裹在\<div id="content"\>后面。于是，利用正则表达式 *【正则表达式是一种根据特定规则提取文本的技术，您可以先学习之后再回到本章节观看】* ，我们可以写出如下代码：

```python
    re_content = re.compile(r'''<div id="content">\n(.*)''', re.M)
    content = re.findall(re_content, html)[0]
```
&emsp;&emsp;再处理一下特殊字符，让文本好看一点，我们最终得到了这样一个函数：

```python
def get_base_content(html):
    re_content = re.compile(r'''<div id="content">\n(.*)''', re.M)
    content = re.findall(re_content, html)[0]
    content = content.replace("<br />", "\n")
    content = content.replace("　　&nbsp;\n", "")
    return content
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200502134734320.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
完美！
## 获取标题
&emsp;&emsp;如法炮制，我们把标题也取一下，看着好看一点：

```python
def get_title(html):
    re_title = re.compile(r'<meta name="keywords" content="(.*),神澜奇域海龙珠,唐家三少,E8中文网" />')
    return re.search(re_title, html).group(1)
```
&emsp;&emsp;这样就完成了一章内容的获取。
## 批量爬取
&emsp;&emsp;爬完了一章，批量爬取就很简单了。
&emsp;&emsp;观察源代码，我们可以看到所有的下一章链接都被明显标出
![网页处理](https://img-blog.csdnimg.cn/20200502135138654.png#pic_center)
&emsp;&emsp;所以事实上，我们要做的就是：
{% mermaid %}
graph TB
    Start[/开始/]-->A([获取一章标题]);
    B([获取一章内容]);
    A-->B;
    C{是否有下一章};
    B-->C;
    C--是-->A;
    C--否-->End[/结束/];
{% endmermaid %}
那么如何判断是不是最后一章呢？我们看一下网页是怎么处理的：
![网页处理](https://img-blog.csdnimg.cn/20200502140043524.png#pic_center)
&emsp;&emsp;可以看到，网页版对于最后一张的处理是回到主页。所以我们只需要判断获取到的下一页url是不是一个  ./ 就可以确定了。
&emsp;&emsp;上述完整代码如下：

```python
BASE_URL = "https://www.e8zw.com/book/416/416756/"
def get_next_page(html):
    re_next_page = re.compile(r'<a id="pager_next" href="(.*?)"')
    return BASE_URL + re.search(re_next_page, html).group(1)
```

```python
if __name__ == '__main__':
    # print(get_base_content(get_html(URL)))
    html = ""
    url = URL
    while True:
        html = get_html(url)
        text = get_base_content(html)
        title = get_title(html)
        print(f"{title}\n{text}")
        url = get_next_page(html)
```
## 保存为文本
读取之后，利用简单的文件操作即可保存啦！
完成，撒花！！！
## 完整代码

```python
import re
import urllib.request as ur
BASE_URL = "https://www.e8zw.com/book/416/416756/"
URL = "https://www.e8zw.com/book/416/416756/2235794.html"


def get_html(url):
    head = {  # 创造请求头
        "Referer": url,
        "User-Agent": "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
    }
    request = ur.Request(url, headers=head)  # 新建一个request，使用我们构造好的head
    response = ur.urlopen(request)  # 访问
    html = response.read().decode("utf-8")
    return html


def get_base_content(html):
    re_content = re.compile(r'''<div id="content">\n(.*)''', re.M)
    content = re.findall(re_content, html)[0]
    content = content.replace("<br />", "\n")
    content = content.replace("　　&nbsp;\n", "")
    return content


def get_next_page(html):
    re_next_page = re.compile(r'<a id="pager_next" href="(.*?)"')
    return BASE_URL + re.search(re_next_page, html).group(1)


def get_title(html):
    re_title = re.compile(r'<meta name="keywords" content="(.*),神澜奇域海龙珠,唐家三少,E8中文网" />')
    return re.search(re_title, html).group(1)


if __name__ == '__main__':
    html = ""
    url = URL
    f = open("D:/projects/something_download/神澜奇遇——海龙珠.txt", "w+", encoding="utf-8")
    while True:
        html = get_html(url)
        text = get_base_content(html)
        title = get_title(html)
        print(f"{title}\n{text}")
        url = get_next_page(html)
        f.write(f"{title}{text}\n\n")
        if url.endswith("./"):
            print("全本写入完毕！")
            break

    f.close()

```

## 其他

 - 你可以试着用这样的方法保存其他小说，然后不出意外，有些地方的小说你一定会遇到问题（譬如访问不了，网页中没有内容等等）。我们之后再扯
 - 我的水平不高，所讲之处难免有所漏洞，还望指正

## 后续
- [系列文章完整目录](/2021/05/26/python-spider-lesson-catalog/)


