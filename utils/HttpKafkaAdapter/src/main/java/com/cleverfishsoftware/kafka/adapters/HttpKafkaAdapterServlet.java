
/*
 */
package com.cleverfishsoftware.kafka.adapters;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Properties;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 *
 */
@WebServlet(
        name = "HttpKafkaAdapterServlet",
        urlPatterns = {"/HttpKafkaAdapterServlet"}
//        ,
//        initParams = {
//            @WebInitParam(name = "kafka.properties", value = "kafka-producer-0.10.2.1.properties"),
//            @WebInitParam(name = "kafka.topic", value = "kafka-simple-topic-1")
//        }
)
public class HttpKafkaAdapterServlet extends HttpServlet {

    private KafkaMessageSender kafkaMessageSender = new KafkaMessageSender();

    @Override
    public void init() throws ServletException {
        super.init();
        kafkaMessageSender = new KafkaMessageSender();
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        String requestBodyAsString = getRequestBodyAsString(request);
        kafkaMessageSender.send(requestBodyAsString);

        response.setStatus(HttpServletResponse.SC_ACCEPTED);
    }

    private String getRequestBodyAsString(HttpServletRequest request) throws IOException {
        StringBuilder stringBuilder = new StringBuilder();
        try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(request.getInputStream()))) {
            char[] charBuffer = new char[1024];
            int bytesRead;
            while ((bytesRead = bufferedReader.read(charBuffer)) > 0) {
                stringBuilder.append(charBuffer, 0, bytesRead);
            }
        }
        return stringBuilder.toString();
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "A Servlet that will take an HTTP Post and put the message body on a Kafka Topic";
    }// </editor-fold>

}
