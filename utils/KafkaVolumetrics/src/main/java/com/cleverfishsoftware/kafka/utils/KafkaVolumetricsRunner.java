/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import static java.util.concurrent.TimeUnit.SECONDS;
import java.util.concurrent.atomic.AtomicInteger;

/**
 *
 */
public class KafkaVolumetricsRunner {

    public static void main(String[] args) {

        final String bootstrapServers = args[0];
        final String consumerGroup = args[1];
        final String consumerId = args[2];
        final List<String> topics = Arrays.asList(args[3].split(","));
        final long sleep = Long.parseLong(args[4]);
        final int numConsumers = Integer.parseInt(args[5]);
        final boolean verbose = Boolean.parseBoolean(args[6]);
        final int delayInSeconds = Integer.getInteger(args[7]);

        final boolean sslTrue = Boolean.parseBoolean(args[8]);
        String keystoreFileName = null;
        String keystorePassword = null;
        Properties kafkaProperties = new Properties();
        if (sslTrue) {
            try {
                keystoreFileName = args[9];
                keystorePassword = args[10];
                kafkaProperties.put("security.protocol", "SSL");
                kafkaProperties.put("ssl.truststore.location", keystoreFileName);
                kafkaProperties.put("ssl.truststore.password", keystorePassword);
            } catch (ArrayIndexOutOfBoundsException ex) {
                System.out.println("Must supply the kestore and the password if ssl is required. Change ssl flag or provide the filename of the keystor and the password.");
                System.exit(-1);
            }
        }

        kafkaProperties.put("bootstrap.servers", bootstrapServers);
        kafkaProperties.put("group.id", consumerGroup);
        kafkaProperties.put("enable.auto.commit", "true");
        kafkaProperties.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        kafkaProperties.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        kafkaProperties.put("session.timeout.ms", "10000");
        kafkaProperties.put("fetch.min.bytes", "50000");
        kafkaProperties.put("receive.buffer.bytes", "262144");
        kafkaProperties.put("max.partition.fetch.bytes", "2097152");

        final AtomicInteger byteCounter = new AtomicInteger(0);
        final AtomicInteger messageCounter = new AtomicInteger(0);

        final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
        RunnableConsumerCounterConsoleWriter runnableConsoleConsumerWriter = new RunnableConsumerCounterConsoleWriter(byteCounter, messageCounter);
        final int initialDelay=delayInSeconds; // don't report until end of first interval 
        final ScheduledFuture<?> handle = scheduler.scheduleWithFixedDelay(runnableConsoleConsumerWriter, initialDelay, delayInSeconds, SECONDS);
//        scheduler.schedule(() -> { // add a limit to run the scheduled task, in this example for one hour
//            handle.cancel(true);
//        }, 60 * 60, SECONDS);

        final ExecutorService executor = Executors.newFixedThreadPool(numConsumers);
        final List<RunnableConsumerCounter> consumers = new ArrayList<>();
        for (int i = 0; i < numConsumers; i++) {
            RunnableConsumerCounter consumer = new RunnableConsumerCounter(consumerGroup, consumerId, kafkaProperties, topics, sleep, byteCounter, messageCounter, verbose);
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
