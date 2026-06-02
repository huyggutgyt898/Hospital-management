package com.hospital.servlet;

import com.hospital.model.Account;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/patient/preferences")
public class PatientPreferencesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!ensurePatient(req, resp)) {
            return;
        }
        applyFromRequest(req, resp);
        redirectBack(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!ensurePatient(req, resp)) {
            return;
        }
        String theme = applyFromRequest(req, resp);
        String lang = (String) req.getSession().getAttribute("patientLang");

        String accept = req.getHeader("Accept");
        if (accept != null && accept.contains("application/json")) {
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            out.print("{\"success\":true,\"theme\":\"" + theme + "\",\"lang\":\"" + lang + "\"}");
            return;
        }
        redirectBack(req, resp);
    }

    private boolean ensurePatient(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/jsp/auth/login.jsp");
            return false;
        }
        Account account = (Account) session.getAttribute("account");
        if (account == null || !"patient".equalsIgnoreCase(account.getRole())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }

    private String applyFromRequest(HttpServletRequest req, HttpServletResponse resp) {
        HttpSession session = req.getSession();
        String themeParam = req.getParameter("theme");
        String langParam = req.getParameter("lang");

        String theme = (String) session.getAttribute("patientTheme");
        if (theme == null) {
            theme = "light";
        }
        String lang = (String) session.getAttribute("patientLang");
        if (lang == null) {
            lang = "vi";
        }

        if (themeParam != null && !themeParam.isEmpty()) {
            theme = "dark".equalsIgnoreCase(themeParam) ? "dark" : "light";
            addPrefCookie(req, resp, "theme", theme);
            session.setAttribute("patientTheme", theme);
        }

        if (langParam != null && !langParam.isEmpty()) {
            lang = "en".equalsIgnoreCase(langParam) ? "en" : "vi";
            addPrefCookie(req, resp, "language", lang);
            session.setAttribute("patientLang", lang);
        }

        return theme;
    }

    private void addPrefCookie(HttpServletRequest req, HttpServletResponse resp, String name, String value) {
        Cookie cookie = new Cookie(name, value);
        cookie.setMaxAge(365 * 24 * 60 * 60);
        String path = req.getContextPath();
        if (path == null || path.isEmpty()) {
            path = "/";
        }
        cookie.setPath(path);
        resp.addCookie(cookie);
    }

    private void redirectBack(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String redirect = sanitizeRedirect(req.getParameter("redirect"), req.getContextPath());
        resp.sendRedirect(redirect);
    }

    static String sanitizeRedirect(String redirect, String ctx) {
        if (ctx == null) {
            ctx = "";
        }
        String fallback = ctx + "/jsp/patient/settings.jsp";

        if (redirect == null || redirect.isEmpty()) {
            return fallback;
        }

        if (redirect.contains("://")) {
            try {
                java.net.URI uri = new java.net.URI(redirect);
                String path = uri.getPath();
                if (path == null || path.isEmpty()) {
                    return fallback;
                }
                if (!ctx.isEmpty() && !path.startsWith(ctx)) {
                    return fallback;
                }
                String query = uri.getQuery();
                return query != null && !query.isEmpty() ? path + "?" + query : path;
            } catch (Exception e) {
                return fallback;
            }
        }

        if (!ctx.isEmpty() && !redirect.startsWith(ctx)) {
            return fallback;
        }
        return redirect;
    }
}
