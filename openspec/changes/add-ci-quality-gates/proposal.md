# Proposal

## Why

Code cũ có bốn lớp kiểm tra trong CI mà bản dựng lại chưa có: kiểm tra commit message, phát hiện code lặp, kiểm tra kiến trúc và quét secrets. Cả ba repo đều public, GitHub secret scanning đang tắt, và đã có một lần cặp khóa dev bị push lên PR (dreamday-backend#24). Change này chọn lại những kiểm tra còn đáng giá cho stack mới (Rust, Next.js) và đặt chúng chỉ trong CI.

## What Changes

- **Secrets**: bật GitHub secret scanning và push protection cho cả ba repo; thêm job `secrets` chạy `gitleaks` trên các commit của PR ở cả ba repo; quét toàn bộ lịch sử một lần khi thiết lập.
- **Commit message**: thêm job `commitlint` kiểm tra mọi commit của PR theo Conventional Commits ở cả ba repo, dùng bộ luật mặc định `@commitlint/config-conventional`.
- **Code lặp**: thêm job `jscpd` (ngưỡng 2% như code cũ) cho backend và frontend, bỏ qua test, migration và file sinh tự động.
- **Clippy (backend)**: thêm `clippy.toml` cấm `chrono::Utc::now` ngoài `SystemClock`, để mọi code lấy giờ qua `Clock` trong `AppState`; job `lint` hiện có tự áp dụng.
- Các job mới là **required check** của nhánh `develop`, để PR (kể cả PR auto-merge) chỉ merge khi chúng xanh.
- Không thêm hook local (husky, pre-commit): mọi kiểm tra chạy trong CI.

## Capabilities

### New Capabilities
- (không có; change này chỉ đổi công cụ, không đổi hành vi sản phẩm)

### Modified Capabilities
- (không có)

## Impact

- `apps/backend`: `.github/workflows/ci.yml` thêm 3 job, thêm `.jscpd.json`, `.gitleaksignore` và `clippy.toml`.
- Repo gốc: thêm workflow CI với `secrets` và `commitlint`.
- `apps/frontend`: sau khi khung mới được dựng (`add-auth` task 2.1–2.2), giữ lại CI cũ còn chạy được với Next.js 16 (`commitlint`, `jscpd`) và thêm `secrets`.
- Cài đặt GitHub của ba repo: secret scanning, push protection, required checks.

## Out of scope

- Hook local trên máy dev (husky, lint-staged, pre-commit).
- Tự sinh changelog và release (release-please) dựa trên commit.
- Kiểm tra kiến trúc trong CI (code cũ có `import-linter` và `semgrep`). Backend: ranh giới giữa các module tính năng đã do compiler kiểm tra (D2 của `add-auth`); luật `src/shared/` không phụ thuộc module tính năng và luật không viết SQL vào bảng của module khác do review đảm nhận, vì `grep` không đủ chính xác và các công cụ Rust hiện có còn non hoặc cần nightly. Frontend: không thêm.
- Quét lỗ hổng dependency (Dependabot, `cargo audit`, `pnpm audit`).

## Open questions

- (không còn)
