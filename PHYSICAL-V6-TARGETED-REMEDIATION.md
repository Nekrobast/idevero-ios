# Physical V6 targeted remediation — build 12

Base: `b18806815bf779389a4a44cdf104d7caa0e44de7` (build 11).
Branch: physical-v6-remediation; PR #7 remains Draft and unmerged.
Build 10 and build 11 physical results remain FAIL historical evidence.
Build 11 physically passed language, technical literals, event grounding,
Discovery Control, History, machine-ID display and bottom-bar clearance.

## Reproduction before production edits

Only two new test files were added. No production file changed before the RED run.

- Run 37139955975: harness compile error assigning an immutable `unknowns` property.
  NOT semantic RED evidence. Corrected by constructing an immutable snapshot.
- Run 37140037356 / commit 15948f6ac73098cf65efb78b9fa39c105a648991:
  compiled and executed; 10 targeted unit methods, 5 failing / 13 assertions;
  3 targeted native UI methods, all 3 failing / 3 assertions.
  Original 24 contracts, 21 build-11 remediation methods and concurrency 4 passed.
  ARM64 build was skipped after the intentional RED gate.

| Reproduction | Before production fix |
| --- | --- |
| Broad domain, ES/EN, model-generated candidates/context | RED CONFIRMED |
| One explicit workflow plus an invented second option | RED CONFIRMED |
| Shared sector noun and verb with an unsupported object | RED CONFIRMED |
| Accepted/locked authority versus Apple self-claims during recompile | RED CONFIRMED |
| Unconfirmed and excluded choices as priority authority | RED CONFIRMED |
| Two explicitly requested objectives, ES/EN | ALREADY PASSING |
| Equivalent wording / no two priority choices | ALREADY PASSING |
| Untrusted model primary question, selected deterministic question control | ALREADY PASSING |
| Completion/error publication and cancellation cleanup | ALREADY PASSING; not proof of visual feedback |
| Actual Create regeneration, feedback visible after scrolling | RED CONFIRMED |
| Actual History regeneration, feedback visible after scrolling | RED CONFIRMED |
| Actual Update selection entry, visible explanatory title | RED CONFIRMED |

Supplementary tests added after that RED run cover meaningful paraphrase
deduplication, action-object recombination, action nouns versus verb intent,
negated objectives, and actual ViewModel reanalysis with
accepted/locked priority authority omitted by the model. They are not claimed as
pre-fix executed RED tests. History reanalysis runs after regeneration once the
first previously failing assertion passes.

## Exact data/state defects

Primary Job: FoundationModelsProvider validates primaryJobStatus but retains
raw primaryJobCandidates. DomainContextBuilder permits shared request/domain
tokens or calibrated frame items as support. AppleUnknownSelector independently
reads the raw frame candidates and tests only natural-language/display shape.
Thus a model claim can justify its own alternatives, and the selector can expose
alternatives even when the compiled context has rejected them.

Feedback: Actualizar is a Menu, not an operation. Its actions dispatch Tasks to
the ViewModel. Recompile publishes busy true, awaits a fast local actor call,
then publishes busy false and completion. SwiftUI can coalesce that transition.
ResultView renders feedback after the long prompt, inside the scroll content.
Scrolling or reanalysis repositioning can hide it. The old UI test checked the
caption beside the action row, not persistent viewport visibility or both roots.

## Minimal transverse fixes

PrimaryJobEvidence uses action-object support from the original request and
included user-explicit/accepted/locked CORE_WORKFLOW discoveries. Every material
object must be supported under the same action. Model confidence, sector names,
anchors and ESTABLISHED labels are not independent evidence. Generic bilingual
action forms and plural/article normalization preserve supported wording and
deduplicate equivalent alternatives. A single surviving option does not create
a two-way priority question. Source action intent must be explicit rather than
an action noun inside a sector name; negated clauses are not positive evidence.
Without two distinct supported alternatives, the
existing open primary clarification is used.

The actual Foundation boundary and context builder use that filter. Validated
model primary questions cannot bypass the deterministic question. Recompilation
also validates restored context after existing user decisions are protected;
authority/discovery identity and persistence/upsert implementation are unchanged.
Validation is a display/compilation projection. The source domain frame remains
intact during regeneration and in saved snapshots. Run 37141389242 identified
an initial regression in testDomainFrameSurvivesHistoryAndRegenerate; production
was corrected to preserve metadata rather than changing that original test.
Targeted tests now assert the same exact safe alternatives in the projection,
retain their actual question/output assertions, and additionally require source
frame equality. No original test or physical display requirement was weakened.

Actualizar opens a native titled confirmation dialog. Operations still call
the same handlers; Create and History share screen-level native feedback above
the scroll viewport. Busy disables the existing controls, published start/end
revisions support repeated VoiceOver announcements, and a yield permits initial
presentation without a fake minimum duration. Completion/error remains visible
even for sub-frame local work. Cancellation checks and sequence-owned cleanup
prevent stale completion and a stuck busy state. No second inference added.

## Release safety

Build 12 is a new unsigned physical candidate, generated only after CI passes.
The workflow records its exact source commit, SHA-256 and run in the manifest.
Both large and compact Accessibility Large destinations run the complete UI suite.
Original contracts and old assertions are untouched. Targeted and cumulative
hard-code audits are run against production additions.

main: `67b5347a9bf3cb02e65bdf0617ab42b8ed3b6ef6` (frozen).
PR #6 and #7: no merge. No release, App Store or TestFlight publication.

PHYSICAL QUALITY V6: AWAITING FINAL IPHONE RETEST.
