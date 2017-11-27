/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 *
 */
public class ConsoleConsumerStatsRunner {
    
    public static void main(String[] args) {

        String bootstrapServers = args[0];
        String consumerGroup = args[1];
        String consumerId = args[2];
        List<String> topics = Arrays.asList(args[3].split(","));
        long sleep = Long.parseLong(args[4]);

        Properties kafkaProperties = new Properties();
        kafkaProperties.put("bootstrap.servers", bootstrapServers);
        kafkaProperties.put("group.id", consumerGroup);
        kafkaProperties.put("enable.auto.commit", "true");
        kafkaProperties.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        kafkaProperties.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        kafkaProperties.put("session.timeout.ms", "10000");
        kafkaProperties.put("fetch.min.bytes", "50000");
        kafkaProperties.put("receive.buffer.bytes", "262144");
        kafkaProperties.put("max.partition.fetch.bytes", "2097152");

        int numConsumers = 1;
        ExecutorService executor = Executors.newFixedThreadPool(numConsumers);

        final List<RunnableConsoleConsumerStats> consumers = new ArrayList<>();
        for (int i = 0; i < numConsumers; i++) {
            RunnableConsoleConsumerStats consumer = new RunnableConsoleConsumerStats(consumerGroup, consumerId, kafkaProperties, topics, sleep);
            consumers.add(consumer);
            executor.submit(consumer);
        }

        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                consumers.stream().forEach((consumer) -> {
                    consumer.shutdown();
                });
                executor.shutdown();
                try {
                    executor.awaitTermination(5000, TimeUnit.MILLISECONDS);
                } catch (InterruptedException e) {
                }
            }
        });

    }

}
