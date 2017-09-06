FROM centos

RUN yum install -y java-1.8.0-openjdk*

RUN mkdir -pv /usr/kafka \
&& curl -O http://www-us.apache.org/dist/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz \
&& tar -xvf kafka_2.11-0.9.0.1.tgz -C /usr/kafka \
&& rm -f kafka_2.11-0.9.0.1.tgz \
&& ln -s /usr/kafka/kafka_2.11-0.9.0.1 /usr/kafka/default

WORKDIR /usr/kafka/default
