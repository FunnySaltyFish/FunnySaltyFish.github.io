---
title: 写出优雅的Kotlin代码：聊聊我认为的 "Kotlinic"
tags:
  - Kotlin
cover: /images/bg_kotlin.jpeg
date: 2023-01-08 13:23:42
---

"Kotlinic" 一词属于捏造的，参考的是著名的"Pythonic"，后者可以译为“很Python”，意思是写的代码一看就很有Python味。照这个意思，"Kotlinic"就是“很Kotlin”，很有Kotlin味。

Kotlin程序员们不少是从Java转过来的，包括我；大部分时候，大家也都把它当大号的Java语法糖在用。但Kotlin总归是一门新语言，而且，在我眼里还是门挺优雅的语言。所以，或许我们可以把Kotlin写得更Kotlin些。我想**简单粗浅**的聊聊。

> 本文希望：聊聊一些好用的、简洁的但又不失语义的Kotlin代码
>
> 本文不希望：鼓励无脑追求高超技巧，完全放弃了可读性、可维护性，全篇奇技淫巧的操作

受限于本人水平，可能有错误或不严谨之处。如有此类问题，欢迎指出。**也欢迎在评论区探讨交流~**

## 善用with、apply、also、let

### with和apply

with和apply，除了能帮忙少打一些代码外，重要的是能让代码区分更明确。比如

```Kotlin
 val textView = TextView(context)
 textView.text = "fish"
 textView.setTextColor(Color.BLUE)
 textView.setOnClickListener {  }
 val imageView = ImageView(context)
 // ...
```

这就是典型的Java写法，自然，没什么问题。但要是类似的代码多起来，总感觉不知道哪里是哪里。如果换用apply呢？

```Kotlin
 val textView = TextView(context).apply {
     text = "fish"
     setTextColor(Color.BLUE)
     setOnClickListener {  }
 }
 val imageView = ImageView(context).apply {
 ​
 } 
```

`apply` 的大括号轻松划清了边界：**我这里的代码和TextView相关**。看着更整齐。

如果后面不需要这个变量，赋值还能省了

```Kotlin
  // 设置某个view下的各个控件
 with(view) {
     findViewById<TextView>(R.id.some_id).apply {
         text = "fish"
         setTextColor(Color.BLUE)
         setOnClickListener {  }
     }
 ​
     findViewById<ImageView>(R.id.some_id).apply {
 ​
     }
 } 
```

apply的另一个常见场景是用于那些返回自己的函数，比如常见的Builder类的方法

```
 fun setName(name: String): Builder{
     this.name = name
     return this
 }
```

改成apply就简洁得多

```
 fun setName(name: String) = apply{ this.name = name }
```

### also

also的常见场景有很多，它的语义就是**干完上一件事后附带干点什么事。** 举个例子，给个函数 **：**

```
 fun someFunc() : Model{
     // ...
     return Model(name = "model", value = "value")
 }
```

如果我们突然想加个Log，打印一下返回值，按Java的写法，要这么干：

```
 fun someFunc(): Model{
     // ...
     val tempModel = Model(name = "model", value = "value")
     print(tempModel)
     return tempModel
 }
```

改的不少。但是按Kotlin的写法呢？

```
 fun someFunc() : Model{
     return Model(name = "model", value = "value").also {
         print(it)
     }
 }
```

不需要额外整个变量出来。

类似的，比如上面 `apply` 的例子，在没有声明变量的情况下，也可以这样用这个值

```
 findViewById<ImageView>(R.id.some_id).apply {
  // ...
 }.also{ println(it) } 
```

### 整在一起

