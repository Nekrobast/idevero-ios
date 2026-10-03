# IDEVERO 0.2.8 build 10 — Physical Quality V6

Do not pre-fill results. CI does not prove Foundation Models runtime quality.

DEVICE: iPhone 17 Pro Max  
IOS:  
IDEVERO: 0.2.8 build 10  
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

TEST 2 DOMAIN AMBIGUITY: PASS / FAIL  
NOTES:

## Test 3 — Technical identifiers

Use a natural request containing legitimate technical identifiers.

Check: legitimate identifiers survive; internal tokens do not appear.

TEST 3 TECHNICAL IDENTIFIERS: PASS / FAIL  
NOTES:

## Test 4 — Simple email

Check: proportional result, no overengineering, no oversized Domain Context.

TEST 4 SIMPLE REQUEST: PASS / FAIL  
NOTES:

## Test 5 — English

Use a fully English request.

Check: coherent English display, no accidental Spanish, standards and proper names preserved.

TEST 5 LANGUAGE: PASS / FAIL  
NOTES:

## Test 6 — Discovery Control

In a real generation: include an Optional item, exclude an Included item, lock another item, then generate the prompt. Verify all three decisions alter the prompt. Reanalyze and verify semantic persistence.

TEST 6 DISCOVERY CONTROL: PASS / FAIL  
NOTES:

## Test 7 — History

Save, open History, regenerate and reanalyze.

Check: no duplicates; locks, exclusions and acceptance preserved; prompt remains correct.

TEST 7 HISTORY: PASS / FAIL  
NOTES:

## Test 8 — Rapid generation

Start generation A, then start B quickly. The older A response must never replace B visually.

TEST 8 RAPID GENERATION: PASS / FAIL  
NOTES:

## Test 9 — Bottom tab

Scroll to the end of both `Lo que Idevero añadió` and `Prompt generado`.

Check: final content visible, actions tappable, nothing under the tab bar, scrolling correct.

TEST 9 BOTTOM TAB: PASS / FAIL  
NOTES:

FULL GENERATED PROMPTS ATTACHED: YES / NO  
SCREENSHOTS ATTACHED: YES / NO  

PHYSICAL QUALITY V6: DO NOT AUTO-FILL
