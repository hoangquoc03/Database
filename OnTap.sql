CREATE TABLE KhachHang (

    id SERIAL PRIMARY KEY,

    ma_kh VARCHAR(20) UNIQUE NOT NULL,

    ho_ten VARCHAR(100) NOT NULL,

    so_du DECIMAL(15,2) DEFAULT 0.00,

    trang_thai VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT NOW()

);
CREATE TABLE TaiKhoan (

    id SERIAL PRIMARY KEY,

    ma_tk VARCHAR(20) UNIQUE NOT NULL,

    khach_hang_id INTEGER REFERENCES KhachHang(id),

    so_du DECIMAL(15,2) DEFAULT 0.00,

    loai_tk VARCHAR(50) DEFAULT 'THUONG',

    trang_thai VARCHAR(20) DEFAULT 'ACTIVE',

    created_at TIMESTAMP DEFAULT NOW()

);
CREATE TABLE GiaoDich (

    id SERIAL PRIMARY KEY,

    ma_gd VARCHAR(30) UNIQUE NOT NULL,

    tai_khoan_id INTEGER REFERENCES TaiKhoan(id),

    loai_gd VARCHAR(20) NOT NULL, -- 'CHUYEN_TIEN', 'RUT_TIEN', 'GUI_TIEN'

    so_tien DECIMAL(15,2) NOT NULL,

    tai_khoan_doi_tac INTEGER, -- Dùng cho chuyển tiền

    noi_dung TEXT,

    trang_thai VARCHAR(20) DEFAULT 'PENDING',

    created_at TIMESTAMP DEFAULT NOW()

);

CREATE TABLE LichSuSoDu (

    id SERIAL PRIMARY KEY,

    tai_khoan_id INTEGER REFERENCES TaiKhoan(id),

    so_du_truoc DECIMAL(15,2),

    so_du_sau DECIMAL(15,2),

    thoi_gian TIMESTAMP DEFAULT NOW()

);
INSERT INTO KhachHang (ma_kh, ho_ten, so_du, trang_thai)
VALUES
('KH001', 'Nguyen Van An', 5000000.00, 'ACTIVE'),
('KH002', 'Tran Thi Binh', 8000000.00, 'ACTIVE'),
('KH003', 'Le Minh Chau', 12000000.00, 'ACTIVE');

INSERT INTO TaiKhoan (ma_tk, khach_hang_id, so_du, loai_tk, trang_thai)
VALUES
('TK001', 1, 5000000.00, 'THUONG', 'ACTIVE'),
('TK002', 2, 8000000.00, 'THUONG', 'ACTIVE'),
('TK003', 3, 12000000.00, 'VIP', 'ACTIVE');

INSERT INTO GiaoDich (ma_gd, tai_khoan_id, loai_gd, so_tien, tai_khoan_doi_tac, noi_dung, trang_thai)
VALUES
('GD001', 1, 'GUI_TIEN', 2000000.00, NULL, 'Nop tien vao tai khoan', 'SUCCESS'),
('GD002', 2, 'RUT_TIEN', 1000000.00, NULL, 'Rut tien ATM', 'SUCCESS'),
('GD003', 3, 'CHUYEN_TIEN', 3000000.00, 1, 'Chuyen tien cho TK001', 'SUCCESS');

INSERT INTO LichSuSoDu (tai_khoan_id, so_du_truoc, so_du_sau)
VALUES
(1, 3000000.00, 5000000.00),
(2, 9000000.00, 8000000.00),
(3, 15000000.00, 12000000.00);

-- Phan 1 --
create or replace procedure chuyen_tien(
p_ma_tk_nguoi_gui varchar,
p_ma_tk_nguoi_nhan varchar,
p_so_tien decimal,
p_noi_dung text default null
)
language plpgsql
as $$
declare
v_id_gui integer;
v_id_nhan integer;
v_so_du_gui decimal(15,2);
v_so_du_nhan decimal(15,2);
begin

