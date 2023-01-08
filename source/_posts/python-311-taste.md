---
title: Python 3.11.0 正式发布！主要新特性一览
date: 2023-01-08 13:30:44
tags: [Python]
cover: /images/bg_python.jpeg
---

去年（2021）的 10 月份，Python 发布了 3.10.0 正式版，我也在第一时间做了介绍（[相关文章](https://juejin.cn/post/7015590447745613854)）；一年后的几天前，Python 3.11.0 正式版也亮相了。目前的下载链接：<https://www.python.org/downloads/release/python-3110/>  
下面就让我们看一下主要的新特性吧。

## 快
3.11 带来的最直观变化就是，Python 更快了。官方的说法是能带来 **10%~60%** 的提速，在基准测试上平均达到了 **1.22x**。更细致的介绍请参见 [What’s New In Python 3.11 — Python 3.11.0 documentation](https://docs.python.org/3.11/whatsnew/3.11.html#faster-cpython)。

下面摘录其中部分提升

操作             | 形式              | 限定           | 最大加速 | 贡献者(们)                                           |
| --------------------- | ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------- | -------------------------------------------------------- |
| 二元运算     | `x+x; x*x; x-x;`  | Binary add, multiply and subtract for common types such as `int`, `float`, and `str` take custom fast paths for their underlying types.                                                                                                                                   | 10%                                                      | Mark Shannon, Dong-hee Na, Brandt Bucher, Dennis Sweeney |
| 下标读取             | `a[i]`            | Subscripting container types such as `list`, `tuple` and `dict` directly index the underlying data structures.Subscripting custom `__getitem__` is also inlined similar to [Inlined Python function calls](https://docs.python.org/3.11/whatsnew/3.11.html#inline-calls). | 10-25%                                                   | Irit Katriel, Mark Shannon                               |
| 下标写入       | `a[i] = z`        | Similar to subscripting specialization above.                                                                                                                                                                                                                             | 10-25%                                                   | Dennis Sweeney                                           |
| 函数调用                 | `f(arg)` `C(arg)` | Calls to common builtin (C) functions and types such as `len` and `str` directly call their underlying C version. This avoids going through the internal calling convention.                                                                                              | 20%                                                      | Mark Shannon, Ken Jin                                    |
| 加载全局变量  | `print` `len`     | The object’s index in the globals/builtins namespace is cached. Loading globals and builtins require zero namespace lookups.                                                                                                                                              | [1](https://docs.python.org/3.11/whatsnew/3.11.html#id4) | Mark Shannon                                             |
| 加载属性        | `o.attr`          | Similar to loading global variables. The attribute’s index inside the class/object’s namespace is cached. In most cases, attribute loading will require zero namespace lookups.                                                                                           | [2](https://docs.python.org/3.11/whatsnew/3.11.html#id5) | Mark Shannon                                             |
| 加载方法调用 | `o.meth()`        | The actual address of the method is cached. Method loading now has no namespace lookups – even for classes with long inheritance chains.                                                                                                                                  | 10-20%                                                   | Ken Jin, Mark Shannon                                    |
| 属性赋值       | `o.attr = z`      | Similar to load attribute optimization.                                                                                                                                                                                                                                   | 2% in pyperformance                                      | Mark Shannon                                             |
| 序列拆包       | `*seq`            | Specialized for common containers such as `list` and `tuple`. Avoids internal calling convention.                                                                                                                                                                         | 8%                                                       | Brandt Bucher                                            |

-   [1](https://docs.python.org/3.11/whatsnew/3.11.html#id2)：类似的优化已在 Python 3.8 出现， 3.11 能针对更多特定情况、减少开支.
-   [2](https://docs.python.org/3.11/whatsnew/3.11.html#id3)：类似的优化已在 Python 3.8 出现， 3.11 能针对更多特定情况。 此外，所有对属性的加载都应由 [bpo-45947](https://bugs.python.org/issue?@action=redirect&bpo=45947) 得以加速.

秉持着试试的思想，我自己也写了段简单的代码进行比较，三种不同的操作各跑 5 组，每组多次，最后平均再输出。代码如下：
```python
"""author: FunnySaltyFish，可在 Github 和 掘金 搜此名找到我"""
from timeit import repeat

def sum_test(n):
    s = 0
    for i in range(n):
        s += i
    return s

def mean(arr):
    return sum(arr) / len(arr)


# 看一个列表生成器的执行时间，执行10000次：
t1 = repeat('[i for i in range(100) if i%2==0]', number=10000)
print(f"列表生成器 平均耗时 {mean(t1):>8.3f}s")
# 执行函数的时间，执行10000次：
t2 = repeat('sum_test(100)', number=10000, globals=globals())
print(f"函数 平均耗时 {mean(t2):>14.3f}s")
# 执行字典生成器的时间，执行10000次：
t3 = repeat('{i:i for i in range(100) if i%2==0}', number=10000)
print(f"字典生成器 平均耗时 {mean(t3):>8.3f}s")
```

在 `Python 3.10.4` 运行输出如下：
```
列表生成器 平均耗时    3.470s
函数 平均耗时         2.704s
字典生成器 平均耗时    4.844s
```

在 `Python 3.11.0` 结果如下：
```
列表生成器 平均耗时    4.367s
函数 平均耗时         2.545s
字典生成器 平均耗时    4.969s
```

结果令我很意外，除了函数调用那组，py 311 在其他两项上反而慢于 310。即使我重新跑了几次效果都差不多。可能是我打开的姿势不对？如果您读到这里发现了问题或者想自己试试，也欢迎在评论区一起讨论。

## 更友好的错误提示
> [PEP 657 – Include Fine Grained Error Locations in Tracebacks ](https://peps.python.org/pep-0657/)  
> 
Py 310 也有这方面的优化，311 则更进一步。 

### 动机
比如说下面的代码:

```python
x['a']['b']['c']['d'] = 1
```

如果上面一长串中，有任何一个是 `None`，报错就是这个样子：

```python
Traceback (most recent call last):
  File "test.py", line 2, in <module>
    x['a']['b']['c']['d'] = 1
TypeError: 'NoneType' object is not subscriptable
```

从这个报错很难看出到底哪里是 `None` ，通常得 debug 或者 print 才知道。

所以在 311 里，报错进化成了这样：

```python
Traceback (most recent call last):
  File "test.py", line 2, in <module>
    x['a']['b']['c']['d'] = 1
    ~~~~~~~~~~~^^^^^
TypeError: 'NoneType' object is not subscriptable
```

这样就能直观地知道，`['c']`这里出问题了。
更多例子如下所示：
```python
Traceback (most recent call last):
  File "test.py", line 14, in <module>
    lel3(x)
    ^^^^^^^
    
  File "test.py", line 12, in lel3
    return lel2(x) / 23
           ^^^^^^^
           
  File "test.py", line 9, in lel2
    return 25 + lel(x) + lel(x)
                ^^^^^^
                
  File "test.py", line 6, in lel
    return 1 + foo(a,b,c=x['z']['x']['y']['z']['y'], d=e)
                         ~~~~~~~~~~~~~~~~^^^^^
TypeError: 'NoneType' object is not subscriptable
```

```python
def foo(x):
    1 + 1/0 + 2
def bar(x):
    try:
        1 + foo(x) + foo(x)
    except Exception:
        raise
bar(bar(bar(2)))

...

Traceback (most recent call last):
  File "test.py", line 10, in <module>
    bar(bar(bar(2)))
            ^^^^^^
  File "test.py", line 6, in bar
    1 + foo(x) + foo(x)
        ^^^^^^
  File "test.py", line 2, in foo
    1 + 1/0 + 2
        ~^~
ZeroDivisionError: division by zero
```

## 异常组与 except *
> [PEP 654 – Exception Groups and except* | peps.python.org](https://peps.python.org/pep-0654/)

### 动机
- **并发错误**：很多异步任务的各种框架允许用户同时进行多个任务，并将结果聚合后一起返回，这时进行异常处理就比较麻烦
- **在复杂计算中抛出的多个错误**

pep 中列出了几种情况，总的来说很多都围绕“**同时有多个错误发生，且每一个都需要处理**”的情况。为了更好解决这个问题， 311 提出了异常组

### ExceptionGroup
此 pep 提出了两个新的类： `BaseExceptionGroup(BaseException)` 和 `ExceptionGroup(BaseExceptionGroup, Exception)`. 它们可以被赋给`Exception.__cause__` 、 `Exception.__context__`，并且可以通过`raise ExceptionGroup(...)` + `try: ... except ExceptionGroup: ...` 或 `raise BaseExceptionGroup(...)` + `try: ... except BaseExceptionGroup: ...` 抛出和捕获。  
二者的构造参数均接受俩参数：
- `message`：消息
- `exceptions`：错误列表  
如： `ExceptionGroup('issues', [ValueError('bad value'), TypeError('bad type')])`

区别在于，`ExceptionGroup` 只能包裹 `Exception` 的子类 ，而 `BaseExceptionGroup` 能包裹任意 `BaseException` 的子类。 为行文方便，后文里的“异常组”将代指二者之一。 

因为异常组可以嵌套，所以它能形成一个树形结构。方法 `BaseExceptionGroup.subgroup(condition)` 能帮我们获取到满足条件的的子异常组，它的整体结构和原始异常组相同。

```python
>>> eg = ExceptionGroup(
...     "one",
...     [
...         TypeError(1),
...         ExceptionGroup(
...             "two",
...              [TypeError(2), ValueError(3)]
...         ),
...         ExceptionGroup(
...              "three",
...               [OSError(4)]
...         )
...     ]
... )
>>> import traceback
>>> traceback.print_exception(eg)
  | ExceptionGroup: one (3 sub-exceptions)
  +-+---------------- 1 ----------------
    | TypeError: 1
    +---------------- 2 ----------------
    | ExceptionGroup: two (2 sub-exceptions)
    +-+---------------- 1 ----------------
      | TypeError: 2
      +---------------- 2 ----------------
      | ValueError: 3
      +------------------------------------
    +---------------- 3 ----------------
    | ExceptionGroup: three (1 sub-exception)
    +-+---------------- 1 ----------------
      | OSError: 4
      +------------------------------------

>>> type_errors = eg.subgroup(lambda e: isinstance(e, TypeError))
>>> traceback.print_exception(type_errors)
  | ExceptionGroup: one (2 sub-exceptions)
  +-+---------------- 1 ----------------
    | TypeError: 1
    +---------------- 2 ----------------
    | ExceptionGroup: two (1 sub-exception)
    +-+---------------- 1 ----------------
      | TypeError: 2
      +------------------------------------
>>>
```

如果 `subgroup`啥也没匹配到，它会返回`None`；如果你想把匹配的和没匹配的分开，则可以用`spilt`方法
```python
>>> type_errors, other_errors = eg.split(lambda e: isinstance(e, TypeError))
>>> traceback.print_exception(type_errors)
  | ExceptionGroup: one (2 sub-exceptions)
  +-+---------------- 1 ----------------
    | TypeError: 1
    +---------------- 2 ----------------
    | ExceptionGroup: two (1 sub-exception)
    +-+---------------- 1 ----------------
      | TypeError: 2
      +------------------------------------
>>> traceback.print_exception(other_errors)
  | ExceptionGroup: one (2 sub-exceptions)
  +-+---------------- 1 ----------------
    | ExceptionGroup: two (1 sub-exception)
    +-+---------------- 1 ----------------
      | ValueError: 3
      +------------------------------------
    +---------------- 2 ----------------
    | ExceptionGroup: three (1 sub-exception)
    +-+---------------- 1 ----------------
      | OSError: 4
      +------------------------------------
>>>
```

### exept *
为了更好处理异常组，新的语法`except*`就诞生了。它可以匹配异常组的一个或多个异常，并且**将其他未匹配的继续传递给其他`except*`**。示例代码如下：
```python
try:
    ...
except* SpamError:
    ...
except* FooError as e:
    ...
except* (BarError, BazError) as e:
    ...
```
对于上面的例子，假设产生异常的代码为`ubhandled = ExceptionGroup('msg', [FooError(1), FooError(2), BazError()])`。则 `except*` 就是不断对 `unhandled` 进行 `spilt`，并将未匹配到的结果传下去。对上面的例子：
1. `unhandled.split(SpamError)` 返回 `(None, unhandled)`，`unhandled` 不变
2. `unhandled.split(FooError)` 返回`match = ExceptionGroup('msg', [FooError(1), FooError(2)])`、 `rest = ExceptionGroup('msg', [BazError()])`. 这个 `except*` 块会被执行, `e` 和 `sys.exc_info()` 的值被设为 `match`，`unhandled` = `rest`
3. 第三个也匹配到了， `e` 和 `sys.exc_info()` 被设为 `ExceptionGroup('msg', [BazError()])`


对于嵌套的情况，示例如下：
```python
>>> try:
...     raise ExceptionGroup(
...         "eg",
...         [
...             ValueError('a'),
...             TypeError('b'),
...             ExceptionGroup(
...                 "nested",
...                 [TypeError('c'), KeyError('d')])
...         ]
...     )
... except* TypeError as e1:
...     print(f'e1 = {e1!r}')
... except* Exception as e2:
...     print(f'e2 = {e2!r}')
...
e1 = ExceptionGroup('eg', [TypeError('b'), ExceptionGroup('nested', [TypeError('c')])])
e2 = ExceptionGroup('eg', [ValueError('a'), ExceptionGroup('nested', [KeyError('d')])])
>>>
```

更多复杂的情况请参考 pep 内容，此处不再赘述


## TOML 的标准库支持
类似于 `Json` 和 `yaml`，TOML 也是一种配置文件的格式。它于 `2021.1` 发布了 `v1.0.0` 版本。目前，不少的 python 包就使用 TOML 书写配置文件。  
>TOML 旨在成为一个语义明显且易于阅读的最小化配置文件格式。  
TOML 被设计成可以无歧义地映射为哈希表。  
TOML 应该能很容易地被解析成各种语言中的数据结构。

一个 TOML 的文件例子如下：
```toml
name = "FunnySaltyFish" 
author.juejin = "https://juejin.cn/user/2673613109214333" 
author.github = "https://github.com/FunnySaltyFish/" 

[blogs]
python1 = "https://juejin.cn/post/7146579580176842783"
python2 = "https://juejin.cn/post/7015590447745613854"
```

它转化为 Json 如下所示
```json
{
    "name":"FunnySaltyFish",
    "author":{
        "juejin":"https://juejin.cn/user/2673613109214333",
        "github":"https://github.com/FunnySaltyFish/"
    },
    "blogs":{
        "python1":"https://juejin.cn/post/7146579580176842783",
        "python2":"https://juejin.cn/post/7015590447745613854"
    }
}
```

3.11 中使用的方法也很简单，基本和 `json` 模块用法类似。不过并未支持写入，需要的话可以用第三方库 `toml`
```python
import tomllib

path = "./test.toml"
with open(path, "r", encoding="utf-8") as f:
    s = f.read()
    # loads 从字符串解析
    data = tomllib.loads(s)
    print(data)

# 或者 load 直接读文件
with open(path, "rb") as f2:
    data = tomllib.load(f2)
    print(data)

# tomllib 不支持写入，可以使用 toml 库，它包含 dump/dumps
# toml.dump 和 toml.dumps 均类似 json.dump 和 json.dumps，不赘述
# with open("./new_config.toml", "w+", encoding="utf-8") as f:
#     toml.dump(data, f)
```


## typing.Self
> [PEP 673 – Self Type | peps.python.org](https://peps.python.org/pep-0673/)

这是 python 的 type hint 的增强，如果不太了解，可以参考我写的 [写出更现代化的Python代码：聊聊 Type Hint](https://juejin.cn/post/7146579580176842783)，里面已经提到了这个特性。  
简而言之，typing.Self 用于在尚未定义完全的类中代指自己，简单解决了先有鸡还是先有蛋的问题。用法如下：
```python
from typing import Self

class Shape:
    def set_scale(self, scale: float) -> Self:
        self.scale = scale
        return self


class Circle(Shape):
    def set_radius(self, radius: float) -> Self:
        self.radius = radius
        return self
```

## Variadic Generics 不定长泛型
要解释这个，我们需要先提一下`泛型`。如果你学过其他语言，比如 Java，你不会对这个概念陌生。  
举个栗子，如果你希望写一个 `f` 函数，你希望这个函数支持传入类型为 `list[int]`或`list[str]`的参数，也就是**各项类型相同且要么为int要么为str的列表**。你可以这样写：
```python
from typing import TypeVar

T = TypeVar("T", int, str)

def f(arr: list[T]) -> T:
    pass

i = f([1, 2, 3])  # 合法，i 的类型为 int
s = f(["a", "b", "c"])  # 合法，s 的类型为 str
b = f([1, 2, 3.0]) # 不合法，因为 3.0 不是 int 或 str
```

`T` 就代表泛型，根据传入的参数情况，被认定为 `int` 或 `str`。  
如果需要写泛型类，我们可以用到 `Generic`。比如下面的代码：
```python
K = TypeVar("K", int, str)
V = TypeVar("V")


class Item(Generic[K, V]):  
    # Item是一个泛型类，可以确定其中的2个类型
    key: K
    value: V
    def __init__(self, k: K, v: V):
        self.key = k
        self.value = v


i = Item(1, 'a')  # OK Item是泛型类，所以符合要求的类型值都可以作为参数
i2 = Item[int, str](1, 'a')  #  OK 明确的指定了Item的K, V的类型
i3 = Item[int, int](1, 2)  #  OK 明确的指定成了另外的类型
i4 = Item[int, int](1, 'a')  # Rejected 因为传入的参数和指定的类型V不同
```

此代码引自 [Python 3.11新加入的和类型系统相关的新特性](https://www.dongwm.com/post/python-3-11-new-typing-feature/#PEP646%E2%80%93VariadicGenerics)，一篇很好的文章，大家也可以去看一下

回到本文，为什么 3.11 又提出了个 `TypeVarTuple` 呢？让我们考虑这样的情况：

我们给定一个函数，它接收一个数组，并且对数据的形状有严格要求。  
*事实上，如果你经常用 `numpy`、`tensorflow` 或者 `pytorch` 之类的库，你会经常碰见类似的情况。*

```python
def to_gray(videos: Array): ...
```

但从这个标记中，很难看出数组应该是什么 shape 的。可能是：

> batch × time × height × width × channels

也或者是

> time × batch × channels × height × width.

所以，`TypeVarTuple`就诞生了。我们可以类似这样去写这个类：

```python
from typing import TypeVar, TypeVarTuple

DType = TypeVar('DType')
Shape = TypeVarTuple('Shape')

class Array(Generic[DType, *Shape]):

    def __abs__(self) -> Array[DType, *Shape]: ...

    def __add__(self, other: Array[DType, *Shape]) -> Array[DType, *Shape]: ...
```

在使用时就可以限制维度和格式：
```python
from typing import NewType

Height = NewType('Height', int)
Width = NewType('Width', int)

x: Array[float, Height, Width] = Array()
```

或者甚至指定确切的大小（使用 字面量 Literal）
```python
from typing import Literal as L


x: Array[float, L[480], L[640]] = Array()
```

更多的介绍请参考 pep


## 任意字符串字面量
> [PEP 675](https://www.python.org/dev/peps/pep-0675/) -- Arbitrary Literal String Type
## 可选的 TypedDict 键
> [PEP 655](https://www.python.org/dev/peps/pep-0655/) -- Marking individual TypedDict items as required or potentially-missing
## 数据类变换
> [PEP 681](https://www.python.org/dev/peps/pep-0681/) -- Data Class Transforms

关于上面三者的介绍，我感觉 [Python 3.11新加入的和类型系统相关的新特性](https://www.dongwm.com/post/python-3-11-new-typing-feature/#PEP675%E2%80%93ArbitraryLiteralStringType) 已经很清晰了，我就不重复造轮了。感兴趣的读者可以前往阅读


## 除此之外
除了上面提到的 pep，3.11 的主要更新列表还包含两个 gh，分别为 
- [gh-90908](https://github.com/python/cpython/issues/90908) -- 为 asyncio 引入任务组
- [gh-34627](https://github.com/python/cpython/issues/34627/) -- 正则表达式项支持 Atomic Grouping (`(?>...)`) 和 Possessive Quantifiers (`*+, ++, ?+, {m,n}+`)

感兴趣的同学可以自行前往对应链接阅读。

本文完。
> 作者 FunnySaltyFish，juejin/Github 可直接搜到。本文仅发于掘金和个人网站(blog.funnysaltyfish.fun)，如需交流建议前往这俩平台找我（掘金优先） 