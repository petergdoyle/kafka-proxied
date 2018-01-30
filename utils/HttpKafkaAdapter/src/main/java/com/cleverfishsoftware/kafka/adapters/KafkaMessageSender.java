/*
 */
package com.cleverfishsoftware.kafka.adapters;

import java.util.Properties;
import org.apache.kafka.clients.producer.Callback;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;

/**
 * The KafkaProducer is thread safe and sharing a single producer instance
 * across threads will generally be faster than having multiple instances.
 */
public class KafkaMessageSender {

    private final Properties properties;
    private final String topic;
    private final KafkaProducer<String, String> producer;

    public KafkaMessageSender(final Properties properties, final String topic) {
        this.properties = properties;
        this.topic = topic;
        this.producer = new KafkaProducer<>(properties);
    }

    public void send(final String msg) {
        ProducerRecord<String, String> producerRecord = new ProducerRecord<>(topic, msg);
        producer.send(producerRecord, (RecordMetadata metadata, Exception ex) -> {
            if (ex != null) {
                logError(metadata, ex);
            }
            logSuccess(metadata);
        });
    }

    private void logSuccess(RecordMetadata metadata) {
        System.out.println("[INFO] The offset of the record we just sent is: " + metadata.offset());
    }

    public Properties getProperties() {
        return properties;
    }

    public String getTopic() {
        return topic;
    }

    private void logError(RecordMetadata metadata, Exception e) {
        System.out.println("[ERROR] The offset of the record we just failed on is: " + metadata.offset());
    }

}
