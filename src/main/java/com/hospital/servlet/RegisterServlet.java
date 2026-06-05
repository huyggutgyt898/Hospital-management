/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.servlet;

/**
 *
 * @author Admin
 */
import com.hospital.dao.AccountDAO;
import com.hospital.dao.PatientDAO;
import com.hospital.dao.DBConnection;
import com.hospital.model.Account;
import com.hospital.model.Patient;
import com.hospital.util.PasswordHash;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet{
        private AccountDAO accountDAO = new AccountDAO();
        private PatientDAO patientDAO = new PatientDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        // Hiển thị form đăng ký
        req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        System.out.println("DO POST RUNNING");
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");
        String fullname = req.getParameter("fullname");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        
        // Validation
        String error = validateInput(username, password, confirmPassword, fullname);
        
        if (error != null) {
            req.setAttribute("error", error);
            req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req, resp);
            return;
        }
        
        try {
            // Kiểm tra username đã tồn tại
            if (accountDAO.isUsernameExists(username)) {
                req.setAttribute("error", "Tên đăng nhập đã tồn tại!");
                req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req, resp);
                return;
            }
            
            // Tạo tài khoản mới với role = "patient"
            String hashedPassword = PasswordHash.hashSHA256(password);
            Account newAccount = new Account(username, hashedPassword, email, phone, fullname,  "patient");
            newAccount.setIsActive(true);
            newAccount.setCreateAt(null);  // Tự đăng ký nên không có người tạo

            try (Connection conn = DBConnection.getConnection()) {
                conn.setAutoCommit(false);
                int accountId = accountDAO.createAccount(conn, newAccount);
                if (accountId <= 0) {
                    conn.rollback();
                    throw new SQLException("Không tạo được tài khoản");
                }

                newAccount.setAccountID(accountId);
                Patient newPatient = new Patient(fullname, 0, null, null, null, null, accountId);
                newPatient.setHealthInsurance("Chưa");
                int patientId = patientDAO.createPatient(conn, newPatient);
                if (patientId <= 0) {
                    conn.rollback();
                    throw new SQLException("Không tạo được bản ghi patient");
                }

                conn.commit();
                req.getSession().setAttribute("successMsg", "Tạo tài khoản thành công! Vui lòng đăng nhập.");
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/jsp/auth/register.jsp").forward(req, resp);
        }
    }
    
    private String validateInput(String username, String password, String confirmPassword, String fullname) {
        if (username == null || username.trim().isEmpty()) {
            return "Vui lòng nhập tên đăng nhập!";
        }
        if (username.length() < 3 || username.length() > 50) {
            return "Tên đăng nhập phải từ 3-50 ký tự!";
        }
        if (password == null || password.trim().isEmpty()) {
            return "Vui lòng nhập mật khẩu!";
        }
        if (password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự!";
        }
        if (!password.equals(confirmPassword)) {
            return "Mật khẩu xác nhận không khớp!";
        }
        if (fullname == null || fullname.trim().isEmpty()) {
            return "Vui lòng nhập họ tên!";
        }
        return null;
    }
}
