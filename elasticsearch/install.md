https://www.elastic.co/guide/en/elasticsearch/reference/8.1/docker.html

docker pull docker.elastic.co/elasticsearch/elasticsearch:8.1.1

docker network create elastic

```
docker run --name es01 --net elastic -p 9200:9200 -p 9300:9300 -it docker.elastic.co/elasticsearch/elasticsearch:8.1.1

// reset elastic user password
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-reset-password
```

ERROR: [1] bootstrap checks failed. You must address the points described in the following [1] lines before starting Elasticsearch.
bootstrap check failure [1] of [1]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
https://blog.csdn.net/xcc_2269861428/article/details/100186654

```
echo 'vm.max_map_count=262144' > /etc/sysctl.d/10-elasticsearch.conf
sysctl -w vm.max_map_count=262144
```

```
curl --cacert http_ca.crt -u elastic:*PQpBaR*8J65xQCgTMxq https://localhost:9200
```

```
// create new enrollment-token for node
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node

// add new node to es cluster
docker run -e ENROLLMENT_TOKEN="<token>" --name es02 --net elastic -it docker.elastic.co/elasticsearch/elasticsearch:8.1.1
```

http_ca.crt
The CA certificate that is used to sign the certificates for the HTTP layer of this Elasticsearch cluster.

http.p12
Keystore that contains the key and certificate for the HTTP layer for this node.
```
bin/elasticsearch-keystore show xpack.security.http.ssl.keystore.secure_password
```

transport.p12
Keystore that contains the key and certificate for the transport layer for all the nodes in your cluster.
```
bin/elasticsearch-keystore show xpack.security.transport.ssl.keystore.secure_password
```

```
docker network create elastic
docker pull docker.elastic.co/kibana/kibana:8.1.1
docker run --name kib-01 --net elastic -p 5601:5601 docker.elastic.co/kibana/kibana:8.1.1
// reset enrollment token for Kibana
docker exec -it es01 /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana

curl -L -O https://raw.githubusercontent.com/elastic/beats/8.1/deploy/kubernetes/filebeat-kubernetes.yaml
```




# dockerd启动参数
https://docs.docker.com/engine/reference/commandline/dockerd/
  "log-opts": {
    "cache-disabled": "false",
    "cache-max-file": "5",
    "cache-max-size": "20m",
    "cache-compress": "true",
    "env": "os,customer",
    "labels": "somelabel",
    "max-file": "5",
    "max-size": "10m"
  }

# kubelet启动参数
https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/#kubelet-config-k8s-io-v1beta1-KubeletConfiguration
containerLogMaxSize	Default: "10Mi"
containerLogMaxFiles	Default: 5
LoggingConfiguration {
format [Required] string
flushFrequency [Required] time.Duration
verbosity [Required] uint32
vmodule [Required] VModuleConfiguration
sanitization [Required] bool
options [Required] FormatOptions
}
log-dir

# filebeat
processor
https://www.elastic.co/guide/en/beats/filebeat/current/filtering-and-enhancing-data.html
input.processor.add_kubernetes_metadata 
https://www.elastic.co/guide/en/beats/filebeat/current/add-kubernetes-metadata.html
output.elasticsearch
https://www.elastic.co/guide/en/beats/filebeat/current/elasticsearch-output.html


# 创建my-index-000001 index，并向其中导入1号文档，内容为{"create_date":"2015/09/02"}
curl -XPUT --cacert http_ca.crt -u elastic:*PQpBaR*8J65xQCgTMxq https://localhost:9200/my-index-000001/_doc/1 -H 'Content-Type:application/json' -d '{"create_date":"2015/09/02"}'
