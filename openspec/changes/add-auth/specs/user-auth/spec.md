# Spec Delta

## Purpose

Cho phép người dùng tạo tài khoản bằng email + mật khẩu, chứng minh quyền sở hữu email, đăng nhập an toàn và quản lý mật khẩu, làm nền xác định danh tính cho mọi tính năng khác.

## ADDED Requirements

### Requirement: USER-AUTH-R1 Đăng ký tài khoản
Hệ thống SHALL cho phép khách chưa đăng nhập đăng ký bằng email, mật khẩu và tên hiển thị. Email MUST được chuẩn hóa (bỏ khoảng trắng hai đầu, chuyển chữ thường) trước khi lưu và so sánh. Tài khoản mới MUST ở trạng thái chưa xác thực email và hệ thống MUST gửi email xác thực.

#### Scenario: USER-AUTH-S1 Đăng ký hợp lệ
- **GIVEN** email `An@Example.com ` chưa có tài khoản
- **WHEN** khách đăng ký với email đó, mật khẩu hợp lệ và tên hiển thị "An"
- **THEN** hệ thống tạo tài khoản với email `an@example.com`, trạng thái chưa xác thực
- **AND** gửi email xác thực tới `an@example.com`
- **AND** hiển thị màn hình "Kiểm tra email của bạn"

#### Scenario: USER-AUTH-S2 Đăng ký khi đã đăng nhập
- **WHEN** người dùng đang đăng nhập mở trang đăng ký
- **THEN** hệ thống chuyển họ về trang chính của app thay vì cho đăng ký

### Requirement: USER-AUTH-R2 Đăng ký không tiết lộ email đã tồn tại
Phản hồi đăng ký MUST giống hệt nhau dù email đã có tài khoản hay chưa. Khi email đã có tài khoản, hệ thống MUST NOT tạo tài khoản mới hay thay đổi mật khẩu, mà gửi email thông báo phù hợp tới địa chỉ đó.

#### Scenario: USER-AUTH-S3 Đăng ký bằng email đã xác thực
- **GIVEN** `an@example.com` đã có tài khoản đã xác thực
- **WHEN** khách đăng ký với `an@example.com`
- **THEN** hệ thống hiển thị cùng màn hình "Kiểm tra email của bạn" như USER-AUTH-S1
- **AND** không thay đổi tài khoản hiện có
- **AND** gửi tới `an@example.com` email cho biết đã có tài khoản, kèm lối đăng nhập và quên mật khẩu

#### Scenario: USER-AUTH-S4 Đăng ký bằng email chưa xác thực
- **GIVEN** `an@example.com` đã có tài khoản chưa xác thực
- **WHEN** khách đăng ký lại với `an@example.com` và một mật khẩu khác
- **THEN** hệ thống hiển thị cùng màn hình như USER-AUTH-S1
- **AND** không thay đổi mật khẩu của tài khoản hiện có
- **AND** gửi lại email xác thực (theo giới hạn của USER-AUTH-R5)

### Requirement: USER-AUTH-R3 Kiểm tra dữ liệu đăng ký
Hệ thống MUST từ chối đăng ký khi email sai định dạng, tên hiển thị (sau khi bỏ khoảng trắng hai đầu) ngoài khoảng 1–50 ký tự, hoặc mật khẩu không đạt quy tắc: dài 8–128 ký tự và có ít nhất 1 chữ hoa, 1 chữ thường, 1 chữ số, 1 ký tự đặc biệt. Chữ hoa/thường tính theo Unicode (kể cả chữ có dấu); ký tự đặc biệt là ký tự không phải chữ cái, chữ số hay khoảng trắng. Hệ thống MUST chỉ ra trường lỗi và mọi quy tắc mật khẩu chưa đạt.

#### Scenario: USER-AUTH-S5 Mật khẩu quá ngắn
- **WHEN** khách đăng ký với mật khẩu `Dl@t123` (7 ký tự)
- **THEN** hệ thống từ chối và báo lỗi độ dài ở trường mật khẩu
- **AND** không tạo tài khoản, không gửi email

#### Scenario: USER-AUTH-S6 Mật khẩu quá dài
- **WHEN** khách đăng ký với mật khẩu 129 ký tự (có đủ chữ hoa, chữ thường, chữ số, ký tự đặc biệt)
- **THEN** hệ thống từ chối và báo lỗi độ dài ở trường mật khẩu

