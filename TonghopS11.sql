

-- Bảng tài khoản ngân hàng

CREATE TABLE tai_khoan (

    id VARCHAR(10) PRIMARY KEY,

    ten_tai_khoan VARCHAR(100) NOT NULL,

    so_du DECIMAL(15,2) NOT NULL DEFAULT 0,

    trang_thai VARCHAR(20) DEFAULT 'ACTIVE',

    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);

-- Bảng giao dịch

CREATE TABLE giao_dich (

    id SERIAL PRIMARY KEY,

    tai_khoan_nguoi_gui VARCHAR(10),

    tai_khoan_nguoi_nhan VARCHAR(10),

    so_tien DECIMAL(15,2),

    loai_giao_dich VARCHAR(50),

    thoi_gian TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    trang_thai VARCHAR(20),

    mo_ta TEXT

);

 

-- Bảng vé xem phim (cho phần Isolation Levels)

CREATE TABLE ve_phim (

    id SERIAL PRIMARY KEY,

    suat_chieu_id VARCHAR(10),

    ten_phim VARCHAR(100),

    so_luong_con INT NOT NULL,

    gia_ve DECIMAL(10,2),

    ngay_chieu DATE

);


-- Thêm dữ liệu tài khoản

INSERT INTO tai_khoan (id, ten_tai_khoan, so_du, trang_thai) VALUES 

('TK001', 'Nguyen Van A', 5000000, 'ACTIVE'),

('TK002', 'Tran Thi B', 3000000, 'ACTIVE'),

('TK003', 'Le Van C', 1000000, 'LOCKED'),

('TK004', 'Pham Thi D', 2000000, 'ACTIVE'),

('TK005', 'Bank Fee Account', 0, 'ACTIVE');

 

-- Thêm dữ liệu vé phim

INSERT INTO ve_phim (suat_chieu_id, ten_phim, so_luong_con, gia_ve, ngay_chieu) VALUES 

('SC001', 'Avengers: Endgame', 5, 80000, '2024-01-15'),

('SC002', 'Spider-Man: No Way Home', 3, 75000, '2024-01-16'),

('SC003', 'The Batman', 1, 85000, '2024-01-17');  -- Chỉ còn 1 vé!


-- Phan 1
UPDATE tai_khoan 
SET so_du = so_du - 1000000 
WHERE id = 'TK001';

-- Giả sử dòng này bị lỗi
UPDAT tai_khoan 
SET so_du = so_du + 1000000 
WHERE id = 'TK002';
BEGIN;

--------------------------------------------------
-- 1. Kiểm tra số dư tài khoản gửi
--------------------------------------------------
SELECT so_du
FROM tai_khoan
WHERE id = 'TK001'
FOR UPDATE;

--------------------------------------------------
-- 2. Trừ tiền TK001 (chỉ khi đủ tiền)
--------------------------------------------------
UPDATE tai_khoan
SET so_du = so_du - 1000000
WHERE id = 'TK001'
  AND so_du >= 1000000;

-- Nếu không có dòng nào bị update → lỗi
-- (trong thực tế backend sẽ kiểm tra row_count)

--------------------------------------------------
-- 3. Cộng tiền TK002
--------------------------------------------------
UPDATE tai_khoan
SET so_du = so_du + 1000000
WHERE id = 'TK002';

--------------------------------------------------
-- 4. Hoàn tất giao dịch
--------------------------------------------------
COMMIT;

