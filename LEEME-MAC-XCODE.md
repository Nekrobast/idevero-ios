# Primer uso en Mac con Xcode

1. Descomprime `Idevero-iOS-0.2.1-FirstBuildReady.zip`.
2. Instala Xcode con el SDK necesario, ábrelo una vez y acepta sus componentes.
3. Abre `Idevero.xcodeproj`.
4. Selecciona el scheme `Idevero` y un iPhone Simulator con iOS 17 o posterior.
5. Espera a que termine la indexación. Usa **Product → Clean Build Folder** y después **Product → Build**.
6. Si falla, copia archivo, línea y error exacto en `XCODE-FIRST-RUN-CHECKLIST.md`.
7. Ejecuta **Product → Test** y conserva el resultado de cada test.
8. Ejecuta Local Expert con `app para apicultores`, `email gracias`, `Excel stock` e `imagen samurái lluvia`.
9. Guarda un prompt, abre History y confirma que reaparecen input, prompt, routing, discoveries, estados y provenance.
10. Desde History usa **Regenerar**: no debe cambiar el análisis semántico ni invocar Apple.
11. Desde History usa **Reanalizar**: debe recalcular y conservar locks/exclusions.
12. Bloquea y excluye discoveries, cierra/reabre el registro y repite ambos controles.
13. Solo después pasa a Foundation Models con el checklist de dispositivo.

## Foundation Models en dispositivo

1. Usa un iPhone, iOS y configuración compatibles con Apple Intelligence y Foundation Models.
2. Activa Apple Intelligence y espera a que el modelo del sistema esté disponible.
3. Selecciona el iPhone como destino y configura solo la firma local requerida por Xcode.
4. Ejecuta `app para apicultores`: el modo debe indicar `APPLE AUGMENTED + LOCAL EXPERT` cuando esté disponible.
5. Si no está disponible o falla, debe indicar Local Expert y generar igualmente.

No compres Apple Developer Program para estas pruebas. No añadas claves API.
