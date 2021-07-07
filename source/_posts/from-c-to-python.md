---
title: 从C到Python
tags: [教程,Python]
categories: 教程
date: 2021-06-01 08:00:00
cover: /images/bg_network.jpg
---

## 从C到Python

本文适合于那些有过一定C语言基础并希望学习Python的人，仅在简明指出二者的过渡。

首先请记住：Python入门**非常容易**，所以在阅读本文时，请不必抱有任何心理压力！**看不懂的跳过就行，日后自然会理解**

---

### 说明

1. 目前Python主流版本有2.X和3.X，本文使用的版本为`Python 3.8.5`
2. C环境则为 gcc 8.1.0
3. 如对应知识点下面有小字，则为补充及说明内容，您可按需阅读



### 宏观

下面从大体上阐释二者的部分区别

1. Python代码写起来比C语言**简明得多**
2. Python是一门**面向对象**的语言，C语言则是**面向过程**
3. Python是一门解释型语言，C则是编译型语言

上面的话有个概念就好，不必死磕。



### 变量

在C语言中，变量分为声明和定义，且需要指出详细的类型，如下：

```c
	//变量声明
    int i;
    float f;
    double d;
    char c;
    long l;
    short s;
```

Python作为解释型语言，变量无需指定类型，赋值即可

```python
var_string = "这是字符串变量"
var_number = 1
var_list = [1,2,3]
var_tuple = (1,2,3)
var_set = {1,2,3}
var_dict = {"key":"value"}
```

上述例子展示了python 六种基本数据类型
从中也可以获取关于Python3的几个特点：
- 变量的名字符合 **小写字母+下划线+数字** 的组合
- 语句末尾不需要分号
- 天然支持中文 *（准确来说是Unicode编码）*

由于Python是动态语言，不同类型的对象可以赋值给同一个变量，如下
```python
a = "先是字符串"
a = 1.0
```

### 基本数据类型
#### 数字 Number
```python
# Python3 支持 int、float、bool、complex（复数）
a = 45
b = 3.0
c = True
d = 4+7j
```
上面的`#`表示单行注释，类似于C的`//`

#### 字符串 String
字符串，你可以拿字符数组`char[]/char*`理解，但是强大的多

```python
text1 = "普通字符串"
text2 = r"原始字符串，里面是什么就输出什么"
text3 = """
多行字符串
里面的
东西
可以换行写
"""
```
要理解`r""`，可以参照下面的例子
```python
normal = "这是第一行\n这是第二行'
raw = r"这是第一行\n这也是第一行"
print(normal) #这是第一行
              #这是第二行
print(raw)    #这是第一行\n这也是第一行
```
可以用 **+** 连接两个字符串
```python
text = "Hello"+" "+"World!"
print(text) #Hello World!
```
用  **\*** 将其重复
```python
text = "一部分"
text *= 3
print(text) #自行运行尝试
```
#### 列表 List
类似于数组，但具有下面的特性
- 长度无限
- 里面可以随便装任何类型的对象
```python
l = [1,"字符串",True]
number = l[0] #1
...
```
如果指定的index不存在，则会报错
```python
l[3]
# Traceback (most recent call last):
#   File "<stdin>", line 1, in <module>
# IndexError: list index out of range
```
可以用 **append** 方法添加一个元素
```python
l.append("新元素")
print(l) #[1, '字符串', True, '新元素']
```
**extend**添加多个
```python
l.extend(["第一个","第二个"])
print(l) #[1, '字符串', True, '新元素', '第一个', '第二个']
```
**pop** 删除某个元素并返回被删的那个
```python
l.pop()
'第二个'
>>> l
[1, '字符串', True, '新元素', '第一个']
>>> l.pop(3)
'新元素'
>>> l
[1, '字符串', True, '第一个']
```
上面的 `>>>`代表在Python交互式环境中，安装完Python后即可使用

其余复杂细节之后再讲

#### 元组 Tuple
类似于列表，但是长度固定，且内容不可被修改
```python
>>>tuple_test = ("第一个","第二个","第三个")
>>>print(tuple_test[2])
第三个
>>> tuple_test[2] = "试图修改" 
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: 'tuple' object does not support item assignment
```

未完待续
