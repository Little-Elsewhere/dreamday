# Authentication API (frontend contract)

Base path: `/api/v1/auth`  
Local URLs: `http://api.dreamday.local` (Nginx) or `http://localhost:8000`.

Success bodies use `{ "code": number, "message": string }` at the top level.  
Error bodies put the same shape under `detail`:

```json
{ "detail": { "code": 1005, "message": "Invalid email or password." } }
```

Use **`code`** for i18n / branching. Treat `message` as an English fallback only.

Emails are normalized server-side (`strip` + lowercase). Password on register: **12–128** characters.

---

## End-to-end overview

```mermaid
flowchart TD
  subgraph register_flow [Register]
    R1[POST /register] --> R2{email new?}
    R2 -->|yes| R3[202 code 1001]
    R3 --> R4[Check-email screen]
    R2 -->|exists| R5[409 code 1012]
    R5 --> R6[Show already registered → Login]
  end

  subgraph verify_flow [Verify email]
    V1[User opens link /auth/confirm?token=...] --> V2[POST /verify-email]
    V2 -->|ok| V3[200 code 1004 → Login]
    V2 -->|bad/expired| V4[400 code 1003]
  end

  subgraph login_flow [Login]
    L1[POST /login] --> L2{result}
    L2 -->|ok| L3[Store access + refresh tokens]
    L2 -->|1005| L4[Invalid credentials]
    L2 -->|1006| L5[Check-email screen]
    L5 --> L6[POST /resend-verification]
    L2 -->|1007| L7[Account disabled]
  end

  subgraph password_flow [Password]
    F1[POST /forgot-password] --> F2[202 code 1013]
    F2 --> F3[Email link /auth/reset-password?token=...]
    F3 --> F4[POST /reset-password]
    F4 -->|ok| F5[200 code 1015 → Login]
    U1[POST /update-password Bearer] -->|ok| U2[New access + refresh]
  end

  R4 --> V1
  L6 --> V1
  V3 --> L1
  F5 --> L1
```

---

## Token model (after successful login)

| Token | Where to store | How used |
| --- | --- | --- |
| `access_token` | Memory or short-lived storage | `Authorization: Bearer <access_token>` on protected calls |
| `refresh_token` | Secure persistent storage (e.g. httpOnly cookie or secure storage) | `POST /refresh` and `POST /logout` body |

Login / refresh response:

```json
{
  "access_token": "...",
  "token_type": "bearer",
  "expires_in": 900,
  "refresh_token": "...",
  "refresh_expires_in": 2592000
}
```

- When access expires or `/me` returns `401` with `1010`, call **`POST /refresh`** with the current refresh token.
- On refresh success, **replace** both tokens; discard the old refresh token.
- If refresh fails (`401` / `1008`), clear session and send the user to login.
- **Never reuse** an old refresh token after rotation: reuse revokes the whole token family.

```mermaid
sequenceDiagram
  participant FE as Frontend
  participant API as Backend

  FE->>API: POST /login
  API-->>FE: access + refresh
  FE->>API: GET /me (Bearer access)
  API-->>FE: 200 user
  Note over FE: access expired
  FE->>API: POST /refresh { refresh_token }
  API-->>FE: new access + new refresh
  FE->>API: GET /me (Bearer new access)
  FE->>API: POST /logout { refresh_token }
  API-->>FE: 200 code 1011
```

---

## Message codes

| Code | HTTP (typical) | Meaning | Frontend action |
| --- | --- | --- | --- |
| `1001` | `202` | Registration accepted; verification email may be sent | Check-email screen |
| `1002` | `202` | Resend accepted (always, even if no mail sent) | Stay on check-email; optional toast |
| `1003` | `400` | Invalid or expired verification link | Error on confirm page; offer resend / register |
| `1004` | `200` | Email verified | Redirect to login |
| `1005` | `401` | Invalid email or password | Inline form error |
| `1006` | `403` | Email not verified | Check-email screen; call resend |
| `1007` | `403` | Account disabled | Dedicated disabled message |
| `1008` | `401` | Invalid or expired refresh token | Clear session → login |
| `1009` | `401` | Missing Bearer access token | Treat as logged out / refresh or login |
| `1010` | `401` | Invalid or expired access token | Try refresh, else login |
| `1011` | `200` | Logged out | Clear tokens → login |
| `1012` | `409` | Email already registered | Point user to login |
| `1013` | `202` | Forgot-password accepted (always) | “Check your email” UI |
| `1014` | `400` | Invalid or expired password reset link | Error on reset page; offer forgot again |
| `1015` | `200` | Password reset success | Redirect to login |
| `1016` | `400` | Current password incorrect (`/update-password`) | Inline error on update-password form |

