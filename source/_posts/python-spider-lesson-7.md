---
title: 学了python不知干啥？爬爬虫！（7）代理的使用
date: 2021-05-26 16:53:57
tags: [爬虫,Python]
categories: Python爬虫教程
cover: /images/bg_network.jpg
---

多线程批量翻译
> 合理爬取，不恶意扩大站点压力
> 本文章仅作示例，请勿用作非法用途

该系列的其他篇目：

[系列文章完整目录](https://funnysaltyfish.github.io/2021/05/24/python_spider_lesson_catalog/)

---

在Python爬虫过程中，常常会遇见因为各种原因被服务器拒绝访问的情况。有时候设置User-Agent能够解决问题，但如果遇到服务器校验ip访问次数来判断爬虫的情况，这样简单的做法就无能为力了。往往这种时候，采用代理ip间接访问能取得不错的成效。
那么，什么是代理呢？

---

## 代理
### 基本概念
让我们假想这样一个场景，你是一个广告员，负责给一个老奶奶打广告并获拿到她的反馈留言。老奶奶每天见到你很心烦，看见你多次来就不见你了。这时候你想到了另一个办法，你找到老奶奶的儿子孙子外甥侄子……把将自己的广告内容告诉他们，让他们跟老奶奶复述，然后由他们将得到的反馈结果告诉你，从而间接完成自己的目的。当这样的过程中发生在爬虫时，那些爬取过程中的“中间人”，就是代理。
### 分类
常见的HTTP代理分为三个类型，即**透明代理IP、匿名代理IP、高匿名代理IP**，它们的具体区别见下：
>1)透明代理(Transparent Proxy)：透明代理虽然可以直接“隐藏”客户端的 IP 地址，但是还是可以从来查到客户端的 IP 地址。

> 2)匿名代理(Anonymous Proxy)：匿名代理能提供隐藏客户端 IP 地址的功能。使用匿名代理，服务器能知道客户端使用用了代理，当无法知道客户端真实 IP 地址。

>3)高匿代理(Elite Proxy 或 High Anonymity Proxy):高匿代理既能让服务器不清楚客户端是否在使用代理，也能保证服务器获取不到客户端的真实 IP 地址。

### 代理的选择

> 普通匿名代理能隐藏客户机的真实 IP，但会改变我们的请求信息，服务器端有可能会认为我们使用了代理。不过使用此种代理时，虽然被访问的网站不能知道客户端的 IP 地址，但仍然可以知道你在使用代理，当然某些能够侦测 IP 的网页仍然可以查到客户端的 IP。
而高度匿名代理不改变客户机的请求，这样在服务器看来就像有个真正的客户浏览器在访问它，这时客户的真实IP是隐藏的，服务器端不会认为我们使用了代理。
因此，爬虫程序需要使用到代理 IP 时，尽量选择普通匿名代理和高匿名代理。另外，如果要保证数据不被代理服务器知道，推荐使用 HTTPS 协议的代理。

上面的描述未免有些理论化，我们实际使用试一下吧~

