# kafka-proxied
## Exposing Kafka Cluster through Public Network Gateway


![kafka_cluster_topology](kafka_cluster_topology.png)


###Internal Network Kafka Cluster Configuration

####kafka_node_1 (runs Kafka-Zookeeper and Kafka-Broker-1 processes)
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

