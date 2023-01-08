---
title: 写出更现代化的Python代码：聊聊 Type Hint
date: 2023-01-08 13:28:24
tags: [Python]
cover: /images/bg_python.jpeg
---

`Type Hint`是 Python 3.5 新增的支持，中文可以译为 `类型提示`。屏幕前的你或许听过，又或许没有。所以今天，让我们一起了解了解。  
*本文基于 `Python 3.10.4`，部分代码需要在 `Python 3.10.0` 及以上运行，原因在后续文章中会有说明*  
*本文的代码编辑器为 VS Code ，您可以选择其他现代编辑器/IDE以体验*

### 为什么需要 Type Hint
简而言之，按我的理解，`type hint`的目的是**写给“别人”看**。这个“别人”，就包括`代码编辑器`、`其他阅读代码的人`和`几天后的你自己`。  
废话不多说，Show You My Code!


### 开始写代码
现在我们假设，你想写一个函数，用处是**统计给定字符串中某个字符出现的次数**，于是你大手一挥，写下了这样的代码：
```python
def count_char(text, char):
    return text.啥来着？？？
```
尴尬的是，你记得`str`类有这个方法，但却忘记了这个方法叫啥了，看看编辑器的自动提示？

![image.png](https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/06407b5e81624e28b259e17b2fb03367~tplv-k3u1fbpfcp-watermark.image?)
遗憾的是，编辑器不知道你的text是啥类型的，自然没法帮你补全。那我们能不能告诉它：这是个`str`呢？可以，给参数名后面加个`: str`就好了
*（这个空格不是必须的，只是为了好看）*

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/28a93b2da60e4387a54b1d4f438e5050~tplv-k3u1fbpfcp-watermark.image?)
这就是`Type Hint`的作用，通过**显示指明类型告诉调用者和编辑器：我需要什么类型**。这能帮助你充分利用现代编辑器的自动提示功能，并让你写出的代码更加易于阅读和维护。

### 一个注意点
在继续下面内容之前，我们得明确一件事：**Type Hint只是手动指明我们需要的类型，但它不是强制的**。举个栗子，对于这个函数，正确的使用如下：
```python
def count_char(text: str, char):
    return text.count(char)

# text 参数为 str
print(count_char("Hello World", "e"))
```
但如果我们给`text`传了个别的类型，比如`int`，会发生什么？答案是仍然能编译通过，只是执行时报错而已。

![编辑器并不报错](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/98fe2bf576f9405583ffe4e2820d14ae~tplv-k3u1fbpfcp-watermark.image?)
这就是为什么它叫`Type Hint`：只是提示，并非强制。  
当然，我们也可以借助其他手段来实现强制的类型限定，比如借助 `mypy`

#### mypy
安装`mypy`很容易，只需要`pip install mypy`即可。之后就可以用`mypy filename.py`检测此类错误

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/20295996bd474da9aa13b702f59bb9dd~tplv-k3u1fbpfcp-watermark.image?)
当然，能在vscode中直接用更好。我们可以按`ctrl+shift+p`打开设置（工作区or全局，看你想法）
![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ec486cafc0641f6b8d33b3b14741c1d~tplv-k3u1fbpfcp-watermark.image?)

配置如下：

```json
{
    "python.linting.mypyEnabled": true
}
```

即可在vscode中实时用`mypy`检查

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c88f93a3fd634daa809477c3c939824d~tplv-k3u1fbpfcp-watermark.image?)

### 基本使用
对于普通类型，用法就像刚刚说的，在名字后面加个`: 类型`即可