-- Phan 2 
CREATE OR REPLACE FUNCTION chuyen_khoan_an_toan(
    p_tk_nguoi_gui VARCHAR(10),
    p_tk_nguoi_nhan VARCHAR(10),
    p_so_tien DECIMAL
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_so_du DECIMAL;
    v_trang_thai_gui VARCHAR;
    v_trang_thai_nhan VARCHAR;
BEGIN
    --------------------------------------------------
    -- Kiểm tra tài khoản gửi
    --------------------------------------------------
    SELECT so_du, trang_thai
    INTO v_so_du, v_trang_thai_gui
    FROM tai_khoan
    WHERE id = p_tk_nguoi_gui
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN ' Tài khoản gửi không tồn tại';
    END IF;

    IF v_trang_thai_gui <> 'ACTIVE' THEN
        RETURN 'Tài khoản gửi bị khóa';
    END IF;

    IF v_so_du < p_so_tien THEN
        RETURN ' Số dư không đủ';
    END IF;

    --------------------------------------------------
    -- Kiểm tra tài khoản nhận
    --------------------------------------------------
    SELECT trang_thai
    INTO v_trang_thai_nhan
    FROM tai_khoan
    WHERE id = p_tk_nguoi_nhan
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN ' Tài khoản nhận không tồn tại';
    END IF;

    IF v_trang_thai_nhan <> 'ACTIVE' THEN
        RETURN ' Tài khoản nhận bị khóa';
    END IF;

    --------------------------------------------------
    -- Thực hiện chuyển tiền
    --------------------------------------------------
    UPDATE tai_khoan
    SET so_du = so_du - p_so_tien
    WHERE id = p_tk_nguoi_gui;

    UPDATE tai_khoan
    SET so_du = so_du + p_so_tien
    WHERE id = p_tk_nguoi_nhan;

    --------------------------------------------------
    -- Ghi log giao dịch
    --------------------------------------------------
    INSERT INTO giao_dich (
        tk_nguoi_gui,
        tk_nguoi_nhan,
        so_tien,
        trang_thai
    )
    VALUES (
        p_tk_nguoi_gui,
        p_tk_nguoi_nhan,
        p_so_tien,
        'SUCCESS'
    );

    RETURN ' Chuyển khoản thành công';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Lỗi: %', SQLERRM;
        RETURN ' Lỗi hệ thống – giao dịch đã rollback';
END;
$$;

SELECT chuyen_khoan_an_toan('TK001', 'TK002', 500000);

-- Phan 3
SELECT so_luong_con FROM ve_phim WHERE suat_chieu_id = 'SC003';
BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT so_luong_con
FROM ve_phim
WHERE suat_chieu_id = 'SC003'
FOR UPDATE;

UPDATE ve_phim
SET so_luong_con = so_luong_con - 1
WHERE suat_chieu_id = 'SC003'
  AND so_luong_con > 0;

COMMIT;
-- Phan 4
CREATE OR REPLACE FUNCTION chuyen_tien_va_mua_ve()
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_so_du DECIMAL;
    v_ve_con INT;
    v_tien_ve DECIMAL := 160000; -- 2 vé * 80.000
BEGIN
    --------------------------------------------------
    -- 1. KHÓA & KIỂM TRA TÀI KHOẢN TK004
    --------------------------------------------------
    SELECT so_du
    INTO v_so_du
    FROM tai_khoan
    WHERE id = 'TK004'
      AND trang_thai = 'ACTIVE'
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN '❌ TK004 không tồn tại hoặc bị khóa';
    END IF;

    IF v_so_du < 1005000 THEN
        RETURN '❌ Số dư TK004 không đủ';
    END IF;

    --------------------------------------------------
    -- 2. CHUYỂN TIỀN TK004 → TK001
    --------------------------------------------------
    UPDATE tai_khoan
    SET so_du = so_du - 1000000
    WHERE id = 'TK004';

    UPDATE tai_khoan
    SET so_du = so_du + 1000000
    WHERE id = 'TK001';

    --------------------------------------------------
    -- 3. TRỪ PHÍ GIAO DỊCH → TK005
    --------------------------------------------------
    UPDATE tai_khoan
    SET so_du = so_du - 5000
    WHERE id = 'TK004';

    UPDATE tai_khoan
    SET so_du = so_du + 5000
    WHERE id = 'TK005';

    --------------------------------------------------
    -- 4. SAVEPOINT TRƯỚC KHI MUA VÉ
    --------------------------------------------------
    SAVEPOINT sp_mua_ve;

    SELECT so_luong_con
    INTO v_ve_con
    FROM ve_phim
    WHERE suat_chieu_id = 'SC001'
    FOR UPDATE;

    IF v_ve_con < 2 THEN
        ROLLBACK TO SAVEPOINT sp_mua_ve;
        RETURN '⚠️ Đã chuyển tiền & thu phí, nhưng mua vé THẤT BẠI (hết vé)';
    END IF;

    --------------------------------------------------
    -- 5. TRỪ VÉ
    --------------------------------------------------
    UPDATE ve_phim
    SET so_luong_con = so_luong_con - 2
    WHERE suat_chieu_id = 'SC001';

    --------------------------------------------------
    -- 6. TRỪ TIỀN MUA VÉ
    --------------------------------------------------
    UPDATE tai_khoan
    SET so_du = so_du - v_tien_ve
    WHERE id = 'TK004';

    --------------------------------------------------
    -- 7. GHI LOG GIAO DỊCH
    --------------------------------------------------
    INSERT INTO giao_dich (tk_nguoi_gui, tk_nguoi_nhan, so_tien, trang_thai)
    VALUES
    ('TK004', 'TK001', 1000000, 'TRANSFER'),
    ('TK004', 'TK005', 5000, 'FEE'),
    ('TK004', 'SC001', 160000, 'BUY_TICKET');

    RETURN '✅ Chuyển tiền + thu phí + mua vé THÀNH CÔNG';
EXCEPTION
    WHEN OTHERS THEN
        RETURN '❌ Lỗi hệ thống – giao dịch đã rollback';
END;
$$;
SELECT chuyen_tien_va_mua_ve();
