# PRE-1.0 Minimal Compliance + Save Reliability

## Authorized Why suite push dispatch

Individual Why validation run 37295979227 passed 1/1 on iPhone 17 Pro Max normal and iPhone 16e Accessibility Large at 0e4894425d15bbb2ee05b7c0558b314884477cec, with one tap, expansion and reachable source detail. Classification B (test discovery defect) is confirmed; no production fix is required.
The authorized workflow-only adaptation adds [why-suite] to the existing job condition and Why selector, resolving that push to suite. [why-targeted], manual inputs and all prior tags retain their behavior. Native commands, devices, Dynamic Type, timeouts, tests, assertions and guard logic are unchanged. Only this workflow and this documentation receive updated review seals; production seals remain unchanged. Full Presentation and full regression are still pending, not GREEN claims.

Stage: confirmed native FEATURE RED; minimal production implementation awaiting targeted GREEN.
Update: targeted GREEN confirmed; preparing full regression for physically distinguishable build 15.

PHYSICALLY VALIDATED BASELINE: 61eb2a8490b1bcfcbedbaadfda18b4746035326f.
CONSOLIDATED PRE-1.0 BASELINE: 36b36c2463e00e3ef148f7d8ac7fe8f7a99d6a1d.

## Historical guards and authorized adaptation

- ios-ci.yml equivalence step froze all production/tests/Tools and allowed only Markdown/workflow hygiene. It would reject any new tests, Settings access or save correction before executing XCTest. Replaced for this branch by Authorized Remediation Diff Gate and its tests.
- audit-presentation-remediation.mjs froze build13 outside three presentation files. Settings/save edits legitimately exceed that historical scope.
- audit-human-friendly-ux.mjs froze model/viewmodel/OperationFeedback and History persistence handlers. Save error propagation must change History persist handling, not schema or user decisions.
- audit-physical-v6.mjs protects conservative identity, no fixture hardcodes, no paid APIs and current version/build. It remains executed unchanged.
- All three historical scripts and the prior workflow are immutable at their historical commits; scripts themselves are not edited/deleted. The historical freeze remains evidence, not falsely claimed for a candidate containing authorized edits.

## New guard

Exact filenames only. Every changed/new permitted file (apart from the control-plane policy itself) requires a SHA-256 of reviewed full content. A path match alone NEVER permits content. All other baseline files, including all existing test assertions, intelligence, compiler, schema, knowledge, presentation and concurrency, remain byte-identical.

Full-file seals cover mixed Create/History/Settings files, so an unrelated callback mutation fails even in an otherwise permitted UI path. On later implementation each authorized snapshot must be manually reviewed and recorded; there is no auto-bless mode. The policy and audit implementation are themselves reviewable control-plane code, not a security boundary against someone deliberately rewriting the gate and its policy.

The complete existing XCTest/UI/device/artifact pipeline from Select installed Xcode onward is additionally byte-identical to the baseline. No assertions/skips/holdout counts changed. No version/build change.

Self-tests use in-memory copies read from baseline Git objects: Settings/privacy and save-path authorized samples PASS; semantic engine, compiler, Foundation, PromptRecord schema, Discovery Control, provider selection, concurrency and existing tests mutations FAIL; wrong change inside a sealed mixed file FAIL; deletion/unlisted addition FAIL. No real production mutated.

## Feature RED separation

New MinimalComplianceSaveUITests specify identifiable Privacy/Support access, real Save confirmation, visible accessible save failure with retry and retained Copy/Share/result, and History update save failure. They execute against original production first. No feature production is implemented until behavioral failures are confirmed from native XCTest logs.

DEBUG-only controlled persistence-failure injection will later be scoped to the new feedback boundary, not PromptRecord or provider logic; tests do not inject domains/answers into production. Before implementation launch environment arguments have no effect, making baseline save-failure feedback tests RED rather than pretending errors are already supported.

## Next stages, not claims of completion

After confirmed feature RED: minimal Settings/native system links with centralized optional URLs; nil URLs show an honest unpublished state without broken/fabricated links. ES/EN policy/support drafts use explicit legal-owner/contact placeholders. GitHub Pages files prepared but not activated. Minimal save feedback calls the actual existing save, displays success only after completion, reports errors while preserving result, and offers retry. Native unit/UI targeted GREEN then complete existing regression.

Human input pending: legal responsible party, support contact, approved hosting/public URLs. No publication, account change, purchase or App Store signing.
Current version/build: 0.2.9 / 14. Minimal production changes are implemented below; no new IPA or GREEN claim.

## Initial targeted harness failure (NOT feature RED)