select id,so_du
into v_id_gui,v_so_du_nhan
from TaiKhoan 
where ma_tk = p_ma_tk_nguoi_gui
and trang_thai = 'active';

if not found then
raise exception 'Tai khoan nguoi dung khong ton tai'
end if;

if v_so_du_gui <p_so_tien then
raise exception 'So du khong du de chuyen tein';
end if;

insert into LichSuSoDu(tai_khoan_id,so_du_truoc,so_du_sau)
values (v_id_gui,v_so_du_gui,v_so_du_gui - p_so_tien);

insert into LichSuSoDu(tai_khoan_id,so_du_truoc,so_du_sau)
values (v_id_nhan,v_so_du_nhan,v_so_du_nhan + p_so_tien);

update TaiKhoan
set so_du = so_du - p_so_tien
where id = v_id_gui;

update TaiKhoan
set so_du = so_du+p_so_tien
where id = v_id_nhan;

INSERT INTO GiaoDich(
        ma_gd, tai_khoan_id, loai_gd, so_tien,
        tai_khoan_doi_tac, noi_dung, trang_thai
    )
    VALUES (
        'GD' || EXTRACT(EPOCH FROM NOW()),
        v_id_gui,
        'CHUYEN_TIEN',
        p_so_tien,
        v_id_nhan,
        p_noi_dung,
        'SUCCESS'
    );

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Lỗi: %, rollback toàn bộ giao dịch', SQLERRM;
        RAISE;

end
$$