Validation failures (wrong shape / short password) are FastAPI `422` — not these codes.  
New passwords (register / reset / update) must be **12–128** characters.

---

## Endpoints

### `POST /register`

**Body**

```json
{ "email": "user@example.com", "password": "at-least-12-chars" }
```

| Result | Status | Code | FE |
| --- | --- | --- | --- |
| New email | `202` | `1001` | Check-email screen (mail sent by API) |
| Email already exists | `409` | `1012` | “Already have an account?” → login |

Do **not** treat `202` as “logged in”. No tokens yet.

```mermaid
sequenceDiagram
  participant FE as Frontend
  participant API as Backend
  participant Mail as Email

  FE->>API: POST /register
  alt new email
    API-->>FE: 202 code 1001
    API->>Mail: verification link
    FE->>FE: Check-email UI
  else email exists
    API-->>FE: 409 code 1012
    FE->>FE: Suggest login
  end
```

---

### `POST /resend-verification`

**Body**

```json
{ "email": "user@example.com" }
```

| Result | Status | Code | Notes |
| --- | --- | --- | --- |
| Always (unknown / verified / unverified) | `202` | `1002` | Anti-enumeration: response shape is the same |

FE should call this from the **check-email** screen (after register, or after login `1006`).  
During resend cooldown the API may reuse the same link; after cooldown it issues a new one. FE does not need to handle that distinction.

```mermaid
sequenceDiagram
  participant FE as Frontend
  participant API as Backend

  FE->>API: POST /login
  API-->>FE: 403 code 1006
  FE->>FE: Check-email screen
  FE->>API: POST /resend-verification { email }
  API-->>FE: 202 code 1002
```

---

### `POST /verify-email`

Used by the confirmation page. Read `token` from the email link query string (`EMAIL_VERIFICATION_URL` + `?token=...`), then:

**Body**

```json
{ "token": "<from query string>" }
```

| Result | Status | Code | FE |
| --- | --- | --- | --- |
| Success | `200` | `1004` | “Verified” → login |
| Bad / expired / already used | `400` | `1003` | Error + link to resend or register |

Do not cache this response. Prefer POST (not GET) for the API call.

```mermaid
sequenceDiagram
  participant User
  participant FE as Confirm page
  participant API as Backend

  User->>FE: Open /auth/confirm?token=...
  FE->>API: POST /verify-email { token }
  alt valid
    API-->>FE: 200 code 1004
    FE->>User: Go to login
  else invalid
    API-->>FE: 400 code 1003
    FE->>User: Expired link UI + resend
  end
```

---

### `POST /login`

**Body**

```json
{ "email": "user@example.com", "password": "..." }
```

| Result | Status | Code | FE |
| --- | --- | --- | --- |
| Success | `200` | — (token payload) | Persist tokens; enter app |
| Bad credentials | `401` | `1005` | Form error |
| Not verified | `403` | `1006` | Check-email + `POST /resend-verification` |
| Disabled | `403` | `1007` | Disabled message |

Login does **not** send verification email. FE must call resend explicitly on `1006`.

---

### `POST /forgot-password`

Aligned with fastapi-users: always `202` (anti-enumeration).

**Body**

```json
{ "email": "user@example.com" }
```

| Result | Status | Code | Notes |
| --- | --- | --- | --- |
| Always | `202` | `1013` | Mail sent only if an **active** account exists |

FE: show “If an account exists, we sent a link” — same copy whether or not the email is registered.  
Reset page URL comes from `PASSWORD_RESET_URL` with `?token=...`.

```mermaid
sequenceDiagram
  participant FE as Frontend
  participant API as Backend
  participant Mail as Email

  FE->>API: POST /forgot-password { email }
  API-->>FE: 202 code 1013
  opt active account
    API->>Mail: reset link with token
  end
  FE->>FE: Check-email / recovery success UI
```

---

### `POST /reset-password`

Public. Used by `/auth/reset-password?token=...` (or equivalent).

**Body**

```json
{ "token": "<from query string>", "password": "at-least-12-chars" }
```

| Result | Status | Code | FE |
| --- | --- | --- | --- |
| Success | `200` | `1015` | Clear any old session → login |
| Bad / expired token | `400` | `1014` | Error + link back to forgot-password |

