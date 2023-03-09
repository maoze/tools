# IPVS

使用ipvs实现lvs功能，需要内核模块和命令行工具的支持。内核模块有ip_vs、ip_vs_rr、ip_vs_**等，命令行工具主要是ipvsadm。

ipvs的主要概念有virtual service(VS)和real-server(RS)两个概念。VS用来指定前端，是服务的入口，负责提供负载均衡的能力，ipvs的负载均衡能力随着版本的更新一直在增长，在CentOS 7中，ipvsadm版本1.27，有10种负载均衡，CentOS 8中，ipvsadm 1.31，有13种负载均衡（注：需要内核同时支持，每一种负载均衡能力都有对应的内核模块，如rr对应ip_vs_rr）。RS是后台，负责提供真正的服务。

VS如何向RS转发客户端的请求包，称为`packet-forwarding`。ipvs有三种`packet-forwarding-method`，可以理解为工作模式。分别为gatewaying(direct routing, DR)、ipip(tunneling)、masquerading(NAT)。阿里云提供了一个新的fullnat模式，但内核及ipvsadm的主线没有合入。

## Virtual Service
ipvs提供了四层的转发能力，VS可以设置tcp-service和udp-service两种（ipvsadm 1.31提供了sctp-service）。创建service使用`-A`，同时可以指定负载均衡模式。创建service后可以使用`-E`更改配置。
```
//创建tcp-service，指定负载均衡模式为rr
# ipvsadm -A -t 192.168.1.1:80 -s rr
//将上面的service负载均衡模式改为wrr
# ipvsadm -E -t 192.168.1.1:80 -s wrr
```
## Packet-forwading-method
### masquerading(NAT)
在NAT模式下，VS收到客户端的请求后，会按照设置好的负载均衡算法，计算出一个后端，然后对请求包做DNAT，即将请求包的目标地址从service ip/port改为后台server的ip/port，源地址不变。

测试环境
```
+---------------------------------------------------------------+
|                                                 RS1           |
|                                           +--------------+    |
|                                           |     VM2      |    |
|                               +---------->+192.168.122.45|    |
|     Client                VS  |           +--------------+    |
| +--------------+      +-------+------+                        |
| |     VM4      |      |     VM1      |                        |
| |192.168.122.70+----->+192.168.122.30|                        |
| +--------------+      +-------+------+          RS2           |
|                               |           +--------------+    |
|                               |           |     VM3      |    |
|                               +---------->+192.168.122.46|    |
|                                           +--------------+    |
|                                                               |
| +--------------------------------------------------------+    |
| |                 virbr0  192.168.122.1                  |    |
| |                                                        |    |
| +--------------------------------------------------------+    |
|                                                               |
|                    Physical Machine                           |
+---------------------------------------------------------------+
```
在45和46两台RS上启动httpd，分别将index.html内容设为本机IP
```
//192.168.122.45:
# yum install httpd -y
# echo '192.168.122.45' > /var/www/html/index.html
# systemctl start httpd

//192.168.122.46:
# yum install httpd -y
# echo '192.168.122.46' > /var/www/html/index.html
# systemctl start httpd
```
在30上建立Virtual Service
```
//192.168.122.30:
# ipvsadm -A -t 192.168.122.30:80 -s rr
# ipvsadm -a -t 192.168.122.30:80 -r 192.168.122.45:80 -m
# ipvsadm -a -t 192.168.122.30:80 -r 192.168.122.46:80 -m
```
在70上访问30
```
//192.168.122.70
# curl 192.168.122.30
```
这里会发现，curl是没有返回的。这是因为我们的所有虚机都在同一个网段内。RS上收到了请求包，源IP还是client的IP，所以RS直接将response发给了client。client收到了response包，因为源IP不是自己请求的IP，所以client将包丢弃了。产生这个问题的原因是masquerading模式Virtual Service只做了DNAT。所以masquerading模式时，RS一般会将自己的默认路由设为VS所在的服务器，这样保证所有DNAT的流量可以经由VS服务器回复。

