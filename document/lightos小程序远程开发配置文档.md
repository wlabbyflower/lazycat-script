## 1. 安装配置lightos

https://appstore.lazycat.cloud/#/shop/detail/cloud.lazycat.lightos.entry

> 移动编程离不开 Lightos，效率非常高。而且一台微服可以创建多个实例，配合`codex`或者`claude`，加上微服自身的内网穿透，将服务直接发布到微服中移动编程也能立马看效果。说一句移动编程天花板一点而不为过。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/1958dc53-f742-440d-8d56-f087aa9980d5.png "image.png")

> 首先创建一个新的lightos实例，作为小程序开发的底座。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/38c16f70-e004-4802-b31a-22345668aace.png "image.png")
![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/28a49f37-a142-414d-9dc7-1ab0b6ab8323.png "image.png")

> 系统选择 arch（因为arch的包一般比较新，小程序开发平台一般都比较兼容）
> 基础软件包中的 `基础开发工具` 一定要勾选上，然后就是Ai开发的 `codex` 或者 `claude`

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/c52320fe-d2ba-4fd8-852e-c51e9cc17bda.png "image.png")

> 第二步一定要挂载上 `/dev`（后续桌面环境需要使用上），推荐挂载上`/lzcapp/document`(可以直接访问懒猫网盘中的内容)

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/5c7eeb29-b75b-4f8f-ab59-127a3f84b4f0.png "image.png")

> 这一步是配置lightos实例的名字和用户名以及密码（密码一定要记住，后面多次会用到），最下方的开机自启动根据需求选择。然后点击创建就好了。

## 2. 配置桌面环境和微信小程序开发环境

> 这一步主要是为后面微信小程序开发做准备。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/44896639-4c77-43a7-b26e-860090ab1370.png "image.png")

> 进入lightos实例的`webshell` (这个是后面经常会使用到的一个功能)

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/7123a70a-e379-4e64-95f8-bd68c8224f0f.png "image.png")

> 执行`curl https://raw.giteeusercontent.com/longtaipeng/lazycat-script/raw/master/arch-wechat.sh -O` 下载一下配置文件。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/7c3a1beb-98a0-4129-a891-1571287c1490.png "image.png")

> 给予脚本可执行权限 `chmod +x ./arch-wechat.sh`
> 执行脚本 `VNC_NO_PASSWORD=1 ./arch-wechat.sh`
> 输入密码。（输入时不会有显示，输入完成之后按下回车就好了）,脚本配置过程中需要输入好几次密码，但看到 `password for xxx`时输入密码就好了。耐心等脚本配置好。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/1f5b16e8-ce5e-422c-9f59-907177282597.png "image.png")

> 出现这个就表示脚本配置成功了。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/1ce3f211-ad28-40ee-912a-91209fc1f982.png "image.png")

> 第一次需要手动启动一下桌面服务 `sudo systemctl start novnc.service`
> 查看桌面服务状态 `sudo systemctl status novnc.service` 出现图片上的 ativce (running) 就表示成功了。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/2111651c-09e4-4e89-9e6f-5a75563eae81.png "image.png")

> 在设置里面将桌面服务发布出去，方便访问桌面服务。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/d808bb23-a888-460a-b596-4f1951a68892.png "image.png")
![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/479faa7e-2ba1-4333-863e-1d5e345ba407.png "image.png")

> 转发服务的域名填写为 `127.0.0.1` 端口为 `6080`
> 服务名和域名推荐填写为 `wechat-novnc`
> 推荐不使用账号验证。然后点击发布

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/4dd9239b-2181-4966-8656-1da1e9ee3e44.png "image.png")

> 在客户端桌面就能看到刚才的服务。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/3d40bbaa-5ded-4b7d-971c-e429cdb03085.png "image.png")

> 点击连接就能连接上桌面

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/ce113fdc-a93b-47fb-800f-aaf8b2453f46.png "image.png")

> 使用小技巧：点击箭头处就可以映射电脑的输入法进去。点击设置就能修改桌面缩放模式，建议修改为`远程调整`

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/e942e0e0-286b-4983-8a4a-4ecd0ab91d17.png "image.png")
![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/a58788a5-1a43-47a8-b0e2-dcfb74cafde7.png "image.png")

> 应用里面可以打开微信开发者工具

> 现在就可以在微服里面开发小程序了。但这个不是最终版本，最终是配合 codex 实现远程小程序开发。

## 4. 配合codex远程开发

> 注意，AI模型一定要选择比较好的，比如"GPT"，“DEEPSEEK”系列的，避免因为AI模型问题导致无法正常工作。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/e9ed824a-9030-431e-8155-a8626e7d288d.png "image.png")
![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/96cf565f-b83c-4ed8-9292-93409f67383f.png "image.png")

> 点击小程序开发者工具的设置，安全里面开启服务端口，这个是确保让AI模型能够连接上小程序开发者工具

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/b3405a8b-091e-4f3f-acc9-bb5d8ecae7f1.png "image.png")

> 然后打开自己的项目。

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/978e01ec-8083-4cfd-8eca-d0aa1426af20.png "image.png")

> 回到 lightos 的webshell中，和自己的AI对话。内容如下：
> "我安装了微信开发者工具,你连接一下微信开发者工具, 微信开发者工具的服务端口我已经开启了,你通过这个连接应该就是可以了的"
> 温馨提示：上面的内容你可以加上前面图片中获取到的服务端口，这样可以减少AI的调用次数。如果发现自己AI连接不上的话，建议切换AI模型。（只能切换AI模型解决！！！）

![image.png](https://lzc-playground-1301583638.cos.ap-chengdu.myqcloud.com/guidelines/439/63cd9d60-4fb7-40a4-b367-21c84b202641.png "image.png")

> 二次对话，内容如下：
> “开启微信小程序的自动调试功能(每次编译之后自动在我手机上的微信打开),开启自动编译之后,编译一下我当前小程序开发者工具打开的项目”
> 成功之后，微信会自动打开小程序。

至此，通过lightos + AI 实现随时随地编程就已经实现了。后续只需要在lightos的webshell中打开你的AI Cli 就可以随时随地修改您的小程序代码，随时查看效果。
