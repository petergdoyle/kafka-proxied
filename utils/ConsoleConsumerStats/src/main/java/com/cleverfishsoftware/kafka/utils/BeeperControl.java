/*
 */
package com.cleverfishsoftware.kafka.utils;

import java.util.Date;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import static java.util.concurrent.TimeUnit.*;

/**
 *
 */
public class BeeperControl {

    private final ScheduledExecutorService scheduler
            = Executors.newScheduledThreadPool(1);

    public void beepForAnHour() {
        final Runnable beeper = () -> {
            System.out.println("beep: " + new Date().toString());
        };
        final ScheduledFuture<?> handle = scheduler.scheduleAtFixedRate(beeper, 10, 10, SECONDS);
        scheduler.schedule(() -> {
            handle.cancel(true);
        }, 60 * 60, SECONDS);
    }

    public static void main(String[] args) {
        BeeperControl beeperControl = new BeeperControl();
        beeperControl.beepForAnHour();
    }
}