在我们这个测试环境中，所有机器的默认路由都是192.168.122.1。如果将45和46的默认路由改为VS所在的30，45和46的网络会有问题，具体原因没有细查。为了测试完成，我们在45和46上添加静态路由，指定192.168.122.70的路由为192.168.122.30，这样两台RS的response包会先发给30，30上的DNAT会将response包的源IP修改为30，再发送给client。（阿里云提供的[fullnat模式](https://github.com/alibaba/LVS)可以解决这个问题）
```
//192.168.122.45
# ip r add 192.168.122.70/32 via 192.168.122.30


//192.168.122.46
# ip r add 192.168.122.70/32 via 192.168.122.30
```
这时在70上再访问30，就可以了
```
//192.168.122.70
# curl 192.168.122.30
192.168.122.45
# curl 192.168.122.30
192.168.122.46
# curl 192.168.122.30
192.168.122.45
# curl 192.168.122.30
192.168.122.46
```
由于我们设置的VS是rr模式，可以看到请求是轮流发送到RS上的。

修改VS为wrr模式，并且设置45的权重为2，46的权重为1
```
//192.168.122.30
# ipvsadm -E -t 192.168.122.30:80 -s wrr
# ipvsadm -e -t 192.168.122.30:80 -r 192.168.122.45:80 -w 2 -m
# ipvsadm -e -t 192.168.122.30:80 -r 192.168.122.46:80 -w 1 -m
```
再次在client上访问30
```
//192.168.122.70
# for i in `seq 100` ; do curl 192.168.122.30 2>/dev/null; done  | grep 192.168.122.45 | wc -l
67
# for i in `seq 100` ; do curl 192.168.122.30 2>/dev/null; done  | grep 192.168.122.46 | wc -l
33
```
可以看到，权重生效了。

### Gatewaying(direct routing, DR)
在DR模式下，VS接收到请求后，只会做一件事，就是将目标MAC修改为RS的MAC，源MAC修改为VS的MAC，IP和PORT都不会做任何改变，然后将包转发给RS。使用这种模式，要解决两个问题：
1. 如何保证RS会响应目标地址为VIP的请求，这通常是将VIP加到RS的一个网卡上实现的；
2. 问题1引出了这个问题，VS、RS上都有VIP，如果有对VIP的ARP请求，会造成冲突。解决方法是抑制RS对VIP的ARP响应，只允许VS响应对VIP的ARP请求。

另外要注意的是，DR模式下，由于VS只修改MAC，所以VS和RS的端口必须一致，想要代理不同端口的服务必须通过增加其它方法来实现。

网上可以看到两种方法实验DR模式。方法一是将VIP加在RS的lo接口上，通过设置内核参数抑制ARP响应
```
# ip a add 192.168.122.30 dev lo
# echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
# echo 2 > /proc/sys/net/ipv4/conf/eth0/arp_announce
# echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
# echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
```
arp_ignore参数的作用是控制系统在收到外部的arp请求时，是否要返回arp响应。
```
0：响应任意网卡上接收到的对本机IP地址的arp请求（包括环回网卡上的地址），而不管该目的IP是否在接收网卡上。
1：只响应目的IP地址为接收网卡上的本地地址的arp请求。
2：只响应目的IP地址为接收网卡上的本地地址的arp请求，并且arp请求的源IP必须和接收网卡同网段。
3：如果ARP请求数据包所请求的IP地址对应的本地地址其作用域（scope）为主机（host），则不回应ARP响应数据包，如果作用域为全局（global）或链路（link），则回应ARP响应数据包。
4~7：保留未使用
8：不回应所有的arp请求
```
arp_announce的作用是控制系统在对外发送arp请求时，如何选择arp请求数据包的源IP地址。
```
0：允许使用任意网卡上的IP地址作为arp请求的源IP，通常就是使用数据包a的源IP。
1：尽量避免使用不属于该发送网卡子网的本地地址作为发送arp请求的源IP地址。
2：忽略IP数据包的源IP地址，选择该发送网卡上最合适的本地地址作为arp请求的源IP地址。
```
方法一验证时，我将VIP设置为了VS的IP，这样造成了一个问题是RS和VS上都有VS的IP，当VS发送RS的arp请求时，RS看到请求IP是自己lo接口上的IP，就没有答复。所以不能使用DR时，不能将VIP设置为VS的IP。
```
//192.168.122.30
# ipvsadm -D -t 192.168.122.30:80
# ipvsadm -A -t 192.168.122.22:80
# ipvsadm -a -t 192.168.122.22:80 -r 192.168.122.45:80 -g
# ipvsadm -a -t 192.168.122.22:80 -r 192.168.122.46:80 -g

//192.168.122.45
# ip a del 192.168.122.30/32 dev lo
# ip a add 192.168.122.22/32 dev lo
# echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
# echo 2 > /proc/sys/net/ipv4/conf/eth0/arp_announce
# echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
# echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce

//192.168.122.46
# ip a del 192.168.122.30/32 dev lo
# ip a add 192.168.122.22/32 dev lo
# echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
# echo 2 > /proc/sys/net/ipv4/conf/eth0/arp_announce
# echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
# echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
```
方法二是将VIP加在RS的eth0接口上，通过arptables命令过滤掉ARP请求
```
# ip a add 192.168.122.30/32 dev eth0
# arptables -I INPUT -d 192.168.122.30 -j DROP
# arptables -I OUTPUT -s 192.168.122.30 -j mangle --mangle-ip-s 192.168.122.45
# arptables -nvL
Chain INPUT (policy ACCEPT 49066 packets, 1374K bytes)
-j DROP -i * -o * -d 192.168.122.30 , pcnt=88 -- bcnt=2464 

Chain OUTPUT (policy ACCEPT 2449 packets, 68572 bytes)
-j mangle -i * -o * -s 192.168.122.30 --mangle-ip-s 192.168.122.45 , pcnt=2 -- bcnt=56 

Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
```
