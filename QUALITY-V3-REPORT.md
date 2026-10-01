# IDEVERO Foundation Models Quality V3

## Physical Quality V2 finding

On iPhone 17 Pro Max, 0.2.4 build 6 produced two Apple findings for `Quiero crear una app para apicultores`: harvest-date recording and local-market data exchange. The first was context-dependent; the second expanded into an unrequested commercial workflow. The unknown about frequently produced products had low impact on the product's primary architecture.

## Root cause

Quality V2 trusted model self-ratings too heavily and used lexical specificity as a major acceptance signal. A peripheral idea could label itself HIGH/HIGH/LOW, provide a long causal-sounding reason and pass without being anchored to the domain's core structure.

## Quality V3

- One on-device inference builds a Domain Frame before findings.
- The frame separates actors, entities, relationships, workflows, decisions and constraints.
- Broad product requests can mark the primary job `UNDERSPECIFIED` and return 2–3 materially different candidates without choosing one.
- Findings carry semantic role, anchor, assumption level, confirmation need, scope dependency and decision impact.
- Model materiality/fit/risk values remain claims, not acceptance proof.
- Unanchored findings are rejected. Optional/context-dependent findings remain OPTIONAL. Business expansions are rejected from the principal prompt.
- Unknowns are ranked by architecture, workflow and scope impact; maximum three.
- Product prompts expose a prominent grouped domain frame while compressing universal product scaffolding into one instruction.

## Authority and privacy

Local Expert still owns task, intent, domain, target, locks, exclusions, priority, merge and final compilation. Foundation Models remains on-device and never writes the final prompt. No API, backend or network provider was added.

## Physical status

Quality V3 model output is not claimed before the 0.2.5 physical retest. CI validates the contract, gate, merge, compiler, regressions and iPhoneOS compilation.

## Validated CI baseline

- Commit: `f9afc273c12a293b0d5d54ea20e86678fa57d4d3`
- GitHub Actions run: `36862684183`
- XCTest: 40 passed, 0 failed, 1 physical-device-only test skipped
- UI tests: 2 passed
- Regex: 67/67 passed
- Generic iPhoneOS ARM64 build: PASS
- Foundation Models Simulator and iPhoneOS compilation: PASS
- Physical Quality V3 output and latency: awaiting iPhone retest
