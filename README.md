# Kafka-proxied
This project provides scripts and configuration details required to get a multi-node Kafka Cluster running and make it available to producers and consumers both to an internal andwork and over a public dns finally to configure using Kafka MirrorMaker to replicate topic data to a remote Kafka Cluster. 

## Exposing Kafka Cluster through Public Network Gateway
So let's design a Kafka system topology... 

Pictured below is a typical Kafka setup sitting on an internal network with Kafka running over a multi-node cluster distributed across three machines. The first machine `engine1` will be running both Zookeeper and a Kafka broker with broker id `1`. The second and third machines `engine2` and `engine3` are running Kafka brokers identified with broker ids `2` and `3`. This cluster will be referred to as `cluster 1`. All machines are running on the sub-net in the `197.48.1.*` group and are port-mapped from a firewall sitting at the LAN gateway. The port mapping between the gateway firewall and the internal machine:port is show in the diagrm. The LAN gateway has the domain name `my-public-domain` and is resolveable by Internet dns to ip `75.70.33.98`. Notice that the external ports are different than the internal ones, that is those that kafka will be running on based on their machine ip. 

Outside the LAN are two machines sitting in the cloud that have reliable internet accessible ip addreses and domain names as well. These don't have to be cloud machines in fact they could be any machines sitting outside the LAN but the cloud scenario is a likely one. The one machine `Kafkaclientmachine1` will also be running a small single-node Kafka cluster that has Kafka topic data being replicated to it through Kafka MirrorMaker. Both cloud machines `Kafkaclientmachine1` and `Kafkaclientmachine2` are capable of acting as Kafka consumers, producers or can run MirrorMaker processes and in fact can run a small kafka cluster between them or a a single node cluster on one. So `Kafkaclientmachine1` will be running a single-node kafka cluster referred to as `cluster 2` and the `Kafkaclientmachine2` will be running MirrorMaker to pull specific topic data from `cluster 1` and put it onto `cluster 2`. 

For security the kafka machines `engine1` `engine2` and `engine3` will also be running their own firewall and only allow communication to kafka brokers and zookeeper from the internal network and from the specific ip of `Kafkaclientmachine2`. No kafka service ports shall be accesible into `Kafkaclientmachine1` and `Kafkaclientmachine2` and only port 22 will be open for secure shell access.

**While this setup may seem typical, there are a few special considerations and some not so well known nor well  documented configuration settings and OS network configuration decisions to be made in order to make the internal Kafka cluster work both inside and outside the LAN**. By the time you get through this you will understand what has to be considered and how to configure Kafka and even the host machines themselves in order to make it all work. We are trying to avoid the frustration of "***LEADER NOT AVAILABLE***" and not knowing what the problems are or how to fix them. 

While this configuration is about setting up and configuration kafka on hardware machines, it is applicable for VMs and for Dockerized Kafka process as well. Dockerization of Kafka has some additional considerations so that will sit outside the scope of this effort for now but will be added in later. A Vagrantfile is provided in the source code here and available to you to stand up three Vagrant managed VirtualBox VMs if you don't have access to three physical machines. The only special consideration there are some special Vagrant/VirtualBox network settings which again, may be outside the scope of this effort right now should you try this route and run into problems. 

Just a **warning** that you must be somewhat comfortable with Linux, Linux Networking, Kafka to complete this setup. It is not intended to be a guide for Windows and while it is all Linux, it is ready to use on RPM based Linux distros like Redhat and CentOS (not tested on Fedora). Modifications are required (and welcomed to be added to the project) if you intend on using other Linux distros like Ubuntu.  

**Note:** Check Reference Section below for more information on Kafka, Kafka-MirrorMaker, Vagrant, and Docker

![Kafka_cluster_topology](kafka_cluster_topology.png)

### Internal Network Kafka Cluster Configuration
So let's step through the proces of setting this all up and making it work correctly. While Kafka is fairly well documented on the [Apache Kafka website](https://kafka.apache.org), and on the major Hadoop distributions like [Cloudera](https://www.cloudera.com/documentation/kafka/latest/topics/kafka.html) and [Hortonworks](https://hortonworks.com/apache/kafka/) it can be a lot to take in all once and more importantly to set up consistently when you want to repeat the process over and over. The intent of this project is to provide a consistent set of scripts (bash) to configure, stand up and tear down Kafka. This can be quite helpful as first steps towards  setting up production Kafka clusters until things are working. Rather than use other DevOps provisioning tools like Ansible, or perhaps Chef or Puppet, the choice was made to do this using bash scripts as that is available on any linux machine and in many cases for what we are setting up there would be more work to make those tools do the job completely as we are doing more than just install things. **Currently all bash scripts assume an RPM linux distro is being used so if you want to use a Debian distro like Ubunto, you will have to modify appropriately**.