#### Scenario: USER-AUTH-S7 Mật khẩu thiếu nhiều loại ký tự
- **WHEN** khách đăng ký với mật khẩu `dalatmuadong` (chỉ chữ thường)
- **THEN** hệ thống từ chối và báo thiếu chữ hoa, thiếu chữ số và thiếu ký tự đặc biệt cùng lúc

#### Scenario: USER-AUTH-S8 Mật khẩu thiếu chữ thường
- **WHEN** khách đăng ký với mật khẩu `DALAT@2026`
- **THEN** hệ thống từ chối và báo thiếu chữ thường

#### Scenario: USER-AUTH-S9 Khoảng trắng không tính là ký tự đặc biệt
- **WHEN** khách đăng ký với mật khẩu `Da lat 2026`
- **THEN** hệ thống từ chối và báo thiếu ký tự đặc biệt

#### Scenario: USER-AUTH-S10 Mật khẩu hợp lệ có chữ tiếng Việt
- **WHEN** khách đăng ký với mật khẩu `Đà Lạt mùa đông 2026!`
- **THEN** hệ thống chấp nhận mật khẩu (`Đ` là chữ hoa, `2` là chữ số, `!` là ký tự đặc biệt)

#### Scenario: USER-AUTH-S11 Tên hiển thị chỉ có khoảng trắng
- **WHEN** khách đăng ký với tên hiển thị `"   "`
- **THEN** hệ thống từ chối và báo lỗi ở trường tên hiển thị

#### Scenario: USER-AUTH-S12 Email sai định dạng
- **WHEN** khách đăng ký với email `an@`
- **THEN** hệ thống từ chối và báo lỗi ở trường email

### Requirement: USER-AUTH-R4 Xác thực email
Email xác thực MUST chứa một link dùng một lần, hết hạn sau 15 phút. Mở link hợp lệ MUST đánh dấu email đã xác thực. Link đã dùng, hết hạn, hoặc đã bị thay bằng link mới hơn MUST bị từ chối với thông báo cho phép yêu cầu link mới.

#### Scenario: USER-AUTH-S13 Mở link xác thực hợp lệ
- **GIVEN** tài khoản chưa xác thực và link xác thực còn hạn
- **WHEN** người dùng mở link
- **THEN** tài khoản được đánh dấu đã xác thực
- **AND** hệ thống hiển thị thông báo thành công kèm lối đăng nhập

#### Scenario: USER-AUTH-S14 Mở link đã dùng
- **GIVEN** link xác thực đã được dùng
- **WHEN** người dùng mở lại link
- **THEN** hệ thống báo link không còn hiệu lực và không thay đổi tài khoản

#### Scenario: USER-AUTH-S15 Mở link hết hạn
- **GIVEN** link xác thực được gửi hơn 15 phút trước
- **WHEN** người dùng mở link
- **THEN** hệ thống báo link đã hết hạn và cho phép yêu cầu link mới

#### Scenario: USER-AUTH-S16 Link cũ sau khi đã gửi lại
- **GIVEN** người dùng đã yêu cầu gửi lại email xác thực
- **WHEN** họ mở link trong email cũ hơn
- **THEN** hệ thống báo link không còn hiệu lực
- **AND** link trong email mới nhất vẫn dùng được

### Requirement: USER-AUTH-R5 Gửi lại email xác thực
Khách SHALL yêu cầu gửi lại email xác thực bằng email của họ. Phản hồi MUST giống hệt nhau dù email tồn tại, đã xác thực hay chưa. Hệ thống MUST gửi tối đa một email xác thực cho mỗi tài khoản trong mỗi 60 giây, và mỗi lần gửi mới MUST vô hiệu các link xác thực trước đó.

#### Scenario: USER-AUTH-S17 Gửi lại cho tài khoản chưa xác thực
- **GIVEN** tài khoản `an@example.com` chưa xác thực, lần gửi gần nhất cách đây hơn 60 giây
- **WHEN** khách yêu cầu gửi lại cho `an@example.com`
- **THEN** hệ thống gửi email xác thực mới và báo "Nếu email tồn tại, chúng tôi đã gửi link"

