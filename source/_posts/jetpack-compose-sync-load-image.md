---
title: Jetpack Compose异步加载图片的实现
date: 2021-07-14 19:25:27
tags: ["Jetpack Compose"]
cover: /images/bg_jetpack_compose.jpeg
---

本文使用两种方式，实现Compose中图片的异步加载
## 前言
Android开发中异步加载图片是非常常见的需求。本文将带你实现这一需求。
本文将分为如下两个方面：

 1. 自己写函数
 2. 用开源库

---

## 实现
### 借助Glide库自己写
Glide开源库基本上成为了Android中加载图片的首选，其简单易用的API和强大的缓存能力让这一过程变得十分方便。
自然在Jetpack Compose中也可以使用。
#### 引入依赖
在模块中的`build.gradle`中加入

```bash
implementation 'com.github.bumptech.glide:glide:4.12.0'
annotationProcessor 'com.github.bumptech.glide:compiler:4.12.0'
```

#### 编写函数
如何让Glide把图片加载到Compose组件上去呢？我们可以利用其提供的`into(Target)`指定自定义的target，再搭配上`mutableState<Bitmap>`的返回值，即可实现在图片加载完成后Compose自动更新
图片加载时一般会有一个默认的`loading`图，我们可以如法炮制，让Glide先帮我们加载一张本地图片，然后再去加载网络图片即可。
编写的函数如下：

```kotlin
/**
 * 使用Glide库加载网络图片
 * @author [FunnySaltyFish](https://funnysaltyfish.github.io)
 * @date 2021-07-14
 * @param context Context 合理的Context
 * @param url String 加载的图片URL
 * @param defaultImageId Int 默认加载的本地图片
 * @return MutableState<Bitmap?> 加载完成（失败为null）的Bitmap-State
 */
fun loadImage(
    context: Context,
    url: String,
    @DrawableRes defaultImageId: Int = R.drawable.load_holder
): MutableState<Bitmap?> {
    val TAG = "LoadImage"
    val bitmapState: MutableState<Bitmap?> = mutableStateOf(null)

    //为请求加上 Headers ，提高访问成功率
    val glideUrl = GlideUrl(url,LazyHeaders.Builder().addHeader("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.67").build())

    //先加载本地图片
    Glide.with(context)
        .asBitmap()
        .load(defaultImageId)
        .into(object : CustomTarget<Bitmap>() {
            override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                //自定义Target，在加载完成后将图片资源传递给bitmapState
                bitmapState.value = resource
            }

            override fun onLoadCleared(placeholder: Drawable?) {}
        })

    //然后再加载网络图片
    try {
        Glide.with(context)
            .asBitmap()
            .load(glideUrl)
            .into(object : CustomTarget<Bitmap>() {
                override fun onResourceReady(resource: Bitmap, transition: Transition<in Bitmap>?) {
                    //自定义Target，在加载完成后将图片资源传递给bitmapState
                    bitmapState.value = resource
                }

                override fun onLoadCleared(placeholder: Drawable?) {}
            })
    } catch (glideException: GlideException) {
        Log.d(TAG, "loadImage: ${glideException.rootCauses}")
    }

    return bitmapState
}
```
#### 使用例子
简单的例子如下：

```kotlin
@Composable
fun LoadPicture(
    url : String
){

    val imageState = loadImage(
        context = LocalContext.current,
        url = url,
    )

    Card(modifier = Modifier
        .padding(4.dp)
        .clickable { }) {
        //如果图片加载成功
        imageState.value?.let {
            Image(
                bitmap = it.asImageBitmap(),
                contentDescription = "",
                modifier = Modifier
                    .padding(4.dp)
                    .fillMaxWidth()
            )
        }
    }
}

//......

LazyColumn {
	val urls = arrayListOf<String>()
	for (i in 500..550){urls.add("https://nyc3.digitaloceanspaces.com/food2fork/food2fork-static/featured_images/$i/featured_image.png")}
	itemsIndexed(urls){ _ , url -> LoadPicture(url = url)}
}
```
效果如下图所示：
**加载中**

![加载中](https://img-blog.csdnimg.cn/20210714190357323.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
**加载完毕**
![加载成功](https://img-blog.csdnimg.cn/20210714190734214.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
`P.S.：别忘了声明网络权限哦！`

### 借助开源框架
事实上，谷歌在其[开发文档](https://developer.android.google.cn/jetpack/compose/libraries)中也给出了示例，用的是开源库[Accompanist](https://github.com/google/accompanist)
![谷歌的官方例子](https://img-blog.csdnimg.cn/20210714191039630.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)
所以我们也可以用这个
#### 简单的例子

```bash
implementation "com.google.accompanist:accompanist-coil:0.13.0"
```

```kotlin
/**
 * @author [FunnySaltyFish](https://funnysaltyfish.github.io)
 * @date 2021-07-14
 * @param url 加载的链接
 */
@Composable
fun LoadPicture2(url:String){
    val painter = rememberCoilPainter(url)

    Box {
        Image(
            painter = painter,
            contentDescription = "",
        )

        when (painter.loadState) {
            is ImageLoadState.Loading -> {
                // 显示一个加载中的进度条
                CircularProgressIndicator(Modifier.align(Alignment.Center))
            }
            is ImageLoadState.Error -> {
                // 如果发生了什么错误，你可以在这里写
                Text(text = "发生错误", color = MaterialColors.RedA200)
            }
            else -> Text(text = "未知情况", color = MaterialColors.PurpleA400)
        }
    }
}
```
效果如下：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20210714191350243.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

![加载中](https://img-blog.csdnimg.cn/20210714191350753.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzQzNTk2MDY3,size_16,color_FFFFFF,t_70#pic_center)

`P.S.：如果想更好的看到加载的情况，可以在模拟器设置中将网络类型设置为较慢的类型`

#### 一些限制
个人感觉，这种方式有以下的问题：

- 滑动加载时不如Glide流畅
- 对Kotlin版本有要求，如（截止文章写作时）最新的`0.13.0`版就必须用`kotlin1.5`及以上版本，否则就会编译出错

## 参考
- [视频](https://www.youtube.com/watch?v=ktOWiLx83bQ&list=PLgCYzUzKIBE_I0_tU5TvkfQpnmrP_9XV8&index=20)

