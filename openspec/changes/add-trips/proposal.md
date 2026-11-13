# Proposal

## Why

Nhóm bạn đi du lịch (kể cả đi nhiều quốc gia, lệch múi giờ) cần một không gian chung cho mỗi chuyến đi để cùng lên kế hoạch. Định hướng dài hạn là một mạng xã hội nơi người dùng tham khảo chuyến đi công khai của người khác, nên trip phải hỗ trợ private/public ngay từ đầu.

## What Changes

- Người dùng đã đăng nhập tạo trip; người tạo trở thành **owner**.
- Thông tin trip: tên, điểm đến (text), mô tả, ngày bắt đầu/kết thúc dạng **ngày theo lịch** (không có giờ), **múi giờ mặc định** (IANA, gợi ý cho schedule item mới), **một loại tiền tệ** cho cả trip.
- Nội dung trip (tên, điểm đến, mô tả) **để dạng rõ, không mã hóa**, kể cả khi trip private, nên đổi visibility không phải mã hóa lại dữ liệu.
- Loại tiền tệ chọn khi tạo trip; **bị khóa sau khi trip có khoản chi đầu tiên**.
- `visibility`: `private` (mặc định) hoặc `public`. Không có trạng thái nháp/lifecycle riêng; chỉ owner đổi visibility.
- Trip public có **URL công khai ổn định**, xem được khi chưa đăng nhập, có metadata (tiêu đề, mô tả) để chia sẻ link đẹp.
- Trip public được trả về qua một **góc nhìn công khai riêng** (response riêng, không phải ẩn bớt trường từ response nội bộ). Không bao giờ lộ email, lời mời, danh sách thành viên, số dư.
- Trip public hiển thị **tác giả bằng tên hiển thị + avatar**, không bao giờ hiện email.
- Chỉ owner sửa thông tin trip và xóa trip.
- **Xóa trip là soft delete** (hệ thống không bao giờ hard delete). Trip đã xóa vào **"Thùng rác"** của owner và owner **khôi phục được trên UI**; không có cơ chế tự dọn sau một thời gian. Trip đã xóa không truy cập được (kể cả URL công khai); dữ liệu con (lịch trình, checklist, chi phí, thành viên) giữ nguyên, không xóa dây chuyền, và trở lại nguyên vẹn khi khôi phục.
- **Ảnh bìa** (tùy chọn, owner upload/thay/xóa): dùng chung quy tắc upload với avatar (JPEG/PNG/WebP, giới hạn kích thước, kiểm tra định dạng bằng nội dung file, server re-encode và xóa metadata). Tối đa 5 MB, server lưu WebP chiều rộng tối đa 1600px. Trip **public**: ảnh bìa phục vụ từ vùng công khai bằng URL không đoán được (dùng cho trang công khai và ảnh preview khi chia sẻ link). Trip **private**: ảnh nằm ở vùng riêng tư, thành viên xem qua **presigned URL** ngắn hạn cấp sau khi kiểm tra quyền. Đổi visibility thì file được chuyển giữa hai vùng; ảnh bị thay/xóa chuyển sang vùng riêng tư (không xóa).

## Capabilities

### New Capabilities
- `trips`: tạo/sửa/xóa trip, thông tin trip, tiền tệ, múi giờ mặc định, visibility private/public và góc nhìn công khai.

### Modified Capabilities
- (không có)

## Impact

- Phụ thuộc `user-auth` (đăng nhập) và `user-profile` (tên hiển thị, avatar của tác giả) từ change `add-auth`.
- Là nền cho `trip-membership`, `trip-schedule`, `trip-checklists`, `trip-expenses`.
- Backend: bảng trips, API trip nội bộ + API trip công khai. Frontend: tạo/sửa trip, trang trip công khai (SEO, metadata).

## Out of scope (MVP)

- Feed khám phá, tìm kiếm trip public, follow/like/bình luận.
- Sao chép trip public làm mẫu (mô hình ngày + giờ địa phương đã cho phép dời ngày về sau).
- Bản đồ, nhiều loại tiền / quy đổi tỉ giá, nhiều ảnh / album.

## Open questions

- (không còn)
