# Windows下实现远程服务器X window应用显示

实验环境：
* 服务器系统版本：CentOS Linux release 8.4.2105
* Windows版本：Windows10 21H1 19043.1288
* Xshell版本：Xshell 7(Build 0087)
* Xming：6.9.0.31

## 1. Xming介绍
Xming是一个windows系统下运行的X window服务器。之前是个人开源软件，官网是[这个](http://www.straightrunning.com/XmingNotes/)，后来作者开始要求[捐款才能下载](http://www.straightrunning.com/XmingNotes/#head-16)，其实就是收费了（要求捐款金额是10英镑£10 (GBP)）。目前网上能找到的版本是6.9.0.31。当前（2021.10.30）最新版本是:7.7.0.71。经过验证，6.9.0.31这个版本在当前Win10上可以实现目标。该版本应该已经是非常老，[代码包](https://sourceforge.net/projects/xming/files/Xming-source/6.9.0.31/)至少在2009年就有。github上的[代码库](https://github.com/sourcecode-reloaded/Xming)是2020年建立，但只是该版本的一个拷贝。这么老的程序在当前可以正常运行，侧面说明质量还是比较高吧。

## 2. Xshell介绍
Xshell感觉不用太介绍了，收费软件，有个人免费版。全面，好用。官网是[这个](https://www.netsarang.com/en/)。这个公司的Xmanager也完全可以实现Xming同样功能，但没有个人免费版。Xshell国内想买正版需要通过国内代理商，Xshell 7 ¥989，Xftp 7 ¥639，Xmanager 7没有标价，需咨询客服，估计不便宜。

这里提一下Putty，这是一个优秀的开源ssh客户端，有很大的群众基础，而且Xming还与putty有专门的兼容，所以Putty+Xming应该是一个非常好组合。我自己是用惯了Xshell，懒得折腾putty了。

## 3. 软件下载与安装
这里主要介绍一下Xming。[下载地址](https://sourceforge.net/projects/xming/files/Xming/6.9.0.31/Xming-6-9-0-31-setup.exe/download)。下载完成后双击安装，一路下一步安装完成。默认安装路径是`C:\Program Files (x86)\Xming`。作者在官网上强烈建议了不要更改默认路径，我也没给自己找麻烦:-)。

## 4. 软件配置
### Xming Server

XLaunch是Xming的启动配置软件。启动XLaunch，选择自己的配置，然后`下一页`直到完成。点击完成后，Xming Server会自己启动。

我自己全是用的默认配置。网上很多文章提到了其中的`Dislay number`这个配置项，需要与后续Xshell和远程服务器相匹配。`Display number`默认为0，对应Xming监听的端口号。Xming使用tcp协议，监听的端口号是`6000+Display number`，比如`Display number`是00，则启动的Xming Server监听6000端口，`Display number`是1，则启动的Xming Server监听6001端口，以此类推。可以同时启动多个Xming Server，这时每次启动XLaunch时要求输入不同的`Display number`。

在以管理员运行的CMD或powershell中可以输入命令查看Xming占用的端口。
```
// 通过程序名找到对应PID，输出第二列为PID，实验中PID为6412
> tasklist | findstr Xming
// 通过上面找到的PID 6412找到对应的端口，下面命令中最后的$是正则表达式符号，6412$表示出现在行尾的6412
> netstat -aon | findstr 6412$
```

网上有文档提到了要修改`C:\Program Files (x86)\Xming`路径下的X*.hosts文件，在里面添加远程服务器ip。我自己测试过发现这个不添加似乎也没什么问题。

### Xshell

新建Xshell会话，`连接`和`连接-用户身份验证`两页正常配置，在`连接-SSH-隧道`页中，选中`X11转移`中的`转发X11连接到`，再选择`X DISPLAY`，其后的输入框中输入`localhost:0.0`，这里的第1个0要与上面Xming Server设置中的`Display number`对应。

### 远程服务器

网上很多文章提到了要在服务器端设置`export DISPLAY=localhost:0.0`之类。这个问题验证后发现，当Xshell选中`转发X11连接到`，连接到服务器后，终端会自动设定`DISPLAY`的值，不同终端冒号后的值不同，此时如果`unset DISPLAY`，应用图形无法输出，如果将DISPLAY值中冒号后的数值改为其它，应用图形也无法输出。所以图形显示确实需要DISPLAY环境变量支持，并且有一定的对应规则，该规则还没搞清楚，但肯定**不需要跟上面设置的Xming的`Display number`对应**。在我的实验环境中DISPLAY会自动设置，不需要手动，但这个自动配置到底是Xshell的功能，还是CentOS 8的什么特殊组件/参数的功劳，目前还不清楚。

补充，ssh客户端有参数`-X`开启X11转发，此时ssh连接建立后，服务器端的sshd会监听一个端口，作为X11转发的隧道。该端口号减去6000即为该ssh连接对应的DISPLAY号。sshd会自动设置DISPLAY环境变量。

经过以上步骤，登陆后即可运行图形应用命令，并在Win10上显示对应软件。如virt-manager/gedit/eog/gimp等。

## 5. 一点经验：
* Xming要先启动，ssh连接建立后启动Xming无效

另外说一点，我在实验过程遇到问题时，查到一篇文章说可以在服务器的sshd启动参数里加`-d`启动debug模式，说是可以帮助排查。但我加上后，每次应用输出出错时，都会连带着干掉sshd，导致无法远程登陆。没有细查这个问题，但强烈建议不要打开sshd的debug模式，除非你到服务器终端前重启一下sshd是一件非常简单的事情。
