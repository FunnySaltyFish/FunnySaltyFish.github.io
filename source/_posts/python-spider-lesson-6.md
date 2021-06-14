---
title: 学了python不知干啥？爬爬虫！（6）爱词霸翻译（内容详尽，从打开网页手把手完成JS逆向并写出代码）
date: 2021-05-26 16:51:21
tags: [爬虫,Python]
categories: Python爬虫教程
cover: /images/bg_network.jpg
---

多线程批量翻译
> 合理爬取，不恶意扩大站点压力
> 本文章仅作示例，请勿用作非法用途

---

## 前言
&emsp;&emsp;前几篇教程的爬取，我们一直局限于静态网站，且请求仅限于get。但在实际的开发过程中，动态内容才往往是爬取的核心。在本节内容中，我将带你一步步分析[爱词霸](https://www.iciba.com/)的翻译结果获取过程，并伪装请求实现单词翻译。
&emsp;&emsp;本篇内容为本人原创，转载请注明！
&emsp;&emsp;请注意，**本篇内容仅限于学习交流，切勿用于商业用途！**
![结果](https://img-blog.csdnimg.cn/20210417210225461.png#pic_center)

---
## 分析
### 网络加载过程
&emsp;&emsp;首先打开[爱词霸](https://www.iciba.com/fy)，并使用 F12 打开开发者工具 <small>*【此处使用浏览器为Edge，如使用其他浏览器请参照对应教程打开此界面】* </small> 。![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417162427533.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
为了动态分析翻译过程，我们需要切换到 **网络(Network)** 标签页
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021041716255944.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
输入任意单词，点击翻译按钮，你将会看到如下请求结果：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417171652787.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

这就是动态翻译的请求。在此条请求上**右键-复制链接地址**
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417171850950.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
得到如下结果
```bash
https://ifanyi.iciba.com/index.php?c=trans&m=fy&client=6&auth_user=key_ciba&sign=0020c1fc11e96d3a
```
目前的链接有许多参数尚未明确，我们先留着，之后再做分析。
切换到预览标签页并展开结果，我们惊喜地发现，翻译结果就藏在对应的**json**中。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417172006899.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417172006903.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;目标就是模拟这个请求，那么下一步我们需要弄清楚这里面的参数究竟各代表什么。
&emsp;&emsp;切换到标头页，在这里我们可以查看详细的请求头

![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417172236684.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;可以看到，除了明显的get请求外，该请求还携带有表单参数。分析字段不难发现，post的表单带有此次翻译的单词信息。其中，**from和to分别是源语言和目标语言，q即为翻译的单词**。
&emsp;&emsp;我们需要弄清楚其他参数是什么意思。此处采用对比的方法。
&emsp;&emsp;再次翻译另一个单词，得到第二组请求地址和请求头


```bash
https://ifanyi.iciba.com/index.php?c=trans&m=fy&client=6&auth_user=key_ciba&sign=09467500f66fb4a7
```
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417172236750.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;上下对比可知，两次请求的url中，仅有**sign**参数发生改变。可以猜测正是此参数起到加密作用。下一步我们就需要搞清楚，这个参数是怎么来的。
&emsp;&emsp;我们进入重头戏：**源码分析！**

---

### JS源码分析
&emsp;&emsp;现在我们的目标是找sign，那么最直白的思路就很显然了：看看源代码那些地方出现了"sign"，那些就是比较可疑的地方。
&emsp;&emsp;切换到**源代码**标签，使用快捷键**Ctrl+Shift+F**或按下图找到**全局搜索**面板
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417173210828.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)先尝试一下直接搜索sign
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417173319380.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
得到了9个结果，先进入第一个排查。
使用“优质打印”格式化代码以便于后面的分析。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417173436554.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)


使用**Ctrl+F**打开页内搜索，尝试查找“sign”
但是结果很不理想，有相当大的一部分是关于assign的，不利于结果的分析。
我们大概推测，sign在代码执行过程中应该是某个对象的参数。因此改用"\\.sign"重新搜索
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417173720868.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
逐个排查，发现这几个**signature**有较大概率是我们的目标。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417173829502.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
是不是呢？验证一下就知道了。
在源代码左侧的行号旁单击鼠标打上断点，程序就会在运行到此处时暂停。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417182814797.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
重新点击翻译按钮，得到运行结果
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417182839959.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
观察上图，从变量的值我们可以看到，在这行代码执行前就已经产生了sign
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417182936815.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;不难看出，变量**r**可能就是封装好的请求内容，而**e**则是对应链接。
&emsp;&emsp;那么我们的关注点就在**变量e**上，而变量e已经带有了对应的sign。于是我们从旁边的**调用堆栈**标签找到在断点执行位置的上一处，观察此处的代码和变量值
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417183235511.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417183444428.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417183444406.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
**变量r**的值引起了我们的注意，这一串字符非常符合刚刚看到的**sign**的特征。究竟是不是，我们让代码恢复执行，看看结果。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417183627965.png#pic_center)
最终的请求url中的**sign**参数正是此处的**r**！
于是为**r**赋值的这一行代码就非常重要了，摘录如下：
```javascript
takeResult: function(e) {
                var t = p.a.parse(e)
                  , r = c()("6key_cibaifanyicjbysdlove1".concat(t.q.replace(/(^\s*)|(\s*$)/g, ""))).toString().substring(0, 16);
                return g("/index.php?c=trans&m=fy&client=6&auth_user=key_ciba&sign=".concat(r), {
                    baseURL: "//ifanyi.iciba.com",
                    method: "post",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    data: e
                })
            },
```
&emsp;&emsp;从这里的js代码可得知，**r**是调用**c()函数**得到的结果，传入的参数是一个固定字符串 `“6key_cibaifanyicjbysdlove1”` 再拼接上翻译的单词，之后调用 `replace(/(^\s*)|(\s*$)/g, ""))` 的结果。下一步就是看看，这个c()究竟是个什么东西？
&emsp;&emsp;切换标签为**控制台**页，输入c()
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417184359353.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
发现它返回的是一个函数，点击上面的输出结果，可以跳转到对应的源代码位置
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417184442573.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
&emsp;&emsp;这是一个陌生的函数。进行到这一步，让我们回顾一下，我们输入的参数是明文，出来的却是英文字符组成的字符串。我们可以猜测，此处的函数作用就是对参数进行某种加密或哈希算法。
&emsp;&emsp;翻阅这个js文件，可以发现大量的**位运算**操作，这正是加密中常用的操作。因此我们可以就此猜测，这个文件就是一个库文件，功能就是实现常见的字符串加密算法。
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021041718495455.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

到这里思路换了个方向。我们不妨暂时跳出分析代码的过程，看看JS中有没有这样的库存在。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417185037435.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
搜索的结果几乎全部指向了**CryptoJS**这个第三方库，那我们去Github看看它的源代码
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417185137656.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
尝试搜索刚刚代码中出现的 `_createHelper` 字段。
![在这里插入图片描述](https://img-blog.csdnimg.cn/2021041718524599.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
在 `core.js` 下，我们发现了这一段：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417185313782.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
与刚才的
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417185332876.png#pic_center)
一模一样！！！

### 寻找具体算法
简单搜索得知，**CryptoJS**提供了种类丰富的加密算法。要找到此处用的是哪一种就有很多办法。这里我们选择：**黑箱理论**。

> 黑箱理论，是指对特定的系统开展研究时，人们把系统作为一个看不透的黑色箱子，研究中不涉及系统内部的结构和相互关系，仅从其输入输出的特点了解该系统规律，用黑箱方法得到的对一个系统规律的认识。

寻找一个特定的输入：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417185757621.png#pic_center)
在调试模式下选中生成参数的部分代码，就可以看到此次运行的结果
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417185813154.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
上面这一次的运行结果如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417200408602.png#pic_center)

随便打开一个用于加密的[网站](http://encode.chahuo.com/)，经过不断尝试，在尝试到**MD5**的时候，得到了一模一样的结果：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210417200430587.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

```bash
18dc7242de5f73cae3b299a6c8eba326
```
如此就确定了加密方式：**MD5！**
一切就绪，下一步自然就是编写代码啦！开干！

### 代码编写
上面分析得很到位了，每一个参数都给了详尽的解释，此处就不再赘述。参见代码和注释即可。

## 完整代码

```python
"""
    爱词霸 单词翻译。仅用于学习与交流
    @copyright : FunnySaltyFish
    @date : 2021/04/17 20:38:45
"""
import requests
from hashlib import md5
import json

def get_result(word,source="zh",to="en"):
    # 伪装请求头
    # 不知道为什么要有这一行的可以看 https://blog.csdn.net/qq_43596067/article/details/105889267
    headers = {
        "User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.90 Safari/537.36 Edg/89.0.774.57"
    }
    # 计算sign参数
    sign = get_signature(word)[0:16]
    # 组装url
    url = f"https://ifanyi.iciba.com/index.php?c=trans&m=fy&client=6&auth_user=key_ciba&sign={sign}"
    # post表单 数据
    data = {
        "from":source,
        "to":to,
        "q":word
    }
    # 获得的json文本
    result = requests.post(url=url,headers=headers,data=data)
    return result.text

def get_signature(word:str):
    # 按js代码写出来的拼接字符串
    raw = "6key_cibaifanyicjbysdlove1"+word.replace(r"(^\s*)|(\s*$)","")
    return md5(raw.encode("utf-8")).hexdigest()

def parse_json(text):
    # 简单解析获得翻译结果
    # 针对其他一些翻译结果 ， 您可以自行修改
    result = json.loads(text)
    return result["content"]["out"]

if __name__ == "__main__":
    word = "你好"
    raw = get_result(word)
    translation = parse_json(raw)
    print(f"【{word}】的翻译结果是【{translation}】")
```

<center>✿✿ヽ(°▽°)ノ✿  完结撒花  ✿✿ヽ(°▽°)ノ✿</center>
<center><a href="/2021/05/26/python-spider-lesson-catalog">回到目录</a></center>