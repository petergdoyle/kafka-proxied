package com.cleverfishsoftware.kafkaproxied.kafkaconsumer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class KafkaConsumerRunner {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        final String bootstrapServers = args[0];
        final String consumerGroup = args[1];
        final String consumerId = args[2];
        final List<String> topics = Arrays.asList(args[3].split(","));
        final int numConsumers = Integer.parseInt(args[4]);
        final boolean verbose = Boolean.parseBoolean(args[5]);
        final boolean readFromBeginning = Boolean.parseBoolean(args[6]);

        final boolean sslTrue = Boolean.parseBoolean(args[7]);
        Properties kafkaProperties = new Properties();
        if (sslTrue) {
            try {
                String keystoreFileName = args[8];
                String keystorePassword = args[9];
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
        kafkaProperties.put("client.id", consumerId);
        if (readFromBeginning) {
            kafkaProperties.put("auto.offset.reset", "smallest");
        }
        kafkaProperties.put("enable.auto.commit", "true");
        kafkaProperties.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        kafkaProperties.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer");
        kafkaProperties.put("session.timeout.ms", "10000");
        kafkaProperties.put("fetch.min.bytes", "50000");
        kafkaProperties.put("receive.buffer.bytes", "262144");
        kafkaProperties.put("max.partition.fetch.bytes", "2097152");

        final ExecutorService executor = Executors.newFixedThreadPool(numConsumers);
        final List<RunnableKafkaConsumer> consumers = new ArrayList<>();
        for (int i = 0; i < numConsumers; i++) {
            RunnableKafkaConsumer consumer = new RunnableKafkaConsumer(consumerGroup, consumerId, kafkaProperties, topics, verbose);
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
