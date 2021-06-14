---
title: 学了python不知干啥？爬爬虫！ （4）多线程爬取
date: 2021-05-26 16:46:37
tags: [爬虫,Python]
categories: Python爬虫教程
cover: /images/bg_network.jpg
---

多线程批量翻译
> 合理爬取，不恶意扩大站点压力
> 本文章仅作示例，请勿用作非法用途

----
 
 ## 效果
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916184305737.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
 ## 需求
 自己的[项目](http://www.coolapk.com/apk/254263)需要一个功能，要求有大量的中英对照翻译，中文词很好找，网上随便搜一下就有了
 ![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916184419733.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
但是英文翻译呢？
手动翻译自然可以，但身为程序猿，用代码实现不是更加优雅吗？
开干！
## 分析
经过梳理后，我们可以把整个过程分为以下几个步骤：
 1. 加载xlsx文件，解析为中文词的列表（元组）
 2. 一一翻译，将结果储存在一个字典中
 3. 保存为json文本

## 开始
### 加载xlsx
由于不是本篇重点，直接上代码好了

```python
	# 获取原始数据
    xls = xlrd.open_workbook("D:/Downloads/7000hanzi.xlsx")
    sheet = xls.sheet_by_index(0)
    col = sheet.col_values(1)
    col.pop(0) #剔除表头数据
```
### 爬取翻译
#### 旧方法
如果按照之前的方法，只需要遍历一下列表，然后一个一个翻译就好了。
但是！这个效率问题值得我们考虑。
假设翻译一个单词需要1s，连续翻译7000个也就要7000s；换句话说，将近两个小时！![在这里插入图片描述](https://imgconvert.csdnimg.cn/aHR0cHM6Ly9zczAuYmRzdGF0aWMuY29tLzcwY0Z1SFNoX1ExWW54R2twb1dLMUhGNmhoeS9pdC91PTI3NzgyNjQ2NTMsMTAyNDI4NjMyMSZmbT0yNiZncD0wLmpwZw?x-oss-process=image/format,png#pic_center)
这时候，就需要多线程出场了！
#### 新思路
使用多线程有什么好处呢？
> 假设现在你面前有一个桌子，上面放着一堆苹果，有很多人等待着吃苹果。
> 规则是每次每人只能拿一个苹果，且拿到苹果的人吃完之后其他人才能拿下一个。
> 我们现在来看一看两种不同情况

>单线程：由于吃苹果是一个很耗时间的过程，于是你的面前出现了一条长龙，每个人都在干巴巴的等着那个吃苹果的人，眼巴巴的看着他吃完苹果再换人。

>多线程：一堆人一字排开，同时拿着苹果开吃，谁吃完了就换一个顶替。这样不一会儿苹果就被吃完了。

上面是我一个简单的比喻，希望你可以理解。
换到代码上面怎么实现呢？
##### 使用多线程的例子
Python里面使用多线程很简单，主要用到threading.Thread
来一个小例子

```python
#FunnySaltyFish 2020/9/16
import threading
import random
class FunnyThread(threading.Thread):
    def __init__(self,id):
        threading.Thread.__init__(self)
        self.id = id

    def run(self) -> None:
        print(f"线程 {self.id} 开始执行")
        sum_number = 0
        for i in range(random.randint(100,10000000)):
            sum_number += i
        print(f"线程 {self.id} 算完了")

if __name__ == "__main__":
    thread1 = FunnyThread("thread1")
    thread2 = FunnyThread("thread2")
    thread3 = FunnyThread("thread3")
    thread1.start()
    thread2.start()
    thread3.start()
```
在上面这个例子中，我们定义了一个类继承自Thread，然后重写run方法，该方法就是线程执行时干的事。
上述例子中，每个线程会计算一定数量的整数和（吃苹果），具体算多少个数是随机的，以模拟不同线程执行不同耗时任务（也就是吃苹果的速度不一样）
运行上述例子，你会得到以下结果：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20200916192439951.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
*（因随机数产生不同，结果以实际运行为准）*
三条线程分别计算三组结果，互不干扰。
<small>关于多线程，就介绍到这里；有兴趣的话您可以先收藏着本帖，去其他地方深入了解相关知识再回来。这里简单的知识就够用了 </small>

##### 使用Queue
多线程翻译是可以了，但是怎么知道当前的线程应该去翻译哪个单词了呢？
这里我们用到Queue
还是拿苹果比喻。

> 假设有一个竖着的管子，管子的宽度只能容纳单个苹果，且单项开口，你最后放进去的最先拿出来。每个人走到管子前面，伸手抓一个，到旁边吃，换个人再抓一个……直到管子里面没有苹果，结束。

值得注意的是，Python中的Queue是线程安全的，也就是说，即使108个好汉都想同时上梁山，它也能确保梁山一次只被一个好汉上，不会因为多个线程同时访问而冲突。

放到代码中如下：

```python
# 初始化单词队列
words_queue = Queue(7000)
```

```python
 while not self.queue.empty():
            cur_word = self.queue.get()
            print(f"-->线程 {self.id} 正在翻译 “{cur_word}” ")
            cur_translation = self.translate(cur_word)
```


### 保存为json
在保存之前，我们需要确保所有线程都已翻译完毕。
使用Thread的join()方法实现。

## 完整代码
请注意，不像之前的几个教程，这份代码不能直接执行。请对照注释自行修改

```python
# FunnySaltyFish 2020/9/16
from time import sleep
import xlrd
import json
import threading
import requests
from queue import Queue
from youdao3 import YoudaoFanyi


class Crawl_thread(threading.Thread):
    def __init__(self, id, queue) -> None:
        threading.Thread.__init__(self)
        self.id = id
        self.queue = queue

    def run(self) -> None:
        print("->启动线程", self.id)
        self.start_crawl()
        print("-<线程", self.id, "结束")

    def start_crawl(self):
        while not self.queue.empty():
            cur_word = self.queue.get()
            print(f"-->线程 {self.id} 正在翻译 “{cur_word}” ")
            cur_translation = self.translate(cur_word)
            words[cur_word] = cur_translation
            sleep(0.5)

    def translate(self, word):
        try:
        	# 这里用到了一个有道的翻译库
        	# 因为涉及到key和id就不放出来了
        	# 您可以自行修改这里的翻译代码以体验
            return youdao.fanyi(word)
        except Exception as e:
            print(f"在翻译 {word} 时出错，错误是 {e} ")
            return "错误"


words = {}
THREAD_NUMS = 10 # 线程数目，按需修改
youdao = YoudaoFanyi()


def main():
    # 获取原始数据
    # 请自行修改
    xls = xlrd.open_workbook("D:/Downloads/7000hanzi.xlsx")
    sheet = xls.sheet_by_index(0)
    col = sheet.col_values(1)
    col.pop(0)  # 剔除表头数据

    # 初始化单词队列
    words_queue = Queue(7000)
    for word in col:
        words_queue.put(word)

    # 初始化爬取线程
    crawl_threads = []
    crawl_names = []
    for i in range(THREAD_NUMS):
        crawl_names.append(f"thread-{i+1}")
    for name in crawl_names:
        thread = Crawl_thread(name, words_queue)
        thread.start()
        crawl_threads.append(thread)

    # 等待所有线程爬取完成后再执行
    for t in crawl_threads:
        t.join()
    print("爬取完毕！")

    # 保存结果
    final_text = json.dumps(words)
    with open("D:\projects\others\words.json", "w+") as f:
        f.write(final_text)
    print("完成！")


if __name__ == "__main__":
    main()

```

顺带一提，软件运行起来的效果看起来真的非常爽
刷刷刷的~

## 其他
 - 我的水平不高，所讲之处难免有所漏洞，还望指正
 - [系列文章完整目录](/2021/05/26/python-spider-lesson-catalog/)
