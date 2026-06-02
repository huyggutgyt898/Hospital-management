/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.servlet;

/**
 *
 * @author ICT
 */
import com.hospital.model.Doctor;
import com.hospital.dao.DoctorDAO;
import com.hospital.dao.AccountDAO;
import java.util.List;
import com.hospital.dao.AppointmentDAO;
import com.hospital.model.Account;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/dashboard_admin")
public class DashboardServletadmin extends HttpServlet{
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            AccountDAO accountDAO = new AccountDAO();
            AppointmentDAO appointmentDAO = new AppointmentDAO();
            
            // Lấy số liệu từ AccountDAO
            int totalUsers = accountDAO.getTotalUsers();
            int totalDoctors = accountDAO.getTotalDoctors();
            int totalPatients = accountDAO.getTotalPatients();
            
            // Lấy số liệu từ AppointmentDAO
            int totalAppointments = appointmentDAO.getTotalAppointments();
            
            // Gửi dữ liệu sang JSP
            request.setAttribute("totalUsers", totalUsers);
            request.setAttribute("totalDoctors", totalDoctors);
            request.setAttribute("totalPatients", totalPatients);
            request.setAttribute("totalAppointments", totalAppointments);
            
            DoctorDAO doctorDAO = new DoctorDAO();
            List<Doctor> recentDoctors = doctorDAO.getRecentDoctors(10);
            request.setAttribute("recentDoctors", recentDoctors);
            
            // Chuyển tiếp sang trang dashboard JSP
            request.getRequestDispatcher("/admin_dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(500, "Lỗi khi tải dashboard: " + e.getMessage());
        }
    }
}
