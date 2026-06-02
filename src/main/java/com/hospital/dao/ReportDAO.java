package com.hospital.dao;

import com.hospital.model.Report;
import com.hospital.dao.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {
    
    // Thêm báo cáo mới
    public boolean addReport(Report report) {
        String sql = "INSERT INTO report (report_type, title, content, period_start, period_end, created_at, created_by, account_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, report.getReportType());
            ps.setString(2, report.getTitle());
            ps.setString(3, report.getContent());
            ps.setDate(4, report.getPeriodStart());
            ps.setDate(5, report.getPeriodEnd());
            ps.setTime(6, report.getCreatedAt());
            ps.setString(7, report.getCreatedBy());
            ps.setInt(8, report.getAccountId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Lấy tất cả báo cáo
    public List<Report> getAllReports() {
        List<Report> reports = new ArrayList<>();
        String sql = "SELECT * FROM report ORDER BY created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery(sql)) {
            
            while (rs.next()) {
                Report report = new Report();
                report.setReportId(rs.getInt("report_id"));
                report.setReportType(rs.getString("report_type"));
                report.setTitle(rs.getString("title"));
                report.setContent(rs.getString("content"));
                report.setPeriodStart(rs.getDate("period_start"));
                report.setPeriodEnd(rs.getDate("period_end"));
                report.setCreatedAt(rs.getTime("created_at"));
                report.setCreatedBy(rs.getString("created_by"));
                report.setAccountId(rs.getInt("account_id"));
                reports.add(report);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return reports;
    }
    
    // Lấy báo cáo theo ID
    public Report getReportById(int reportId) {
        String sql = "SELECT * FROM report WHERE report_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reportId);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Report report = new Report();
                report.setReportId(rs.getInt("report_id"));
                report.setReportType(rs.getString("report_type"));
                report.setTitle(rs.getString("title"));
                report.setContent(rs.getString("content"));
                report.setPeriodStart(rs.getDate("period_start"));
                report.setPeriodEnd(rs.getDate("period_end"));
                report.setCreatedAt(rs.getTime("created_at"));
                report.setCreatedBy(rs.getString("created_by"));
                report.setAccountId(rs.getInt("account_id"));
                return report;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // Cập nhật báo cáo
    public boolean updateReport(Report report) {
        String sql = "UPDATE report SET report_type = ?, title = ?, content = ?, period_start = ?, period_end = ? WHERE report_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, report.getReportType());
            ps.setString(2, report.getTitle());
            ps.setString(3, report.getContent());
            ps.setDate(4, report.getPeriodStart());
            ps.setDate(5, report.getPeriodEnd());
            ps.setInt(6, report.getReportId());
            
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    // Xóa báo cáo
    public boolean deleteReport(int reportId) {
        String sql = "DELETE FROM report WHERE report_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, reportId);
            return ps.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}