/*
 */
package com.cleverfishsoftware.kafka.utils;

/**
 *
 * @author peter
 */
public class RunnableKafkaVolumetricsInfluxDbWriter {

    InfluxDB influxDB = InfluxDBFactory.connect("http://172.17.0.2:8086", "root", "root");
    String dbName = "aTimeSeries";

    influxDB.createDatabase (dbName);
    String rpName = "aRetentionPolicy";

    influxDB.createRetentionPolicy (rpName, dbName, "30d", "30m", 2, true);
}
