package com.hospital.servlet;

import com.hospital.dao.AccountDAO;
import com.hospital.model.Account;
import com.hospital.util.PasswordHash;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/user/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private AccountDAO accountDAO = new AccountDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("account") == null) {
                out.print("{\"success\":false,\"message\":\"Vui lòng đăng nhập lại!\"}");
                return;
            }

            Account sessionAccount = (Account) session.getAttribute("account");

            if (!"patient".equalsIgnoreCase(sessionAccount.getRole())) {
                out.print("{\"success\":false,\"message\":\"Chỉ tài khoản bệnh nhân được đổi mật khẩu tại đây.\"}");
                return;
            }

            String currentPassword = req.getParameter("currentPassword");
            String newPassword = req.getParameter("newPassword");
            String lang = req.getParameter("lang");
            if (lang == null || lang.isEmpty()) {
                lang = "vi";
            }
            boolean isEn = "en".equals(lang);

            if (currentPassword == null || currentPassword.trim().isEmpty() ||
                newPassword == null || newPassword.trim().isEmpty()) {
                out.print(jsonMsg(false, isEn
                        ? "Please fill in all fields!"
                        : "Vui lòng nhập đầy đủ thông tin!"));
                return;
            }

            currentPassword = currentPassword.trim();
            newPassword = newPassword.trim();

            Account account = accountDAO.findById(sessionAccount.getAccountID());
            if (account == null) {
                out.print(jsonMsg(false, isEn ? "Account not found." : "Không tìm thấy tài khoản."));
                return;
            }

            if (!PasswordHash.verifyPassword(currentPassword, account.getPasswordAccount())) {
                out.print(jsonMsg(false, isEn
                        ? "Current password is incorrect!"
                        : "Mật khẩu hiện tại không đúng!"));
                return;
            }

            if (newPassword.length() < 6) {
                out.print(jsonMsg(false, isEn
                        ? "New password must be at least 6 characters!"
                        : "Mật khẩu mới phải có ít nhất 6 ký tự!"));
                return;
            }

            if (PasswordHash.verifyPassword(newPassword, account.getPasswordAccount())) {
                out.print(jsonMsg(false, isEn
                        ? "New password must be different from the current one!"
                        : "Mật khẩu mới phải khác mật khẩu hiện tại!"));
                return;
            }

            String hashedPassword = PasswordHash.hashSHA256(newPassword);
            boolean success = accountDAO.updatePassword(account.getAccountID(), hashedPassword);

            if (success) {
                account.setPasswordAccount(hashedPassword);
                session.setAttribute("account", account);
                out.print(jsonMsg(true, isEn
                        ? "Password changed successfully!"
                        : "Đổi mật khẩu thành công!"));
            } else {
                out.print(jsonMsg(false, isEn
                        ? "Failed to change password. Please try again."
                        : "Đổi mật khẩu thất bại! Thử lại sau."));
            }

        } catch (Exception e) {
            e.printStackTrace();
            out.print(jsonMsg(false, "System error: " + e.getMessage()));
        }
    }

    private String jsonMsg(boolean success, String message) {
        String safe = message == null ? "" : message.replace("\\", "\\\\").replace("\"", "\\\"");
        return "{\"success\":" + success + ",\"message\":\"" + safe + "\"}";
    }
}