### Step By Step

Let's walk through this step by step starting with the simplest configuration with the least amount of considerations and challenges and go from there... 

#### Setup a Multi-node Kafka Cluster on a Single Machine
##### Create The Kafka Cluster
This is the simplest setup of all. If you refer to the diagram above, this is the setup required to get ```cluster 2``` running. This is eventually to be used to be the target of the replication of topic data from ```cluster 1``` but in order to do that it needs to be a fully operational free-standing kafka cluster. Unlike ```cluster 1``` it does not need to expose brokers through an external domain and combination of external ports. 
**Start the Zookeeper Node**
cd into the location where you cloned this repository and find the scripts/ directory and run the script that will start a zookeeper instance on this ```kafkaclientmachine1``` machine. If everything is okay you should see output from zookeeper look like the following. **Note: ** The scripts are there to help you build paramaterized kafka commands, the same ones that are in the kafka distribution. The scripts rely on a $KAFKA_HOME environment variable being set. If you haven't installed kafka, run ```./install_kafka.sh``` first and either log out and log back into your machine or source the ```~/.bash_profile``` that is modified to set a $KAFKA_HOME for your local installation. 
```bash
[peter@kafkaclientmachine1 ~]$ cd kafka-proxied/scripts/
[peter@kafkaclientmachine1 scripts]$ ./start_kafka_zookeeper.sh
Enter the number of zookeeper instances: 1
Enter the zookeeper host: localhost
Enter the zookeeper host port: 2181
‘/home/peter/vagrant/kafka-proxied/scripts/config/0.10.1.1/zookeeper-template.properties’ -> ‘/home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-zookeeper-1-config.properties’
/home/peter/vagrant/kafka-proxied/local/kafka/default/bin/zookeeper-server-start.sh /home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-zookeeper-1-config.properties> /home/peter/vagrant/kafka-proxied/local/kafka/logs/engine1-zookeeper-1-console.log 2>&1
About to start Zookeeper instance 1, continue? (y/n): y
Tail on log file (/home/peter/vagrant/kafka-proxied/local/kafka/logs/engine1-zookeeper-1-console.log)? (y/n): y
[2017-08-25 06:21:58,294] INFO Server environment:os.name=Linux (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,294] INFO Server environment:os.arch=amd64 (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,294] INFO Server environment:os.version=3.10.0-514.26.2.el7.x86_64 (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,294] INFO Server environment:user.name=peter (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,294] INFO Server environment:user.home=/home/peter (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,294] INFO Server environment:user.dir=/home/peter/vagrant/kafka-proxied/scripts (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,299] INFO tickTime set to 3000 (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,299] INFO minSessionTimeout set to -1 (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,299] INFO maxSessionTimeout set to -1 (org.apache.zookeeper.server.ZooKeeperServer)
[2017-08-25 06:21:58,305] INFO binding to port 0.0.0.0/0.0.0.0:2181 (org.apache.zookeeper.server.NIOServerCnxnFactory)
```
**Start the Broker Nodes**
This installation will (arbitrarily) have 2 brokers running in the cluster. So let's set those up. **Note** You need to specify 2 instances, the correct broker ports, and zookeeper information appropriately. Look through next section carefully and follow as shown.

