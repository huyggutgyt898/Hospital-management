<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- Giả sử bạn lưu đối tượng user trong Session sau khi đăng nhập --%>
<c:set var="user" value="${sessionScope.user}" />

<header class="navbar" style="position:relative;">
  <div class="navbar-left">
    <button id="sidebar-toggle-btn" class="navbar-icon-btn" title="Thu/mở sidebar">
      <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
      </svg>
    </button>

    <div class="navbar-clock">
      <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="10"/>
        <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6l4 2"/>
      </svg>
      <span id="navbar-clock">
          <%-- Sẽ được update bằng JS bên dưới --%>
          --/--/---- - --:--
      </span>
    </div>
  </div>

  <div class="navbar-right">
    <!-- Notification Bell -->
    <div style="position:relative;">
      <div class="navbar-icon-btn" id="notif-btn" title="Thông báo">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"/>
        </svg>
        <%-- Chỉ hiện badge nếu có thông báo chưa đọc (giả sử listNotif là một mảng) --%>
        <c:if test="${not empty listNotif}">
            <span class="badge-dot"></span>
        </c:if>
      </div>

      <!-- Notification Dropdown -->
      <div class="notif-dropdown" id="notif-dropdown">
        <div class="notif-header">
          <span>Thông báo</span>
          <button style="font-size:11px;color:var(--primary);background:none;cursor:pointer;" onclick="markAllRead()">Đánh dấu đã đọc</button>
        </div>
        
        <div id="notif-list-container">
            <%-- Phần này sau này bạn nên dùng AJAX để load từ DB --%>
            <div class="notif-item unread">
              <div class="notif-dot"></div>
              <div class="notif-text">
                <strong>Lịch hẹn mới</strong>
                Bệnh nhân Nguyễn Văn A đã đặt lịch hẹn.
              </div>
              <div class="notif-time">5 phút</div>
            </div>
        </div>
      </div>
    </div>

    <!-- User Profile Dropdown -->
    <div style="position:relative;">
      <div class="navbar-user" id="user-menu-btn">
        <%-- Lấy chữ cái đầu của tên làm Avatar nếu không có ảnh --%>
        <div class="avatar" style="background:var(--primary);color:#fff;font-weight:700;">
            ${not empty user ? user.name.substring(0,1).toUpperCase() : 'A'}
        </div>
        <div>
          <div class="user-name">${not empty user ? user.fullName : 'Admin Nam'}</div>
          <div class="user-role">${not empty user ? user.roleName : 'Quản trị viên'}</div>
        </div>
        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/>
        </svg>
      </div>

      <div class="dropdown-menu" id="user-dropdown">
        <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
          Hồ sơ cá nhân
        </a>
        <a class="dropdown-item" href="${pageContext.request.contextPath}/settings">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/><circle cx="12" cy="12" r="3"/></svg>
          Cài đặt
        </a>
        <div class="dropdown-divider"></div>
        <a class="dropdown-item danger" href="${pageContext.request.contextPath}/logout">
          <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
          Đăng xuất
        </a>
      </div>
    </div>
  </div>
</header>

<script>
// Logic đồng hồ thời gian thực
function updateClock() {
    const now = new Date();
    const d = String(now.getDate()).padStart(2, '0');
    const m = String(now.getMonth() + 1).padStart(2, '0');
    const y = now.getFullYear();
    const h = String(now.getHours()).padStart(2, '0');
    const min = String(now.getMinutes()).padStart(2, '0');
    document.getElementById('navbar-clock').textContent = d + '/' + m + '/' + y + ' - ' + h + ':' + min;
}
setInterval(updateClock, 1000);
updateClock();

// --- Giữ nguyên các Script Dropdown và Sidebar Toggle của bạn ---
// [Phần JS giữ nguyên như file HTML của bạn]
</script>