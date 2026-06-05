/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.dao;

/**
 *
 * @author Admin
 */
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String MYSQL_HOST = envOrDefault("MYSQL_HOST", "localhost");
    private static final String MYSQL_PORT = envOrDefault("MYSQL_PORT", "3306");
    private static final String MYSQL_DB = envOrDefault("MYSQL_DB", "hospital_hms");
    private static final String URL = envOrDefault("MYSQL_URL",
            "jdbc:mysql://" + MYSQL_HOST + ":" + MYSQL_PORT + "/" + MYSQL_DB +
            "?useUnicode=true" +
            "&characterEncoding=UTF-8" +
            "&serverTimezone=Asia/Ho_Chi_Minh");
    private static final String USER = envOrDefault("MYSQL_USER", "root");
    private static final String PASSWORD = envOrDefault("MYSQL_PASSWORD", "1234");
    
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e){
            e.printStackTrace();
        }
    }
    
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
    
    private static String envOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value != null && !value.isEmpty() ? value : defaultValue;
    }
    
    public static void closeConnection(Connection conn) {
        if(conn != null){
            try{
                conn.close();
            }catch(SQLException e){
                e.printStackTrace();
            }
        }
    } 
}
