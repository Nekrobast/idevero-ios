# IDEVERO 0.2.3 → 0.2.4: comparación de calidad

## Antes

- Apple devolvía `concept/reason/lens` sin categoría de conocimiento ni señales de materialidad o scope.
- Un duplicado local recibía provenance Apple, pero la razón Apple se perdía.
- El prompt de aplicación mezclaba requisitos genéricos y sectoriales en una lista plana.
- El comienzo podía ser gramaticalmente pobre: `Diseña y especifica Quiero crear…`.

## Después, verificable sin inferencia física

- El contrato distingue workflow, entidad, relación, decisión, dato, restricción, fallo, riesgo, aceptación y contexto operativo.
- El filtro rechaza tipos genéricos, baja materialidad, bajo intent fit, alto scope risk, razones superficiales y paráfrasis del input.
- Un duplicado continúa siendo uno; si la razón Apple es claramente más específica, sustituye la razón superficial local conservando estado, prioridad, ID y ambas procedencias.
- El compiler coloca conocimiento Apple en `Contexto y requisitos específicos del dominio`, separado de requisitos universales.
- La petición se conserva como `Encargo original` y la instrucción principal ya no concatena verbos incompatibles.
- Emails simples mantienen el compiler compacto y no reciben jerarquía de producto.

## Holdout estructural

Se ejecutan en XCTest doce entradas: seis aplicaciones de sectores distintos, marketplace, spreadsheet, shopping, travel, email e image. El test verifica que V2 conserva la forma de tarea adecuada. Los casos de aplicación no incorporan respuestas sectoriales programadas.

## Comparación semántica honesta

No se inventan respuestas de Foundation Models para el holdout: CI no dispone del runtime Apple Intelligence. La comparación semántica AFTER para apicultura y los demás sectores queda `AWAITING PHYSICAL RETEST`. La evidencia de 0.2.3 se conserva como baseline físico.

## Criterio de shallow augmentation

En la revisión física, si al retirar el nombre del sector los hallazgos Apple siguen siendo plausibles para casi cualquier app, el resultado se marcará `SHALLOW DOMAIN AUGMENTATION`. Este criterio es de evaluación; no se usa como keyword rule de producción.
