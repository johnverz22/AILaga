---
description: "AILaga local-AI safety invariants — apply whenever touching lib/services/ai or capture/ask features"
trigger: always_on
---

# AI safety invariants (Developer C track)

- AI output is always a *proposal*. Only deterministic code + human confirm may write to real tables (`confirmAll` in one transaction, idempotent).
- Validation flags bad values (`check`) — never auto-corrects or invents numbers.
- `source_quote` must be a substring of the transcript, else drop.
- No model installed or engine failure → Basic mode (NullEngine + BasicTextExtractor); every feature must still work.
- SOS never touches AI.
- Byte counters and perf numbers shown in UI/demo must be real (TrafficStats via MethodChannel) — never fabricated; record measurements in `docs/SPIKE_RESULTS.md`.
