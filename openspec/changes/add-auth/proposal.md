# Proposal

## Why

Mọi tính năng trip đều cần biết người dùng là ai. Lời mời qua email chỉ an toàn khi email đã được chứng minh thuộc về người dùng, và trip public cần hiển thị tác giả bằng tên + avatar thay vì email.

## What Changes

### Tài khoản (chỉ email + mật khẩu trong MVP)

- Đăng ký bằng email + mật khẩu + **tên hiển thị (bắt buộc)**. Email được chuẩn hóa (trim + lowercase).
- Mật khẩu 8–128 ký tự, có ít nhất 1 chữ hoa, 1 chữ thường, 1 chữ số và 1 ký tự đặc biệt.
- **Bắt buộc xác thực email** trước khi đăng nhập và dùng app; gửi lại email xác thực được (có cooldown).
- Đăng nhập, đăng xuất, quên mật khẩu (link đặt lại có hạn ngắn), đổi mật khẩu khi đã đăng nhập.
- Đặt lại / đổi mật khẩu thì **mọi phiên đăng nhập khác bị đăng xuất**.
- **Giới hạn đăng nhập sai theo từng tài khoản** (không giới hạn theo IP): sai **5 lần liên tiếp** thì **khóa đăng nhập 30 phút** và báo rõ cho người dùng; đăng nhập đúng thì đếm lại từ 0. **Đặt lại mật khẩu qua email mở khóa ngay** (chống việc người khác cố tình khóa tài khoản).
- Đăng ký, quên mật khẩu và gửi lại email xác thực **không tiết lộ email có tồn tại hay không** (phản hồi giống hệt nhau). Đăng ký bằng email đã có tài khoản thì gửi email báo "bạn đã có tài khoản" kèm link đăng nhập / quên mật khẩu.
- Link xác thực email và link đặt lại mật khẩu dùng một lần, **hết hạn sau 15 phút**; gửi lại tối đa **1 lần mỗi 60 giây**, link mới vô hiệu link cũ.
- Luồng đăng ký / đăng nhập **giữ lại lời mời đang mở** (link hoặc email) để quay về chấp nhận sau khi xong.

### Phiên đăng nhập

- **Một session token ngẫu nhiên**, lưu dạng hash trong DB, đặt trong cookie httpOnly; hạn trượt (ví dụ 30 ngày, gia hạn khi còn hoạt động). Thu hồi bằng cách đánh dấu `revoked_at` (không xóa bản ghi).
- Không dùng JWT access/refresh token như hệ thống cũ.

### Hồ sơ người dùng

- Tên hiển thị (sửa được), avatar.
- **Upload avatar ngay trong MVP**: JPEG/PNG/WebP, tối đa **5 MB**; kiểm tra định dạng bằng nội dung file (không tin content-type của client); server **re-encode sang WebP 512×512 và xóa metadata** (EXIF có thể chứa vị trí GPS); cắt vuông.
- Avatar là thông tin công khai: phục vụ từ **vùng lưu trữ công khai bằng URL không đoán được** (cache qua CDN). Đổi/xóa avatar thì file cũ **chuyển sang vùng riêng tư** (không xóa).
- Chưa có avatar thì hiển thị avatar tự tạo từ chữ cái đầu + màu.
- Email **không bao giờ** hiển thị ở góc nhìn công khai.

## Capabilities

### New Capabilities
- `user-auth`: đăng ký, xác thực email, đăng nhập/đăng xuất, quên/đặt lại/đổi mật khẩu, phiên đăng nhập.
- `user-profile`: tên hiển thị, avatar (upload + fallback), dữ liệu hồ sơ hiển thị công khai.

### Modified Capabilities
- (không có)

## Impact

- Là nền cho mọi change khác (`trips`, `trip-membership`, …).
- Cần gửi email (SMTP; Mailpit khi chạy local) và lưu trữ file (S3-compatible; RustFS khi chạy local).
- Frontend: các màn hình auth, trang hồ sơ, cắt ảnh avatar.

## Out of scope (MVP)

- Đăng nhập Google/Apple/khác, 2FA, xóa tài khoản, đổi email, quản lý danh sách thiết bị đăng nhập.

## Open questions

- (không còn)
