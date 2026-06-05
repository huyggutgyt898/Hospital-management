# Hospital-management

## Mô tả ngắn
Dự án là web application Java Servlet/JSP với packaging `war` và MySQL.

## Chuẩn bị để đưa lên GitHub
1. Mở terminal tại thư mục dự án.
2. Khởi tạo git nếu chưa có:
   ```bash
git init
git add .
git commit -m "Initial commit"
``` 
3. Tạo repo trên GitHub, rồi liên kết remote:
   ```bash
git branch -M main
git remote add origin https://github.com/<username>/<repo>.git
git push -u origin main
```

## Chuẩn bị deploy
Dự án đã có:
- `Dockerfile` để chạy với Tomcat 9 và Java 17
- `.gitignore` + `.dockerignore`
- `src/main/java/com/hospital/dao/DBConnection.java` đã hỗ trợ biến môi trường database

## Cấu hình database
Ứng dụng đọc cấu hình MySQL từ biến môi trường:
- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_DB`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- hoặc `MYSQL_URL` để dùng nguyên dòng JDBC URL

Ví dụ:
```bash
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DB=hospital_hms
MYSQL_USER=root
MYSQL_PASSWORD=1234
```

## Deploy miễn phí dễ setup
### Gợi ý nhanh: Render hoặc Railway
1. Đăng ký tài khoản GitHub.
2. Tạo repo GitHub và push code.
3. Đăng ký tài khoản Render.com hoặc Railway.app.
4. Kết nối repo GitHub vào Render/Railway.
5. Chọn deploy dạng Docker / web service.
6. Cấu hình biến môi trường database ở dashboard platform.

### Nếu dùng Render
- Chọn `New +` -> `Web Service`
- Kết nối GitHub repo
- Chọn `Docker` (nếu có)
- Render sẽ tự build bằng `Dockerfile`
- Thiết lập biến môi trường MySQL như bên trên

### Nếu dùng Railway
- Chọn `New Project` -> `Deploy from GitHub`
- Kết nối repo
- Chọn `Docker` nếu có tùy chọn
- Thêm biến môi trường MySQL

## Chạy thử cục bộ
1. Build Maven:
   ```bash
mvn clean package
```
2. Chạy Docker:
   ```bash
docker build -t hospital-management .
docker run -p 8080:8080 \
  -e MYSQL_HOST=localhost \
  -e MYSQL_PORT=3306 \
  -e MYSQL_DB=hospital_hms \
  -e MYSQL_USER=root \
  -e MYSQL_PASSWORD=1234 \
  hospital-management
```
3. Mở `http://localhost:8080`

## Lưu ý
- Dự án cần MySQL và bảng dữ liệu.
- File schema đang có ở `src/main/resources/db/payment_schema.sql`.
- Nếu deploy internet, dùng MySQL cloud (PlanetScale, ClearDB, Render MySQL, db4free.net...) hoặc một database host công khai.

## Các bước tiếp theo
1. Tạo repo GitHub
2. Push code
3. Build và kiểm tra local
4. Deploy trên Render hoặc Railway
5. Thêm biến môi trường database
