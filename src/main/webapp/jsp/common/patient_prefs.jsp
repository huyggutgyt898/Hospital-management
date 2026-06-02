<%@ page import="javax.servlet.http.Cookie" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%
    HttpSession patientSession = request.getSession(false);
    String patientTheme = null;
    String patientLang = null;

    if (patientSession != null) {
        Object themeAttr = patientSession.getAttribute("patientTheme");
        Object langAttr = patientSession.getAttribute("patientLang");
        if (themeAttr instanceof String) {
            patientTheme = (String) themeAttr;
        }
        if (langAttr instanceof String) {
            patientLang = (String) langAttr;
        }
    }

    Cookie[] prefCookies = request.getCookies();
    if (prefCookies != null) {
        for (Cookie c : prefCookies) {
            if (patientTheme == null && "theme".equals(c.getName())
                    && c.getValue() != null && !c.getValue().isEmpty()) {
                patientTheme = c.getValue();
            }
            if (patientLang == null && "language".equals(c.getName())
                    && c.getValue() != null && !c.getValue().isEmpty()) {
                patientLang = c.getValue();
            }
        }
    }

    if (patientTheme == null) {
        patientTheme = "light";
    }
    if (patientLang == null) {
        patientLang = "vi";
    }
    if (!"dark".equals(patientTheme)) {
        patientTheme = "light";
    }
    if (!"en".equals(patientLang)) {
        patientLang = "vi";
    }

    if (patientSession != null) {
        patientSession.setAttribute("patientTheme", patientTheme);
        patientSession.setAttribute("patientLang", patientLang);
    }

    boolean patientIsDark = "dark".equals(patientTheme);
    boolean patientIsEn = "en".equals(patientLang);
    String patientCtx = request.getContextPath();
%>
<%!
    public String pt(boolean isEn, String vi, String en) {
        return isEn ? en : vi;
    }
%>
