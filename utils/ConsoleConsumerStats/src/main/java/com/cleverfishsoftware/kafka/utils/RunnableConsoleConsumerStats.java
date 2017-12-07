/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.errors.WakeupException;

/**
 *
 */
public class RunnableConsoleConsumerStats extends AbstractStatsConsumer implements Runnable {

    private final Properties props;
    private final KafkaConsumer<String, String> consumer;
    private final List<String> topics;
    private final String consumerGroup;
    private final String consumerId;
    private final long sleep;

    public RunnableConsoleConsumerStats(String consumerGroup, String consumerId, Properties props, List<String> topics, long sleep) {
        this.props = new Properties(props);
        this.topics = new ArrayList<>(topics.size());
        topics.stream().forEach((each) -> {
            this.topics.add(each);
        });
        this.consumerGroup = consumerGroup;
        this.consumerId = consumerId;
        this.consumer = new KafkaConsumer<>(props);
        this.sleep = sleep;
    }

    @Override
    public void run() {
        try {
            consumer.subscribe(topics);

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(1000);
                for (ConsumerRecord<String, String> record : records) {
                    Map<String, Object> data = new HashMap<>();
                    data.put("partition", record.partition());
                    data.put("offset", record.offset());
                    data.put("value", record.value());
                    System.out.println(this.consumerGroup + "." + this.consumerId + ": " + data);
                    if (sleep > 0) {
                        Thread.sleep(sleep);
                    }
                }
            }
        } catch (WakeupException | InterruptedException e) {
            // ignore
        } finally {
            consumer.close();
        }
    }

    public void shutdown() {
        consumer.wakeup();
    }
}