```bash
[peter@kafkaclientmachine1 scripts]$ ./start_kafka_broker.sh 
Enter the number of broker instances: 2
Confirm the Broker Id (must be unique INT within the cluster): 1
‘/home/peter/vagrant/kafka-proxied/scripts/config/0.10.1.1/broker-template.properties’ -> ‘/home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-broker-1.properties’
Enter the broker port: 9091
Enter the the address the socket server listens on (locally): PLAINTEXT://:9091
Will the broker be accessed by a proxy or external public server (y/n)?: n
Enter the zookeeper host: localhost
Enter the zookeeper host port: 2181
Specify maximum message size the broker will accept (message.max.bytes) in MB. Default value (1 MB): 1
You must make sure that the Kafka consumer configuration parameter fetch.message.max.bytes is specified as at least 1048576!
Specify Size of a Kafka data file (log.segment.bytes) in GiB. Must be larger than any single message. Default value: (1 GiB): 1
Enter Kafka Log default Retention Hours: 1
Enter Kafka Log default Retention Size (Mb): 25
/home/peter/vagrant/kafka-proxied/local/kafka/default/bin/kafka-server-start.sh /home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-broker-1.properties > /home/peter/vagrant/kafka-proxied/local/kafka/logs/engine1-broker-1-console.log 2>&1
About to start Kafka Broker, continue? (y/n): y
Tail on log file (/home/peter/vagrant/kafka-proxied/local/kafka/logs/engine1-broker-1-console.log)? (y/n): y
[2017-08-25 06:34:05,627] INFO [Group Metadata Manager on Broker 1]: Removed 0 expired offsets in 0 milliseconds. (kafka.coordinator.GroupMetadataManager)
[2017-08-25 06:34:05,638] INFO Will not load MX4J, mx4j-tools.jar is not in the classpath (kafka.utils.Mx4jLoader$)
[2017-08-25 06:34:05,651] INFO New leader is 1 (kafka.server.ZookeeperLeaderElector$LeaderChangeListener)
[2017-08-25 06:34:05,657] INFO Creating /brokers/ids/1 (is it secure? false) (kafka.utils.ZKCheckedEphemeral)
[2017-08-25 06:34:05,668] INFO Result of znode creation is: OK (kafka.utils.ZKCheckedEphemeral)
[2017-08-25 06:34:05,669] INFO Registered broker 1 at path /brokers/ids/1 with addresses: PLAINTEXT -> EndPoint(engine1,9091,PLAINTEXT) (kafka.utils.ZkUtils)
[2017-08-25 06:34:05,669] WARN No meta.properties file under dir /tmp/kafka-logs/1/meta.properties (kafka.server.BrokerMetadataCheckpoint)
[2017-08-25 06:34:05,683] INFO Kafka version : 0.10.1.1 (org.apache.kafka.common.utils.AppInfoParser)
[2017-08-25 06:34:05,683] INFO Kafka commitId : f10ef2720b03b247 (org.apache.kafka.common.utils.AppInfoParser)
[2017-08-25 06:34:05,686] INFO [Kafka Server 1], started (kafka.server.KafkaServer)
Confirm the Broker Id (must be unique INT within the cluster): 2
‘/home/peter/vagrant/kafka-proxied/scripts/config/0.10.1.1/broker-template.properties’ -> ‘/home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-broker-2.properties’
Enter the broker port: 9092
Enter the the address the socket server listens on (locally): PLAINTEXT://:9092
Will the broker be accessed by a proxy or external public server (y/n)?: n
Enter the zookeeper host: localhost
Enter the zookeeper host port: 2181
Specify maximum message size the broker will accept (message.max.bytes) in MB. Default value (1 MB): 1
You must make sure that the Kafka consumer configuration parameter fetch.message.max.bytes is specified as at least 1048576!
Specify Size of a Kafka data file (log.segment.bytes) in GiB. Must be larger than any single message. Default value: (1 GiB): 1
Enter Kafka Log default Retention Hours: 1
Enter Kafka Log default Retention Size (Mb): 25
/home/peter/vagrant/kafka-proxied/local/kafka/default/bin/kafka-server-start.sh /home/peter/vagrant/kafka-proxied/local/kafka/config/engine1-broker-2.properties > /home/peter/vagrant/kafka-proxied/local/kafka/logs/engine1-broker-2-console.log 2>&1
About to start Kafka Broker, continue? (y/n): y
Tail on log file (/home/peter/vagrant/kafka-proxied/local/kafka/logs/engine1-broker-2-console.log)? (y/n): y
[2017-08-25 06:34:24,424] INFO [GroupCoordinator 2]: Startup complete. (kafka.coordinator.GroupCoordinator)
[2017-08-25 06:34:24,424] INFO [Group Metadata Manager on Broker 2]: Removed 0 expired offsets in 1 milliseconds. (kafka.coordinator.GroupMetadataManager)
[2017-08-25 06:34:24,435] INFO Will not load MX4J, mx4j-tools.jar is not in the classpath (kafka.utils.Mx4jLoader$)
[2017-08-25 06:34:24,452] INFO Creating /brokers/ids/2 (is it secure? false) (kafka.utils.ZKCheckedEphemeral)
[2017-08-25 06:34:24,463] INFO Result of znode creation is: OK (kafka.utils.ZKCheckedEphemeral)
[2017-08-25 06:34:24,465] INFO Registered broker 2 at path /brokers/ids/2 with addresses: PLAINTEXT -> EndPoint(engine1,9092,PLAINTEXT) (kafka.utils.ZkUtils)
[2017-08-25 06:34:24,466] WARN No meta.properties file under dir /tmp/kafka-logs/2/meta.properties (kafka.server.BrokerMetadataCheckpoint)
[2017-08-25 06:34:24,492] INFO Kafka version : 0.10.1.1 (org.apache.kafka.common.utils.AppInfoParser)
[2017-08-25 06:34:24,492] INFO Kafka commitId : f10ef2720b03b247 (org.apache.kafka.common.utils.AppInfoParser)
[2017-08-25 06:34:24,492] INFO [Kafka Server 2], started (kafka.server.KafkaServer)
```
##### Test The Kafka Cluster
**Create Topics**
Let's create a simple topic with the script parameters as shown. 
```bash
[peter@kafkaclientmachine1 scripts]$ ./create_topic.sh 
Enter the zk host/port: localhost:2181
Enter the topic name: kafka-simple-topic-1
Enter the number of partitions: 1
Enter the replication factor: 1
Enter topic retention time (hrs): 1
Enter topic retention size (Mb): 25
Enter topic max message size (Kb): 256
/home/peter/vagrant/kafka-proxied/local/kafka/default/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic kafka-simple-topic-1 --config max.message.bytes=262144 --config retention.bytes=26214400 --config retention.ms=3600000
About to start Create Topics as shown, continue? (y/n): y
Created topic "kafka-simple-topic-1".

```

