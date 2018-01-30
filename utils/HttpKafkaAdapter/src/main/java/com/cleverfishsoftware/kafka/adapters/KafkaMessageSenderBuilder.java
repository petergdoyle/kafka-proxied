/*
 */
package com.cleverfishsoftware.kafka.adapters;

import java.util.Properties;

public class KafkaMessageSenderBuilder {

    private Properties properties;
    private String topic;

    public KafkaMessageSenderBuilder() {
    }

    public KafkaMessageSenderBuilder setProperties(Properties properties) {
        this.properties = properties;
        return this;
    }

    public KafkaMessageSenderBuilder setTopic(String topic) {
        this.topic = topic;
        return this;
    }

    public KafkaMessageSender createKafkaMessageSender() {
        if (this.properties == null || this.topic == null) {
            throw new IllegalStateException("Cannot instanstantiate KafkaMessageSender without required properties set.");
        }
        return new KafkaMessageSender(properties, topic);
    }

}