#### Scenario: USER-AUTH-S18 Gửi lại quá nhanh
- **GIVEN** email xác thực vừa được gửi cho `an@example.com` 20 giây trước
- **WHEN** khách yêu cầu gửi lại
- **THEN** hệ thống không gửi thêm email
- **AND** phản hồi giống hệt USER-AUTH-S17

#### Scenario: USER-AUTH-S19 Gửi lại cho email không tồn tại hoặc đã xác thực
- **WHEN** khách yêu cầu gửi lại cho email không có tài khoản hoặc đã xác thực
- **THEN** hệ thống không gửi email xác thực
- **AND** phản hồi giống hệt USER-AUTH-S17

### Requirement: USER-AUTH-R6 Đăng nhập
Hệ thống SHALL đăng nhập người dùng khi email và mật khẩu đúng và email đã xác thực, tạo một phiên đăng nhập mới. Email sai hoặc mật khẩu sai MUST cho cùng một thông báo lỗi. Đúng mật khẩu nhưng chưa xác thực email MUST không tạo phiên và hướng dẫn xác thực.

#### Scenario: USER-AUTH-S20 Đăng nhập thành công
- **GIVEN** tài khoản đã xác thực `an@example.com`
- **WHEN** người dùng đăng nhập với ` AN@example.com` và đúng mật khẩu
- **THEN** hệ thống tạo phiên đăng nhập và chuyển vào app

#### Scenario: USER-AUTH-S21 Sai mật khẩu và email không tồn tại cho cùng thông báo
- **WHEN** người dùng đăng nhập với email đúng nhưng sai mật khẩu, hoặc với email không có tài khoản
- **THEN** cả hai trường hợp đều nhận cùng thông báo "Email hoặc mật khẩu không đúng"
- **AND** không tạo phiên

#### Scenario: USER-AUTH-S22 Đúng mật khẩu nhưng chưa xác thực email
- **GIVEN** tài khoản `an@example.com` chưa xác thực
- **WHEN** người dùng đăng nhập với đúng mật khẩu
- **THEN** hệ thống không tạo phiên
- **AND** báo cần xác thực email và cho phép gửi lại email xác thực

### Requirement: USER-AUTH-R7 Khóa đăng nhập sau nhiều lần sai
Hệ thống MUST đếm số lần đăng nhập sai liên tiếp theo từng email đã chuẩn hóa (kể cả email không có tài khoản), không theo IP. Sau 5 lần sai liên tiếp, mọi lần đăng nhập vào email đó MUST bị từ chối trong 30 phút, kể cả khi đúng mật khẩu. Đăng nhập thành công MUST đặt lại bộ đếm về 0.

#### Scenario: USER-AUTH-S23 Bị khóa ở lần sai thứ 5
- **GIVEN** `an@example.com` đã đăng nhập sai 4 lần liên tiếp
- **WHEN** người dùng đăng nhập sai lần thứ 5
- **THEN** email đó bị khóa đăng nhập 30 phút
- **AND** hệ thống báo rõ đăng nhập tạm khóa và gợi ý đặt lại mật khẩu để mở khóa ngay

#### Scenario: USER-AUTH-S24 Đúng mật khẩu trong lúc bị khóa
- **GIVEN** `an@example.com` đang bị khóa đăng nhập
- **WHEN** người dùng đăng nhập với đúng mật khẩu
- **THEN** hệ thống từ chối với cùng thông báo tạm khóa và không tạo phiên

#### Scenario: USER-AUTH-S25 Hết thời gian khóa
- **GIVEN** `an@example.com` bị khóa từ hơn 30 phút trước
- **WHEN** người dùng đăng nhập với đúng mật khẩu
- **THEN** đăng nhập thành công và bộ đếm về 0

#### Scenario: USER-AUTH-S26 Đăng nhập thành công đặt lại bộ đếm
- **GIVEN** `an@example.com` đã sai 3 lần liên tiếp
- **WHEN** người dùng đăng nhập thành công rồi sau đó sai thêm 4 lần
- **THEN** email đó chưa bị khóa

#### Scenario: USER-AUTH-S27 Email không tồn tại cũng bị khóa như nhau
- **WHEN** ai đó đăng nhập sai 5 lần với email không có tài khoản
- **THEN** lần thứ 5 nhận cùng thông báo tạm khóa như USER-AUTH-S23
- **AND** không thể dùng hành vi khóa để biết email có tồn tại hay không

