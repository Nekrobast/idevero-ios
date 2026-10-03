# Physical V6 remediation — evidence ledger

Base: `b4d577dd3e703e83c5236194184ca6f4ba8954af`.
Historical build 10 physical result: FAIL. Historical PR #6 is preserved.
Branch: `physical-v6-remediation`; separate Draft PR #7.

## Reproduction before production edits

Only `IdeveroTests/PhysicalV6RemediationTests.swift` was changed for the
reproduction commits. Runs: 37134293683 and 37134529279.
Do not interpret a compile failure as RED confirmation of a semantic defect.

| Physical cause | Reproduction seam | Initial classification |
| --- | --- | --- |
| Open request / model-selected workflow | DomainContextBuilder; two unrelated sector holdouts | RED CONFIRMED |
| Strong unconfirmed inference | AppleDiscoveryMerger; essential-language fixture | RED CONFIRMED |
| Premature downstream questions | AppleUnknownSelector; explicit ambiguous-frame control | ALREADY PASSING for an accurately classified frame; real model status validation was a TEST GAP |
| Technical identifiers | Policy and actual LocalExpertProvider compilation; unseen long identifiers | RED CONFIRMED for long-name display policy; original-request literal retention ALREADY PASSING |
| English / Spanish consistency | LocalExpertProvider outcome, discoveries, unknowns and compiled prompt | RED CONFIRMED English; Spanish/simple-email ALREADY PASSING |
| Include/exclude/lock | Actual CreateViewModel -> coordinator -> compile -> SwiftData -> reconstructed analysis -> reanalysis | RED CONFIRMED when model omits prior choices; fresh record ID also reproduced |
| Equivalent vs distinct identity | Changed IDs, conservative known paraphrases, unrelated finding | ALREADY PASSING |
| Excluded context bypass | Same excluded finding repeated in calibrated domain context | RED CONFIRMED |
| Machine perspectives | Two unseen identifiers, Spanish and English | RED CONFIRMED |
| Regeneration feedback | Actual ViewModel with delayed deterministic local compiler; duplicate invocation | RED CONFIRMED; native-view completion feedback required a new UI harness |

Run 37134293683: 10 new tests, 7 failing methods / 30 failed assertions.
Run 37134529279: 12 new tests, 8 failing methods / 31 failed assertions.
Both compiled and executed on macos-26; the 24 original contracts and 4 concurrency
tests passed. Device build was correctly skipped after the intentional RED gate.
The eight supplementary tests and native UI harness close coverage gaps; they
are not claimed as pre-fix executed RED tests.

## Repair design

The actual Foundation boundary independently validates request evidence before
using primary-job status. Calibrated model workflow claims are case-dependent
without explicit request support, and unconfirmed finding prose is conditional.
Legacy fixture frames retain their existing API contract; production Foundation
frames always pass through validation, including frames without calibrated items.
No physical-sector answer is encoded in these rules.

Local authored knowledge selects English labels/reasons by stable resource
identity, and all compilers choose language from the original input. Resource
indices remain stable before conditional filtering. Domain machine IDs stay in
analysis metadata; display lenses use resource labels or a localized abstraction.

User decisions carry scoped authoritative snapshots; a missing model finding
cannot revoke them. Matching still uses the unchanged conservative identity.
Create and History use the same ViewModel operation path, preserve analysisID
for the same request, expose progress/completion/errors and reject duplicate
recompilation. Compiler exclusions also apply to domain-context items.

Final validation and artifact details are recorded by GitHub Actions and the
generated manifest; physical results must be filled only after iPhone retest.

## Causes identified by source inspection

1. The grounding validator treats model-declared ESTABLISHED as proof and accepts
   frame items as mutual evidence. The model also controls primaryJobStatus.
   This permits a specific workflow to be privileged by a broad request.
2. The epistemic heading is conditional but its body remains model text verbatim.
   A conditional heading cannot neutralize a categorical assertion in the body.
3. The display policy uses acronym-segment length as a proxy for internal metadata.
   The original request is already retained by the product compiler; loss of those
   bytes is not yet reproduced. Long explicit identifiers are tested separately.
4. Resource labels/reasons, local outcome and question placeholders are selected
   in Spanish before the compiler selects English headings.
5. Reanalysis restores flags only on newly emitted findings. It retains no
   authoritative snapshot for a user choice absent from a new model response.
   Reanalysis also creates a fresh analysisID, which can duplicate saved records.
   DomainContext is compiled independently of discovery exclusion.
6. Local discoveries concatenate a domain machine ID into the display lens. The
   display-localization function only translates individual English terms.
7. Regenerate and discovery actions await recompilation without publishing busy,
   completion or error state, while ResultView has no working-state input.

Foundation Models physical runtime cannot be validated on a hosted simulator.
Physical Quality V6 must remain AWAITING IPHONE RETEST for any new candidate.