Run 37226325313 on commit 600ca73922a4e336881cc8489d53b9416469742d allocated macos-26 / GitHub Actions 1000000100. All 13 isolation simulations and actual diff gate PASS. Native XCTest did not execute: Bash rejected empty EXTRA array under nounset. Artifact 11311583356 is harness diagnostics only, not XCTest or IPA validation. Fix only the new workflow command by initializing its testing selector array with the UI target. Do not remove nounset or change any assertions. Feature RED remains unproven until native test assertions actually fail.

## Native feature RED confirmed and unpublished pages

Corrected harness commit: 84b6c0979aa2aa9ad9405cd420e5a15e9f394336. Run 37226446216 allocated macos-26 / GitHub Actions 1000000101; isolation simulations and diff gate PASS; native targeted XCTest executed four tests and reported four expected assertion failures: missing save error (line 63), missing History error (line 90), missing save success (line 52), missing privacy access (line 37). FEATURE RED is confirmed. The subsequent docs-only commit 93d71db4ef5ed90f56721cd9abd2f694969ec121 is the implementation starting point, not the executed run SHA.

Privacy and Support ES/EN drafts are prepared under docs, with legal-owner/contact/effective-date placeholders. Three static HTML pages parse, have no broken relative links, and contain no scripts/external assets. GitHub Pages is suitable for this public repository, but is NOT activated; technically expected URLs are documented only as provisional, not live/final and not app configuration. No human identity, email or domain fabricated. No production modified, no new IPA generated, no new build number.

## Minimal implementation for targeted GREEN

Settings exposes native Privacy Policy and Support rows, localized ES/EN, Dynamic Type and combined VoiceOver labels with minimum 44-point targets. Centralized destinations remain nil: rows disclose pending publication and explain it in a native alert, without opening a fabricated URL or WebView. Pages remain unpublished and legal/contact placeholders unchanged.

Create and History persistence use a dedicated feedback boundary. Success is announced only after save returns and dismisses after eight seconds. Throwing saves show a visible accessible error and retry without clearing analysis, prompt, Copy or Share. History restores the exact previously held record fields on a save error; a failed new insertion is removed from the context so it cannot appear as a successful saved record. No global context rollback, schema change, migration or provider change. DEBUG-only generic fault injection is limited to this boundary; Release ignores test environment overrides.

The four original feature UI tests are unchanged. Five supplementary unit contracts cover completion ordering, error/retry, exact History restoration, duplicate-free persistence, and safe unpublished URL configuration. All existing test and production files outside the three authorized views remain frozen. Snapshot entries seal reviewed new helpers/tests and view changes; gate logic, simulations and workflow remain unchanged. Targeted GREEN must pass before full regression or build 15. Any targeted failure requires STOP.

## Targeted GREEN and demonstrated final-gate metadata defect

Run 37228541383 on f17345e9f56b3af5f4996b2e28f28dddf068b506: macos-26 / GitHub Actions 1000000102. All four unchanged feature UI tests PASS, all five new unit tests PASS, zero failures/skips; native TEST SUCCEEDED. All 13 isolation simulations and the actual gate PASS.

Only after this result, build 14 is incremented to 15 in both project configurations; marketing version remains 0.2.9. This distinguishes the remediation IPA from physically validated build 14. Demonstrated defect: the physical audit, bundle assertion, artifact reports, manifest and Windows verifier required build 14, while manifest claimed productionEquivalentToPhysicalBaseline=True despite these authorized production changes. They must not reject the authorized build increment or misrepresent physical validation.

Minimal correction: physical audit changes ONLY its expected build and status text. New build-15 verifier retains the prior verifier's checks; historical build-14 verifier remains untouched. Full-file review seals remain mandatory. The isolation gate additionally enforces exact project 14-to-15 substitution and exact physical-audit build-only correction, even if a wrong full-file seal were supplied. Three new simulations cover those strict exceptions; the original 13 remain intact. The original native pipeline tail must equal its baseline with ONLY explicit build/report/verifier metadata substitutions, truthful production-equivalence False, and the new physical-retest checklist packaged. No native test/build/re-signability commands, assertions, skips, holdout expectations or model files change.

Full CI is triggered by a push on this owned remediation branch, added alongside main to the workflow push filter because the available GitHub connector has no workflow-dispatch operation; no PR is created before all GREEN. Existing PR #9, main and release remain unchanged. Hosting is still inactive. Current candidate physical status remains AWAITING IPHONE RETEST.

## Support compact Accessibility Large STOP: evidence and scoped discovery correction