### Requirement: USER-AUTH-R8 Phiên đăng nhập
Mỗi lần đăng nhập thành công MUST tạo một phiên riêng, nhận diện bằng một token ngẫu nhiên không đoán được, chỉ được lưu dạng hash phía server. Phiên MUST hết hạn khi không hoạt động 30 ngày; mỗi request hợp lệ MUST gia hạn thêm 30 ngày kể từ lúc đó. Trình duyệt MUST NOT đọc được token bằng JavaScript.

#### Scenario: USER-AUTH-S28 Phiên còn hoạt động được gia hạn
- **GIVEN** phiên được dùng lần cuối 29 ngày trước
- **WHEN** người dùng mở app
- **THEN** request được chấp nhận và phiên hết hạn sau 30 ngày kể từ lúc này

#### Scenario: USER-AUTH-S29 Phiên không hoạt động quá 30 ngày
- **GIVEN** phiên được dùng lần cuối 31 ngày trước
- **WHEN** người dùng mở một trang cần đăng nhập
- **THEN** hệ thống coi như chưa đăng nhập và chuyển tới trang đăng nhập

#### Scenario: USER-AUTH-S30 Nhiều thiết bị có phiên độc lập
- **GIVEN** người dùng đăng nhập trên laptop và điện thoại
- **WHEN** họ đăng xuất trên điện thoại
- **THEN** phiên trên laptop vẫn hoạt động

### Requirement: USER-AUTH-R9 Đăng xuất
Người dùng đã đăng nhập SHALL đăng xuất; hệ thống MUST thu hồi phiên hiện tại (đánh dấu thu hồi, không xóa bản ghi) để token đó không dùng được nữa.

#### Scenario: USER-AUTH-S31 Token sau khi đăng xuất không dùng được
- **GIVEN** người dùng đăng xuất
- **WHEN** một request dùng lại token của phiên đó
- **THEN** request bị coi như chưa đăng nhập

### Requirement: USER-AUTH-R10 Quên mật khẩu
Khách SHALL yêu cầu đặt lại mật khẩu bằng email. Phản hồi MUST giống hệt nhau dù email có tài khoản hay không. Với tài khoản tồn tại, hệ thống MUST gửi link đặt lại dùng một lần, hết hạn sau 15 phút, tối đa một email mỗi 60 giây; mỗi lần gửi mới MUST vô hiệu các link đặt lại trước đó.

#### Scenario: USER-AUTH-S32 Yêu cầu đặt lại cho email tồn tại
- **GIVEN** tài khoản `an@example.com` tồn tại
- **WHEN** khách yêu cầu đặt lại mật khẩu cho `an@example.com`
- **THEN** hệ thống gửi email chứa link đặt lại
- **AND** báo "Nếu email tồn tại, chúng tôi đã gửi link"

#### Scenario: USER-AUTH-S33 Yêu cầu đặt lại cho email không tồn tại
- **WHEN** khách yêu cầu đặt lại mật khẩu cho email không có tài khoản
- **THEN** hệ thống không gửi email
- **AND** phản hồi giống hệt USER-AUTH-S32

#### Scenario: USER-AUTH-S34 Yêu cầu lại quá nhanh
- **GIVEN** link đặt lại vừa được gửi cho `an@example.com` 20 giây trước
- **WHEN** khách yêu cầu lại
- **THEN** hệ thống không gửi thêm email và phản hồi giống hệt USER-AUTH-S32

### Requirement: USER-AUTH-R11 Đặt lại mật khẩu
Mở link đặt lại hợp lệ SHALL cho phép đặt mật khẩu mới theo quy tắc của USER-AUTH-R3. Đặt lại thành công MUST: thu hồi mọi phiên của tài khoản, mở khóa đăng nhập và đặt lại bộ đếm sai, đánh dấu email đã xác thực, và vô hiệu link. Link đã dùng, hết hạn hoặc đã bị thay MUST bị từ chối.

#### Scenario: USER-AUTH-S35 Đặt lại thành công
- **GIVEN** link đặt lại còn hạn
- **WHEN** người dùng đặt mật khẩu mới hợp lệ
- **THEN** mật khẩu được đổi và mọi phiên cũ bị thu hồi
- **AND** hệ thống chuyển tới trang đăng nhập với thông báo thành công

