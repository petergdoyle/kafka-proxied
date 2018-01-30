/*

 */
package com.cleverfishsoftware.kafka.adapters.spring;

import com.cleverfishsoftware.kafka.adapters.HttpKafkaAdapterServlet;
import java.util.Arrays;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.embedded.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;

/**
 */
@SpringBootApplication
public class SpringBootMain {

    public static void main(String[] args) throws Exception {
        SpringApplication.run(SpringBootMain.class, args);
    }

    @Bean
    ServletRegistrationBean SyncServletRegistration() {
        ServletRegistrationBean srb = new ServletRegistrationBean();
        srb.setServlet(new HttpKafkaAdapterServlet());
        srb.setUrlMappings(Arrays.asList("/HttpKafkaAdapterServlet/*"));
        return srb;
    }
}
