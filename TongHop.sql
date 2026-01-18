CREATE TABLE SinhVien (

    id SERIAL PRIMARY KEY,

    ma_sv VARCHAR(20) UNIQUE,

    ho_ten VARCHAR(100) NOT NULL,

    email VARCHAR(150) NOT NULL,

    gioi_tinh VARCHAR(10),

    que_quan VARCHAR(100),

    ngay_sinh DATE,

    lop_id INTEGER,

    created_at TIMESTAMP DEFAULT NOW()

);

 

-- Bảng lớp học (500 records)

CREATE TABLE LopHoc (

    id SERIAL PRIMARY KEY,

    ma_lop VARCHAR(20) UNIQUE,

    ten_lop VARCHAR(100),

    khoa_id INTEGER

);

 

-- Bảng điểm (15 triệu records - mỗi SV có ~5 môn)

CREATE TABLE BangDiem (

    id SERIAL PRIMARY KEY,

    sinh_vien_id INTEGER,

    mon_hoc_id INTEGER,

    diem_so DECIMAL(4,2),

    hoc_ky VARCHAR(10),

    created_at TIMESTAMP DEFAULT NOW()

);

 

-- Bảng môn học (200 records)

CREATE TABLE MonHoc (

    id SERIAL PRIMARY KEY,

    ma_mon VARCHAR(20) UNIQUE,

    ten_mon VARCHAR(100)

);

INSERT INTO LopHoc (ma_lop, ten_lop, khoa_id) VALUES
('CNTT01', 'Công nghệ thông tin 01', 1),
('CNTT02', 'Công nghệ thông tin 02', 1),
('QTKD01', 'Quản trị kinh doanh 01', 2),
('KT01',   'Kế toán 01', 3),
('DL01',   'Du lịch 01', 4);
INSERT INTO SinhVien
(ma_sv, ho_ten, email, gioi_tinh, que_quan, ngay_sinh, lop_id)
VALUES
('SV001', 'Nguyễn Văn A', 'a@gmail.com', 'Nam', 'Hà Nội', '2002-05-10', 1),
('SV002', 'Trần Thị B', 'b@gmail.com', 'Nữ', 'Hải Phòng', '2002-08-21', 1),
('SV003', 'Lê Văn C', 'c@gmail.com', 'Nam', 'Đà Nẵng', '2001-11-02', 2),
('SV004', 'Phạm Thị D', 'd@gmail.com', 'Nữ', 'Huế', '2002-03-15', 3),
('SV005', 'Hoàng Văn E', 'e@gmail.com', 'Nam', 'TP HCM', '2001-12-30', 4);
INSERT INTO MonHoc (ma_mon, ten_mon) VALUES
('CTDL', 'Cấu trúc dữ liệu'),
('CSDL', 'Cơ sở dữ liệu'),
('OOP',  'Lập trình hướng đối tượng'),
('MMT',  'Mạng máy tính'),
('HQT',  'Hệ quản trị');
INSERT INTO BangDiem
(sinh_vien_id, mon_hoc_id, diem_so, hoc_ky)
VALUES
(1, 1, 8.5, 'HK1'),
(1, 2, 7.8, 'HK1'),
(1, 3, 9.0, 'HK2'),

(2, 1, 6.5, 'HK1'),
(2, 2, 7.0, 'HK1'),

(3, 3, 8.0, 'HK2'),
(3, 4, 7.5, 'HK2'),

(4, 2, 9.2, 'HK1'),
(4, 5, 8.8, 'HK2'),

(5, 1, 7.0, 'HK1'),
(5, 4, 6.8, 'HK2');

-- 1.1 --
EXPLAIN ANALYZE 

SELECT * FROM SinhVien WHERE email = 'nam.nguyen@techmaster.edu.vn';
/*
Seq Scan on sinhvien  (cost=0.00..11.12 rows=1 width=870) (actual time=0.037..0.037 rows=0.00 loops=1)
*/
-- 1.2 --
create index idx_email
on SinhVien(email);

CREATE INDEX idx_sinhvien_lop_id
ON SinhVien(lop_id);

CREATE INDEX idx_sinhvien_que_quan
ON SinhVien(que_quan);

CREATE INDEX idx_sinhvien_gioitinh_quequan
ON SinhVien(gioi_tinh, que_quan);
-- 1.3 --

EXPLAIN ANALYZE
SELECT *
FROM SinhVien
WHERE que_quan = 'Hà Nội'
AND gioi_tinh = 'Nam';
--2 --
CREATE VIEW v_bao_cao_diem AS

SELECT 

    sv.ma_sv,

    sv.ho_ten,

    sv.email,

    l.ten_lop,

    COUNT(bd.id) as so_mon_hoc,

    AVG(bd.diem_so) as diem_trung_binh

FROM SinhVien sv

JOIN LopHoc l ON sv.lop_id = l.id

JOIN BangDiem bd ON sv.id = bd.sinh_vien_id

GROUP BY sv.id, sv.ma_sv, sv.ho_ten, sv.email, l.ten_lop;

-- 2.2 --
CREATE VIEW v_bao_cao_diem AS
SELECT 
    sv.ma_sv,
    sv.ho_ten,
    sv.email,
    sv.gioi_tinh,
    sv.que_quan,
    l.ten_lop,
    COUNT(bd.id) AS so_mon_hoc,
    ROUND(AVG(bd.diem_so), 2) AS diem_trung_binh
FROM SinhVien sv
JOIN LopHoc l ON sv.lop_id = l.id
JOIN BangDiem bd ON sv.id = bd.sinh_vien_id
GROUP BY sv.id, sv.ma_sv, sv.ho_ten, sv.email, sv.gioi_tinh, sv.que_quan, l.ten_lop;

CREATE VIEW v_thong_ke_lop AS
SELECT
    l.ten_lop,
    COUNT(DISTINCT sv.id) AS si_so,
    ROUND(AVG(bd.diem_so), 2) AS diem_tb_lop,
    CASE
        WHEN AVG(bd.diem_so) >= 8 THEN 'Giỏi'
        WHEN AVG(bd.diem_so) >= 6.5 THEN 'Khá'
        WHEN AVG(bd.diem_so) >= 5 THEN 'Trung bình'
        ELSE 'Yếu'
    END AS xep_loai
FROM LopHoc l
JOIN SinhVien sv ON sv.lop_id = l.id
JOIN BangDiem bd ON bd.sinh_vien_id = sv.id
GROUP BY l.ten_lop;
CREATE MATERIALIZED VIEW mv_thong_ke_toan_truong AS
SELECT 
    que_quan,
    gioi_tinh,
    COUNT(*) AS so_luong,
    ROUND(AVG(diem_trung_binh), 2) AS diem_tb_tinh
FROM v_bao_cao_diem
GROUP BY que_quan, gioi_tinh;

CREATE VIEW v_sinh_vien_ca_nhan AS
SELECT 
    ma_sv, ho_ten, email, ten_lop, diem_trung_binh
FROM v_bao_cao_diem
WHERE email = CURRENT_USER;

CREATE VIEW v_giang_vien AS
SELECT 
    ma_sv, ho_ten, ten_lop, diem_trung_binh
FROM v_bao_cao_diem;



