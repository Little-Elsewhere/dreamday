# Design

## Context

- Code cũ: backend Python dùng `commitizen`, `jscpd`, `import-linter`, `detect-secrets` (CI và pre-commit); frontend dùng `commitlint` + husky, `jscpd`, `semgrep` với luật tự viết.
- Bản dựng lại: backend Rust có CI `format`, `lint`, `test`; frontend sẽ dựng lại ở `add-auth` nhóm 2; repo gốc chỉ có workflow auto-merge.
- Cả ba repo public, thuộc organization `Little-Elsewhere`.

## Decisions

### D1. Chỉ kiểm tra trong CI, không có hook local
Một người làm, commit thường do công cụ viết; hook local thêm công cụ phải cài trên mỗi máy (Node cho repo Rust) mà CI vẫn phải kiểm tra lại. CI là nơi duy nhất chặn merge.

### D2. Secrets: GitHub secret scanning + `gitleaks` CLI
- Secret scanning và push protection miễn phí cho repo public và chặn token của các nhà cung cấp lớn ngay lúc push, nhưng không nhận ra khóa tự sinh như `DATA_ENCRYPTION_KEY`.
- `gitleaks` bổ sung luật theo entropy và từ khóa (`key`, `secret`, `token`) nên bắt được loại sự cố đã gặp. Job tải binary phát hành chính thức (phiên bản cố định) và chạy `gitleaks git` trên khoảng commit `base..head` của PR, không dùng `gitleaks-action` vì action này yêu cầu `GITLEAKS_LICENSE` (miễn phí nhưng phải đăng ký tại gitleaks.io) với repo của organization.
- Dữ liệu test cố ý giống khóa (ví dụ khóa `[1; 32]` trong test) được ghi vào `.gitleaksignore` theo fingerprint khi bị báo.
- Thay vì: `detect-secrets` như code cũ → cần Python và file baseline phải cập nhật liên tục.

### D3. Commitlint không cần file cấu hình
Job chạy `npx @commitlint/cli` với `--extends @commitlint/config-conventional` trên khoảng commit của PR. Bộ luật mặc định đã khớp các commit hiện có (`feat`, `fix`, `docs`, `chore`, `build`, `ci`, …, header tối đa 100 ký tự). Repo Rust không cần `package.json`; runner của GitHub có sẵn Node.
- Thay vì: `cocogitto` hay `committed` (Rust) → mỗi repo một công cụ khác nhau.

### D4. `jscpd` bỏ qua test và file sinh tự động
Ngưỡng 2% như code cũ. Bỏ qua `tests/`, `migrations/`, `target/`, lockfile và `.github/`: test theo scenario cố ý lặp cấu trúc, còn migration và lockfile không phải code viết tay. Backend chạy `npx jscpd@<phiên bản cố định>` với `.jscpd.json` ở gốc repo; frontend thêm `jscpd` vào devDependencies.

### D5. Kiến trúc backend bằng một bước `grep`
Ranh giới giữa các module tính năng đã do compiler kiểm tra (file con private, `mod.rs` re-export, D2 của `add-auth`). Luật còn lại là `src/shared/` không phụ thuộc module tính năng: mọi đường dẫn `crate::` trong `src/shared/` phải bắt đầu bằng `crate::shared`. Job dùng `grep` để tìm vi phạm và fail nếu có.
- Thay vì: công cụ phân tích phụ thuộc cho Rust (`cargo-modules`, …) → thêm công cụ cho đúng một luật.

### D6. Required checks
Job chỉ chặn merge khi được đặt là required check trong ruleset của `develop`. Workflow auto-merge của repo gốc dùng `gh pr merge --auto`, vốn chờ các required check.

## Risks / Trade-offs

- [`gitleaks` báo nhầm dữ liệu test] → Ghi fingerprint vào `.gitleaksignore`, kèm lý do trong commit message.
- [`jscpd` báo lặp ở code ngắn giống nhau có chủ đích] → Điều chỉnh `minTokens` hoặc `ignore` trong `.jscpd.json` thay vì hạ ngưỡng chung.
- [Bước `grep` bỏ sót cách viết khác như `super::super::`] → Chấp nhận; review vẫn là lớp kiểm tra thứ hai.