On success the API also: marks email verified (proof of inbox access), revokes **all** refresh tokens for that user.

```mermaid
sequenceDiagram
  participant User
  participant FE as Reset page
  participant API as Backend

  User->>FE: Open /auth/reset-password?token=...
  FE->>API: POST /reset-password { token, password }
  alt valid
    API-->>FE: 200 code 1015
    FE->>User: Go to login
  else invalid
    API-->>FE: 400 code 1014
    FE->>User: Expired link + forgot again
  end
```

---

### `POST /update-password`

Authenticated (`Authorization: Bearer <access_token>`). Requires the **current** password (stricter than fastapi-users’ password-only patch).

**Body**

```json
{
  "current_password": "old-password",
  "new_password": "at-least-12-chars"
}
```

| Result | Status | Code / body | FE |
| --- | --- | --- | --- |
| Success | `200` | Same token payload as login (no `code` field) | **Replace** stored access + refresh |
| Wrong current password | `400` | `1016` | Inline form error |
| Missing / bad access | `401` | `1009` / `1010` | Refresh or login |

All previous refresh tokens are revoked; response is a fresh token pair so the user stays signed in on this device.

```mermaid
sequenceDiagram
  participant FE as Frontend
  participant API as Backend

  FE->>API: POST /update-password (Bearer) { current_password, new_password }
  alt current password ok
    API-->>FE: 200 access + refresh
    FE->>FE: Replace stored tokens
  else wrong current password
    API-->>FE: 400 code 1016
  end
```

---

### `POST /refresh`

**Body**

```json
{ "refresh_token": "..." }
```

Success: same shape as login tokens. Failure: `401` / `1008` → clear session.

---

### `POST /logout`

**Body**

```json
{ "refresh_token": "..." }
```

Always treat as logged out on the client after calling (or if call fails, still clear local tokens). Success: `200` / `1011`.

---

### `GET /me`

**Headers:** `Authorization: Bearer <access_token>`

| Result | Status | Code | FE |
| --- | --- | --- | --- |
| OK | `200` | — | `{ id, email, is_email_verified, created_at }` |
| Missing Bearer | `401` | `1009` | Refresh or login |
| Bad / expired access, or inactive / unverified user | `401` | `1010` | Refresh or login |

---

## Recommended frontend screens

| Screen | Trigger |
| --- | --- |
| Register form | `/auth/register` |
| Login form | `/auth/login` |
| Check email | After `1001`, or login `1006`; include **Resend** → `/resend-verification` |
| Confirm email | `/auth/confirm?token=...` → `/verify-email` |
| Forgot password | Form → `POST /forgot-password` → recovery success / check-email copy (`1013`) |
| Reset password | `/auth/reset-password?token=...` → `POST /reset-password` |
| Update password (logged in) | `/auth/update-password` → `POST /update-password` with Bearer + current/new password |
| App shell | Has valid session; load `/me` as needed |

```mermaid
stateDiagram-v2
  [*] --> Anonymous
  Anonymous --> CheckEmail: register 1001
  Anonymous --> Authenticated: login 200
  Anonymous --> CheckEmail: login 1006
  Anonymous --> Anonymous: login 1005 / register 1012→login
  Anonymous --> RecoverySent: forgot-password 1013
  RecoverySent --> Anonymous: reset-password 1015 → login
  RecoverySent --> RecoverySent: bad token 1014 → forgot again
  CheckEmail --> Anonymous: verify 1004 → login
  CheckEmail --> CheckEmail: resend 1002
  Authenticated --> Authenticated: update-password 200 (new tokens)
  Authenticated --> Anonymous: logout / refresh 1008
```

---

## Implementation checklist (FE)

1. Branch UI on `detail.code` (and success `code`), not on English `message`.
2. Register `409`/`1012` → login CTA; do not stay on a false “check email” for duplicates.
3. Login `1006` → check-email UI + call resend (backend will not auto-send on login).
4. Store and rotate refresh tokens correctly; never keep using a rotated refresh token.
5. Attach Bearer access token only; send refresh only to `/refresh` and `/logout`.
6. Confirm page: read `token` query param → `POST /verify-email`.
7. Forgot password: always treat `1013` as success UI; do not reveal whether the email exists.
8. Reset page: read `token` → `POST /reset-password`; on `1015` go to login.
9. Update password: send `current_password` + `new_password` with Bearer; on success **replace** tokens (response is token payload, not a `code`).
10. After logout, failed refresh, or successful **reset-password**, clear auth state before showing login.
