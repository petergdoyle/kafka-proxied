package com.cleverfishsoftware.kafkaproxied.kafkaconsumer;

import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

public class RunnableKafkaConsumer implements Runnable {

    private final Properties props;
    private final KafkaConsumer<String, String> consumer;
    private final List<String> topics;
    private final String consumerGroup;
    private final String consumerId;
    final boolean verbose;

    RunnableKafkaConsumer(String consumerGroup, String consumerId, Properties props, List<String> topics, boolean verbose) {
        this.props = new Properties(props);
        this.topics = new ArrayList<>(topics.size());
        topics.stream().forEach((each) -> {
            this.topics.add(each);
        });
        this.consumerGroup = consumerGroup;
        this.consumerId = consumerId;
        this.consumer = new KafkaConsumer<>(props);
        this.verbose = verbose;
    }

    @Override
    public void run() {
        consumer.subscribe(topics);
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(1000);
            for (ConsumerRecord<String, String> record : records) {
                String value = record.value();
                if (verbose) {
                    System.out.println(RunnableKafkaConsumer.class.getName() + " message received: " + value);
                }
            }
        }
    }

    public void shutdown() {
        consumer.wakeup();
    }
}
