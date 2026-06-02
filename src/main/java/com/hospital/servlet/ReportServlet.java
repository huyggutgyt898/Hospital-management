package com.hospital.servlet;

import com.hospital.dao.ReportDAO;
import com.hospital.model.Account;
import com.hospital.model.Report;
import java.io.IOException;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/admin/reports/*")
public class ReportServlet extends HttpServlet {
    
    private ReportDAO reportDAO = new ReportDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        
        if (account == null || !"admin".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/index.html");
            return;
        }
        
        if (pathInfo == null || "/list".equals(pathInfo)) {
            // Hiển thị danh sách báo cáo
            request.setAttribute("reports", reportDAO.getAllReports());
            request.getRequestDispatcher("/jsp/admin/reports.jsp").forward(request, response);
            
        } else if ("/create".equals(pathInfo)) {
            // Hiển thị form tạo báo cáo
            request.getRequestDispatcher("/jsp/admin/create_report.jsp").forward(request, response);
            
        } else if (pathInfo.startsWith("/edit/")) {
            // Hiển thị form sửa báo cáo
            int reportId = Integer.parseInt(pathInfo.substring(6));
            Report report = reportDAO.getReportById(reportId);
            request.setAttribute("report", report);
            request.getRequestDispatcher("/jsp/admin/edit_report.jsp").forward(request, response);
            
        } else if (pathInfo.startsWith("/delete/")) {
            // Xóa báo cáo
            int reportId = Integer.parseInt(pathInfo.substring(8));
            reportDAO.deleteReport(reportId);
            response.sendRedirect(request.getContextPath() + "/admin/reports/list");
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        
        if (pathInfo == null || "/create".equals(pathInfo)) {
            // Tạo báo cáo mới
            String reportType = request.getParameter("reportType");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            Date periodStart = Date.valueOf(request.getParameter("periodStart"));
            Date periodEnd = Date.valueOf(request.getParameter("periodEnd"));
            Time createdAt = Time.valueOf(LocalTime.now());
            String createdBy = account.getFullname();
            int accountId = account.getAccountID();
            
            Report report = new Report();
            report.setReportType(reportType);
            report.setTitle(title);
            report.setContent(content);
            report.setPeriodStart(periodStart);
            report.setPeriodEnd(periodEnd);
            report.setCreatedAt(createdAt);
            report.setCreatedBy(createdBy);
            report.setAccountId(accountId);
            
            if (reportDAO.addReport(report)) {
                request.setAttribute("success", "Tạo báo cáo thành công!");
            } else {
                request.setAttribute("error", "Tạo báo cáo thất bại!");
            }
            
            request.setAttribute("reports", reportDAO.getAllReports());
            request.getRequestDispatcher("/jsp/admin/reports.jsp").forward(request, response);
            
        } else if ("/update".equals(pathInfo)) {
            // Cập nhật báo cáo
            int reportId = Integer.parseInt(request.getParameter("reportId"));
            String reportType = request.getParameter("reportType");
            String title = request.getParameter("title");
            String content = request.getParameter("content");
            Date periodStart = Date.valueOf(request.getParameter("periodStart"));
            Date periodEnd = Date.valueOf(request.getParameter("periodEnd"));
            
            Report report = reportDAO.getReportById(reportId);
            report.setReportType(reportType);
            report.setTitle(title);
            report.setContent(content);
            report.setPeriodStart(periodStart);
            report.setPeriodEnd(periodEnd);
            
            reportDAO.updateReport(report);
            response.sendRedirect(request.getContextPath() + "/admin/reports/list");
        }
    }
}