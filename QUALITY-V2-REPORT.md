# IDEVERO Foundation Models Quality V2

## Baseline físico

IDEVERO 0.2.3 build 5 fue instalado y ejecutado en un iPhone 17 Pro Max. Foundation Models respondió, la UI mostró `Apple Foundation Models`, se observó una deduplicación `LOCAL KNOWLEDGE + APPLE MODEL INFERENCE` y un hallazgo exclusivamente Apple. La limitación observada fue cualitativa: el prompt final seguía dominado por requisitos universales de producto.

## Causa raíz auditada

1. El contrato Apple solo expresaba `concept`, `reason` y `lens`; no obligaba a distinguir workflows, entidades, relaciones, fallos o decisiones.
2. El merge añadía provenance al duplicado local, pero descartaba siempre la razón y la perspectiva Apple.
3. `SpecializedCompiler.product()` aplanaba todos los hallazgos en una sola lista `concepto: razón`, sin jerarquía ni peso explícito para contexto sectorial.
4. La frase inicial concatenaba `Diseña y especifica` con el input original y producía construcciones como `Diseña y especifica Quiero crear…`.

## Cambios V2

- Instrucción compacta orientada a conocimiento que un experto del dominio sabe y el marco genérico no contiene.
- Contrato estructurado enriquecido con `kind`, `materiality`, `userIntentFit` y `scopeRisk`; unknowns con impacto y razón.
- Máximo de seis findings y tres unknowns; se prefieren 3–6 findings materiales.
- Quality gate previo al merge: valida forma, tipo, materialidad, ajuste a intención, riesgo de scope, razón informativa y reformulación del input.
- Merge sin duplicación que puede conservar la razón Apple cuando es materialmente más específica que la local; nunca concatena texto indiscriminadamente.
- Compiler de producto con jerarquía separada para outcome, conocimiento de dominio, requisitos esenciales, unknowns y alcance/calidad.
- Findings con provenance Apple —incluidos los fusionados— aparecen en la sección sectorial.
- Métricas locales DEBUG para inferencia, merge y compilación; no contienen el prompt.

## Garantías conservadas

- Local Expert sigue controlando task, intent, domain, target, prioridades y prompt final.
- Foundation Models no escribe el prompt final.
- IDs estables, locks, exclusions y estados persisten.
- No se modificó Knowledge ni el modelo persistente `Discovery`.
- No se añadió vocabulario de apicultura, veterinaria, ascensores, bodegas, fotografía o talleres al runtime.

## Validación

CI cubre rejection de findings genéricos, aceptación de findings materiales, deduplicación, provenance, preservación selectiva de una razón Apple más profunda, locks/exclusions, frase natural, jerarquía sectorial, routing de 12 holdouts y compactación del email simple.

La calidad semántica real de V2 debe volver a probarse en el iPhone físico. El Simulator valida estructura y regresión, pero no ejecuta Foundation Models.
