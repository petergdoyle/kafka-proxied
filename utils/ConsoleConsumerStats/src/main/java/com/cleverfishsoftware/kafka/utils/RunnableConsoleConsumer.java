/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.atomic.AtomicInteger;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.errors.WakeupException;

/**
 *
 */
public class RunnableConsoleConsumer implements Runnable {

    private final Properties props;
    private final KafkaConsumer<String, String> consumer;
    private final List<String> topics;
    private final String consumerGroup;
    private final String consumerId;
    private final long sleep;
    final AtomicInteger byteCounter;
    final AtomicInteger messageCounter;

    public RunnableConsoleConsumer(final String consumerGroup, final String consumerId, final Properties props, final List<String> topics, final long sleep, final AtomicInteger byteCounter, final AtomicInteger messageCounter) {
        this.props = new Properties(props);
        this.topics = new ArrayList<>(topics.size());
        topics.stream().forEach((each) -> {
            this.topics.add(each);
        });
        this.consumerGroup = consumerGroup;
        this.consumerId = consumerId;
        this.consumer = new KafkaConsumer<>(props);
        this.sleep = sleep;
        this.byteCounter = byteCounter;
        this.messageCounter = messageCounter;
    }

    @Override
    public void run() {
        try {
            consumer.subscribe(topics);
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(1000);
                for (ConsumerRecord<String, String> record : records) {
                    final int partition = record.partition();
                    final long offset = record.offset();
                    final String value = record.value();
                    final int messageCount = messageCounter.incrementAndGet();
                    final int byteCount = byteCounter.addAndGet(value.length());
                    Map<String, Object> data = new HashMap<>(3);
                    data.put("partition", partition);
                    data.put("offset", offset);
                    data.put("value", value);
                    data.put("messageCount", messageCount);
                    data.put("byteCount", byteCount);
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
