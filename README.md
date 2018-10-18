# Kafka-proxied

This project provides scripts and configuration details required to get a single or multi-node Kafka Cluster running and make it available to producers and consumers both to an internal and work and over a public DNS finally to configure using Kafka MirrorMaker to replicate topic data to a remote Kafka Cluster.

## Kafka Up and running
**Installation Pre-Requisites** 
At a minimum you can have a Kafka cluster up and running with a Java Jdk and the Kafka distribution. It is possible to test and configure multiple versions of Kafka to test version compatibility and simulate various installations. Please note that most of the scripts rely on `JAVA_HOME` and `KAFKA_HOME` environment variables being set. If you already have Java and Kafka installations then you can just add these environment variables to the shell at the session level or global. Google for the options on how to do this otherwise these installation scripts will modify or create a `~/.bash_profile` that would be loaded the next time you start a shell session or source that file. 

- - -
**Warning:** These scripts can and will permanently modify and even delete/replace Kafka configurations without much warning - so please consider creating a separate throw-away Kafka installation (with these scripts). Don't run the risk of corrupting or destroying an existing Kafka installation or at least create a backup of that existing installation.
**Note:** There is an `install/` directory in this project with pretty much everything you need to install the minimal and optional pre-requisites needed.

- Java JDK (7+)
	- under the `install/` directory you can install either the open-jdk (`install_openJdk8.sh`) or oracle-jdk (`install_oracleJdk8.sh`). You need to make some choices here about what you want to intall on your system and please be aware that the oracle download urls change and disappear frequently. Check github for updates and tweeks that may be required to get the Oracle direct download to work. There are brave souls out there that attempt to keep things working for us all (https://gist.github.com/P7h/9741922) 
- Kafka (multiple versions)
	- under the `install/` directory there is a script to download known/support versions of Kafka. Because Kafka configurations may change from release to release this project attempts to keep track of those configurations. Currently supported versions are under the `kafka/config` directory and this is what the download script and subsequent interactive Kafka scripts make copies of and use. Check this directory for currently supported versions.   

- - -

**Optional**
- Maven
	- along with the Kafka Commnand line utilities there are a number of custom Producer and Consumer load utilities written in Java available to this project that require a build. To build java executeables run `install/install_maven.sh` will install Maven 3. 
- Docker
	- while not necessary to run MirrorMaker, Docker is a great way to manage multiple MirrorMaker processes. The `install/install_docker.sh` script was written to install Docker and Docker-Compose on a Centos 7 distro. Check options for installation on other Linux distros.
- Network Utilities
	- netcat is very useful in checking ports and server availabilty but doesn't always come pre-installed - (`install/install_netcat.sh`)

## Step-by-Step

## All-in-One

## Testing Connections

## Testing producers

## Testing consumers

## Running Sustained Load

## Running Kafka MirrorMaker

## Securing Kafka
SSL
ACL

## Utilities

## Serving Kafka through a Public DNS
