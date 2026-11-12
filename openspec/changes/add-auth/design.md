# Design

## Context

- Đây là change đầu tiên của bản dựng lại: chưa có người dùng, chưa có dữ liệu cần giữ. Code cũ trong `apps/*` chỉ để tham khảo (xem proposal.md - Why).
- Stack local đã có: PostgreSQL, Mailpit (SMTP), RustFS (S3), Nginx với `dreamday.local` → frontend, `api.dreamday.local` → backend, `media.dreamday.local` → RustFS.
- Yêu cầu hành vi nằm trong `specs/user-auth` và `specs/user-profile`; tài liệu này chỉ ghi các quyết định kỹ thuật không suy ra được từ spec.

## Goals / Non-Goals

**Goals:**
- Khung code mới, tối giản, đủ làm nền cho các change sau (trips, membership, …).
- Mọi scenario của change này có test tự động chạy được trên máy local và CI.

- Backend viết bằng Rust và đồng thời là dự án học Rust của người làm: ưu tiên code tường minh, dễ đọc hơn code ngắn gọn dùng nhiều macro hay trừu tượng.

**Non-Goals:**
- Hàng đợi việc nền (queue/worker), cache, rate limit theo IP, quan sát/metrics.
- Tách thư viện dùng chung giữa FE và BE (quy tắc validate được viết ở cả hai phía).
- Sinh tài liệu OpenAPI (frontend gọi backend qua vài endpoint, kiểu dữ liệu viết tay bằng zod).

## Decisions

### D0. Backend chuyển từ FastAPI sang Rust (axum)
Backend viết lại bằng Rust: `axum` (HTTP), `tokio` (async runtime), `sqlx` (PostgreSQL, migration), `serde` (JSON), `thiserror` (kiểu lỗi), `tracing` (log).
- Lý do: người làm muốn học Rust thật sự và chấp nhận chậm trong vài tháng đầu. Thời điểm đổi rẻ nhất vì chưa có code mới; spec không phụ thuộc ngôn ngữ.
- Thay vì: giữ FastAPI → nhanh hơn lúc đầu nhưng không đạt mục tiêu học.

### D1. Dựng lại trong chính hai submodule, gắn tag cho code cũ
Code cũ được gắn tag `legacy` trên remote rồi xóa khỏi nhánh `develop` ở task đầu tiên; bộ khung mới viết từ đầu.
- Thay vì: viết song song trong thư mục mới → hai bộ code cùng tồn tại, dễ nhầm và dễ "bê" code cũ sang. Tag giữ lại được mọi thứ để tham khảo.

### D2. Backend: một crate, tổ chức theo feature
Một crate duy nhất (không workspace), mỗi tính năng một thư mục, phần dùng chung ở `src/shared/`.
```
apps/backend/
├── Cargo.toml
├── migrations/               file SQL (từ task 1.4)
├── src/
│   ├── main.rs               chỉ khởi động: log, Config, AppState, mở cổng
│   ├── lib.rs                khai báo module + build_router(state)
│   ├── health.rs             GET /health
│   ├── shared/
│   │   ├── mod.rs
│   │   ├── config.rs         Config::from_env()
│   │   ├── state.rs          AppState
│   │   ├── error.rs          AppError
│   │   ├── clock.rs          trait Clock, SystemClock, FakeClock
│   │   ├── crypto.rs         (task 1.6)
│   │   ├── mailer.rs         (task 4.3)
│   │   └── storage.rs        (task 5.3)
│   ├── auth/                 routes.rs, service.rs, model.rs (nhóm task 4)
│   └── profile/              routes.rs, service.rs, model.rs (nhóm task 5)
└── tests/
    ├── common/mod.rs         dựng AppState giả cho test
    └── health.rs
```
- **`main.rs` mỏng, logic trong `lib.rs`.** `main.rs` chỉ khởi động; module và hàm `build_router(state)` nằm trong `src/lib.rs` để test trong `tests/` dựng được router với state giả (test tích hợp chỉ import được thư viện, không import được `main.rs`).
- **Thư mục dùng chung tên `shared`, không phải `core`.** Rust có sẵn crate `core`; một module cùng tên ở gốc crate làm `use core::…` thành mơ hồ và gây lỗi khó hiểu cho người mới.
- **Mỗi module tính năng có ba file.** `routes.rs` chứa handler axum và một hàm `pub fn router() -> Router<AppState>`; `service.rs` chứa logic và truy vấn sqlx; `model.rs` chứa struct dữ liệu. `lib.rs` gộp các router bằng `merge`, nên thêm tính năng chỉ là thêm một thư mục và một dòng trong `build_router`.
- **Ranh giới module.** Mỗi module chỉ truy vấn bảng của chính nó; module khác lấy dữ liệu qua hàm công khai trong `service.rs` của module đó, không viết SQL vào bảng của nhau; `src/shared/` không phụ thuộc module tính năng nào. Lý do: thêm tính năng là thêm thư mục mới, và sau này tách một module thành crate hay service riêng chỉ là di chuyển file.
- **`AppState`** là struct `Clone` truyền cho handler qua extractor `State` của axum. Task 1.3 có `config: Arc<Config>` và `clock: Arc<dyn Clock>`; các task sau thêm `db: PgPool`, `mailer`, `storage`, khóa mã hóa. Dịch vụ ngoài dùng `Arc<dyn Trait>` thay vì generic (`AppState<C: Clock>`) để chữ ký hàm ngắn và dễ đọc; chi phí gọi động không đáng kể so với I/O.
- **`Config`** đọc biến môi trường một lần trong `Config::from_env()` bằng `std::env::var`, trả `Result`; thiếu hoặc sai giá trị thì `main` in lỗi nêu tên biến và thoát. Không dùng crate config. Task 1.3 chỉ có `APP_PORT` (mặc định `8000`); app lắng nghe ở `0.0.0.0` để chạy được trong Docker.
- **`AppError`** là một `enum` (dùng `thiserror`) implement `IntoResponse`, trả lỗi dạng D14. Handler trả `Result<_, AppError>` và dùng `?`. Lỗi không lường trước (DB, I/O) thành biến thể `Internal`: ghi log chi tiết bằng `tracing`, chỉ trả mã `internal_error` cho client. Biến thể được thêm dần theo scenario.
- **`Clock`** có một hàm `now()` trả `DateTime<Utc>` của `chrono` (bật feature `chrono` của sqlx từ task 1.4). `FakeClock` (chỉnh được giờ) nằm trong `src/shared/clock.rs` chứ không trong `#[cfg(test)]`, vì test trong `tests/` không thấy được code `#[cfg(test)]` của thư viện.
- **`GET /health`** trả `200` với `{ "status": "ok" }` và không chạm DB; chỉ dùng cho healthcheck của Compose.
- **Log** bằng `tracing` + `tracing-subscriber`, khởi tạo trong `main.rs`.
- **Dependency của task 1.3:** `axum`, `tokio`, `serde`, `serde_json`, `thiserror`, `tracing`, `tracing-subscriber`, `chrono`; dev: `tower` (cho `oneshot`), `http-body-util` (đọc body trong test). Crate khác thêm ở task dùng tới nó.
- Truy vấn dùng `sqlx::query!`/`query_as!` để SQL được kiểm tra với schema lúc build; `.sqlx/` (cache truy vấn) được commit để build Docker/CI không cần DB.
- Migration là file SQL trong `migrations/`, chạy bằng `sqlx::migrate!()` khi app khởi động (sqlx tự giữ advisory lock); không cần service migrate riêng.
- Thay vì: ORM (SeaORM, Diesel) → thêm một lớp phải học, che mất SQL; tầng repository như code cũ → thêm một tầng chỉ để chuyển tiếp; workspace nhiều crate → chưa có vấn đề thời gian build để giải quyết; nhiều service (microservices) → một người làm, chưa có người dùng, nên chi phí vận hành và gọi qua mạng lớn hơn lợi ích.

### D3. Test backend chạy trên PostgreSQL thật
- `#[sqlx::test]` tạo một database riêng cho mỗi test trên Postgres của Compose và chạy sẵn migration; test gọi thẳng `Router` bằng `tower::ServiceExt::oneshot`, không mở cổng HTTP.
- Thời gian, gửi email và lưu file đi qua trait trong `AppState` (`Clock`, `Mailer`, `Storage`); test dùng bản giả (đồng hồ chỉnh được, mailer ghi vào bộ nhớ) để kiểm tra các mốc 60 giây / 15 phút / 30 phút / 30 ngày mà không phải chờ. Test tích hợp storage dùng RustFS thật.
- Tên test chứa ID scenario (ví dụ `user_auth_s23_locks_on_fifth_failure`).
- Frontend: Vitest cho logic thuần (validate mật khẩu, kiểm tra đích quay lại), Playwright cho luồng chính, đọc email qua API của Mailpit.

### D4. Mô hình dữ liệu
```
users           id, email_ciphertext, email_hmac (unique), password_hash,
                display_name_ciphertext, email_verified_at, avatar_key, created_at, updated_at
sessions        id, user_id, token_hash (unique), created_at, last_used_at,
                expires_at, revoked_at
email_tokens    id, user_id, purpose (verify_email | reset_password), token_hash (unique),
                created_at, expires_at, consumed_at, revoked_at
login_throttles email_hmac (PK), failed_count, locked_until, updated_at
```
- `email_ciphertext`, `email_hmac` và `display_name_ciphertext` là `bytea`, tính từ giá trị đã chuẩn hóa theo D15.
- `users` chưa có `deleted_at` vì xóa tài khoản nằm ngoài phạm vi; thêm khi có change xóa tài khoản.
- Một bảng `email_tokens` cho cả hai loại link vì chúng có cùng vòng đời (phát, hết hạn, dùng, bị thay). Phát link mới thì đặt `revoked_at` cho các link còn hiệu lực cùng `purpose`. Cooldown 60 giây kiểm tra bằng `created_at` của link gần nhất cùng `purpose`.
- `login_throttles` khóa theo email, không theo `user_id`, để email không có tài khoản cũng bị đếm và khóa (USER-AUTH-S27).

### D5. Token: ngẫu nhiên 256 bit, lưu SHA-256
Session token và token trong link email đều có 256 bit ngẫu nhiên; DB chỉ lưu SHA-256 của token.
Token sinh từ 32 byte của `rand` (CSPRNG của hệ điều hành), mã hóa base64url; hash bằng `sha2`.
- Thay vì: argon2/bcrypt cho token → token đã đủ ngẫu nhiên nên hash nhanh là đủ, và tra cứu được bằng index.
- Mật khẩu dùng argon2id (crate `argon2`). Hash và verify argon2 tốn CPU nên chạy trong `tokio::task::spawn_blocking` để không chặn runtime.

### D6. Chuẩn hóa Unicode
Mật khẩu và tên hiển thị được chuẩn hóa NFC (crate `unicode-normalization`) trước khi kiểm tra và lưu/hash. Độ dài tính theo số ký tự (`char`) sau NFC, không theo byte. Phân loại chữ hoa/thường/chữ số dùng `char::is_uppercase`, `is_lowercase`, `is_numeric` của Rust (theo Unicode).
- Lý do: cùng một chữ `ạ` có thể được bàn phím gửi ở dạng dựng sẵn hoặc tổ hợp; không chuẩn hóa thì người dùng gõ đúng mật khẩu vẫn bị báo sai khi đổi thiết bị.

### D7. Chống dò email bằng thời gian phản hồi
- Đăng nhập với email không có tài khoản vẫn chạy verify argon2 với một hash giả, để thời gian phản hồi tương đương email có tài khoản.
- Đăng ký / gửi lại xác thực / quên mật khẩu: gửi email trong một task `tokio::spawn` tách khỏi request, để việc có hay không gửi email không làm chênh thời gian phản hồi.
- Đếm sai đăng nhập dùng `INSERT … ON CONFLICT … DO UPDATE` trên `login_throttles` để nhiều request song song không làm sai bộ đếm. Trạng thái khóa được kiểm tra trước khi verify mật khẩu.

### D8. Gửi email trực tiếp qua SMTP, không có hàng đợi
`lettre` (async, tokio) gửi trong task `tokio::spawn` tách khỏi request; mẫu email viết bằng `askama` (template được kiểm tra lúc build), tách theo ngôn ngữ (`vi`, `en`). Ngôn ngữ lấy từ header `Accept-Language` mà frontend đặt bằng locale hiện tại của giao diện (USER-AUTH-R15).
- Thay vì: queue + worker → thêm hạ tầng; khi gửi lỗi người dùng đã có nút gửi lại.

### D9. Mở link trong email không tự dùng token
Link email trỏ tới trang frontend (`/{locale}/verify-email?token=…`, `/{locale}/reset-password?token=…`). Trang xác thực hiển thị nút "Xác thực email"; token chỉ bị dùng khi người dùng bấm (POST).
- Lý do: một số dịch vụ email (bộ lọc link an toàn) tự mở link để quét; nếu GET đã dùng token thì link chết trước khi người dùng bấm, đặc biệt nguy hiểm khi link chỉ sống 15 phút.

### D10. Phiên qua BFF
- Next.js gọi `POST /auth/login` phía server, nhận token trong body và tự đặt cookie `dd_session` (`HttpOnly`, `Secure`, `SameSite=Lax`, `Path=/`, `Max-Age` 30 ngày). Mỗi lần Next.js gọi backend thay cho người dùng, nó gửi `Authorization: Bearer <token>`.
- Backend không đặt cookie và không đọc cookie; mọi API cần đăng nhập chỉ nhận header `Authorization`.
- Mỗi request hợp lệ cập nhật `last_used_at` và `expires_at = now + 30 ngày` (một câu `UPDATE`). Next.js làm mới `Max-Age` của cookie trong `proxy.ts` để cookie không hết hạn trước phiên.
- Mutation đi qua Server Actions, vốn đã kiểm tra `Origin`; kết hợp `SameSite=Lax` là đủ chống CSRF, không cần token CSRF riêng.

### D11. Đích quay lại
Tham số `next` được chấp nhận chỉ khi bắt đầu bằng một `/` và không bắt đầu bằng `//` hoặc `/\`; ngược lại bị bỏ qua (USER-AUTH-R14). Khi đăng ký, `next` được gắn vào link xác thực trong email để giữ được đích kể cả khi người dùng mở email trên thiết bị khác, rồi được truyền tiếp sang trang đăng nhập.

### D12. Avatar
- Xử lý ảnh bằng crate `image`: nhận diện định dạng từ nội dung (`with_guessed_format`), chỉ nhận `JPEG`/`PNG`/`WEBP`, đặt `image::Limits` để chặn ảnh "bom giải nén", xoay theo orientation EXIF trước khi bỏ metadata, cắt vuông ở giữa, resize 512×512. Encode WebP **lossy** bằng crate `webp` (bọc libwebp) vì `image` chỉ ghi được WebP lossless (file lớn hơn nhiều). Ảnh encode lại từ pixel nên không mang theo metadata nào.
- Xử lý ảnh tốn CPU nên chạy trong `spawn_blocking`. Body upload bị giới hạn 5 MB bằng `DefaultBodyLimit` của axum.
- S3 dùng `aws-sdk-s3` với `force_path_style` để làm việc với RustFS.
- Lưu ở bucket công khai với key ngẫu nhiên `avatars/<uuid4>.webp`, header `Cache-Control: public, max-age=31536000, immutable`. URL = `MEDIA_PUBLIC_URL` + key.
- Thay/gỡ avatar: ghi key mới vào DB trước, sau đó chuyển file cũ sang bucket riêng tư (`archive/avatars/<user_id>/<key>`) bằng copy rồi xóa khỏi bucket công khai.
- Frontend chưa có công cụ cắt ảnh trong change này; server cắt vuông ở giữa theo USER-PROFILE-R3.
- Upload đi qua Server Action nên cần nâng `serverActions.bodySizeLimit` của Next.js lên 6 MB.

### D13. Avatar mặc định tính ở frontend
Chữ cái đầu và màu nền tính ở frontend từ tên hiển thị và `user.id` (hash id → một màu trong bảng màu cố định). Backend không lưu gì thêm.

### D14. Lỗi API dạng mã, dịch ở frontend
Backend trả lỗi dạng `{ "code": "...", "fields": { "<field>": ["<code>", …] } }`, ví dụ `password_missing_uppercase`. Frontend dịch mã sang tiếng Việt/Anh. Frontend cũng kiểm tra trước bằng zod để báo lỗi ngay khi gõ, nhưng backend luôn là nơi quyết định.

### D15. Mã hóa thông tin cá nhân ở tầng ứng dụng
Cột được mã hóa trong change này: `users.email_ciphertext`, `users.display_name_ciphertext`. Bảng `login_throttles` chỉ lưu `email_hmac`. Tên hiển thị không cần tra cứu hay unique nên không có cột HMAC.
- Mã hóa bằng AES-256-GCM (crate `aes-gcm`), nonce 12 byte ngẫu nhiên cho mỗi lần mã hóa. Giá trị lưu: `key_version (1 byte) ‖ nonce (12 byte) ‖ ciphertext + tag (16 byte)`. Change này chỉ có `key_version = 1`; byte này để sau đổi khóa được mà không phải đổi định dạng.
- Tra cứu và unique dùng `email_hmac = HMAC-SHA256(DATA_HMAC_KEY, email đã chuẩn hóa)` (crate `hmac` + `sha2`).
- Hai khóa riêng `DATA_ENCRYPTION_KEY` và `DATA_HMAC_KEY` (32 byte, base64) đọc từ biến môi trường vào `AppState`; thiếu hoặc sai độ dài thì app không khởi động. Code nằm trong `src/shared/crypto.rs` với ba hàm `encrypt`, `decrypt`, `hmac`.
- Thay vì: `pgcrypto` → khóa phải đi vào câu SQL nên dễ lộ qua log; chỉ mã hóa at-rest → người đọc được DB đang chạy hoặc bản dump vẫn thấy email; mã hóa deterministic thay cho HMAC → lộ việc hai dòng cùng giá trị và ít thư viện Rust hỗ trợ.
- Prod bật thêm mã hóa at-rest của nhà cung cấp DB (không cần code).

## Risks / Trade-offs

- [Server dừng sau khi trả response nhưng trước khi gửi xong email] → Email bị mất; người dùng bấm gửi lại. Chấp nhận được ở MVP.
- [Kẻ xấu cố tình nhập sai để khóa tài khoản người khác] → Đặt lại mật khẩu qua email mở khóa ngay (USER-AUTH-R11).
- [Link 15 phút hết hạn khi email đến chậm] → Trang báo hết hạn có sẵn nút gửi lại link mới.
- [Rust mới học nên chậm và dễ viết code khó đọc] → Task nhỏ, mỗi PR giải thích khái niệm Rust mới dùng; `cargo clippy -D warnings` và `cargo fmt` trong CI; tránh macro tự viết và generic khi chưa cần.
- [Build Rust trong Docker lâu] → Dùng `cargo-chef` để cache bước build dependency.
- [Crate `webp` cần libwebp (C)] → Dùng feature build tĩnh đi kèm crate; nếu vướng, tạm encode lossless rồi xử lý sau (không ảnh hưởng spec).
- [Mỗi request ghi vào bảng `sessions`] → Chấp nhận ở quy mô hiện tại; nếu thành điểm nghẽn thì chỉ gia hạn khi lần gia hạn trước đã quá một khoảng ngắn.
- [Mất khóa mã hóa] → Mọi email đã lưu không giải mã được nữa. Khóa prod phải được backup riêng (ví dụ password manager của team) và ghi rõ trong `README.md`.
- [Tên hiển thị đã mã hóa nên không tìm kiếm hay sắp xếp theo tên bằng SQL được] → Change này không cần; khi có tính năng cần (ví dụ tìm người dùng theo tên) thì quyết định trong change đó.
- [Kẻ tấn công chiếm được server app] → Có cả DB lẫn khóa nên mã hóa không bảo vệ được; ngoài phạm vi của D15.
- [Chuyển file avatar cũ thất bại sau khi DB đã cập nhật] → File cũ còn ở bucket công khai nhưng không còn được tham chiếu; ghi log để chuyển lại thủ công.

## Migration Plan

Không có dữ liệu cần chuyển. Database local được tạo lại từ đầu bằng migration `sqlx`; migration Alembic cũ đi theo tag `legacy`. Service `backend-migrate` trong Compose được bỏ vì app tự chạy migration khi khởi động (D2).