这几个函数结合起来，在针对一些比较复杂的场景时，对提高代码的可读性还是挺有帮助的。如【唐子玄】在[这篇文章](https://mp.weixin.qq.com/s/EtOYfkB1mLblsjExxUKLdA)里所举的例子：

> 假设需求如下：“缩放 textView 的同时平移 button ，然后拉长 imageView，动画结束后 toast 提示”。

“Java”式写法

```Kotlin
 PropertyValuesHolder scaleX = PropertyValuesHolder.ofFloat("scaleX", 1.0f, 1.3f);
 PropertyValuesHolder scaleY = PropertyValuesHolder.ofFloat("scaleY", 1.0f, 1.3f);
 ObjectAnimator tvAnimator = ObjectAnimator.ofPropertyValuesHolder(textView, scaleX, scaleY);
 tvAnimator.setDuration(300);
 tvAnimator.setInterpolator(new LinearInterpolator());
 ​
 PropertyValuesHolder translationX = PropertyValuesHolder.ofFloat("translationX", 0f, 100f);
 ObjectAnimator btnAnimator = ObjectAnimator.ofPropertyValuesHolder(button, translationX);
 btnAnimator.setDuration(300);
 btnAnimator.setInterpolator(new LinearInterpolator());
 ​
 ValueAnimator rightAnimator = ValueAnimator.ofInt(ivRight, screenWidth);
 rightAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
     @Override
     public void onAnimationUpdate(ValueAnimator animation) {
         int right = ((int) animation.getAnimatedValue());
         imageView.setRight(right);
     }
 });
 rightAnimator.setDuration(400);
 rightAnimator.setInterpolator(new LinearInterpolator());
 ​
 AnimatorSet animatorSet = new AnimatorSet();
 animatorSet.play(tvAnimator).with(btnAnimator);
 animatorSet.play(tvAnimator).before(rightAnimator);
 animatorSet.addListener(new Animator.AnimatorListener() {
     @Override
     public void onAnimationStart(Animator animation) {}
     @Override
     public void onAnimationEnd(Animator animation) {
         Toast.makeText(activity,"animation end" ,Toast.LENGTH_SHORT).show();
     }
     @Override
     public void onAnimationCancel(Animator animation) {}
     @Override
     public void onAnimationRepeat(Animator animation) {}
 });
 animatorSet.start();
```

乱糟糟的。改成“Kotlin式”写法呢？

```
 AnimatorSet().apply {
     ObjectAnimator.ofPropertyValuesHolder(
             textView,
             PropertyValuesHolder.ofFloat("scaleX", 1.0f, 1.3f),
             PropertyValuesHolder.ofFloat("scaleY", 1.0f, 1.3f)
     ).apply {
         duration = 300L
         interpolator = LinearInterpolator()
     }.let {
         play(it).with(
                 ObjectAnimator.ofPropertyValuesHolder(
                         button,
                         PropertyValuesHolder.ofFloat("translationX", 0f, 100f)
                 ).apply {
                     duration = 300L
                     interpolator = LinearInterpolator()
                 }
         )
         play(it).before(
                 ValueAnimator.ofInt(ivRight,screenWidth).apply { 
                     addUpdateListener { animation -> imageView.right= animation.animatedValue as Int }
                     duration = 400L
                     interpolator = LinearInterpolator()
                 }
         )
     }
     addListener(object : Animator.AnimatorListener {
         override fun onAnimationRepeat(animation: Animator?) {}
         override fun onAnimationEnd(animation: Animator?) {
             Toast.makeText(activity,"animation end",Toast.LENGTH_SHORT).show()
         }
         override fun onAnimationCancel(animation: Animator?) {}
         override fun onAnimationStart(animation: Animator?) {}
     })
     start() 
 }
```

从上往下读，层次分明。读起来可以感觉到：

```
 构建动画集，它包含{
     动画1
     将动画1和动画2一起播放
     将动画3在动画1之后播放
     。。。
 }
```

*（上面的代码均来自所引文章）*

## 用好拓展函数

继续上面动画的例子接着说，可以看到，最后的Listener实际上我们只用了 `onAnimationEnd` 这一部分，但却写出了一大堆。这时候，拓展函数就起作用了。

幸运的是，Google官方的 `androidx.core:core-ktx` 已经有了对应的拓展函数：

```
 public inline fun Animator.doOnEnd(
     crossinline action: (animator: Animator) -> Unit
 ): Animator.AnimatorListener =
     addListener(onEnd = action)
     
     
 public inline fun Animator.addListener(
     crossinline onEnd: (animator: Animator) -> Unit = {} ,
     crossinline onStart: (animator: Animator) -> Unit = {} ,
     crossinline onCancel: (animator: Animator) -> Unit = {} ,
     crossinline onRepeat: (animator: Animator) -> Unit = {}
 ): Animator.AnimatorListener {
     val listener = object : Animator.AnimatorListener {
         override fun onAnimationRepeat(animator: Animator) = onRepeat(animator)
         override fun onAnimationEnd(animator: Animator) = onEnd(animator)
         override fun onAnimationCancel(animator: Animator) = onCancel(animator)
         override fun onAnimationStart(animator: Animator) = onStart(animator)
     }
     addListener(listener)
     return listener
 }
```

所以上面的最后几行addListener可以改成

```Kotlin
 doOnEnd { Toast.makeText(activity,"animation end", Toast.LENGTH_SHORT).show() } 
```

是不是简单得多？

当然，弹出Toast似乎也很常用，所以再搞个拓展函数

```Kotlin
 inline fun Activity.toast(text: String, duration: Int = Toast.LENGTH_SHORT) 
     = Toast.makeText(this, text, duration).show()
```

上面的代码又可以改成这样

```Kotlin
 (animation.) doOnEnd  { activity.toast("animation end") } 
```

再比较下原来的

```
  (animation.) addListener(object : Animator.AnimatorListener {
         override fun onAnimationRepeat(animation: Animator?) {}
         override fun onAnimationEnd(animation: Animator?) {
             Toast.makeText(activity,"animation end",Toast.LENGTH_SHORT).show()
         }
         override fun onAnimationCancel(animation: Animator?) {}
         override fun onAnimationStart(animation: Animator?) {}
 })
```

是不是简洁得多？

上面提到 `androidx.core:core-ktx` ，其实它包含了大量有用的拓展函数。如果花点时间了解了解，或许能优化不少地方。最近掘金上也有不少类似的文章，可以参考参考

<https://juejin.cn/post/7115048686170112037>

<https://juejin.cn/post/7116920821150400519>

<https://juejin.cn/post/7121718556546482190>

## 用好运算符重载

Kotlin的运算符重载其实很有用，举个栗子

### 给List添加值

我见过这种代码

```
 val list = listOf(1)
 val newList = listOf(1, 2, 3)
 ​
 val mutableList = list.toMutableList() // 转成可变的
 mutableList.addAll(newList) // 添加新的
 return mutableList.toList() // 返回，改成不可变的
```

但是换成运算符重载呢？

```Kotlin
 val list = listOf(1)
 val newList = listOf(1, 2, 3)
 return list + newList
```

一个"+"号，简明扼要。

又比如，想判断

### 某个View是否在ViewGroup中

最简单的看看索引呗

```Kotlin
 val group = LinearLayout(this)
 val isContain = group.indexOfChild(view) != -1
```

不过，借助core-ktx提供的运算符，我们可以写出这样的代码

```Kotlin
 val group = LinearLayout(this)
 val isContain = view in group
```

语义上更直接

想添加（删除）一个View？除了 `addView` （removeView），也可以直接"+="（-=）

```Kotlin
 val group = LinearLayout(activity)
 group += view // 添加子View
 ​
 group -= view // 移除子View
```

想遍历？重载下 `iterator()` 运算符（core-ktx也写好了），就可以直接for了

```Kotlin
 val group = LinearLayout(this)
 for (child in group) {
     //执行操作
 }
```

（这几个View的例子基本也来自上面的文章）

此外，良好设计的拓展属性和拓展函数也能帮助写出更符合语意的代码，形如

```Kotlin
 // 设置view的大小
 view.setSize(width = 50.dp, height = 100.dp) 
 // 设置文字大小
 textView.setFontSize(18.sp)
```

```Kotlin
 // 获取三天后的时间
 val dueTime = today + 3.days
```

```Kotlin
 // 获取文本的md5编码
 val md5 = "FunnySaltyFish".md5
```

上面的代码很容易能看出是要干嘛，而且也非常容易实现，此处就不再赘述了。

## DSL

关于DSL，大家可能都知道有这么个东西，但可能用的都不多。但DSL若用得好，确实能达到化繁为简的功效。关于DSL的基本原理和实现，fundroid大佬在[Kotlin DSL 实战:像 Compose 一样写代码 - 掘金](https://juejin.cn/post/7069568821568208927)中已经写得非常清晰了，本人就不再画蛇添足，接下来仅谈谈可能的使用吧。

### 构建UI

DSL的一个广泛应用应该就是构建UI了。

#### Anko（已过时）

较早的时候，一个比较广泛的应用可能就是之前的anko库了。JetBrains推出的这个库允许我们能够不用xml写布局。放一个来自博客[Kotlin之小试Anko(Anko库的导入及使用) - SoClear - 博客园](https://www.cnblogs.com/soclear/articles/11449590.html)的例子

```
 private fun showCustomerLayout() {
     verticalLayout {
         padding = dip(30)
         editText {
             hint = "Name"
             textSize = 24f
         }.textChangedListener {
             onTextChanged { str, _, _, _ ->
                 println(str)
             }
         }
         editText {
             hint = "Password"
             textSize = 24f
         }.textChangedListener {
             onTextChanged { str, _, _, _ ->
                 println(str)
             }
         }
         button("跳转到其它界面") {
             textSize = 26f
             id = BTN_ID
             onClick {
                 // 界面跳转并携带参数
                 startActivity<IntentActivity>("name" to "小明", "age" to 12)
             }
         }
 ​
         button("显示对话框") {
             onClick {
                 makeAndShowDialog()
             }
         }
         button("列表selector") {
             onClick {
                 makeAndShowListSelector()
             }
         }
     }
 }
 ​
 private fun makeAndShowListSelector() {
     val countries = listOf("Russia", "USA", "England", "Australia")
     selector("Where are you from", countries) { ds, i ->
         toast("So you're living in ${countries[i]},right?")
     }
 }
 ​
 private fun makeAndShowDialog() {
     alert("this is the msg") {
         customTitle {
             verticalLayout {
                 imageView(R.mipmap.ic_launcher)
                 editText {
                     hint = "hint_title"
                 }
             }
         }
 ​
         okButton {
             toast("button-ok")
             // 会自行关闭不需要我们手动调用
         }
         cancelButton {
             toast("button-cancel")
         }
     }.show()
 }
```

简洁优雅，而且由于是Kotlin代码生成的，还省去了解析xml的消耗。不过，由于“现在有更好的选择”，Anko官方已经停止维护此库；而被推荐的、用于取而代之的两个库分别是：[Views DSL](https://github.com/LouisCAD/Splitties/tree/master/modules/views-dsl) 和 [Jetpack Compose](https://developer.android.google.cn/jetpack/compose)

#### Views DSL

关于这个库，Anko官方在推荐时说，它是“An extensible View DSL which resembles Anko.”。二者也确实很相像，但Views DSL在Anko之上提供了更高的拓展性、对AppCompat的支持、对Material的支持，甚至提供了直接预览kt布局的能力！

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4197269d766946af93fbac6f6d0eb5f2~tplv-k3u1fbpfcp-zoom-1.image)

基本的使用可以看看上图，额外的感兴趣的大家可以去官网查看，此处就不多赘述。

#### Jetpack Compose

作为一个用Compose超过一年的萌新，我自己是十分喜欢这个框架的。但同时，目前（2022-07-25）Compose的基建确实还尚不完善，所以对企业项目来说还，是应该充分评估后再考虑。但我仍然推荐你尝试一下，因为它简单、易用。即使是在现有的View项目中，也能无缝嵌入部分Compose代码；反之亦然。

Talk is cheap, show me your code. 比如要实现一个列表，View项目（使用RecyclerView）需要xml+Adapter+ViewHolder。而Compose就简洁得多：

```
 LazyColumn(Modifier.fillMaxSize()) {
     items(10) { i ->
         Text(text = "Item $i", modifier = Modifier
             .fillMaxWidth()
             .clickable {
                 context.toast("点击事件")
             }
             .padding(8.dp), style = MaterialTheme.typography.h4)
     }
 } 
```

上面的代码创造了一个全屏的列表，并且添加了10个子项。每个item是一个文本，并且简单设置了其样式和点击事件。即使是完全不懂Compose，阅读代码也不难猜到各项的含义。运行起来，效果如下：

![](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/14c46e1385194b10b810b6a9f3734671~tplv-k3u1fbpfcp-zoom-1.image)

### 构建复杂的“字符串”

拼接字符串是一项常见的工作，不过，当它复杂起来但又有一定结构时，简单的"+"或者模板字符串看起来就有些杂乱了。这时，DSL就能很优雅的解决这个任务。

举几个常见的例子吧：

#### Html

使用DSL，能够写出类似这样的代码

```Kotlin
 val htmlText = buildHtml{
     html{
         body{
             div("id" to "wrapper"){
                 p{ +"这是一个段落" }
                 repeat(3){ i ->
                     li{ +"Item ${i+1}" }
                 }
                 img("src" to "https://www.xxx.xxx/", "width" to "100px")
             }
         }
     }
 }
```

上述代码会生成类似这样的html

```html
 <!DOCTYPE html>
 <html lang="zh-CN">
 <body>
     <div id="wrapper">
         <p>这是一个段落</p>
         <ul>Item 1</ul>
         <ul>Item 2</ul>
         <ul>Item 3</ul>
         <img src="https://www.xxx.xxx/" width="100px">
     </div>
 </body>
 </html>
```

简洁直接，而且不容易出错。

你可能比较疑惑上面的 `+"xxx"` 是个啥，其实这是用了运算符重载把String转成了纯文本Tag。代码可能类似于

```Kotlin
 open class Tag()
 open class TextTag(val value: String) : Tag()
 operator fun String.unaryPlus() = TextTag(this)
```

#### Markdown

类似的，也可以用这种方式生成markdown。代码可能类似于

```Kotlin
 val markDownText = buildMarkdown {
     text("我是")
     link("FunnyFaltyFish", "https://github.com/FunnySaltyFish")
     newline()
     bold("很高兴见到你~")
 }
```

生成的文本类似于

```markdown
 我是 [FunnySaltyFish](https://github.com/FunnySaltyFish)  
 ** 很高兴见到你~ **
```

#### SpannableString

对Android开发者来说，这个东西估计更常见。但传统的构造方式可以说够复杂的，所以DSL也能用。好的是，Google已经在 `core-ktx` 里写好了更简便的方法

使用例子如下：

```Kotlin
 val build = buildSpannedString {
         backgroundColor(Color.YELLOW) {
             append("我叫")
             bold {
                 append("FunnySaltyFish")
             }
             append(",是一名学生")
         }
     }
```

渲染出的效果如下

![image.png](https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4323d9bc4a4940f588813cf32d3ce5e9~tplv-k3u1fbpfcp-zoom-1.image)


## 善用"="号

这里的意思其实包含了两个方面：用好Kotlin表达式的返回值，以及"="号做返回值的函数

### Kotlin表达式返回值

学过Kt的大家都知道，不同于Java，它的`if`,`else`,`try`这些是带返回值的。在很多地方，使用 = 加上一个表达式的返回值看着可能会更清晰一些。

也就是，把类似于下面这种的“Java”式写法

```Kotlin
val weekday = 6 // 一周第几天，[1, 7]
var dayDescription = ""
when(weekday){
    in 1..5 -> dayDescription = "工作日"
    in 6..7 -> dayDescription = "周末"
    else -> dayDescription = "世界末日"
}
```

改成下面的“Kotlin”写法

```Kotlin
val weekday = 6 // 一周第几天，[1, 7]
val dayDescription = when(weekday){
    in 1..5 -> "工作日"
    in 6..7 -> "周末"
    else -> "世界末日"
}
```




在try...catch的场合，这样的差异会更明显。比如一个非常简易的读文件例子（下面的代码仅可以读取小文件，请谨慎地实际使用）

```Kotlin
val filePath = "d://学习资料/日语资料.txt"
var result = ""
var inputStream: FileInputStream? = null
try {
    inputStream = FileInputStream(File(filePath))
    result = inputStream.readBytes().decodeToString()
}catch (e: Exception){
    result = "读取失败！"
    e.printStackTrace()
}finally {
    try {
        inputStream?.close()
    }catch (e: IOException){
        e.printStackTrace()
    }
}
```

这是个典型的Java写法，用Kotlin的写法会简洁些

```Kotlin
val result = try {
    File(filePath).inputStream().use {
        it.readBytes().decodeToString()
    }
}catch (e: Exception){
    e.printStackTrace()
    "读取失败"
}
```

这两处代码间主要有下面几处变化：

-   result的赋值直接由try...catch语句的返回值提供

<!---->

-   文件流的关闭由`Closeable.use`拓展函数内部处理，外部调用更简洁

<!---->

-   使用其他拓展函数避免了嵌套的对象创建



如果你对中间读取的错误不关心，可以使用下面的形式

```Kotlin
val result = runCatching {
    File(filePath).inputStream().use {
        it.readBytes().decodeToString()
    }
} .getOrDefault("读取失败")
```

`runCatching`函数返回一个`Result`对象，其`getOrDefault`方法可以在出错时使用给定的默认值（其他几个`get`方法包括`getOrNull`、`getOrThrow`、`getOrElse`）。这样写起来更简洁

不过，上面的写法还是不够Kotlin。借助Kt提供的琳琅满目的拓展函数，其实上面的代码可以写成这样

```Kotlin
val result = runCatching {
    File(filePath).readText()
} .getOrDefault("读取失败")
```

在不需要考虑buffer的情况下，流都不需要管啦 :)



### 函数返回

用"="写函数其实在官方的各种拓展函数里非常常见。有一点比较有趣的是，因为`Unit`在Kotlin里面也是一种普通的类型，所以即使函数什么也不返回（也就是返回Unit），也可以拿"="写。不过这一点就因人而异了，得看实际情况。

对于一些非"unit"返回值的简单函数，用"="显得清晰明了

比如上面的获取`dayDescription`

```
fun getDayDescripton(weekday: Int) = when(weekday){
    in 1..5 -> "工作日"
    in 6..7 -> "周末"
    else -> "世界末日"
}
```

比如打log时可能要输个分割线

```
 // 重复字符串
inline operator fun String.times(n: Int) = this.repeat(n)

val divider = "=" * 20 // ******************** 
```

比如上面的读短文本

```
fun File.readText(default: String) = runCatching {
    this.readText()
} .getOrDefault(default)
```

类似的例子很多很多，就不赘述了。



## 杂项

### Collection

kt的集合可以说是很强大了，该有的不该有的它都给了。随便举几个例子吧

#### 创建

我经常看到类似这样的代码

```
val list = arrayListOf<int>()
list.add(1)
list.add(2)
list.add(3)
```

嗯，很Java。实际上创建一个列表，Kt有更好的方法。

带初始参数的`arrayListOf`

```Kotlin
val list = arrayListOf(1, 2, 3)
```

要是复杂一点呢？比如值为index的平方？

```Kotlin
val list = List(3) { i -> i*i } 
```

基于其他对象创建？

```Kotlin
val names = students.map{ it.name }
```

基于另一个列表中某些符合要求的创建？

```Kotlin
// 及格的同学们
val passedStudents = students.filter{ it.grade >= 60 }
```




#### 转字符串

比如：["a", "b", "c"] -> "a, b, c"

```Kotlin
val string = listOf("a","b","c").joinToString{ it }
```

也可以设置前后缀、分隔符等

```Kotlin
val string = listOf("a","b","c").joinToString(prefix = "[", postfix = "]") { it }
println(string) // [a, b, c] 
```
Kt的`Collection`有很多很好用的方法，此处就不赘述了，大家感兴趣的自己翻翻源代码便是。


### 代理

Kotlin 的 `by` 应该说用的不少，它对应的概念“Delegate”也是语法上相较Java特别的地方。常见的用处呢，最简单的就是`by lazy`延迟初始化；除此之外，利用它也能快速实现一个“懒汉式”的单例（饿汉式的就`object`）

```
class DataManager {
    companion object {
        val IMPL by lazy {
            DataManager()
        }
    }
}
```

放Java的话，上述代码语义上类似于

```
if(IMPL != null)return IMPL;
synchronized(lock) {
    if(IMPL == null){
        IMPL = new DataManager();
    }
    return IMPL;
} 
```

如果不需要锁，还可以加上参数 `lazy(LazyThreadSafetyMode.NONE)`



#### 配合协程

如果懒加载的内容是耗时操作，还可以配合上协程，实现异步的懒加载

```Kotlin
 /*
 * 异步懒加载，by FunnySaltyFish
*
* @param T 要加载的数据类型
* @param scope 加载时的协程作用域
* @param block 加载代码跨
* @return Lazy<Deferred<T>>
*/
fun <T> lazyPromise(scope: CoroutineScope = MainScope(), block: suspend CoroutineScope.() -> T) =
    lazy {
        scope.async(start = CoroutineStart.LAZY) {
            block.invoke(this)
        }
    } 
```

使用的时候才去加载数据，而且可以异步加载。

比如

```Kotlin
private suspend fun fetchData() : String {
    println("开始加载数据")
    delay(1000)
    println("加载完毕")
    return "成功"
}

val username by lazyPromise(viewModelScope) {
    fetchData()
}
val password by lazyPromise(viewModelScope) {
    fetchData()
} 
```

而具体使用这两个变量的方法为

```Kotlin
suspend fun login() = withContext(Dispatchers.IO) {
    username.start()
    password.start()
    println("${username.await()} ${password.await()} 登陆成功！")
} 
```

最后在调用这个函数（比如点击事件）时

```Kotlin
onClick = {
    scope.launch {
        viewModel.login()
    }
} 
```

没有值时会去异步加载这个值，输出如下：

```
开始加载数据
开始加载数据
加载完毕
加载完毕
成功 成功 登陆成功！
```

后面再调用就直接使用已经初始化好的值，输出如下

```
成功 成功 登陆成功！
```



#### 代理属性

代理的一个常见用法估计就是代理各种东东了

Map

```Kotlin
class People(val map: Map<String, Any?>){
    val name: String by map
    val age: Int by map
}

val people = People(mapOf("name" to "FunnySaltyFish", "age" to 20))
println("${people.name}: ${people.age}") // FunnySaltyFish: 20
```

Intent

```Kotlin
// 接收另一个activity传来的数据
val fromEntrance by intentData<String>("entrance")
```

数据库

```Kotlin
// User是某个数据库的表，name age是两列
val name by User.name
val age by User.age
```

至此本文也差不多结束了，林林总总写了我一个多星期，感觉也是一个挺奇妙的过程。最后，如果你觉得我的内容还不错的话，欢迎点个赞，这对我帮助很大！