```python
# 变量
num: int = 10
f: float = 0.7

# 自定义的类也差不多
class Node:
    def __init__(self):
        pass
        
# 函数参数
def visit_node(n: Node):
    pass
```
对于集合类型，我们可以使用`[]`指定里面元素的类型
```python
# 列表，每个元素应该为`str`
def join_to_str(arr: list[str]):
    return "".join(arr)

join_to_str(["Funny", "SaltyFish"]) # 正确的
join_to_str([1, 2, 3]) # 错误 List item 2 has incompatible type "int"; expected "str"
```
Tuple用法也类似
```python
# 值为 int，str的二元组
two_tuple: tuple[int, str] = 200, "哈哈哈"
# 值为 int 的不定长元组
t: tuple[int, ...] = (1, 2, 3, 4)
```


字典可以分别指定`key`、`value`的类型
```python
# 指定键为`str`，值为`int`
def dict_example(d: dict[str, int]):
    pass

dict_example({"github": 1, "juejin": 2}) # 合法的
# Dict entry 0 has incompatible type "str": "str"; expected "str": "int"
dict_example({"github": "github.com/FunnySaltyFish", "juejin": 2}) 
```
注意的是，上面两个`list`和`dict`的例子在较早期的Python版本是会报错的，需要先`from typing import List`，再用`List[str]`标注类型。不过，如果你的程序**希望支持到较多的Python版本**，那么用`List`或许是更好的选择；反之就用`list`吧。

如果你希望此参数既可以传`List`，又可以传`Tuple`，或者传`生成器`，那么可以写成`Iterable`，它表示**可迭代的**。
```python
from typing import Iterable
def iter_print(arr: Iterable):
    for each in arr:
        print(each)

iter_print(["你好","我好","她也好"])    # 列表
iter_print(("Funny", "Salty", "Fish")) # 元组
iter_print((i*2 for i in range(10)))   # 生成器
```
类似的更广泛类型还有`Sequence`和`Mapping`，可以自行了解

### 标注函数

标注函数包括几个方面：标注函数的返回类型，和标注函数类型的参数

#### 标注函数的返回值类型

实际上，如果你把鼠标放到刚刚我们写的`count_char`函数上，你能看到这样的提示

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cfbed0ef1a754bb6a6a3e4e6c3db80cd~tplv-k3u1fbpfcp-watermark.image?)
智能的编辑器通过分析函数内容已经推断出了函数会返回一个`int`，标了个`-> int`，而这就是函数的返回值标注方式
```python
# 返回值int
def count_char(text: str, char: str) -> int:
    return text.count(char)
```
如果函数没有return语句，则返回值为`None`
```python
# 没有返回值，默认为None
def print_n() -> None:
    print("n")
```
如果函数是拿来抛异常，或者更极端，运行完之后程序直接退了，那可以标`NoReturn`
```python
from typing import NoReturn
def exit_app() -> NoReturn:
    exit(0)
    
def exception_func() -> NoReturn:
    raise Exception("异常退出")
```
这样做的好处之一是，编辑器可以识别到函数调用处后面的代码不会被执行，标灰并给出`Unreachable`的提示


![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7bd4ee2ffc63438dade32da58a70d7ea~tplv-k3u1fbpfcp-watermark.image?)

#### 标注函数类型
如果一个参数，它要求传入的为一个函数，则可以使用`Callable`描述。比如下面的函数，可以对另一个函数计时
```python
import time
from typing import Callable
def calc_time(func: Callable):
    start = time.time()
    func()
    end = time.time()
    print(f"此函数花费了{end-start}s")

calc_time(lambda : sum(range(10000000)))
```

`Callable`也可以指定更具体的类型，`Callable[[int, int], str]` 就表示**参数为两个int，返回值为str的函数**


### 更复杂的类型
接下来我们看一些更复杂的类型。  
**问题一：** 如果一个参数可以接受所有类型，可以标成啥？  
你可以不标，或者标成`typing`下的`Any`，它俩是一样的，标了类似于没标。

