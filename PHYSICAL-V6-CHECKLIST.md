# IDEVERO 0.2.8 build 11 — Physical Quality V6 retest

Do not pre-fill results. CI does not prove Foundation Models runtime quality.

DEVICE: iPhone 17 Pro Max
IOS:
IDEVERO: 0.2.8 build 11
APPLE FOUNDATION MODELS: AVAILABLE / UNAVAILABLE

## Test 1 — Apicultores

Input: `Quiero crear una app para apicultores`

Check: no domain or primary-job drift; no unrelated fertilizer content; no duplicates or internal tokens; coherent Spanish; Apple inference is visibly presented as inference; grounded primary jobs; useful questions; proportional context; no scope creep; useful final prompt.

Screenshots: Contexto del dominio; Trabajo principal; Datos/Preguntas por confirmar; Lo que Idevero añadió; prompt completo; bottom of screen.

TEST 1 APICULTORES: PASS / FAIL
NOTES:

## Test 2 — Domain ambiguity

Use a short sector request unrelated to beekeeping.

Check: IDEVERO asks naturally before inventing certainty.
For broad sector/event requests, verify that no arbitrary workflow is privileged
and unconfirmed explanations do not use essential/necessary/must wording.

TEST 2 DOMAIN AMBIGUITY: PASS / FAIL
NOTES:

## Test 3 — Technical identifiers

Use a natural request containing legitimate technical identifiers.

Check: legitimate identifiers survive; internal tokens do not appear.
Use two new technical field names not used in earlier physical tests and verify
their exact spelling in the original request and explicit-literal block.

TEST 3 TECHNICAL IDENTIFIERS: PASS / FAIL
NOTES:

## Test 4 — Simple email

Check: proportional result, no overengineering, no oversized Domain Context.

TEST 4 SIMPLE REQUEST: PASS / FAIL
NOTES:

## Test 5 — English

Use a fully English request.

Check: coherent English display, no accidental Spanish, standards and proper names preserved.
Check Local Expert discoveries, reasons, perspectives, placeholders and questions
as well as headings. Repeat with Spanish and confirm it remains Spanish.

TEST 5 LANGUAGE: PASS / FAIL
NOTES:

## Test 6 — Discovery Control

In a real generation: include an Optional item, exclude an Included item, lock another item, then generate the prompt. Verify all three decisions alter the prompt. Reanalyze and verify semantic persistence.
Include and Lock must be identifiable as confirmed requirements. Exclude must
also prevent the same item entering through Domain Context. Repeat after Save
and reopening History; reanalysis must retain one history record.

TEST 6 DISCOVERY CONTROL: PASS / FAIL
NOTES:

## Test 7 — History

Save, open History, regenerate and reanalyze.

Check: no duplicates; locks, exclusions and acceptance preserved; prompt remains correct.

TEST 7 HISTORY: PASS / FAIL
NOTES:

## Test 8 — Rapid generation

Check visible progress, disabled update/discovery actions and clear completion
when regenerating. If the UI prevents starting B during A, record that protection
as observed; do not mark the manual overlapping scenario FAIL or claim it ran.
CI separately exercises fast-to-slow and generation-to-reanalysis authority.

TEST 8 RAPID GENERATION: PASS / FAIL
NOTES:

## Test 9 — Bottom tab

Scroll to the end of both `Lo que Idevero añadió` and `Prompt generado`.

Check: final content visible, actions tappable, nothing under the tab bar, scrolling correct.

TEST 9 BOTTOM TAB: PASS / FAIL
NOTES:

FULL GENERATED PROMPTS ATTACHED: YES / NO
SCREENSHOTS ATTACHED: YES / NO

Check all perspective labels are human/localized and contain no machine IDs.

PHYSICAL QUALITY V6: AWAITING IPHONE RETEST