-- phan 2 --
CREATE OR REPLACE PROCEDURE thong_tin_tai_khoan(
    p_ma_tk VARCHAR,
    OUT p_ho_ten VARCHAR,
    OUT p_so_du DECIMAL,
    OUT p_so_giao_dich INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Lấy thông tin tài khoản + khách hàng
    SELECT kh.ho_ten, tk.so_du
    INTO p_ho_ten, p_so_du
    FROM TaiKhoan tk
    JOIN KhachHang kh ON tk.khach_hang_id = kh.id
    WHERE tk.ma_tk = p_ma_tk;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy tài khoản %', p_ma_tk;
    END IF;

    -- Đếm số giao dịch
    SELECT COUNT(*)
    INTO p_so_giao_dich
    FROM GiaoDich gd
    JOIN TaiKhoan tk ON gd.tai_khoan_id = tk.id
    WHERE tk.ma_tk = p_ma_tk;
END;
$$;

CREATE OR REPLACE PROCEDURE tinh_lai_suat_thang(
    p_thang INTEGER,
    p_nam INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tk RECORD;
    v_lai DECIMAL(15,2);
    v_ty_le DECIMAL(5,3);
BEGIN
    FOR v_tk IN
        SELECT id, so_du, loai_tk
        FROM TaiKhoan
        WHERE trang_thai = 'ACTIVE'
    LOOP
        -- Xác định lãi suất
        IF v_tk.loai_tk = 'VIP' THEN
            v_ty_le := 0.006;
        ELSE
            v_ty_le := 0.003;
        END IF;

        v_lai := v_tk.so_du * v_ty_le;

        -- Cập nhật số dư
        UPDATE TaiKhoan
        SET so_du = so_du + v_lai
        WHERE id = v_tk.id;

        -- Ghi giao dịch
        INSERT INTO GiaoDich(
            ma_gd, tai_khoan_id, loai_gd, so_tien, noi_dung, trang_thai
        )
        VALUES (
            'LAI' || v_tk.id || p_thang || p_nam,
            v_tk.id,
            'GUI_TIEN',
            v_lai,
            'Lãi suất tháng ' || p_thang || '/' || p_nam,
            'SUCCESS'
        );
    END LOOP;
END;
$$;

-- phan 3 --
CREATE OR REPLACE PROCEDURE phan_loai_khach_hang()
LANGUAGE plpgsql
AS $$
DECLARE
    v_kh RECORD;
BEGIN
    FOR v_kh IN
        SELECT id, so_du FROM KhachHang
    LOOP
        UPDATE KhachHang
        SET trang_thai =
            CASE
                WHEN v_kh.so_du > 1000000000 THEN 'VIP'
                WHEN v_kh.so_du > 100000000 THEN 'GOLD'
                WHEN v_kh.so_du > 10000000 THEN 'SILVER'
                ELSE 'STANDARD'
            END
        WHERE id = v_kh.id;
    END LOOP;
END;
$$;

-- phan 4 --
CREATE OR REPLACE PROCEDURE ap_dung_phi_giao_dich(
    p_ma_gd VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_gd RECORD;
    v_phi DECIMAL(15,2);
    v_ty_le DECIMAL(5,3);
    v_weekend BOOLEAN;
BEGIN
    SELECT gd.*, tk.loai_tk
    INTO v_gd
    FROM GiaoDich gd
    JOIN TaiKhoan tk ON gd.tai_khoan_id = tk.id
    WHERE gd.ma_gd = p_ma_gd;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Không tìm thấy giao dịch';
    END IF;

    v_weekend := EXTRACT(DOW FROM v_gd.created_at) IN (0,6);

    IF v_gd.loai_gd = 'RUT_TIEN' THEN
        v_ty_le := 0.005;
    ELSE
        v_ty_le := 0.003;
    END IF;

    IF v_weekend THEN
        v_ty_le := v_ty_le + 0.002;
    END IF;

    IF v_gd.loai_tk = 'VIP' THEN
        v_ty_le := v_ty_le / 2;
    END IF;

    v_phi := v_gd.so_tien * v_ty_le;

    UPDATE TaiKhoan
    SET so_du = so_du - v_phi
    WHERE id = v_gd.tai_khoan_id;
END;
$$;
CREATE OR REPLACE PROCEDURE tao_sao_ke_thang(
    p_thang INTEGER,
    p_nam INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tk RECORD;
BEGIN
    FOR v_tk IN SELECT id FROM TaiKhoan LOOP
        INSERT INTO GiaoDich(
            ma_gd, tai_khoan_id, loai_gd, so_tien, noi_dung, trang_thai
        )
        SELECT
            'SAOKE' || v_tk.id || p_thang || p_nam,
            v_tk.id,
            'SAO_KE',
            0,
            'Sao kê tháng ' || p_thang || '/' || p_nam,
            'SUCCESS';
    END LOOP;
END;
$$;
CREATE OR REPLACE PROCEDURE khoa_tk_khong_hoat_dong(
    p_so_thang INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE TaiKhoan
    SET trang_thai = 'LOCKED'
    WHERE id NOT IN (
        SELECT DISTINCT tai_khoan_id
        FROM GiaoDich
        WHERE created_at >= NOW() - (p_so_thang || ' months')::INTERVAL
    );
END;
$$;


-- phan 5 --

CREATE TABLE LogLoi (
    id SERIAL PRIMARY KEY,
    procedure_name VARCHAR(100),
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE OR REPLACE PROCEDURE ghi_log_loi(
    p_procedure_name VARCHAR,
    p_error_message TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO LogLoi(procedure_name, error_message)
    VALUES (p_procedure_name, p_error_message);
END;
$$;
CREATE OR REPLACE PROCEDURE gui_tien_an_toan(
    p_ma_tk VARCHAR,
    p_so_tien DECIMAL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
BEGIN
    IF p_so_tien <= 0 THEN
        RAISE EXCEPTION 'Số tiền không hợp lệ';
    END IF;

    SELECT id
    INTO v_id
    FROM TaiKhoan
    WHERE ma_tk = p_ma_tk;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản không tồn tại';
    END IF;

    UPDATE TaiKhoan
    SET so_du = so_du + p_so_tien
    WHERE id = v_id
      AND trang_thai = 'ACTIVE';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tài khoản bị khóa';
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        CALL ghi_log_loi('gui_tien_an_toan', SQLERRM);
        RAISE;
END;
$$;
