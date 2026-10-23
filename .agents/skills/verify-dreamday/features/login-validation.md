# Login email validation

**Purpose:** A person entering an invalid email sees a clear error before sign-in.

**Entry point:** `http://localhost:4000/en/auth/login` in the locally launched frontend.

**Prerequisites:** Follow [Launch and Doctor](../SKILL.md). No account or backend is required. Use Playwright's `mobile` project and the English locale because the expected text below is English.

**Drive:** Run the Playwright Test command in [the verification skill](../SKILL.md). It opens the login page, enters `not-an-email` in Email and a harmless placeholder in Password, then selects Sign in.

**Observable success:** `Enter a valid email address.` appears as a field alert; Email reports `aria-invalid="true"`; the browser remains on `/en/auth/login`. Inspect the saved screenshot and `result.json` for the actual outcome and route. A missing form, wrong message, or unexpected navigation fails the test.

**Gotchas:** This is client-side validation, not an authentication success test. The current sign-in handler has no API call. The account-dependent frontend E2E cases are skipped. This test runs on the mobile project. Use the same `localhost` origin for the server and browser; Next.js dev asset protection blocks unconfigured `127.0.0.1` requests.