#### Scenario: USER-AUTH-S36 Đặt lại mở khóa đăng nhập
- **GIVEN** `an@example.com` đang bị khóa đăng nhập
- **WHEN** người dùng đặt lại mật khẩu thành công
- **THEN** người dùng đăng nhập được ngay bằng mật khẩu mới

#### Scenario: USER-AUTH-S37 Đặt lại xác thực luôn email
- **GIVEN** tài khoản chưa xác thực email
- **WHEN** người dùng đặt lại mật khẩu thành công qua link gửi tới email đó
- **THEN** tài khoản được đánh dấu đã xác thực

#### Scenario: USER-AUTH-S38 Link đặt lại hết hạn hoặc đã dùng
- **GIVEN** link đặt lại đã quá 15 phút hoặc đã được dùng
- **WHEN** người dùng mở link
- **THEN** hệ thống báo link không còn hiệu lực và cho phép yêu cầu link mới

### Requirement: USER-AUTH-R12 Đổi mật khẩu khi đã đăng nhập
Người dùng đã đăng nhập SHALL đổi mật khẩu khi nhập đúng mật khẩu hiện tại và mật khẩu mới hợp lệ. Đổi thành công MUST thu hồi mọi phiên khác và giữ phiên hiện tại.

#### Scenario: USER-AUTH-S39 Đổi mật khẩu thành công
- **GIVEN** người dùng đăng nhập trên laptop và điện thoại
- **WHEN** trên laptop họ đổi mật khẩu với đúng mật khẩu hiện tại
- **THEN** phiên trên laptop vẫn hoạt động và phiên trên điện thoại bị thu hồi

#### Scenario: USER-AUTH-S40 Sai mật khẩu hiện tại
- **WHEN** người dùng đổi mật khẩu với mật khẩu hiện tại sai
- **THEN** hệ thống từ chối, báo lỗi ở trường mật khẩu hiện tại và không đổi mật khẩu

### Requirement: USER-AUTH-R13 Truy cập trang cần đăng nhập
Trang và API cần đăng nhập MUST từ chối khi không có phiên hợp lệ. Với trang, hệ thống MUST chuyển tới đăng nhập và sau khi đăng nhập thành công quay lại đúng trang ban đầu.

#### Scenario: USER-AUTH-S41 Mở trang riêng khi chưa đăng nhập
- **WHEN** khách mở trang danh sách trip của mình
- **THEN** hệ thống chuyển tới trang đăng nhập
- **AND** sau khi đăng nhập thành công, người dùng quay lại trang danh sách trip

#### Scenario: USER-AUTH-S42 Gọi API cần đăng nhập khi chưa đăng nhập
- **WHEN** một request không có phiên hợp lệ gọi API cần đăng nhập
- **THEN** hệ thống từ chối với lỗi chưa xác thực và không trả dữ liệu

### Requirement: USER-AUTH-R14 Giữ đích quay lại qua đăng ký và đăng nhập
Luồng đăng ký, xác thực email và đăng nhập MUST giữ đích quay lại (ví dụ link mời vào trip) và đưa người dùng tới đó sau khi đăng nhập. Đích quay lại MUST chỉ là đường dẫn nội bộ của app; đích trỏ ra ngoài MUST bị bỏ qua.

#### Scenario: USER-AUTH-S43 Khách mở link mời rồi đăng ký
- **GIVEN** khách chưa có tài khoản mở link mời vào trip
- **WHEN** họ đăng ký, xác thực email rồi đăng nhập
- **THEN** sau khi đăng nhập họ được đưa tới trang chấp nhận lời mời đó

#### Scenario: USER-AUTH-S44 Đích quay lại trỏ ra ngoài
- **WHEN** trang đăng nhập được mở với đích quay lại `https://evil.example`
- **THEN** sau khi đăng nhập hệ thống bỏ qua đích đó và chuyển vào trang chính của app

### Requirement: USER-AUTH-R15 Email theo ngôn ngữ người dùng
Email xác thực, đặt lại mật khẩu và thông báo tài khoản MUST được gửi bằng ngôn ngữ (tiếng Việt hoặc tiếng Anh) mà người dùng đang dùng khi thực hiện yêu cầu.

#### Scenario: USER-AUTH-S45 Đăng ký trên giao diện tiếng Việt
- **WHEN** khách đăng ký khi giao diện đang ở tiếng Việt
- **THEN** email xác thực được viết bằng tiếng Việt
