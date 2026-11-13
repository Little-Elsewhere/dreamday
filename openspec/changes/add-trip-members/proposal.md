# Proposal

## Why

Trip là không gian chung của một nhóm, nên cần cách đưa người khác vào trip và phân quyền rõ ràng. Nhóm bạn ở Việt Nam hay chia sẻ qua Zalo/Messenger (cần link), nhưng cũng cần mời đích danh qua email.

## What Changes

- Hai vai trò: **owner** (người tạo trip) và **member**. Không có vai trò chỉ xem.
- **Viewer** là bất kỳ ai không phải thành viên của trip (không phải một vai trò trong trip): người dùng đã đăng nhập hoặc khách chưa có tài khoản. Cả hai chỉ xem được trip public, qua cùng một góc nhìn công khai; trip private thì không xem được.
- Hai cách mời, dùng chung một mô hình lời mời (token lưu dạng hash, hạn dùng, thu hồi); mọi lời mời đều cấp vai trò member:
  - **Link mời**: không gắn email, dùng nhiều lần, mỗi trip **chỉ 1 link đang hoạt động** (tạo link mới thì link cũ hết hiệu lực), owner thu hồi được.
  - **Email mời**: gắn với 1 email, dùng 1 lần, hệ thống gửi email. Người chưa có tài khoản đăng ký bằng chính email đó rồi tham gia. Email người được mời **được mã hóa khi lưu** và so khớp bằng giá trị băm có khóa (HMAC), như email tài khoản trong `user-auth`.
- Lời mời email **chỉ chấp nhận được khi đăng nhập bằng đúng email được mời**; sai email thì báo rõ lời mời dành cho email nào.
- Hạn dùng mặc định của lời mời: **7 ngày**.
- Luồng chấp nhận: mở link → (đăng nhập / đăng ký, giữ nguyên link) → xác nhận "Tham gia trip X?" → trở thành member. Người đã là thành viên mở lại lời mời thì được chuyển thẳng vào trip.
- Owner quản lý thành viên (xóa thành viên) và lời mời.
- Xóa thành viên và thu hồi lời mời là **soft delete / đánh dấu thu hồi**, không xóa bản ghi; mời lại người đã bị xóa vẫn được.
- Member **tự rời trip** được, và owner **xóa thành viên** được, **kể cả khi số dư khác 0**. Người rời/bị xóa **mất toàn bộ quyền truy cập trip** (kể cả không xem được số dư của mình) nhưng **vẫn được giữ trong sổ chi tiêu dưới dạng "đã rời"** (xem `trip-expenses`); các mục checklist đang giao cho họ trở về **không giao cho ai** (xem `trip-checklists`). Owner không rời được (chưa có chuyển quyền owner trong MVP).
- Mời lại người đã rời thì họ trở lại với **cùng danh tính trong sổ chi tiêu** (số dư cũ được giữ nguyên, không tạo người mới).
- Email của thành viên **chỉ owner thấy**; member chỉ thấy tên hiển thị + avatar.

### Ma trận quyền

| Hành động | Owner | Member | Viewer (trip public) |
|---|---|---|---|
| Xem thông tin trip, lịch trình | ✓ | ✓ | ✓ |
| Xem checklist (theo ranh giới dữ liệu) | ✓ | ✓ | ✓ |
| Xem chi phí (theo ranh giới dữ liệu) | ✓ | ✓ | ✓ |
| Xem danh sách thành viên | ✓ | ✓ | ✗ |
| Xem số dư, "ai nợ ai", đã trả nợ | ✓ | ✓ | ✗ |
| Thêm/sửa lịch trình, checklist | ✓ | ✓ | ✗ |
| Thêm khoản chi, được chia tiền | ✓ | ✓ | ✗ |
| Sửa/xóa khoản chi | ✓ | Chỉ khoản mình tạo | ✗ |
| Thêm/đổi tên/xóa category chi phí | ✓ | ✓ | ✗ |
| Hoàn tác thanh toán đã ghi nhận | ✓ | Chỉ thanh toán mình bấm | ✗ |
| Sửa trip, đổi public/private | ✓ | ✗ | ✗ |
| Quản lý thành viên và lời mời | ✓ | ✗ | ✗ |

## Capabilities

### New Capabilities
- `trip-membership`: vai trò, ma trận quyền, lời mời qua link và email, chấp nhận lời mời, quản lý thành viên.

### Modified Capabilities
- (không có)

## Impact

- Phụ thuộc `trips`, `user-auth` (đăng ký/đăng nhập giữ lại link mời), `user-profile` (tên hiển thị + avatar), gửi email.
- Danh sách thành viên hiển thị tên + avatar; chỉ owner thấy email.
- `trip-expenses` cần biết thành viên nào đang hoạt động / đã rời.

## Out of scope (MVP)

- Chuyển quyền owner, nhiều owner.
- Vai trò thành viên chỉ xem (được mời vào trip nhưng không được sửa).
- Lời mời đang chờ hiển thị trong hộp thư của người nhận trong app.

## Open questions

- (không còn)
