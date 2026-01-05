. Xác định các thực thể và thuộc tính
1.1. Thực thể Student (Sinh viên)

PK: student_id

Thuộc tính:

full_name

date_of_birth

gender

email

department

1.2. Thực thể Course (Môn học)

PK: course_id

Thuộc tính:

course_name

credits

department

1.3. Thực thể Instructor (Giảng viên)

PK: instructor_id

Thuộc tính:

full_name

degree

email

department

1.4. Thực thể Class_Section (Lớp học phần)

PK: section_id

Thuộc tính:

semester

academic_year

classroom

FK:

course_id → Course

instructor_id → Instructor

1.5. Thực thể Enrollment (Đăng ký)

Đây là thực thể trung gian dùng để giải quyết quan hệ n–n giữa Student và Class_Section

PK (kết hợp):

student_id

section_id

FK:

student_id → Student

section_id → Class_Section

Thuộc tính (có thể mở rộng):

enroll_date

grade (nếu cần quản lý điểm)

2. Xác định các mối quan hệ
   2.1. Course – Class_Section

Quan hệ: Một môn học có nhiều lớp học phần

Kiểu: 1 – n

Diễn giải:

Một Course → nhiều Class_Section

Một Class_Section → đúng một Course

2.2. Instructor – Class_Section

Quan hệ: Giảng viên dạy lớp học phần

Kiểu: 1 – n

Diễn giải:

Một Instructor → nhiều Class_Section

Một Class_Section → một Instructor

2.3. Student – Class_Section

Quan hệ: Sinh viên đăng ký lớp học phần

Kiểu: n – n

Cách xử lý: Thông qua thực thể Enrollment

Diễn giải:

Một Student → nhiều Class_Section

Một Class_Section → nhiều Student
