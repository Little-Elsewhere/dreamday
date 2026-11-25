# Tasks

Quy ước: mỗi task là một PR (< ~400 dòng thay đổi). "Kiểm tra" của job CI là một PR thử chứng minh job fail khi vi phạm và pass khi hết vi phạm; PR thử được đóng sau khi kiểm tra.

## 1. Cài đặt GitHub và quét lịch sử

- [x] 1.1 Bật secret scanning và push protection cho `dreamday`, `dreamday-backend`, `dreamday-frontend`; kiểm tra: `gh api repos/Little-Elsewhere/<repo> --jq .security_and_analysis` báo `enabled` cho cả hai mục ở cả ba repo
- [x] 1.2 Chạy `gitleaks git` trên toàn bộ lịch sử của ba repo; với mỗi phát hiện: secret thật thì xoay khóa và ghi lại, dữ liệu test thì thêm vào `.gitleaksignore` (D2); kiểm tra: chạy lại không còn phát hiện chưa xử lý

## 2. Backend (`apps/backend`)

- [x] 2.1 Job `secrets` chạy `gitleaks git` trên commit của PR (D2); kiểm tra: PR thử thêm `DATA_ENCRYPTION_KEY=` kèm một khóa base64 ngẫu nhiên vào `.env.example` thì job fail, bỏ đi thì pass
- [x] 2.2 Job `commitlint` (D3); kiểm tra: PR thử có commit `update stuff` thì job fail, commit `docs: …` thì pass
- [x] 2.3 `.jscpd.json` và job `jscpd` (D4); kiểm tra: job pass trên `develop`, PR thử chép lại một hàm dài trong `src/` thì job fail
- [x] 2.4 `clippy.toml` cấm `chrono::Utc::now`, cho phép trong `SystemClock::now` và test của nó (D6); kiểm tra: gọi `Utc::now()` ở một file khác trong `src/` thì `cargo clippy -- -D warnings` fail
- [x] 2.5 Đặt `secrets`, `commitlint`, `jscpd` (cùng `format`, `lint`, `test` hiện có) thành required check của `develop` (D5); kiểm tra: PR có job đỏ không merge được

## 3. Frontend (`apps/frontend`, sau `add-auth` task 2.1–2.2)

Frontend vẫn dùng Next.js 16 như code cũ, nên CI cũ (`commitlint`, `jscpd`, …) được giữ lại nếu còn chạy được thay vì viết lại.

- [ ] 3.1 Rà soát CI cũ sau khi dựng khung mới: giữ các job còn chạy được (`commitlint` với husky bỏ đi theo D1, `jscpd`), bỏ job không còn phù hợp; kiểm tra: CI xanh trên khung mới
- [ ] 3.2 Thêm job `secrets` (D2) và dùng chung cấu hình commitlint mặc định (D3) nếu job cũ khác; kiểm tra như 2.1 và 2.2
- [ ] 3.3 Đặt các job thành required check của `develop` (D5); kiểm tra như 2.5

## Workflow follow-up

- Sau mỗi PR merge vào submodule, pin submodule ở repo gốc bằng một commit `chore: pin …` riêng.
- Khi mọi task xong, archive change bằng `/opsx:archive add-ci-quality-gates`.
