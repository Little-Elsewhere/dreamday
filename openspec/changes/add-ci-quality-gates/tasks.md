# Tasks

Quy ước: mỗi task là một PR (< ~400 dòng thay đổi). "Kiểm tra" của job CI là một PR thử chứng minh job fail khi vi phạm và pass khi hết vi phạm; PR thử được đóng sau khi kiểm tra.

## 1. Cài đặt GitHub và quét lịch sử

- [ ] 1.1 Bật secret scanning và push protection cho `dreamday`, `dreamday-backend`, `dreamday-frontend`; kiểm tra: `gh api repos/Little-Elsewhere/<repo> --jq .security_and_analysis` báo `enabled` cho cả hai mục ở cả ba repo
- [ ] 1.2 Chạy `gitleaks git` trên toàn bộ lịch sử của ba repo; với mỗi phát hiện: secret thật thì xoay khóa và ghi lại, dữ liệu test thì thêm vào `.gitleaksignore` (D2); kiểm tra: chạy lại không còn phát hiện chưa xử lý

## 2. Backend (`apps/backend`)

- [ ] 2.1 Job `secrets` chạy `gitleaks git` trên commit của PR (D2); kiểm tra: PR thử thêm `DATA_ENCRYPTION_KEY=` kèm một khóa base64 ngẫu nhiên vào `.env.example` thì job fail, bỏ đi thì pass
- [ ] 2.2 Job `commitlint` (D3); kiểm tra: PR thử có commit `update stuff` thì job fail, commit `docs: …` thì pass
- [ ] 2.3 `.jscpd.json` và job `jscpd` (D4); kiểm tra: job pass trên `develop`, PR thử chép lại một hàm dài trong `src/` thì job fail
- [ ] 2.4 Job `architecture` (D5); kiểm tra: PR thử thêm `use crate::health;` vào một file trong `src/shared/` thì job fail
- [ ] 2.5 Đặt `secrets`, `commitlint`, `jscpd`, `architecture` (cùng `format`, `lint`, `test` hiện có) thành required check của `develop` (D6); kiểm tra: PR có job đỏ không merge được

## 3. Repo gốc

- [ ] 3.1 Workflow CI với job `secrets` và `commitlint` (D2, D3), đặt thành required check của `develop` (D6); kiểm tra: PR thử có commit sai định dạng không được auto-merge

## 4. Frontend (`apps/frontend`, sau `add-auth` task 2.2)

- [ ] 4.1 Job `secrets` và `commitlint` (D2, D3); kiểm tra như 2.1 và 2.2
- [ ] 4.2 `jscpd` trong devDependencies, `.jscpd.json` bỏ qua thư mục build và báo cáo test, job `jscpd` (D4); kiểm tra như 2.3 với một component
- [ ] 4.3 Đặt các job thành required check của `develop` (D6); kiểm tra như 2.5

## Workflow follow-up

- Sau mỗi PR merge vào submodule, pin submodule ở repo gốc bằng một commit `chore: pin …` riêng.
- Bổ sung task kiểm tra kiến trúc cho frontend khi Open question trong `proposal.md` được trả lời.
- Khi mọi task xong, archive change bằng `/opsx:archive add-ci-quality-gates`.
