# 公钥与证书的区别

简单理解证书是签名过的公钥

## 证书生成的流程：

私钥->请求-（ca认证）->证书

## 生成自签名CA的私钥
```
openssl genrsa -out ca.key 2048
```
## 通过私钥生成公钥（可省略）
```
openssl rsa -in ca.key -pubout -out ca.pub
```
## 生成自签名CA证书
### 使用openssl req命令直接生成自签名证书
```
openssl req -x509 -key ca.key -out ca.crt
```
这个命令会让输入CA的Subject相关信息，命令中的关键是-x509参数，它让req命令不要生成一个请求，而是直接生成一个自签名的证书。

使用openssl req生成请求，再用openssl ca认证证书，由于openssl ca命令不好使，不研究了。

# 使用openssl-ca.cnf生成etcd的自认证ca证书
```
[ req ]
distinguished_name      = req_distinguished_name  #对应Subject：字段
x509_extensions = v3_ca  #对应X509v3 extensions字段
prompt = no  #设置为no后不再需要输入，会直接从配置文件里读
[ req_distinguished_name ]
commonName = etcd-ca  #对应 Subject: 中的CN = etcd-ca
[ v3_ca ]
# keyUsage ==  X509v3 Key Usage
# digitalSignature对应Digital Signature
# keyEncipherment对应Key Encipherment
# keyCertSign对应Certificate Sign
keyUsage = critical,digitalSignature,keyEncipherment,keyCertSign
# basicConstraints ==  X509v3 Basic Constraints
basicConstraints = critical,CA:true
# subjectKeyIdentifier ==  X509v3 Subject Key Identifier
subjectKeyIdentifier = hash
# subjectAltName == X509v3 Subject Alternative Name
subjectAltName = @alt_section
[ alt_section ]
DNS = etcd-ca
```
命令（在openssl-ca.cnf里写有效期没有用，因为req工具不会从cnf文件里读取该值，参见：[这里](https://stackoverflow.com/questions/52025910/specify-days-expire-date-for-generated-self-signed-certificate-with-openssl)）：
```
openssl req -x509 -key ca.key -out ca.crt -config openssl-ca.cnf -days 36500
```

# 使用cnf文件生成etcd的server证书
## 生成server证书的私钥
```
openssl genrsa -out server.key 2048
```
## 生成request的openssl-server-req.cnf
```
[ req ]
distinguished_name      = req_distinguished_name
prompt = no
[ req_distinguished_name ]
commonName                      = c160
```
生成request的命令为：
```
openssl req -new -key server.key -out server.req -config openssl-server-req.cnf
```
可以通过下面的命令查看生成的request内容
```
openssl req -in server.req -noout -text
```
## 生成认证用的openssl-server-ca.cnf
```openssl-server-ca.cnf
[ req ]
distinguished_name      = req_distinguished_name
req_extensions  = v3_req        # The extensions to add to the self signed cert
prompt = no
[ req_distinguished_name ]
commonName                      = c160
[ v3_req ]
keyUsage = critical,digitalSignature,keyEncipherment
extendedKeyUsage = serverAuth,clientAuth
basicConstraints = critical,CA:false
authorityKeyIdentifier = keyid
subjectAltName = @alt_section
[ alt_section ]
DNS.1 = c160
DNS.2 = C170
DNS.3 = C180
DNS.4 = localhost
IP.1 = 196.168.122.160
IP.2 = 127.0.0.1
IP.3 = 0:0:0:0:0:0:0:1
```
openssl-ca.cnf与openssl-server-ca.cnf的核心区别有：
1. ca.cnf是用于生成自签名的CA证书，所以指定extensions时在[req]字段用的是x509_extensions，而server-ca.cnf用的是req_extensions字段；
2. extensions字段中的basicConstraints不同，ca.cnf设置为CA:true，server.cnf设置为CA:false
3. extensions字段中ca.cnf使用了subjectKeyIdentifier=hash，server-ca.cnf使用了authorityKeyIdentifier=keyid
4. extensions字段中的keyUsage，ca.cnf比server-ca.cnf多了keyCertSign

### 使用CA证书对server的request进行认证，生成server的证书
cnf文件中的default_days参数一直没有试验成功，也没搜到x509不支持cnf文件中读取，具体原因没找到。命令如下：
```
openssl x509 -req -in server.req -out server.crt -CA ca.crt -CAkey ca.key -extfile openssl-server-ca.cnf -extensions v3_req -days 365
```
### 使用CA证书对签发的server证书进行验证
```
openssl verify -CAfile ca.crt server.crt
```




