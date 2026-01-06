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

