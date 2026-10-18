# Security policy

- Treat credentials, API keys, access tokens, private environment values, and local secret files as sensitive. Do not read, print, copy, commit, or include their values in prompts, specs, test fixtures, logs, or .ai/HANDOFF.md. Use .env.example placeholders where needed.
- Enforce authentication and authorization on the server for every private trip, member, checklist, itinerary, and expense operation. Do not rely on frontend visibility or client-provided ownership claims.
- Validate external inputs at boundaries; use typed schemas and safe error responses. Avoid logging private travel details, submitted values, credentials, tokens, or financial information.
- Scope database queries to the authorized principal and trip. Consider tenant isolation, invitation abuse, replay, concurrency, and audit needs for collaborative operations.
- Use least privilege for agents and tools. Reviewers remain read-only. Do not weaken sandbox or permission settings to bypass a blocked action.
- Do not launch tests or scripts that mutate production data, contact external users, expose network services, or deploy infrastructure without explicit authorization. Escalate suspected secret exposure or authorization bypass immediately.
