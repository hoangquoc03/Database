# 🎓 Hệ thống Quản lý Đăng ký Môn học Đại học

## 📌 Giới thiệu
Hệ thống Quản lý Đăng ký Môn học Đại học được thiết kế nhằm hỗ trợ việc quản lý sinh viên, môn học, giảng viên, lớp học phần và quá trình đăng ký môn học.  
Hệ thống sử dụng mô hình **Entity–Relationship (ER)** để mô tả các thực thể và mối quan hệ giữa chúng.

---

## 🧩 1. Các Thực Thể và Thuộc Tính

### 👨‍🎓 1.1. Student (Sinh viên)
**Khóa chính (PK):**
- `student_id`

**Thuộc tính:**
- `full_name` – Họ và tên  
- `date_of_birth` – Ngày sinh  
- `gender` – Giới tính  
- `email` – Email  
- `department` – Khoa / Ngành  

---

### 📘 1.2. Course (Môn học)
**Khóa chính (PK):**
- `course_id`

**Thuộc tính:**
- `course_name` – Tên môn học  
- `credits` – Số tín chỉ  
- `department` – Khoa phụ trách  

---

### 👨‍🏫 1.3. Instructor (Giảng viên)
**Khóa chính (PK):**
- `instructor_id`

**Thuộc tính:**
- `full_name` – Họ và tên  
- `degree` – Học vị  
- `email` – Email  
- `department` – Khoa  

---

### 🏫 1.4. Class_Section (Lớp học phần)
**Khóa chính (PK):**
- `section_id`

**Thuộc tính:**
- `semester` – Học kỳ  
- `academic_year` – Năm học  
- `classroom` – Phòng học  

**Khóa ngoại (FK):**
- `course_id` → `Course(course_id)`  
- `instructor_id` → `Instructor(instructor_id)`

---

### 📝 1.5. Enrollment (Đăng ký môn học)
Đây là **thực thể trung gian** dùng để giải quyết quan hệ **n–n** giữa `Student` và `Class_Section`.

**Khóa chính (PK – kết hợp):**
- `student_id`  
- `section_id`

**Khóa ngoại (FK):**
- `student_id` → `Student(student_id)`  
- `section_id` → `Class_Section(section_id)`

**Thuộc tính mở rộng:**
- `enroll_date` – Ngày đăng ký  
- `grade` – Điểm số (nếu quản lý kết quả học tập)

---

## 🔗 2. Các Mối Quan Hệ

### 📘 2.1. Course – Class_Section
**Mối quan hệ:** Một môn học có nhiều lớp học phần  
- **Kiểu:** 1 – n  

**Diễn giải:**
- Một `Course` có thể mở **nhiều** `Class_Section`  
- Một `Class_Section` chỉ thuộc về **một** `Course`

---

### 👨‍🏫 2.2. Instructor – Class_Section
**Mối quan hệ:** Giảng viên giảng dạy lớp học phần  
- **Kiểu:** 1 – n  

**Diễn giải:**
- Một `Instructor` có thể dạy **nhiều** `Class_Section`  
- Một `Class_Section` do **một** `Instructor` phụ trách

---

### 👨‍🎓 2.3. Student – Class_Section
**Mối quan hệ:** Sinh viên đăng ký lớp học phần  
- **Kiểu:** n – n  
- **Giải pháp:** Thông qua bảng trung gian `Enrollment`

**Diễn giải:**
- Một `Student` có thể đăng ký **nhiều** `Class_Section`  
- Một `Class_Section` có thể có **nhiều** `Student`

---

## 🗺️ 3. Sơ đồ ERD
<img width="1038" height="803" alt="image" src="https://github.com/user-attachments/assets/184b3cb9-ab23-4dc3-a720-7ed62a46cfc4" />

---
# 🛒 Hệ thống Quản lý Đơn hàng Thương mại Điện tử
## 🧩 2. Các Thực Thể và Thuộc Tính

### 👤 2.1. Customer (Khách hàng)
**Khóa chính (PK):**
- `customer_id`

**Thuộc tính:**
- `full_name` – Họ tên  
- `email` – Email  
- `phone` – Số điện thoại  
- `address` – Địa chỉ  

---

### 📦 2.2. Product (Sản phẩm)
**Khóa chính (PK):**
- `product_id`

**Thuộc tính:**
- `product_name` – Tên sản phẩm  
- `price` – Giá bán  
- `description` – Mô tả  
- `category` – Loại hàng  

---

### 🧾 2.3. Order (Đơn hàng)
**Khóa chính (PK):**
- `order_id`

**Thuộc tính:**
- `order_date` – Ngày đặt hàng  
- `total_amount` – Tổng tiền  
- `status` – Trạng thái đơn hàng  

**Khóa ngoại (FK):**
- `customer_id` → `Customer(customer_id)`  
- `staff_id` → `Staff(staff_id)`

---

### 📑 2.4. OrderDetail (Chi tiết đơn hàng)
Đây là **thực thể trung gian** dùng để giải quyết quan hệ **n–n** giữa `Order` và `Product`.

**Khóa chính (PK – kết hợp):**
- `order_id`  
- `product_id`

**Khóa ngoại (FK):**
- `order_id` → `Order(order_id)`  
- `product_id` → `Product(product_id)`

**Thuộc tính:**
- `quantity` – Số lượng  
- `unit_price` – Đơn giá tại thời điểm mua  

---

### 👨‍💼 2.5. Staff (Nhân viên)
**Khóa chính (PK):**
- `staff_id`

**Thuộc tính:**
- `full_name` – Họ tên  
- `position` – Vị trí công việc  
- `hire_date` – Ngày vào làm  

---

## 🔗 3. Các Mối Quan Hệ

### 👤 Customer – Order
- **Quan hệ:** Khách hàng đặt đơn hàng  
- **Kiểu:** 1 – n  

**Diễn giải:**
- Một khách hàng có thể đặt **nhiều đơn hàng**  
- Một đơn hàng chỉ thuộc về **một khách hàng**

---

### 🧾 Order – Product
- **Quan hệ:** Đơn hàng chứa sản phẩm  
- **Kiểu:** n – n  
- **Giải pháp:** Thông qua bảng `OrderDetail`

**Diễn giải:**
- Một đơn hàng có thể chứa **nhiều sản phẩm**  
- Một sản phẩm có thể xuất hiện trong **nhiều đơn hàng**

---

### 👨‍💼 Staff – Order
- **Quan hệ:** Nhân viên xử lý đơn hàng  
- **Kiểu:** 1 – n  

**Diễn giải:**
- Một nhân viên có thể xử lý **nhiều đơn hàng**  
- Một đơn hàng được xử lý bởi **một nhân viên**

---

## 🗺️ 4. Sơ đồ ERD
<img width="739" height="573" alt="image" src="https://github.com/user-attachments/assets/29e827f3-de7c-4c31-a6ac-5e221939f4f0" />
---
# 🏨 Hệ thống Quản lý Đặt phòng Khách sạn

---
## 🧩 2. Các Thực Thể và Thuộc Tính

### 🏨 2.1. Hotel (Khách sạn)
**Khóa chính (PK):**
- `hotel_id`

**Thuộc tính:**
- `hotel_name` – Tên khách sạn  
- `address` – Địa chỉ  
- `stars` – Số sao  
- `description` – Mô tả  
- `manager_name` – Người quản lý  

---

### 🚪 2.2. Room (Phòng)
**Khóa chính (PK):**
- `room_id`

**Thuộc tính:**
- `room_type` – Loại phòng (Deluxe, Standard, ...)  
- `price_per_night` – Giá mỗi đêm  
- `status` – Tình trạng (Trống / Đã đặt)  
- `capacity` – Sức chứa  

**Khóa ngoại (FK):**
- `hotel_id` → `Hotel(hotel_id)`

---

### 👤 2.3. Customer (Khách hàng)
**Khóa chính (PK):**
- `customer_id`

**Thuộc tính:**
- `full_name` – Họ tên  
- `email` – Email  
- `phone` – Số điện thoại  
- `nationality` – Quốc tịch  

---

### 📅 2.4. Booking (Đặt phòng)
**Khóa chính (PK):**
- `booking_id`

**Thuộc tính:**
- `booking_date` – Ngày đặt  
- `check_in_date` – Ngày nhận phòng  
- `check_out_date` – Ngày trả phòng  
- `total_amount` – Tổng tiền  
- `status` – Trạng thái (Chờ / Xác nhận / Hủy)

**Khóa ngoại (FK):**
- `customer_id` → `Customer(customer_id)`

---

### 🧾 2.5. Booking_Room (Chi tiết đặt phòng)
Đây là **thực thể trung gian** giải quyết quan hệ **n–n** giữa `Booking` và `Room`.

**Khóa chính (PK – kết hợp):**
- `booking_id`  
- `room_id`

**Khóa ngoại (FK):**
- `booking_id` → `Booking(booking_id)`  
- `room_id` → `Room(room_id)`

**Thuộc tính:**
- `price_per_night` – Giá tại thời điểm đặt  

---

### 💳 2.6. Payment (Thanh toán)
**Khóa chính (PK):**
- `payment_id`

**Thuộc tính:**
- `payment_method` – Phương thức (Thẻ, Chuyển khoản, ...)  
- `payment_date` – Ngày thanh toán  
- `amount` – Số tiền  
- `status` – Trạng thái thanh toán  

**Khóa ngoại (FK):**
- `booking_id` → `Booking(booking_id)`

---

### ⭐ 2.7. Review (Đánh giá)
**Khóa chính (PK):**
- `review_id`

**Thuộc tính:**
- `rating` – Điểm số  
- `comment` – Bình luận  
- `review_date` – Ngày đăng  

**Khóa ngoại (FK):**
- `customer_id` → `Customer(customer_id)`  
- `hotel_id` → `Hotel(hotel_id)`

---

## 🔗 3. Các Mối Quan Hệ

### 🏨 Hotel – Room
- **Kiểu:** 1 – n  
- Một khách sạn có **nhiều phòng**  
- Một phòng thuộc về **một khách sạn**

---

