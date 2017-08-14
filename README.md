# kafka-proxied
## Exposing Kafka Cluster through Public Network Gateway


![kafka_cluster_topology](kafka_cluster_topology.PNG)


###Internal Network Kafka Cluster Configuration

####kafka_node_1 (runs Kafka-Zookeeper and Kafka-Broker-1 processes)
This node in the cluster will run a Zookeper instance and a Broker instance. 
This shows the configurations for each process
```
--- /home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-zookeeper-config-1.properties ---
dataDir=/tmp/zookeeper
clientPort=2181
maxClientCnxns=0
--- /home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-broker-1.properties ---
broker.id=1
listeners=PLAINTEXT://:9091
advertised.listeners=PLAINTEXT://cleverfishsoftware.com:9091
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
message.max.bytes=1048576
log.segment.bytes=1073741824
log.dirs=/tmp/kafka-logs/1
num.partitions=1
num.recovery.threads.per.data.dir=1
log.retention.hours=1
log.retention.bytes=26214400
log.retention.check.interval.ms=300000
zookeeper.connect=cleverfishsoftware.com:2181
zookeeper.connection.timeout.ms=16000
```
#####kafka-zookeeper-1-config.properties (no special requirements)
#####kafka-broker-1-config.properties (required to expose public cluster details)
#####/etc/hosts (required dns resolution to the public cluster nodes)
#####firewall config (inbound rules need to allow for external/internal connections)

- - -

####kafka_node_2 (runs Kafka-Broker-2 process)
#####kafka-broker-1-config.properties (required to expose public cluster details)
#####/etc/hosts (required dns resolution to the public cluster nodes)
#####firewall config (inbound rules need to allow for external/internal connections)
- - -
####kafka_node_3 (runs Kafka-Broker-3 process)
#####kafka-broker-1-config.properties (required to expose public cluster details)
#####/etc/hosts (required dns resolution to the public cluster nodes)
#####firewall config (inbound rules need to allow for external/internal connections)
- - -
####Peters-iMac
- ip must be allow to connect on each node
- - -
- - -



###External Network Kafka Clients (consumer and producer)
- - -

####hostpitalitykafkapocnode0
- - -

####hostpitalitykafkapocnode1
- - -
- - -

##Notes:

