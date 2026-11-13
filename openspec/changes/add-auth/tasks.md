# Tasks

Quy ước: task "test đỏ" chỉ viết test (phải chạy và FAIL vì chưa có code); task ngay sau nó viết code cho tới khi các test đó xanh. Tên test chứa ID scenario. Mỗi task là một PR (< ~400 dòng thay đổi).

## 1. Khung backend mới bằng Rust (`apps/backend`)

- [x] 1.1 Ghi cấu hình công cụ vào repo thay vì cài tay trên từng máy: `Brewfile` ở repo gốc (`rustup`, `sqlx-cli`, `openspec`, `gh`, Docker), `rust-toolchain.toml` trong `apps/backend` (`channel = "stable"`, kèm `clippy`, `rustfmt`, `rust-analyzer`), và mục Prerequisites trong `README.md` cho máy mới (`brew bundle`, thêm `$(brew --prefix rustup)/bin` vào `PATH` vì formula `rustup` là keg-only, copy file env); kiểm tra: `brew bundle check` báo đủ, `cargo --version` và `cargo clippy --version` chạy được trong `apps/backend`
- [x] 1.2 Gắn tag `legacy` cho code cũ, đẩy tag lên remote, xóa code Python và cấu hình Python (pyproject, uv, ruff, pre-commit, …) khỏi nhánh làm việc (D1); kiểm tra: `git ls-remote --tags origin legacy` có kết quả và repo chỉ còn file chung (LICENSE, `.gitignore`, `.github/`)
- [ ] 1.3 `cargo new` một crate, dựng axum theo D2: `src/main.rs`, `src/lib.rs` (`build_router`), `src/shared/` (`Config::from_env`, `AppState`, `AppError`, `Clock` với `SystemClock` và `FakeClock`), `src/health.rs`, `tests/common/`; viết test trước; kiểm tra: `cargo test` xanh với test `oneshot` gọi `/health` trả 200 và `{ "status": "ok" }`, đường dẫn không tồn tại trả 404 dạng D14, `Config::from_env` báo lỗi khi `APP_PORT` không phải số, `FakeClock` trả đúng giờ đã chỉnh; `cargo clippy -- -D warnings` và `cargo fmt --check` sạch
- [ ] 1.4 Kết nối PostgreSQL bằng `sqlx`, thư mục `migrations/` với migration gốc rỗng, chạy `sqlx::migrate!()` khi khởi động; kiểm tra: một `#[sqlx::test]` mẫu chạy xanh trên Postgres của Compose
- [ ] 1.5 Dockerfile dev và prod (cache dependency bằng `cargo-chef`), CI chạy `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test` với service Postgres, CD build image prod; kiểm tra: workflow CI xanh trên PR
- [ ] 1.6 `src/shared/crypto.rs` theo D15: `encrypt`/`decrypt` (AES-256-GCM, định dạng `key_version ‖ nonce ‖ ciphertext+tag`), `hmac` (HMAC-SHA256); đọc `DATA_ENCRYPTION_KEY`, `DATA_HMAC_KEY` vào config, thiếu hoặc sai độ dài thì không khởi động; kiểm tra: test mã hóa rồi giải mã ra đúng giá trị, hai lần mã hóa cho kết quả khác nhau, giải mã bằng khóa sai hoặc dữ liệu bị sửa thì lỗi, HMAC ổn định, config thiếu khóa thì báo lỗi

## 2. Khung frontend mới (`apps/frontend`)

- [ ] 2.1 Gắn tag `legacy`, đẩy tag, xóa code cũ khỏi nhánh làm việc (D1); kiểm tra như 1.2
- [ ] 2.2 Dựng khung Next.js App Router: next-intl (`vi`, `en`), font Be Vietnam Pro, shadcn/ui, layout responsive tối thiểu; kiểm tra: `pnpm build` thành công và `/vi`, `/en` hiển thị đúng ngôn ngữ
- [ ] 2.3 Hạ tầng test: Vitest cho logic thuần, Playwright với 3 viewport (mobile, tablet, laptop) và helper đọc email từ API Mailpit; kiểm tra: một test mẫu của mỗi loại chạy xanh

## 3. Hạ tầng dùng chung (repo gốc)

- [ ] 3.1 Thêm/sửa biến môi trường cho SMTP, bucket công khai và riêng tư, `MEDIA_PUBLIC_URL`, `APP_URL`, `DATA_ENCRYPTION_KEY`, `DATA_HMAC_KEY` (README hướng dẫn sinh khóa và backup khóa prod theo D15); chuyển service `backend` sang image Rust, bỏ service `backend-migrate` (D2), healthcheck không dùng Python; cập nhật `compose.yaml`, `nginx/`, `env/*/.env.example`, `README.md` cùng lúc; kiểm tra: `docker compose up` chạy đủ service, hai bucket tồn tại trên RustFS, file trong bucket công khai mở được qua `media.dreamday.local`

## 4. `user-auth` — backend

- [ ] 4.1 Migration SQL cho `users`, `sessions`, `email_tokens`, `login_throttles` (D4) và struct tương ứng; kiểm tra: `#[sqlx::test]` xác nhận DB chặn trùng `email_hmac` và `token_hash`
- [ ] 4.2 Test đỏ đăng ký và kiểm tra dữ liệu: USER-AUTH-S1, S3–S12, S45, S46 (gồm mã hóa email và tên hiển thị theo D15, chuẩn hóa NFC theo D6, mã lỗi theo D14, email theo ngôn ngữ)
- [ ] 4.3 Cài đặt đăng ký, quy tắc mật khẩu, trait `Mailer` (bản `lettre` và bản giả cho test), gửi email bằng `tokio::spawn` (D7, D8) với mẫu `askama` `vi`/`en`; kiểm tra: test của 4.2 xanh
- [ ] 4.4 Test đỏ xác thực email và gửi lại: USER-AUTH-S13–S19 (dùng `clock` cho 15 phút và 60 giây)
- [ ] 4.5 Cài đặt phát/dùng/thu hồi `email_tokens` và cooldown; kiểm tra: test của 4.4 xanh
- [ ] 4.6 Test đỏ đăng nhập và khóa: USER-AUTH-S20–S27, S47, kèm test hai request sai song song vẫn đếm đủ 2 lần
- [ ] 4.7 Cài đặt đăng nhập, hash giả cho email không tồn tại, bộ đếm `login_throttles` nguyên tử (D7); kiểm tra: test của 4.6 xanh
- [ ] 4.8 Test đỏ phiên, đăng xuất, API cần đăng nhập: USER-AUTH-S28–S31, S42
- [ ] 4.9 Cài đặt extractor `CurrentUser` (axum `FromRequestParts`) đọc `Authorization: Bearer`, gia hạn trượt, đăng xuất (D5, D10); kiểm tra: test của 4.8 xanh
- [ ] 4.10 Test đỏ quên và đặt lại mật khẩu: USER-AUTH-S32–S38
- [ ] 4.11 Cài đặt quên/đặt lại mật khẩu (thu hồi phiên, mở khóa, xác thực email); kiểm tra: test của 4.10 xanh
- [ ] 4.12 Test đỏ đổi mật khẩu: USER-AUTH-S39–S40
- [ ] 4.13 Cài đặt đổi mật khẩu (giữ phiên hiện tại, thu hồi phiên khác); kiểm tra: test của 4.12 xanh

## 5. `user-profile` — backend

- [ ] 5.1 Test đỏ xem và đổi tên hiển thị: USER-PROFILE-S1, S3–S5, S15, và schema hồ sơ công khai chỉ có tên + avatar (phần backend của S14; S14 đầy đủ được kiểm tra lại trong `add-trips`)
- [ ] 5.2 Cài đặt `GET/PATCH /me`; kiểm tra: test của 5.1 xanh
- [ ] 5.3 Trait `Storage` với bản `aws-sdk-s3` (upload công khai, chuyển sang bucket riêng tư); kiểm tra: test tích hợp với RustFS upload rồi chuyển file thành công
- [ ] 5.4 Test đỏ avatar: USER-PROFILE-S6–S12 (ảnh mẫu có GPS, ảnh 1200×800, file 6 MB, PDF đổi đuôi, URL cũ không còn mở được)
- [ ] 5.5 Cài đặt xử lý ảnh (`image` + `webp`, trong `spawn_blocking`) và upload/thay/gỡ avatar theo D12; kiểm tra: test của 5.4 xanh

## 6. `user-auth` — frontend

- [ ] 6.1 Test đỏ Vitest: quy tắc mật khẩu (USER-AUTH-S5–S10) và kiểm tra đích quay lại (USER-AUTH-S44)
- [ ] 6.2 Cài đặt schema zod và hàm kiểm tra `next` (D11, D14); kiểm tra: test của 6.1 xanh
- [ ] 6.3 Test đỏ Playwright cho phiên: USER-AUTH-S2, S29, S41
- [ ] 6.4 Cài đặt client gọi backend phía server, cookie `dd_session`, làm mới cookie và chặn trang trong `proxy.ts` (D10); kiểm tra: test của 6.3 xanh
- [ ] 6.5 Test đỏ Playwright đăng ký → xác thực → đăng nhập: USER-AUTH-S1, S11, S13, S15, S22, S43, S45 (đọc email qua Mailpit)
- [ ] 6.6 Cài đặt trang đăng ký, "kiểm tra email", xác thực bằng nút bấm (D9), gửi lại, đăng nhập; kiểm tra: test của 6.5 xanh trên cả 3 viewport
- [ ] 6.7 Test đỏ Playwright khóa đăng nhập, quên và đặt lại mật khẩu: USER-AUTH-S23, S32, S35, S38
- [ ] 6.8 Cài đặt thông báo khóa, trang quên mật khẩu và đặt lại mật khẩu; kiểm tra: test của 6.7 xanh
- [ ] 6.9 Test đỏ Playwright đổi mật khẩu và đăng xuất: USER-AUTH-S31, S39–S40
- [ ] 6.10 Cài đặt trang đổi mật khẩu và nút đăng xuất; kiểm tra: test của 6.9 xanh

## 7. `user-profile` — frontend

- [ ] 7.1 Test đỏ: Vitest cho avatar mặc định ổn định (USER-PROFILE-S13); Playwright cho trang hồ sơ, đổi tên, upload và gỡ avatar (USER-PROFILE-S1–S4, S6, S8–S9, S12)
- [ ] 7.2 Cài đặt trang hồ sơ, component avatar với chữ cái đầu (D13), form upload (nâng `bodySizeLimit` theo D12); kiểm tra: test của 7.1 xanh trên cả 3 viewport

## 8. Kiểm tra tích hợp

- [ ] 8.1 Chạy toàn bộ test backend, Vitest và Playwright trên stack Compose đầy đủ; kiểm tra: tất cả xanh và mọi scenario USER-AUTH-S1–S47, USER-PROFILE-S1–S15 đều có ít nhất một test mang ID của nó (`grep` theo ID)

## Workflow follow-up

- Sau mỗi PR merge vào submodule, pin submodule ở repo gốc bằng một commit `chore: pin …` riêng.
- Khi mọi task xong, archive change bằng `/opsx:archive add-auth` để đưa spec vào `openspec/specs/`.