### 👤 Customer – Booking
- **Kiểu:** 1 – n  
- Một khách hàng có thể tạo **nhiều booking**  
- Một booking thuộc về **một khách hàng**

---

### 📅 Booking – Room
- **Kiểu:** n – n  
- **Giải pháp:** Thực thể trung gian `Booking_Room`  
- Một booking có thể bao gồm **nhiều phòng**  
- Một phòng có thể xuất hiện trong **nhiều booking** (khác thời gian)

---

### 📅 Booking – Payment
- **Kiểu:** 1 – 1  
- Một booking có **đúng một thanh toán** (nếu thành công)

---

### 👤 Customer – Review – Hotel
- Một khách hàng có thể viết **nhiều đánh giá**  
- Mỗi đánh giá gắn với **một khách sạn**  
- Chỉ đánh giá khách sạn đã từng ở

---

## 🗺️ 4. Sơ đồ ERD
<img width="619" height="643" alt="image" src="https://github.com/user-attachments/assets/100e5e10-1169-4719-bd9c-b62a2bdafbd5" />
---
# 🎓 Hệ thống Quản lý Lớp học Trực tuyến
## 🧩 2. Các Thực Thể và Thuộc Tính

### 👤 2.1. User (Người dùng)
**Khóa chính (PK):**
- `user_id`

**Thuộc tính:**
- `full_name` – Họ tên  
- `email` – Email  
- `password` – Mật khẩu  
- `role` – Vai trò (`student` / `instructor` / `admin`)

---

### 👨‍🏫 2.2. Instructor (Giảng viên)
Là **một loại User**, mở rộng từ bảng `User`.

**Khóa chính & khóa ngoại (PK, FK):**
- `instructor_id` → `User(user_id)`

**Thuộc tính bổ sung:**
- `degree` – Học vị  
- `expertise` – Chuyên môn  

---

### 📚 2.3. Category (Danh mục khóa học)
**Khóa chính (PK):**
- `category_id`

**Thuộc tính:**
- `category_name` – Tên danh mục  

---

### 📘 2.4. Course (Khóa học)
**Khóa chính (PK):**
- `course_id`

**Thuộc tính:**
- `course_name` – Tên khóa học  
- `description` – Mô tả  
- `level` – Cấp độ  
- `price` – Giá  
- `release_date` – Ngày phát hành  

**Khóa ngoại (FK):**
- `category_id` → `Category(category_id)`  
- `instructor_id` → `Instructor(instructor_id)`

---

### 📝 2.5. Enrollment (Đăng ký học)
Thực thể trung gian cho quan hệ **n–n** giữa `User (Student)` và `Course`.

**Khóa chính (PK – kết hợp):**
- `user_id`  
- `course_id`

**Khóa ngoại (FK):**
- `user_id` → `User(user_id)`  
- `course_id` → `Course(course_id)`

**Thuộc tính:**
- `enroll_date` – Ngày đăng ký  
- `status` – Trạng thái (`đang học`, `hoàn thành`, `hủy`)

---

### 📖 2.6. Lesson (Bài học)
**Khóa chính (PK):**
- `lesson_id`

**Thuộc tính:**
- `title` – Tiêu đề  
- `content` – Nội dung  
- `duration` – Thời lượng  

**Khóa ngoại (FK):**
- `course_id` → `Course(course_id)`

---

### ❓ 2.7. Quiz (Bài kiểm tra)
**Khóa chính (PK):**
- `quiz_id`

**Thuộc tính:**
- `title` – Tiêu đề  
- `question_count` – Số câu hỏi  

**Khóa ngoại (FK):**
- `lesson_id` → `Lesson(lesson_id)`

---

### 📊 2.8. Result (Kết quả)
**Khóa chính (PK):**
- `result_id`

**Thuộc tính:**
- `score` – Điểm  
- `attempt_date` – Ngày làm bài  

**Khóa ngoại (FK):**
- `user_id` → `User(user_id)`  
- `quiz_id` → `Quiz(quiz_id)`

---

## 🔗 3. Các Mối Quan Hệ

### 👨‍🏫 Instructor – Course
- **Kiểu:** 1 – n  
- Một giảng viên có thể dạy **nhiều khóa học**  
- Một khóa học do **một giảng viên** phụ trách  

---

### 📚 Category – Course
- **Kiểu:** 1 – n  
- Một danh mục có **nhiều khóa học**  
- Một khóa học thuộc về **một danh mục**

---

### 📘 Course – Lesson – Quiz
- Một khóa học có **nhiều bài học**  
- Một bài học có thể có **nhiều quiz**

---

### 👤 Student – Course
- **Kiểu:** n – n  
- **Giải pháp:** Thông qua bảng `Enrollment`  
- Một học viên có thể học **nhiều khóa học**  
- Một khóa học có **nhiều học viên**

---

### 👤 Student – Quiz – Result
- Một học viên có thể làm **nhiều quiz**  
- Mỗi lần làm quiz tạo ra **một kết quả (Result)** riêng  

---

## 🗺️ 4. Sơ đồ ERD
<img width="885" height="718" alt="image" src="https://github.com/user-attachments/assets/6e45bc58-7e43-4d84-b63d-7fbcc5b074a3" />
