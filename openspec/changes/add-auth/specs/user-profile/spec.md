# Spec Delta

## Purpose

Quản lý danh tính hiển thị của người dùng (tên hiển thị, avatar) dùng ở mọi nơi trong app và ở góc nhìn công khai, đồng thời bảo đảm email không bị lộ ra ngoài.

## ADDED Requirements

### Requirement: USER-PROFILE-R1 Xem hồ sơ của chính mình
Người dùng đã đăng nhập SHALL xem hồ sơ của mình gồm email, tên hiển thị, avatar và thời điểm tạo tài khoản.

#### Scenario: USER-PROFILE-S1 Mở trang hồ sơ
- **GIVEN** người dùng đã đăng nhập
- **WHEN** họ mở trang hồ sơ
- **THEN** hệ thống hiển thị email, tên hiển thị, avatar và ngày tạo tài khoản của họ

#### Scenario: USER-PROFILE-S2 Mở trang hồ sơ khi chưa đăng nhập
- **WHEN** khách mở trang hồ sơ
- **THEN** hệ thống chuyển tới trang đăng nhập (theo USER-AUTH-R13)

### Requirement: USER-PROFILE-R2 Đổi tên hiển thị
Người dùng đã đăng nhập SHALL đổi tên hiển thị của mình. Tên MUST được bỏ khoảng trắng hai đầu và dài 1–50 ký tự. Người dùng MUST NOT đổi được hồ sơ của người khác.

#### Scenario: USER-PROFILE-S3 Đổi tên hợp lệ
- **WHEN** người dùng đổi tên hiển thị thành `  Bình Nguyễn  `
- **THEN** tên hiển thị được lưu là `Bình Nguyễn` và hiển thị ở mọi nơi dùng tên của họ

#### Scenario: USER-PROFILE-S4 Tên không hợp lệ
- **WHEN** người dùng đổi tên hiển thị thành chuỗi rỗng hoặc dài 51 ký tự
- **THEN** hệ thống từ chối, báo lỗi ở trường tên và giữ tên cũ

#### Scenario: USER-PROFILE-S5 Không sửa được hồ sơ người khác
- **WHEN** người dùng gửi yêu cầu đổi tên hiển thị của một người dùng khác
- **THEN** hệ thống từ chối và hồ sơ người kia không đổi

### Requirement: USER-PROFILE-R3 Upload avatar
Người dùng đã đăng nhập SHALL upload avatar dạng JPEG, PNG hoặc WebP, tối đa 5 MB. Định dạng MUST được xác định từ nội dung file, không theo tên hay loại do client khai báo. Ảnh lưu MUST là WebP vuông 512×512, đã xóa toàn bộ metadata (bao gồm vị trí GPS); ảnh không vuông được cắt vuông ở giữa.

#### Scenario: USER-PROFILE-S6 Upload ảnh hợp lệ
- **WHEN** người dùng upload ảnh JPEG 3 MB chụp từ điện thoại có chứa vị trí GPS
- **THEN** avatar mới là ảnh WebP 512×512
- **AND** ảnh được phục vụ không còn metadata nào, kể cả vị trí GPS

#### Scenario: USER-PROFILE-S7 Ảnh không vuông
- **WHEN** người dùng upload ảnh 1200×800
- **THEN** avatar là phần vuông ở giữa ảnh, kích thước 512×512

#### Scenario: USER-PROFILE-S8 File quá lớn
- **WHEN** người dùng upload ảnh 6 MB
- **THEN** hệ thống từ chối với thông báo vượt quá 5 MB và giữ avatar cũ

#### Scenario: USER-PROFILE-S9 File giả dạng ảnh
- **WHEN** người dùng upload một file PDF đổi tên thành `avatar.png`
- **THEN** hệ thống từ chối với thông báo định dạng không hỗ trợ và giữ avatar cũ

### Requirement: USER-PROFILE-R4 Phục vụ avatar
Avatar MUST được phục vụ công khai qua một URL không đoán được, xem được mà không cần đăng nhập và cache được lâu dài. Khi avatar bị thay hoặc gỡ, ảnh cũ MUST không còn xem được qua URL cũ; dữ liệu ảnh cũ MUST được giữ lại (không xóa vĩnh viễn).

#### Scenario: USER-PROFILE-S10 Xem avatar khi chưa đăng nhập
- **GIVEN** người dùng có avatar
- **WHEN** khách chưa đăng nhập mở URL avatar đó
- **THEN** ảnh được hiển thị

#### Scenario: USER-PROFILE-S11 URL avatar cũ sau khi thay ảnh
- **GIVEN** người dùng đã thay avatar
- **WHEN** ai đó mở URL của avatar cũ
- **THEN** ảnh cũ không còn hiển thị

### Requirement: USER-PROFILE-R5 Gỡ avatar và avatar mặc định
Người dùng SHALL gỡ avatar của mình. Người dùng không có avatar MUST được hiển thị avatar mặc định tạo từ chữ cái đầu của tên hiển thị trên nền màu cố định theo từng người dùng.

#### Scenario: USER-PROFILE-S12 Gỡ avatar
- **GIVEN** người dùng có avatar
- **WHEN** họ gỡ avatar
- **THEN** mọi nơi hiển thị avatar mặc định từ chữ cái đầu của họ

#### Scenario: USER-PROFILE-S13 Avatar mặc định ổn định
- **GIVEN** người dùng "An" không có avatar
- **WHEN** avatar của An được hiển thị ở hai trang khác nhau
- **THEN** cả hai nơi hiện chữ "A" trên cùng một màu nền

### Requirement: USER-PROFILE-R6 Hồ sơ công khai không chứa email
Ở mọi nơi hồ sơ của một người được hiển thị cho người khác (bao gồm góc nhìn công khai), hệ thống MUST chỉ trả về tên hiển thị và avatar; email MUST NOT xuất hiện, trừ những nơi spec khác cho phép rõ ràng.

#### Scenario: USER-PROFILE-S14 Tác giả trip công khai
- **WHEN** khách chưa đăng nhập xem một trip công khai
- **THEN** tác giả hiển thị bằng tên hiển thị và avatar
- **AND** phản hồi không chứa email của tác giả

### Requirement: USER-PROFILE-R7 Tên hiển thị được mã hóa khi lưu
Tên hiển thị MUST được mã hóa trước khi lưu vào database và MUST NOT xuất hiện ở dạng rõ trong bất kỳ bảng nào, kể cả khi tên được hiển thị công khai. Hệ thống MUST giải mã được tên để hiển thị ở mọi nơi spec cho phép.

#### Scenario: USER-PROFILE-S15 Đăng ký và đổi tên không lưu tên dạng rõ
- **GIVEN** khách đăng ký với tên hiển thị `Nguyễn Văn An`
- **WHEN** người dùng đổi tên hiển thị thành `Bình Nguyễn`
- **THEN** không bảng nào trong database chứa chuỗi `Nguyễn Văn An` hay `Bình Nguyễn`
- **AND** trang hồ sơ của họ hiển thị `Bình Nguyễn`
