# Tasks

## 1. Điều kiện

- [ ] 1.1 Xác nhận mọi change khác đã archive; kiểm tra: `openspec list` chỉ còn `remove-legacy-tags`

## 2. Xóa tag

- [ ] 2.1 Xóa tag `legacy` của `apps/backend` trên remote và local; kiểm tra: `git ls-remote --tags origin legacy` không trả về gì
- [ ] 2.2 Xóa tag `legacy` của `apps/frontend` trên remote và local; kiểm tra như 2.1

## Workflow follow-up

- Khi mọi task xong, archive change bằng `/opsx:archive remove-legacy-tags`.