**Produce Messages**
Let's create some messages to put on the topic that we can identify later came from the local machine running the kafka cluster. Run the script as shown to start the kafka console producer and enter messages. Hit ```ctl-c``` to stop.
[peter@kafkaclientmachine1 scripts]$ ./start_kafka_console_producer.sh 
Enter a kafka broker server: localhost:9091
Enter the topic name: kafka-simple-topic-1
/home/peter/vagrant/kafka-proxied/local/kafka/default/bin/kafka-console-producer.sh --broker-list localhost:9091 --topic kafka-simple-topic-1
message-from-localhost-1
message-from-localhost-2          
message-from-localhost-3

**Consume Messages**
Now let's consume those messages to verify things are working okay. Once you run the script to parameteriz the kafka console consumer command for you, it should return the same three messages created previously. 
```bash
[peter@engine1 scripts]$ ./start_kafka_console_consumer.sh 
Enter the topic name: kafka-simple-topic-1
Read topic from beginning (all messages retained) (y/n): y
Use new kafka consumer: y
Enter the broker host:port : localhost:9091
/home/peter/vagrant/kafka-proxied/local/kafka/default/bin/kafka-console-consumer.sh --new-consumer --bootstrap-server localhost:9091 --topic kafka-simple-topic-1 --from-beginning --delete-consumer-offsets
message-from-localhost-1
message-from-localhost-2
message-from-localhost-3

```



#### Setup a Multi-node Kafka Cluster on Separate Machines Within The Same LAN
#### Setup a Multi-node Kafka Cluster on Separate Machines Within The Same LAN And Expose Through Public Internet









``` advertised.listener ``` address

2017-08-21 19:42:54,401] WARN [Controller-1-to-broker-1-send-thread], Controller 1's connection to broker cleverfishsoftware.com:19091 (id: 1 rack: null) was unsuccessful (kafka.controller.RequestSendThread)
java.io.IOException: Connection to cleverfishsoftware.com:19091 (id: 1 rack: null) failed
	at kafka.utils.NetworkClientBlockingOps$.awaitReady$1(NetworkClientBlockingOps.scala:83)
	at kafka.utils.NetworkClientBlockingOps$.blockingReady$extension(NetworkClientBlockingOps.scala:93)
	at kafka.controller.RequestSendThread.brokerReady(ControllerChannelManager.scala:230)
	at kafka.controller.RequestSendThread.liftedTree1$1(ControllerChannelManager.scala:182)
	at kafka.controller.RequestSendThread.doWork(ControllerChannelManager.scala:181)
- - -

## Notes:

- a proxy may be required if the port on the host machine (engine1, 2, 3) cannot be mapped directly to the same port 

## References:

**Note: **For more information on Kafka MirorMaker please refer to the documentation. You can get some of that here https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=27846330 and here https://docs.microsoft.com/en-us/azure/hdinsight/hdinsight-apache-Kafka-mirroring if you are interested in mirroring Kafka data up to azure 