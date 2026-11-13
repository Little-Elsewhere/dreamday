# Proposal

## Why

Nhóm cần lên lịch trình từng ngày của chuyến đi (ngày 1 đi đâu, ăn gì, chơi ở đâu…) bằng một công cụ lập lịch trực quan giống Google Calendar. Chuyến đi có thể qua nhiều quốc gia và múi giờ, nên một múi giờ cho cả trip sẽ sai với chặng bay hoặc khi đổi quốc gia.

## What Changes

### Schedule item

- Hai loại item:
  - **Có giờ**: bắt đầu = ngày + giờ địa phương + múi giờ IANA của nơi diễn ra; kết thúc (tùy chọn) có **múi giờ riêng** (mặc định bằng múi giờ bắt đầu), ví dụ bay HAN 23:30 (Asia/Ho_Chi_Minh) → NRT 06:30 (Asia/Tokyo).
  - **Cả ngày**: chỉ có ngày bắt đầu/kết thúc, **có thể kéo dài nhiều ngày** (ví dụ "Ngày 1: Hà Nội", "Lưu trú khách sạn A, ngày 1–3").
- Thuộc tính: tiêu đề, loại (bay, di chuyển, lưu trú, hoạt động, ăn uống, khác), địa điểm (text), ghi chú. **Ghi chú luôn được mã hóa khi lưu**; các trường khác là nội dung trip, để dạng rõ.
- Lưu tên múi giờ IANA (ví dụ `Asia/Tokyo`), không lưu offset cố định, để đúng với giờ mùa hè (DST). Backend tính sẵn thời điểm UTC của item có giờ để sắp xếp và kiểm tra.
- Múi giờ mặc định của item mới: múi giờ của item trước, nếu không có thì múi giờ mặc định của trip. Chọn múi giờ bằng ô tìm kiếm theo thành phố.
- Kiểm tra: thời điểm kết thúc (UTC) phải sau thời điểm bắt đầu; item cả ngày có ngày kết thúc ≥ ngày bắt đầu. Item nằm ngoài khoảng ngày của trip **được phép, chỉ cảnh báo**.

### Giao diện lịch (kiểu Google Calendar)

- Lưới giờ đặt mỗi item **theo giờ địa phương của chính nó** (giờ trên đồng hồ tại nơi diễn ra), có nhãn múi giờ trên item. Thời lượng hiển thị của item đổi múi giờ (ví dụ chuyến bay) là tương đối; cảnh báo trùng lịch cũng chỉ tương đối.
- Hàng **cả ngày** ở trên cùng cho item cả ngày, item nhiều ngày trải ngang qua các ngày.
- Theo thiết bị: **mobile** xem 1 ngày (vuốt để chuyển ngày); **tablet** xem 3 ngày; **laptop** xem cả tuần / cả khoảng ngày của trip. Mọi thiết bị có thêm chế độ **danh sách (agenda)** theo ngày.
- Lịch giới hạn trong khoảng ngày của trip; có vạch "bây giờ" khi chuyến đi đang diễn ra.
- Tương tác (owner/member):
  - Bấm ô trống để tạo item, bấm item để sửa qua hộp thoại.
  - **Kéo thả để dời** item và **kéo cạnh để đổi thời lượng**, hoạt động cả trên cảm ứng (nhấn giữ rồi kéo).
  - Khi dời/đổi thời lượng, item **giữ nguyên múi giờ** của nó; chỉ giờ địa phương thay đổi. Kéo cạnh của item có múi giờ kết thúc riêng thì đổi giờ kết thúc theo múi giờ kết thúc.
- Viewer (trip public) chỉ xem, không kéo thả.
- Xóa item là **soft delete**; ngay sau khi xóa có nút **"Hoàn tác"** để khôi phục trên UI.

### Ranh giới dữ liệu

| Dữ liệu | Owner/Member | Viewer (trip public) |
|---|---|---|
| Tiêu đề, loại, thời gian, múi giờ, địa điểm | ✓ | ✓ |
| Ghi chú | ✓ | ✗ |

## Capabilities

### New Capabilities
- `trip-schedule`: schedule item có giờ và cả ngày, mô hình thời gian đa múi giờ, giao diện lịch theo thiết bị, tạo/sửa/kéo thả/đổi thời lượng.

### Modified Capabilities
- (không có)

## Impact

- Phụ thuộc `trips` (khoảng ngày, múi giờ mặc định), `trip-membership` (quyền).
- Cần dữ liệu múi giờ IANA ở backend (zoneinfo) và frontend (Intl).
- Frontend cần một thư viện lịch hỗ trợ lưới giờ, hàng cả ngày, kéo thả/đổi thời lượng trên cảm ứng — chọn trong design.

## Out of scope (MVP)

- Gom item sắp tới của nhiều trip vào trang tổng quan.
- Bản đồ, tìm kiếm địa điểm, nhắc nhở/thông báo, đồng bộ lịch (iCal/Google Calendar), sự kiện lặp lại.
- Chế độ xem lưới theo một múi giờ cố định.

## Open questions

- (không còn)
