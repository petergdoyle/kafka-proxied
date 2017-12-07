/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.concurrent.atomic.AtomicInteger;

/**
 *
 */
public class AbstractStatsConsumer {

    protected volatile AtomicInteger byteCount = new AtomicInteger(0);
    protected volatile AtomicInteger messageCount = new AtomicInteger(0);

}