**问题二：** 如果一个参数可以接受几种不同的类型，怎么标？  
这个问题在`Python 3.10`前有些麻烦，你需要引入`Union`。比如，假设这个参数可以接受`int`和`float`
```python
from typing import Union
def f2(a: Union[int, float]):
    pass

f2(1)   # ok
f2(3.4) # ok
f2("s") # 错误
```
不过,3.10简化了这个操作。现在可以用`|`并列多个类型
```python
def f2(a: int|float):
    pass
```
二者是等价的
```python
print(Union[int, float] == int|float) # True
```
如果需要了解Py3.10的新特性，可以参考我的这篇文章 [Python3.10正式版发布！新特性速览 - 掘金 (juejin.cn)](https://juejin.cn/post/7015590447745613854)

**问题三：** 如果参数可以为`None`呢？
使用`|`，比如`int|None`，或者使用`Optional`
```python
from typing import Optional
a: Optional[int]
a = 1
a = None
```

**问题四：** 如果这个类型还没被定义，咋整？  
这个情景来自类的构造函数，如果需要用到它自己，就会碰到这个问题（或者某些方法需要返回自己）。比如说定义链表的节点：

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0e985bddc0304d348bf3550f3687790f~tplv-k3u1fbpfcp-watermark.image?)
这时候可以""包围，避免循环引用

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/add118c6748b402d9567c801183f3ad5~tplv-k3u1fbpfcp-watermark.image?)

或者可以用`TypeVar`
```python
TListNode  = TypeVar("TListNode", bound="ListNode")

class ListNode:
    def __init__(self, prev_node: TListNode|None) -> None:
        pass

node = ListNode(ListNode(None))
```
不过，目前仍在预览版（估计不久后就有正式版了）的`Python 3.11.0`加入了`typing.Self`，用来指自己。到时候可以这样写
```python
from typing import Self
class ListNode:
    def __init__(self, prev_node: Self|None) -> None:
        pass
```

**问题五：** 有些类型名太长了，我打多了心累，咋办？  
比如说，写http接口的响应函数，然后都处理成`(状态码, 数据字典)`的类型，就会是这样
```python
def http_response():
    return 200, {"code": "0", "data": "https://juejin.cn/user/2673613109214333", "message": "https://github.com/FunnySaltyFish"}
```
那它的类型就得写成：
```python
tuple[int, dict[str, Any]]
```
写多了确实麻烦。所以我们可以给这个类型起个别名：
```python
from typing import TypeAlias, Any
ResponseType: TypeAlias = tuple[int, dict[str, Any]]

def http_response() -> ResponseType:
    pass
```
这样就统一、简洁多了  
注意的是，`TypeAlias`是`Python3.10`强制的，此前的版本可以去掉。但我觉得有`TypeAlias`的版本比较清晰，能指明这是个`类型别名`。

**问题六：** 如果某个变量只能取特定值，怎么写？
比如`sex`，你想让对方只传入`男`、`女`和`其他`三种字符串，可以这么写
```python
sex: Literal["男", "女", "其他"]
sex = "未知" # 错误
```
当然这需要`import`。`Literal`就是`字面量`的意思。

除上面写到的，可以用`typing.Final`创建一个“常量”，告知此值不可被更改

![image.png](https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8f7fa8476d3a4b3198418ef16f99bf94~tplv-k3u1fbpfcp-watermark.image?)

`typing`包下还有其他一些东东，此处就不赘述了。感兴趣的同学可以翻阅 [官方文档](
https://docs.python.org/zh-cn/3/library/typing.html) 以了解更多。


### 最后
现在，你已经掌握了`Type Hint`的基本用法，或许可以开始使用它了。即使不是全部，但从一部分开始也是个不错的选择。毕竟代码最终是给人看的，你也不希望几个月后看着自己曾经写过的代码默默骂一句： **“chao，这里应该传个啥类型来着？”** 


### 参考
- [官方文档](
https://docs.python.org/zh-cn/3/library/typing.html)
- https://www.bilibili.com/video/BV16Y411K73d
- [python/mypy: Optional static typing for Python (github.com)](https://github.com/python/mypy)