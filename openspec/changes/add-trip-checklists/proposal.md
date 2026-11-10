# Proposal

## Why

Chuẩn bị một chuyến đi có nhiều việc cần làm và cần phân công (đặt vé, xin visa, đặt phòng). Nhóm cần một nơi chung để theo dõi việc nào xong, ai phụ trách.

## What Changes

- Mỗi trip có **nhiều checklist chung của nhóm** (không có checklist cá nhân trong MVP).
- Mỗi checklist có tên và nhiều mục; mỗi mục có tên, trạng thái đã xong, ghi chú (tùy chọn).
- Mỗi mục **có thể giao cho 1 thành viên** của trip.
- Khi thành viên **bị xóa khỏi trip hoặc tự rời trip**, các mục đang giao cho họ trở về **không giao cho ai**. Khôi phục hoặc mời lại thành viên đó không tự giao lại các mục.
- Thứ tự **các checklist** và thứ tự **mục trong mỗi checklist** sắp xếp bằng **kéo thả** (owner/member), hoạt động cả trên cảm ứng.
- Owner và member tạo/sửa/xóa checklist và mục; viewer chỉ xem.
- Xóa checklist hoặc mục là **soft delete**; ngay sau khi xóa có nút **"Hoàn tác"** để khôi phục trên UI.

### Ranh giới dữ liệu

| Dữ liệu | Owner/Member | Viewer | Người ngoài (trip public) |
|---|---|---|---|
| Tên danh sách, tên mục | ✓ | ✓ | ✓ |
| Trạng thái đã xong | ✓ | ✓ | ✓ |
| Người được giao, người đánh dấu | ✓ | ✓ | ✗ |
| Ghi chú của mục | ✓ | ✓ | ✗ |

Ghi chú tự do luôn bị ẩn khỏi góc nhìn công khai vì không thể tự nhận biết thông tin nhạy cảm bên trong.

## Capabilities

### New Capabilities
- `trip-checklists`: checklist chung của trip, mục, giao việc, đánh dấu hoàn thành, ranh giới dữ liệu công khai.

### Modified Capabilities
- (không có)

## Impact

- Phụ thuộc `trips`, `trip-membership` (quyền, người được giao phải là thành viên).

## Out of scope (MVP)

- Checklist cá nhân, hạn chót, nhắc nhở, giao cho nhiều người.

## Open questions

- (không còn)