---
## 使用
### 获取代理ip
在互联网搜索，有大量的服务商提供了代理服务。对于专业性较强、访问要求率较高的场景，建议选择收费服务；在这里只做演示，我们随意选择[一家代理提供商](https://www.89ip.cn/1)的免费代理
打开页面，能看到如下代理ip列表
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210520233829414.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

由于不是本篇重点，爬取此页面的代理列表对应过程省略，如果不太明白如何爬取，可以我参考之前的文章。
编写代码如下：

```python
import requests
import re


def get_html(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.57"
    }
    html = requests.get(url,headers=headers).text
    return html


def get_ip_list(url):
    '''
        url 代理IP页面
    '''
    # 通用正则匹配的格式是 (IP,端口,地区) 地区有可能包含换行和空格
    ip_proxy_re = re.compile(
        r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*</td>\s*<td>\s*(\d{1,})\s*</td>\s*<[^\u4E00-\u9FA5]+>([\u4E00-\u9FA5]*\s*[\u4E00-\u9FA5]*\s*[\u4E00-\u9FA5]*)\s*<')
    try:
        data = get_html(url)
    except:
        return []

    # 返回的IP 就是 正则匹配的结果(IP,端口,地区) 地区有可能包含换行和空格
    ip_list = ip_proxy_re.findall(data)
    return ip_list

```
上述代码运行的结果为：

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210520233919729.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
输出的每一项结果包含 ip地址、端口、地区

### 使用
有了代理ip，接下来就是使用了。requests库提供了很方便的办法：仅需要在对应请求中加入 **proxies** 参数即可：

```python
def get_with_ip(url:str,ip:str):
    """带ip访问，其中ip形如 127.0.0.1:8080
    """
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.57"
    }
    proxies = {"http":ip}
    return requests.get(url,headers=headers,proxies=proxies)
```

### 验证
如何才能知道是不是真的在用代理ip访问而不是自己的ip在访问呢？我们可以采取如下办法：
访问一个**查看ip的网址**，然后获取**网址得到的访问ip**，进行验证即可
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210521000541304.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

编写代码如下。

## 代码
将上述过程结合起来，我们写出了下面的代码。代码首先获取ip列表，并在之后尝试使用这些ip访问网址。值得注意的是，因为获取到的免费代理**不一定稳定**，代码中添加了**超时和错误处理**

```python
"""
    代理ip使用
    文章列表见 https://blog.csdn.net/qq_43596067/article/details/117003258
    请注意，由于代理ip质量和时效不稳定，此份代码不一定保证能够运行，请酌情修改
    @copyright : FunnySaltyFish
    @date : 2021/05/20 23:22:11
"""
import requests
import re
import pprint

def get_html(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.57"
    }
    html = requests.get(url,headers=headers).text
    return html


def get_ip_list(url):
    '''
        url 代理IP页面
    '''
    # 通用正则匹配的格式是 (IP,端口,地区) 地区有可能包含换行和空格
    ip_proxy_re = re.compile(
        r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\s*</td>\s*<td>\s*(\d{1,})\s*</td>\s*<[^\u4E00-\u9FA5]+>([\u4E00-\u9FA5]*\s*[\u4E00-\u9FA5]*\s*[\u4E00-\u9FA5]*)\s*<')
    try:
        data = get_html(url)
    except Exception as e:
        print(f"获取ip列表时发生错误，原因是：{e}")
        return []

    # 返回的IP 就是 正则匹配的结果(IP,端口,地区) 地区有可能包含换行和空格
    ip_list = ip_proxy_re.findall(data)
    return ip_list


def get_with_ip(url:str,ip:str):
    """带ip访问，其中ip形如 127.0.0.1:8080
        访问错误时返回""
    """
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.57"
    }
    proxies = {
        "http":ip,
        "https":ip,
    }
    html = ""
    try:
        html = requests.get(url,headers=headers,proxies=proxies,timeout=10).text
    except Exception as e:
        print(f"访问错误！原因是：{e}")
    return html

def validate(ip):
    html = get_with_ip(
        "https://ip.tool.chinaz.com/",
        ip
    )
    if html == "": #访问错误
        return ""
    pattern = re.compile("域名(.+)的信息")
    match = pattern.search(html)
    if match is not None:
        return match.group(1)
    else:
        return ""

if __name__ == "__main__":
    ip_list = get_ip_list("https://www.89ip.cn/1")
    print("获取到的ip列表为：")
    pprint.pprint(ip_list)
    for each in ip_list:
        ip = f"{each[0]}:{each[1]}" # 拼接ip和端口
        print(f"尝试使用ip[{ip}]访问……")
        shown_ip = validate(ip)
        if shown_ip != "":
            print(f"采用的ip地址是：{ip} 爬取后网站显示的ip地址是：{shown_ip}")
```

**【请注意，由于代理ip质量和时效不稳定，此份代码不一定保证能够运行，请酌情修改】**
下面是笔者测试时的运行情况：
--部分访问错误：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210521171431849.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
--部分访问成功
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210521171431820.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210521171431779.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

## 参考资料
* 爬虫所使用的的HTTP代理是什么？https://blog.csdn.net/yingpu618/article/details/107820814