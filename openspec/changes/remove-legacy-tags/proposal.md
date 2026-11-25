# Proposal

## Why

Khi dựng lại, code cũ của mỗi submodule được gắn tag `legacy` để tham khảo trong lúc viết code mới (D1 của `add-auth`). Khi mọi change đã xong và được archive, code mới đã thay thế toàn bộ code cũ, nên tag này không còn cần thiết và chỉ làm người đọc repo nhầm đâu là code đang dùng.

## What Changes

- Xóa tag `legacy` trên remote và trên máy local ở `apps/backend` và `apps/frontend`.
- Chỉ làm khi mọi change khác trong `openspec/changes/` đã được archive.
- Commit cũ vẫn còn trong lịch sử Git của `develop` (code cũ bị xóa bằng một commit, không viết lại lịch sử); chỉ mất con trỏ `legacy` trỏ tới chúng.

## Capabilities

### New Capabilities
- (không có; change này chỉ dọn repo, không đổi hành vi sản phẩm)

### Modified Capabilities
- (không có)

## Impact

- `apps/backend`, `apps/frontend`: mất tag `legacy`; ai còn cần xem code cũ thì checkout commit ngay trước commit xóa code cũ.

## Out of scope

- Xóa các nhánh cũ trên remote (ví dụ `feat/trip-management`, `refactor/domain-packages`, `build/python-3.14`).
- Xóa các tag phát hành cũ của frontend (`v0.2.0` … `v0.4.1`).
- Viết lại lịch sử Git để xóa hẳn code cũ.

## Open questions

- (không còn)
