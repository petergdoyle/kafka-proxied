/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

/**
 *
 */
public class RunnableConsumerCounterWriter implements Runnable {

    final AtomicInteger messageSize;
    final AtomicInteger messageCounter;

    final AtomicLong perpetualMessageCount = new AtomicLong(0L);
    final AtomicInteger perpetualAverageMessageSize = new AtomicInteger(0);
    final AtomicInteger perpetualLargestMessageSize = new AtomicInteger(0);
    final AtomicInteger perpetualSmallestMessageSize = new AtomicInteger(0);

    public RunnableConsumerCounterWriter(AtomicInteger messageSize, AtomicInteger messageCounter) {
        this.messageSize = messageSize;
        this.messageCounter = messageCounter;
    }

    @Override
    public void run() {
        int count;
        int size;
        synchronized (this) {
            count = messageCounter.getAndSet(0);
            size = messageSize.getAndSet(0);
        }
        int avgSize = size / count;
        System.out.println(RunnableConsumerCounterWriter.class.getName() + " messages received: " + count + " bytes received: " + size + " avg message size: " + avgSize);
    }

}