# Proposal

## Why

Nhóm đi du lịch thường ai tiện thì trả trước, sau đó cần biết ai nợ ai. Người tham khảo trip công khai cũng cần biết chuyến đi tốn bao nhiêu, vào việc gì, để chuẩn bị tài chính.

## What Changes

- Mô hình **chia chi phí** (kiểu Splitwise), **một loại tiền tệ mỗi trip** (lấy từ trip).
- Tiền lưu bằng **số nguyên theo đơn vị nhỏ nhất + mã tiền tệ**, không dùng số thực (VND/JPY không có phần lẻ).
- Khoản chi: tiêu đề, số tiền, ngày, **category**, ghi chú, **đúng 1 người trả**, chia cho một tập thành viên.
- **Category tùy chỉnh theo trip**: trip mới có sẵn bộ mặc định (lưu trú, di chuyển, ăn uống, hoạt động, mua sắm, khác); owner/member thêm, đổi tên, xóa (soft delete) category. Khoản chi giữ tham chiếu category kể cả khi category bị xóa. Tên category mặc định **dịch theo ngôn ngữ** đang chọn; category người dùng tự tạo **hiển thị nguyên văn**.
- Hai cách chia: **chia đều** (mặc định) hoặc **số tiền cụ thể** cho từng người (tổng phải bằng số tiền khoản chi). Phần lẻ khi chia đều dồn cho người trả.
- Chỉ owner và member **đang hoạt động** là người trả / được chia trong khoản chi mới; viewer không tham gia chia tiền.
- Thành viên **đã rời / bị xóa** vẫn nằm trong sổ chi tiêu với nhãn **"đã rời"**: các khoản chi cũ giữ nguyên họ, họ vẫn có số dư, vẫn xuất hiện trong gợi ý thanh toán, và **thanh toán với họ vẫn ghi nhận được**: người đã rời là người trả thì người nhận đang hoạt động bấm "Đã nhận"; người đã rời là người nhận thì owner bấm thay (người đã rời không truy cập được trip). Không thêm được người đã rời vào khoản chi mới; sửa khoản chi cũ vẫn giữ được người đã rời đang có trong đó.
- Mọi owner/member thêm được khoản chi; chỉ người tạo hoặc owner sửa/xóa.
- **Số dư** = đã trả − phần phải chịu ± các thanh toán **đã ghi nhận** (không tính thanh toán đã hoàn tác); **gợi ý thanh toán** với số giao dịch tối thiểu.
- Hệ thống chỉ **tính toán** ai cần trả ai bao nhiêu, **không quản lý giao dịch**. Chuyển thiếu/chuyển dư do các thành viên tự xử lý với nhau.
- Trên mỗi gợi ý thanh toán, **chỉ người nhận** bấm **"Đã nhận"**: hệ thống ghi nhận một thanh toán **đúng bằng số tiền của gợi ý** và tính lại số dư. Nếu người nhận đã rời trip, **owner bấm thay**.
- Không có trạng thái chờ, xác nhận hai bên, nhập số tiền, trả một phần hay giao dịch điều chỉnh.
- Bấm nhầm thì **"Hoàn tác"** (người đã bấm hoặc owner): thanh toán bị soft delete và số dư được tính lại.
- **Tóm tắt chi phí**: tổng, chi phí/người (tổng ÷ số người tham gia chia), theo category.
- Xóa khoản chi là **soft delete** (số dư tính lại không tính khoản đã xóa); ngay sau khi xóa có nút **"Hoàn tác"** để khôi phục trên UI.

### Ranh giới dữ liệu

| Dữ liệu | Owner/Member | Viewer | Người ngoài (trip public) |
|---|---|---|---|
| Tiêu đề, số tiền, ngày, category | ✓ | ✓ | ✓ |
| Tổng, chi phí/người, theo category | ✓ | ✓ | ✓ |
| Ai trả, chia cho ai | ✓ | ✗ | ✗ |
| Ghi chú khoản chi | ✓ | ✗ | ✗ |
| Số dư, "ai nợ ai", đã trả nợ | ✓ | ✗ | ✗ |

Viewer và người ngoài dùng chung một góc nhìn chi phí.

## Capabilities

### New Capabilities
- `trip-expenses`: khoản chi, cách chia, số dư, gợi ý và ghi nhận thanh toán, tóm tắt chi phí, ranh giới dữ liệu.

### Modified Capabilities
- (không có)

## Impact

- Phụ thuộc `trips` (tiền tệ, khóa tiền tệ sau khoản chi đầu tiên), `trip-membership` (người trả/được chia phải là owner/member).
- Cần trạng thái hoạt động / đã rời của thành viên từ `trip-membership`; sổ chi tiêu tham chiếu người dùng (không phải bản ghi membership) để giữ liên tục khi được mời lại.
- Định dạng tiền theo locale (vi/en) ở frontend.

## Out of scope (MVP)

- Nhiều loại tiền, quy đổi tỉ giá, chia theo phần trăm/tỉ lệ, nhiều người cùng trả, đính kèm hóa đơn, quỹ chung.
- Quản lý giao dịch thanh toán (xác nhận hai bên, trả một phần, chuyển tiền trong app).

## Open questions

- (không còn)