Run 37229304809 was allowed to finish, never cancelled/retried. Final FAILURE: 165 units (164 PASS, one existing physical-only skip), large UI 15/15 PASS, compact iPhone 16e Accessibility Large UI 14/15 PASS. The only failure is MinimalComplianceSaveUITests.swift:41, Settings must expose Support. The dependent unsigned-device job did not run; no IPA exists for this failed candidate.

Diagnostics artifact 11314281752, idevero-xcode-results-0.2.9, verified ZIP SHA-256 e7cd4a713326d1ecf92b46953b7709370c7edbb3bd093f967d26b3bfa03d61b2. Its native failure hierarchy shows a 390x844 window, CollectionView, vertical scrollbar with two pages at 0%, Privacy Button privacyPolicyAccess frame (16,607.3,358,146), and TabBar frame (0,761,390,83). Support is not materialized in that initial hierarchy. The recorded viewport shows only the upper Settings content. XCTest logs contain no Support scroll attempt: support.waitForExistence fails before reach(support) can execute. Source confirms Support is a native pending-publication Button in the next List section; the same identifier/access view passed on the large device. These observations do not by themselves prove reachability after scrolling or justify altering production/bottom navigation.

Minimal correction is test-only: use the existing bounded human swipe/reach helper BEFORE the original Support existence assertion. Every original assertion/timeout and the other three feature tests remain unchanged. Add keepAlways before/after hierarchy/screenshots plus viewport, native element type/frame/hittability diagnostics; tap Privacy and Support and verify their pending-publication native alert. No production/Settings/identifier/font/safe-area/navigation/schema changes. Classify TEST DISCOVERY DEFECT only if both native targeted jobs show that scrolling makes Support identifiable, visible, hittable and tappable with this unchanged production; otherwise STOP and preserve evidence.

Targeted workflow now executes ONLY MinimalComplianceSaveUITests on exact iPhone 17 Pro Max normal size and iPhone 16e accessibility-large, each with its own diagnostics artifact. The full CI push job skips the explicit support-targeted commit marker; full regression will be manually dispatched on the same exact commit ONLY after both targeted jobs PASS. No arbitrary retry, sleep, timeout increase, reduced font, skip or expectation change. No new allowlisted file or guard logic change: only reviewed seals for already-authorized tests/workflows/documentation are refreshed. All 16 guardrail simulations must remain PASS. Version/build remain 0.2.9/15; no publication or PR before full GREEN.
# Why compact diagnostic — historical RED 37233282476

- Diagnostic artifact 11315621541 SHA-256 `1adc89ec89711ef3fb60048d5e3b643da7dc0567666255b2f500f1646fc0346b` was downloaded and verified before edits. Small UI had 14/15 PASS; large 15/15 and units 164 PASS + one physical-only skip. Privacy/Support/Save remain closed and unchanged.
- Failure hierarchy: viewport `(0,0,390,844)`; ScrollView with 15 pages at 64%; first `discoveryRow` `(16,-345.3,358,497)`; first Why Button `(16,99.7,358,52)` with `collapsed` child. Source detail absent, not merely offscreen. Upper fixed visual overlay ends at `y=155.8`; bottom bar starts at `y=761`. Native synthesized Why event activated `(51.8,104.8667)`, underneath the upper overlay. Screen recording and failure screenshot retain the collapsed chevron.
- Diagnosis: the global first-match button follows the decision row reordered after Include/Lock/Exclude; AX hittability alone accepted an activation point outside visually exposed content. Production accessibility label/type/identifier remain correct. No evidence authorizes a production or bottom-bar change. B classification remains provisional until a visible human-like tap and detail scroll pass natively on both sizes.
- Authorized test-only correction: bounded directional ScrollView drags position Why outside fixed overlays before one tap, then reach the actual source StaticText and preserve the original 3-second existence assertion, adding hittability. Before-positioning/before-tap/after-tap/after-scroll screenshots, hierarchy and frames are retained. Gesture press duration is native touch synthesis, not a sleep or timeout change.
- Exactly one new reviewed path: `IdeveroUITests/PresentationRemediationUITests.swift`. Only its selected-actions/Why test and diagnostic/positioning helpers change; the other two test bodies and all original assertions are frozen. Full-file normalized SHA-256 is review-sealed in the manifest. No directory authorization. Existing 16 simulations remain mandatory; other production/test files remain byte-identical to the prior candidate.
- Targeted workflow adds a Why selector and explicit individual/suite dispatch stage; same devices, Dynamic Type, runner and timeouts. Push `[why-targeted]` runs only the individual test on both sizes and suppresses auto full CI. Suite is dispatched only after individual PASS/PASS; full CI only after suite PASS/PASS and isolation PASS. Version/build remains 0.2.9/15. No IPA/PR/publication until full GREEN; physical retest remains pending.
