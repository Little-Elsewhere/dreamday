---
name: verify-dreamday
description: Launch the local Dreamday frontend and verify its login form with the existing Playwright E2E runner and saved evidence.
---

# Verify Dreamday locally

This procedure covers the English login form on a mobile viewport in the frontend submodule. It uses the app's existing Playwright Test runner and a local Next.js development server. No account, backend, or production service is needed. The account-dependent frontend E2E cases are currently skipped.

Run commands from the infrastructure repository root. Use the checked-out frontend submodule commit. Keep port 4000 free, use Node and pnpm versions accepted by `apps/frontend/package.json`, and install the frontend's locked dependencies before launching if `apps/frontend/node_modules` is absent. Dependency installation requires approval under the setup-verification procedure; use `pnpm --dir apps/frontend install --frozen-lockfile` after approval. Playwright also needs its matching Chromium binary (`pnpm --dir apps/frontend exec playwright install chromium` if missing, after approval).

## Launch

In a dedicated terminal, run:

```sh
env NEXT_PUBLIC_APP_NAME=Dreamday \
  NEXT_PUBLIC_APP_DEFAULT_TITLE=Dreamday \
  NEXT_PUBLIC_APP_TITLE_TEMPLATE='%s - Dreamday' \
  NEXT_PUBLIC_APP_DESCRIPTION=Dreamday \
  NEXT_PUBLIC_APP_URL=http://localhost:4000 \
  MAINTENANCE_MODE=false \
  pnpm --dir apps/frontend dev
```

Wait until Next.js prints `Ready`. The process belongs to this terminal; leave it running through Doctor and Drive. Do not use an existing server on port 4000 unless its checkout and environment are known.

## Doctor

```sh
curl -fsS http://localhost:4000/en/auth/login | rg -o 'Continue your journey'
```

Doctor reads the local login page and checks its English heading. The matching text and a zero exit code confirm that this server is serving the unauthenticated login page. It does not submit credentials or write evidence. The Playwright test checks the rendered form in the browser.

## Drive and evidence

```sh
VERIFY_EVIDENCE_DIR="$(mktemp -d /tmp/dreamday-verify.XXXXXX)"
NEXT_PUBLIC_APP_URL=http://localhost:4000 \
  pnpm --dir apps/frontend exec playwright test e2e/auth/login-validation.spec.ts \
  --project=mobile --output "$VERIFY_EVIDENCE_DIR/artifacts" --reporter=json \
  > "$VERIFY_EVIDENCE_DIR/result.json"
```

The E2E test opens `/en/auth/login`, enters an invalid email and a harmless placeholder password, selects Sign in, and asserts the visible message `Enter a valid email address.`, the email field's invalid state, and that the page stays on the login route. It saves a screenshot under `artifacts` and the reporter's actual outcomes in `result.json`. Inspect both files; a zero exit code alone is not the evidence. See [the feature map](features/README.md). This check is scoped to Playwright's `mobile` project. Use `localhost` consistently: Next.js blocks development CSS and JavaScript assets when the page uses unconfigured `127.0.0.1` origin.

## Cleanup

Stop only the Next.js process started for this run with Ctrl-C in its terminal. Keep the evidence directory for review. Check `git status --short` in the root and frontend submodule for generated changes; do not remove another process's data or another person's work.
