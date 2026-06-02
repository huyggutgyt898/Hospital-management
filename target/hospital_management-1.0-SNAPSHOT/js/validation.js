// webapp/js/validation.js
function validateRegisterForm() {
    var username = document.getElementById('username').value;
    var password = document.getElementById('password').value;
    var confirmPassword = document.getElementById('confirmPassword').value;
    var fullname = document.getElementById('fullname').value;
    
    // Kiểm tra username
    var usernameRegex = /^[a-zA-Z0-9_]{3,50}$/;
    if (!usernameRegex.test(username)) {
        alert('Tên đăng nhập không hợp lệ! Chỉ gồm chữ cái, số, gạch dưới, độ dài 3-50 ký tự.');
        return false;
    }
    
    // Kiểm tra password
    if (password.length < 6) {
        alert('Mật khẩu phải có ít nhất 6 ký tự!');
        return false;
    }
    
    // Kiểm tra xác nhận mật khẩu
    if (password !== confirmPassword) {
        alert('Xác nhận mật khẩu không khớp!');
        return false;
    }
    
    // Kiểm tra họ tên
    if (fullname.trim() === '') {
        alert('Vui lòng nhập họ tên!');
        return false;
    }
    
    return true;
}