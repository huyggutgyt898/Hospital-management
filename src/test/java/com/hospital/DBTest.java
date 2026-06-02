package com.hospital;

import com.hospital.dao.DBConnection;
import java.sql.*;

public class DBTest {
    public static void main(String[] args) {
        System.out.println("=== START DB TEST ===");
        try (Connection conn = DBConnection.getConnection()) {
            System.out.println("Connection successful!");
            
            // Show all tables
            System.out.println("--- Tables in hopital_hms: ---");
            DatabaseMetaData meta = conn.getMetaData();
            try (ResultSet rs = meta.getTables("hopital_hms", null, "%", new String[] { "TABLE" })) {
                while (rs.next()) {
                    System.out.println(rs.getString("TABLE_NAME"));
                }
            }
            
            // Query select count from report or reports
            System.out.println("--- Querying report table: ---");
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM report")) {
                if (rs.next()) {
                    System.out.println("Count in 'report': " + rs.getInt(1));
                }
            } catch (SQLException e) {
                System.out.println("Error querying 'report': " + e.getMessage());
            }

            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM reports")) {
                if (rs.next()) {
                    System.out.println("Count in 'reports': " + rs.getInt(1));
                }
            } catch (SQLException e) {
                System.out.println("Error querying 'reports': " + e.getMessage());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("=== END DB TEST ===");
    }
}
