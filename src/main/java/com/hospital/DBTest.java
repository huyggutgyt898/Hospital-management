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

            // Print columns of report table
            System.out.println("--- Columns in 'report' table: ---");
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT * FROM report LIMIT 1")) {
                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                for (int i = 1; i <= columnCount; i++) {
                    System.out.println("Column " + i + ": " + rsmd.getColumnName(i) + " (" + rsmd.getColumnTypeName(i) + ")");
                }
            } catch (SQLException e) {
                System.out.println("Error reading columns of 'report': " + e.getMessage());
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        System.out.println("=== END DB TEST ===");
    }
}
