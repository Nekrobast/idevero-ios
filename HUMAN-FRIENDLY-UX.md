# Human-friendly UX — isolated presentation phase

Base: fc5b5b5fc1763adcc1d11ae0022dfde545e56051, physically validated 0.2.8 (12).
Branch: human-friendly-ux. Draft PR #8 targets physical-v6-remediation, not main.

## Initial copy audit

P0: discovery actions “Bloquear/Lock” do not explain preservation; machine-like
unknown concepts require a safe fallback, without hiding explicit technical literals.
P1: “idempotencia”, “persistencia”, “arquitectura de información”, “Alto valor”;
provenance and perspective dominate the ordinary card. Action effects lack hints.
P1: generic application strategy titles expose specialist vocabulary. Provider
names and Settings “backend” are developer-facing rather than benefit-facing.
P2 deferred: Spanish app-shell tabs for an English request; app-shell localization
needs an explicit app-language policy, separate from request-language result cards.
P2 deferred: cosmetic email punctuation; History title truncation; broader authored
knowledge wording outside this bounded UX phase. No global UI rewrite.

## Architecture decision

A single immutable DiscoveryPresentation, used only by the shared ResultView row
(therefore Create and History), will project localized title, explanation, priority,
state, actions and optional provenance/perspective. It never feeds the compiler.
Resource-identity metadata covers known specialist concepts and application
strategy candidates; unknown natural-language recommendations retain their source
wording and reason. No runtime AI rewrite, guessing domain objects or mutable
semantic metadata. Explicit technical literals remain in source details.

Normal level: title, one-sentence meaning, priority/state, actions.
Details: reason, source, perspective and unchanged technical wording when different.
Button labels map directly to INCLUDED / LOCKED / EXCLUDED. Existing handlers,
authority and persistence remain untouched. Priority maps are display-only.

Onboarding: a short persistent section subtitle explains the purpose. No new
onboarding persistence or repeated dismissible modal is needed in this iteration.

## Validation policy

Tests were authored before production changes. UI RED must execute successfully;
a compiler or test-harness failure is not semantic RED. Baseline invariant tests
may already pass. Additional projection contracts follow implementation and are
not claimed as pre-production RED. Holdouts use different domains/technical
literals from the card design examples. Existing tests remain unchanged.

Physical V6 build 12 PASS is recorded separately in PHYSICAL-V6-BUILD12-PASS.md.
Any new UX IPA is AWAITING IPHONE UX RETEST, never physical UX PASS from CI.
