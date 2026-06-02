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
import com.hospital.model.Account;
import com.hospital.dao.PatientDAO;
import com.hospital.util.PasswordHash;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONObject;
import java.io.PrintWriter;
import static java.lang.System.out;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet{
    private AccountDAO accountDAO = new AccountDAO();
    private PatientDAO patientDAO = new PatientDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        // Kiểm tra đã login chưa
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("account") != null) {
            Account account = (Account) session.getAttribute("account");
            redirectToDashboard(req, resp, account);
            return;
        }
        // Chuyển đến trang login.jsp
        req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        
        // Validation
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!");
            req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, resp);
            return;
        }
        
        try {
            Account account = accountDAO.findByUsername(username);
            
            // Kiểm tra tài khoản tồn tại
            if (account == null) {
                req.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, resp);
                return;
            }
            
            // Kiểm tra tài khoản có bị khóa không
            if (!account.isIsActive()) {
                req.setAttribute("error", "Tài khoản đã bị khóa! Vui lòng liên hệ admin.");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, resp);
                return;
            }
            
            // Kiểm tra mật khẩu
            if (!PasswordHash.verifyPassword(password, account.getPasswordAccount())) {
                req.setAttribute("error", "Sai tên đăng nhập hoặc mật khẩu!");
                req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, resp);
                return;
            }
            
            // Đăng nhập thành công
            HttpSession session = req.getSession();
            session.setAttribute("account", account);
            session.setAttribute("accountId", account.getAccountID());
            session.setAttribute("username", account.getUsername());
            session.setAttribute("fullname", account.getFullname());
            session.setAttribute("role", account.getRole());
            
            if ("patient".equalsIgnoreCase(account.getRole())) {
                int patientId = patientDAO.getPatientIdByAccountId(account.getAccountID());

                if (patientId > 0) {
                    session.setAttribute("patientId", patientId);
                }
                syncPatientPreferences(req, session);
            }
            
            // Chuyển hướng theo role
            redirectToDashboard(req, resp, account);
            
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher("/jsp/auth/login.jsp").forward(req, resp);
        }
        
        Object pathInfo = null;
        // ---- POST /user/change-password - Đổi mật khẩu ----
        if ("/change-password".equals(pathInfo)) {
            try {
                HttpSession session = req.getSession(false);
                if (session == null || session.getAttribute("account") == null) {
                    out.print("{\"success\":false,\"message\":\"Vui lòng đăng nhập lại!\"}");
                    return;
                }

                Account account = (Account) session.getAttribute("account");
                String currentPassword = req.getParameter("currentPassword");
                String newPassword = req.getParameter("newPassword");

                // Kiểm tra mật khẩu hiện tại
                if (!PasswordHash.verifyPassword(currentPassword, account.getPasswordAccount())) {
                    out.print("{\"success\":false,\"message\":\"Mật khẩu hiện tại không đúng!\"}");
                    return;
                }

                // Kiểm tra mật khẩu mới
                if (newPassword.length() < 6) {
                    out.print("{\"success\":false,\"message\":\"Mật khẩu mới phải có ít nhất 6 ký tự!\"}");
                    return;
                }

                // Cập nhật mật khẩu
                String hashedPassword = PasswordHash.hashSHA256(newPassword);
                boolean success = accountDAO.updatePassword(account.getAccountID(), hashedPassword);

                if (success) {
                    out.print("{\"success\":true,\"message\":\"Đổi mật khẩu thành công!\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Đổi mật khẩu thất bại!\"}");
                }
            } catch (Exception e) {
                out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        }
    }
    
    private void syncPatientPreferences(HttpServletRequest req, HttpSession session) {
        String theme = "light";
        String lang = "vi";
        Cookie[] cookies = req.getCookies();
        if (cookies != null) {
            for (Cookie c : cookies) {
                if ("theme".equals(c.getName()) && c.getValue() != null && !c.getValue().isEmpty()) {
                    theme = c.getValue();
                }
                if ("language".equals(c.getName()) && c.getValue() != null && !c.getValue().isEmpty()) {
                    lang = c.getValue();
                }
            }
        }
        session.setAttribute("patientTheme", "dark".equalsIgnoreCase(theme) ? "dark" : "light");
        session.setAttribute("patientLang", "en".equalsIgnoreCase(lang) ? "en" : "vi");
    }

    private void redirectToDashboard(HttpServletRequest req, HttpServletResponse resp, Account account) throws IOException {
        String role = account.getRole();

        // Debug: in ra role để kiểm tra
        System.out.println("=== REDIRECT DEBUG ===");
        System.out.println("Role from account: '" + role + "'");

        // Dùng equalsIgnoreCase để không phân biệt hoa/thường
        if ("admin".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard_admin");
        } else if ("doctor".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/jsp/dashboard/doctor_dashboard.jsp");
        } else if ("patient".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        } else {
            // Role lạ → nên báo lỗi thay vì im lặng redirect
            req.getSession().invalidate();
            resp.sendRedirect(req.getContextPath() + "/login?error=invalid_role");
        }
    }
}
