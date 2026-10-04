# IDEVERO PRE-1.0 READINESS AUDIT

Fecha: 2026-10-04. Auditoría estática, de evidencia existente y de requisitos oficiales de Apple. SOLO AUDITORÍA Y PLANIFICACIÓN.

PRE-1.0 READINESS: BLOCKED

El bloqueo es de preparación para distribución pública, NO una regresión ni un nuevo fallo demostrado del candidato 0.2.9. No hay un blocker de calidad del prompt demostrado. Existen dos impedimentos concretos para enviar el paquete actual a App Store: acceso a política de privacidad ausente y paquete unsigned sin preparación de distribución. La cuenta Apple/App Store Connect no fue inspeccionada; su estado no se inventa.

## 1. Baseline, alcance y límites

- Repositorio: Nekrobast/idevero-ios.
- Baseline exacto: 36b36c2463e00e3ef148f7d8ac7fe8f7a99d6a1d, release/0.2.9-rc.
- PR #9: OPEN / DRAFT / NOT MERGED, comprobado en GitHub.
- Main: 67b5347a9bf3cb02e65bdf0617ab42b8ed3b6ef6, comprobado intacto.
- Run 37219947690 SUCCESS. Artifact 11310561877, idevero-device-build-0.2.9.
- IPA 0.2.9 (14), SHA-256 8dd6201bbf360a4817bf5f261faf3a790d7f1d93ebd0884f8971f414a072c26d.
- Producción idéntica al build14 físico 61eb2a8490b1bcfcbedbaadfda18b4746035326f.
- Este informe se guarda únicamente en audit/pre-1.0-readiness, creada desde el SHA baseline exacto. Ningún cambio a release/0.2.9-rc, PR #9, producción, tests, versión, build o IPA.
- No se ejecutó CI nuevo ni nuevas pruebas físicas. Reutilizamos evidencia válida; no confundimos inspección estática con mediciones o ejecución.
- Inspeccionados: vistas, modelo/persistencia, coordinación/proveedores, carga local/compilación, proyecto, recursos, tests, workflow, documentación física y contenido del artifact existente. Búsqueda de red/SDK/logging/permisos sobre toda la carpeta Idevero.
- Límites: sin Mac/Xcode local, sin Instruments, sin acceso a cuenta Apple/App Store Connect, sin perfil de consumo o prueba dinámica de red en esta fase. No se certifica ausencia de todo defecto posible.

## 2. Qué está suficientemente terminado

| Área | Evidencia y conclusión |
|---|---|
| Crear y resultado | Editor adaptativo, teclado, creación, scroll al resultado, copiar/compartir/guardar/actualizar presentes. UI grande y compacta GREEN. Funcionalidad principal suficiente; no se necesita un nuevo flujo. |
| Human-Friendly UX | 27 discoveries, 6 iniciales, 21 expandibles, lenguaje claro y detalles técnicos de segundo nivel. Build14 PHYSICAL PASS; no reabrir remediación. |
| Discovery Control | Include/Lock/Exclude, prioridad, decisiones, regeneración y autoridad al reanalizar: gates PASS y evidencia física existente. |
| Historial | Lista, estado vacío, apertura del análisis, edición, regeneración/reanálisis, eliminación. Reconstrucción y compatibilidad de registros previos presentes. Suficiente en camino normal; error de guardado señalado en P1. |
| Persistencia | SwiftData local, UUID por análisis, upsert y análisis serializado. Round-trip y upgrade GREEN; no necesidad de rediseñar el almacenamiento. |
| Ajustes | Explicación de modo automático, privacidad básica y versión/build reales. No necesita preferencias adicionales para 1.0; falta política de privacidad accesible. |
| Local Expert | Recursos JSON incluidos, sin servicio externo; 16 tests PASS y holdouts existentes. Es un producto útil por sí mismo, no una pantalla de error por falta de Apple Intelligence. |
| Foundation Models | Augmentation opcional estructurada y merge protegido, comprobación de disponibilidad y fallback. Compilación PASS; evidencia física de runtime en build12 preservada. No equivale a certificar todos los escenarios en el paquete futuro. |
| ES/EN | Output, títulos, acciones y preservación de literales comprobados en CI; inglés end-to-end físico build12. Interfaz sigue idioma de la petición, no una preferencia persistente del sistema. Hay residuo de primer arranque descrito como P2. |
| Estados | Crear vacío orienta al usuario; Historial vacío explícito; botón deshabilitado para entrada vacía; progreso y errores de análisis; feedback de actualización visible y anunciado. No hace falta un onboarding separado. |
| Navegación/accesibilidad | TabView/NavigationStack nativos, controles semánticos, labels/hints, selección y cabeceras; acciones adaptativas y Dynamic Type. VoiceOver físico final aún debe comprobarse; no se presume un fallo. |
| Calidad del prompt | 24 contratos, 20 semantic holdout, 12 release categorías, PrimaryJobEvidence, literales, ES/EN, no IDs técnicos visibles y control del usuario GREEN. No blocker real demostrado; no perseguir perfección infinita. |

Historia inmutable: build10 FAIL; build11 targeted FAIL; build12 Physical Quality V6 PASS; build13 Human-Friendly UX PARTIAL PASS; build14 Human-Friendly UX PHYSICAL PASS. Fuentes: PHYSICAL-V6-REMEDIATION.md, PHYSICAL-V6-TARGETED-REMEDIATION.md, PHYSICAL-V6-BUILD12-PASS.md, HUMAN-FRIENDLY-UX-BUILD13-PHYSICAL.md, HUMAN-FRIENDLY-UX-BUILD14-PHYSICAL.md.

## 3. Hallazgos clasificados: P0

### P0-01 — Falta enlace accesible a política de privacidad dentro de la app

Evidencia concreta: SettingsView.swift:17-33 muestra modo, dos mensajes de privacidad y versión; no política ni enlace. No se encontraron URLs de política o soporte en producción. Inspección de las demás vistas confirma ausencia de ese acceso.

Apple exige política enlazada dentro de la app y en App Store Connect, incluso sin cuenta o recogida de datos. No implica añadir backend ni analytics. Antes de submission hará falta política pública adecuada y acceso sencillo, por ejemplo desde Ajustes. Una página estática gratuita es suficiente como infraestructura; su contenido debe reflejar el comportamiento real.

Tipo: técnico verificable + contenido legal/operativo externo. Criterio de cierre futuro: URL pública válida, texto aprobado por titular y enlace in-app accesible. [Apple App Review 5.1.1(i)](https://developer.apple.com/app-store/review/guidelines/).

### P0-02 — El paquete validado no es un paquete de distribución App Store

Evidencia concreta: project.pbxproj:30-31 DEVELOPMENT_TEAM vacío; workflow compila Debug unsigned; manifest signing=unsigned; IPA sin LC_CODE_SIGNATURE, _CodeSignature ni embedded.mobileprovision. La re-firma ad-hoc de una copia demuestra capacidad técnica de firma, NO validez de distribución.

Falta producir y validar en una fase autorizada un archive Release firmado para el equipo y App ID correctos, aceptable para App Store Connect. El artifact actual no debe subirse como si fuera ese archive. No afirmamos que Aitor carezca de membresía o certificados: no son visibles aquí.

Tipo: distribución técnica verificable. Cierre futuro: equipo/App ID confirmados, archive/export oficial, firma/provisioning y validación de distribución correctos. [Apple: preparación y envío](https://developer.apple.com/app-store/submitting/).

No se consideran P0: barra flotante; necesidad de onboarding; ausencia de backend; ausencia de SDK externo; supuesta obligación universal de privacy manifest; versión 0.2.9 por sí sola. Apple no exige que la primera versión se llame 1.0: ese cambio corresponderá al objetivo de release, no a una infracción actual.

## 4. P1 — debería resolverse antes de 1.0

### P1-01 — Errores de guardado invisibles y ausencia de confirmación específica de Guardar

CreateView.swift:66 usa try? PromptRecord.upsert; HistoryView.swift:72 usa try? context.save; ResultView.swift:159 llama onSave sin feedback propio. PromptRecord.upsert sí lanza errores, pero la vista los descarta. En caso real de fallo del almacén, el usuario no recibe explicación ni posibilidad informada de copiar su resultado. No se afirma pérdida observada: los caminos normales y upgrades pasan.

Cambio mínimo futuro: confirmación de guardado solo tras éxito y error visible/accesible ante fallo, conservando el resultado para copiar o reintentar. Sin modificar esquema o comportamiento semántico. Tests futuros: save correcto, save fallido controlado y reopen. Es un defecto concreto del manejo de errores, no una mejora hipotética.

### P1-02 — Verificación final de compatibilidad y recursos aún no medida

El proyecto anuncia iOS17+, pero el gate ejecuta simuladores actuales; no existe evidencia en este audit de arranque en iOS17 ni perfil físico de memoria/energía del Release final. CI y evidencia física no muestran un problema. La recomendación es cerrar este hueco con un smoke representativo y perfil corto, NO implementar optimizaciones especulativas.

Incluye dispositivo sin Apple Intelligence, VoiceOver del flujo esencial, modo avión y guardado/reapertura de la versión final. La matriz de sección11 limita repeticiones. Si los resultados son sanos no procede refactor, cache o límites arbitrarios.

## 5. P2 — pulido recomendable

- P2-01: floating bottom bar temporary overlap while scrolling. PRE-1.0 VISUAL POLISH / NON-BLOCKING. No exige corregir antes de 1.0 bajo evidencia actual.
- P2-02: primer arranque sin petición inicia UI en español (RootView:17); placeholder CreateView:140 siempre español; errores base IntelligenceProvider también español. No invalida el ES/EN del prompt. Si se promociona toda la UI como localizada según idioma del sistema, habría que alinear esa promesa o corregir los textos. No es obligatorio añadir selector de idioma.
- P2-03: README conserva título 0.2.8/QualityV5 y hay reportes plantilla históricos. Actualizar documentación de cara al release sin reescribir evidencia. No bloquea binario.
- P2-04: confirmar lectura de mensajes largos/título del resultado en tamaños de texto máximos. Los tests actuales cubren Accessibility Large, no todos los tamaños ni una sesión física VoiceOver completa. Si apareciese un control inaccesible real, re-clasificar por evidencia.

## 6. P3 — post-1.0

- Backup/export/import estructurado propio, sincronización, recuperación avanzada del almacén: no necesarios para la utilidad actual; copiar/compartir prompt ya existe. No prometer recuperación tras desinstalar.
- Preferencias avanzadas de idioma/proveedor, filtros/búsqueda/favoritos en Historial: no requisitos de primera publicación.
- Métricas automáticas, nueva arquitectura, cachés u optimizaciones sin medición: no añadir.
- Nuevos modelos, packs, funciones runtime Relationships/IntentPacks, más plataformas y rediseño: fuera de ruta mínima.

## 7. App Store mandatory checklist

A = obligatorio antes de envío; B = muy recomendable antes de1.0; C = puede esperar. Estas son tareas de preparación, no pruebas de que un campo externo esté ausente. Su estado externo es NO VERIFICABLE.

### A. Técnico verificable en repositorio/binario

- Bundle ID com.aitor93.idevero: formato presente; confirmar propiedad/registro exacto en el equipo, no renombrarlo por preferencia.
- Display name Idevero; icono AppIcon.png 1024x1024 RGB sin alpha, compilado en IPA: presentes. Derechos sobre imagen/nombre requieren confirmación del titular, no se infiere licencia.
- Versión/build 0.2.9/14: válidos actualmente; elegir 1.0 y build único aceptado por Connect cuando se autorice preparación, no incrementarlos en auditoría.
- Launch screen generado, sin onboarding obligatorio; revisar lanzamiento limpio del archive final.
- iPhone-only, deployment iOS17.0; no prometer iPad nativo o Mac. No hace falta añadirlos para publicar.
- Archive Release firmado/distribución: pendiente P0-02. No reutilizar Debug unsigned.
- Info.plist generado sin usage descriptions de cámara/micrófono/localización/contactos y sin permisos que se soliciten en código; no añadir permisos o ATT por precaución.
- No entitlements personalizados ni SDKs externos encontrados; validar entitlements de distribución futura, no añadir CloudKit/PCC/adapters.
- Privacy policy accesible in-app: pendiente P0-01.
- Privacy manifest / Required Reason APIs: procedimiento de comprobación obligatorio; archivo solo cuando uso/API/SDK lo requiere. Véase sección8.

### A. App Store Connect

Preparar ficha/App ID, titular/contacto, categoría apropiada (Productivity propuesta, Info.plist no configura la categoría de Connect), edad mediante cuestionario vigente, derechos/copyright, descripción y keywords, screenshots, Support URL y Privacy Policy URL, declaraciones de privacidad, selección del build firmado y disponibilidad/precio. No fijar edad por intuición ni marcar Kids para un producto general.

Screenshots: al menos una captura válida por conjunto requerido; usar escenas reales sin datos privados y tamaños oficiales. Para iPhone, un conjunto6.9 aceptado evita requerir también6.5; no fabricar capturas iPad para app iPhone-only. [Apple screenshots](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).

Añadir contacto de revisión real; no credenciales demo porque no existe login. Notes explican Crear→descubrimientos→decisiones→reanálisis, guardado local y fallback; recomendarlo por funciones no obvias. No afirmar que Notes, subtitle, marketing URL, promotional text o app preview sean todos obligatorios. Description/keywords/support/copyright/screenshot son campos requeridos. Subtitle útil; marketing URL/promotional text/video opcionales. [Apple campos de versión](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/).

Responder export compliance. No criptografía propia encontrada; no declarar automáticamente “usa cifrado no exento”. Si solo se usa cifrado del OS o ninguno, resolver el cuestionario y establecer ITSAppUsesNonExemptEncryption según resultado; no hace falta certificado CCATS por defecto ni una clave Info.plist concreta si se responde en Connect. [Apple export compliance](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/).

SDK vigente: Apple exige Xcode26+ / SDK iOS26+ desde28-04-2026; el baseline usa Xcode26.6/SDK26.5, y deployment17 supera mínimo permitido13. Revalidar norma al preparar archive. [Apple requisitos vigentes](https://developer.apple.com/news/upcoming-requirements/).

### A. Legal/operativo externo

Membresía activa del Apple Developer Program/equipo, acuerdos pertinentes, identidad/contacto de titular, derechos de recursos, política pública y soporte operativo. Declarar trader status; si corresponde trader en UE, verificar datos exigidos. No inferir trader/no-trader por app gratuita ni compras innecesarias. [Apple DSA](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements/).

Estado de cuenta no inspeccionado. Desde Windows, SIN comprar ni crear registros todavía:
1. https://developer.apple.com/account/ → Membership details: comprobar estado activo, equipo/titular y renovación; compartir solo estado y tipo, nunca secretos/certificados.
2. https://appstoreconnect.apple.com/ → Apps: comprobar si ya existe IDEVERO, su Bundle ID, versiones y builds, sin modificar nada.
3. App → App Information y App Privacy: comprobar categoría/edad/política/declaraciones.
4. Business → Agreements y Compliance/DSA: comprobar pendientes y trader status. Para datos sensibles basta indicar completo/pendiente.
No se necesita Mac para estas lecturas. Signing/archive sí requiere un entorno macOS/Xcode, local o CI autorizado.

### B. Muy recomendable

Cerrar P1-01; smoke accesibilidad/offline/compatibilidad/perfil corto; metadata ES/EN coherente y review notes claras. Consultar derechos/política con asesor si existe incertidumbre concreta, no contratar servicios por defecto.

### C. Puede esperar

Sitio marketing propio, dominio pagado, vídeo promocional, screenshots artísticas adicionales, onboarding animado, sincronización y features nuevas. No condicionan la utilidad ni el envío mínimo legítimo.

Riesgos App Review: política ausente; paquete incorrecto; promesas universales sobre Apple Intelligence; metadata que confunda generar prompts con ejecutar IA/crear apps; privacidad declarada distinta de implementación. No hay evidencia de rechazo por “minimum functionality”: la app ofrece transformación local, control y persistencia; explicar valor real, no crear features para un rechazo hipotético. No existe comunidad/feed público de contenido de usuarios: no añadir backend de moderación por extrapolación automática.

## 8. Privacy audit

Resultado estático: COHERENTE con local-first y OWNER VARIABLE AI COST=0€.

- No URLSession/URLRequest/socket/cliente HTTP, URL remota de datos o Network SDK en producción; Data(contentsOf:) carga JSON del Bundle, no descarga.
- Imports: Foundation, SwiftUI, UIKit, SwiftData y FoundationModels condicional. No Package.resolved/Pods/Carthage/SDK de analytics; IPA sin Frameworks externos embebidos.
- Sin backend, cuenta, publicidad, ad-ID/IDFA/vendor-ID, tracking o telemetría de terceros. UUID de análisis es identidad local de registro, no identificador transmitido.
- Solo print de métricas de duración bajo DEBUG en FoundationModelsProvider:57/224/230; no imprime prompt/petición ni IDs personales. Logs de CI con fixtures no son analytics del usuario.
- PromptRecord almacena título, idea original, prompt completo, decisiones y análisis codificado con proveedor y timestamps. La serialización duplica parte de la información en campos/JSON: almacenamiento deliberado, no transmisión; historial puede crecer sin cuota propia.
- SwiftData usa contenedor local sin entitlement CloudKit. Sin gestión explícita de exclusión de backup o cifrado custom. Un backup del dispositivo gestionado por Apple puede contener el almacén: “local-first” no significa garantía de nunca entrar en copia iCloud del sistema.
- Copy escribe el prompt en UIPasteboard y ShareLink entrega texto a destino elegido por el usuario. Portapapeles universal/servicio externo elegido puede sacar texto del dispositivo. No decir “ningún dato puede salir jamás”; sí “la app no envía tus peticiones a servidores propios”.
- Sin permisos sensibles o ATT requeridos por uso encontrado; permiso de tracking no se añade cuando no hay tracking.
- Eliminación de registros disponible; no hay cuenta que requiera eliminación de cuenta. No se necesita botón GDPR de cuenta inexistente.
- Recuperación: reconstrucción de JSON/legacy, no reparación de store corrupto ni recuperación tras desinstalación. El contenedor predeterminado no ofrece UX personalizada ante error de inicialización; sin fallo observado. Evitar promesa de backup infalible.
- “Data Not Collected” es consistente para procesamiento estrictamente local y sin servicios propios; decisión final debe cubrir archive y políticas reales. El contenido libre guardado SOLO local no obliga por sí mismo a declarar recogida remota. [Apple definición de datos recogidos](https://developer.apple.com/app-store/app-privacy-details/).

Privacy manifest: no PrivacyInfo.xcprivacy en fuente ni IPA. Búsqueda no encontró UserDefaults/@AppStorage/@SceneStorage, file timestamp APIs, boot/systemUptime, disk-space APIs o keyboard APIs de categorías Required Reason utilizadas directamente por app; Date.timeIntervalSinceReferenceDate no es systemUptime. SwiftData del OS no se convierte automáticamente en SDK externo de manifest obligatorio. No hay evidencia para seleccionar un código de razón o declarar ausencia de manifest P0. Antes de envío analizar archive/Privacy Report y warnings de validación; si una API de la lista está presente, declarar su razón aprobada real, nunca inventada. Ausencia de coincidencias estáticas no sustituye validación de binario. [Apple Required Reason APIs](https://developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).

## 9. Foundation Models audit

FoundationModelsProvider:10-21 verifica canImport y iOS26+ y consulta SystemLanguageModel.default.availability. Analyze calcula primero Local Expert, después solo si ready crea LanguageModelSession y llama respond con generación estructurada. Modelo usado: default on-device; no herramientas HTTP, adapters, modelo externo ni selección Private Cloud Compute.

IntelligenceCoordinator:16-20/28-35 elige local si unavailable; errores de inferencia vuelven a local; CancellationError se propaga, no se disfraza como éxito. Fallback no muestra alerta propia porque el resultado local es válido; badge visible depende de intelligenceMode realmente generado. Reanalyze conserva decisiones; regenerate recompila local sin modelo.

Escenarios:
- iOS17-25: app local, sin ruta Foundation.
- iOS26+ en hardware no compatible: unavailable→local.
- Apple Intelligence desactivado, modelo no preparado, idioma/región no compatible: unavailable→local; consulta reasons del framework, no hardcodea hardware.
- Error/contexto excesivo/guardrail en respond: coordinator vuelve a local; no coste remoto.
- Modelo disponible y descargado: inferencia on-device apta offline. Preparación/descarga inicial del modelo corresponde a Apple y puede requerir conexión; no prometer Apple augmentation siempre disponible en modo avión.
- Hardware Apple Intelligence: iPhone15Pro/ProMax y familias iPhone16 o posteriores compatibles según Apple; la autoridad operacional es availability, no una lista congelada. [Apple compatibilidad](https://support.apple.com/en-ie/121115).
- Sin timeout propio visible en respond. No se ha observado hang: medir latencia breve antes de decidir cambios, no crear blocker hipotético.
- No entitlement especial de adapters/PCC requerido por la implementación encontrada. No añadirlo por novedades del framework.

Hay evidencia física runtime/badge de build12 en PHYSICAL-V6-BUILD12-PASS.md. FOUNDATION-MODELS-PHYSICAL-REPORT.md es plantilla vacía, no resultado. Build14 físico reporta otro alcance y su CI tiene skip device-only. No se borra evidencia12 ni se inventa que14 ejecutó pruebas no relatadas. El gate final requiere smoke pequeño del archive candidato en hardware compatible, no repetir10casos antiguos ni exigir siempre una discovery Apple.

Marketing correcto: “Funciona con conocimiento local. En dispositivos y sistemas compatibles, aprovecha Apple Intelligence cuando está disponible.” Incorrecto: “Apple Intelligence en cualquier iPhone”, “IA ilimitada siempre disponible”, “genera respuestas perfectas” o “ejecuta ChatGPT”. El nombre CHATGPT en target indica destino del prompt, no llamada a OpenAI. [Apple framework y availability](https://developer.apple.com/videos/play/wwdc2025/286/).

## 10. UX audit: material, no estética

Barra inferior: RootView mide altura de tabBar y CreateView:74-79 añade safeAreaInset transparente de altura medida+20. ResponsiveLayoutUITests:48-51 comprueba último control con margen8pt por encima de la barra; PASS en grande y compacto Accessibility Large. Build14 físico confirma scroll y acceso a las21 discoveries.

Conclusión objetiva: durante scroll la barra puede tapar visualmente contenido en esa posición momentánea, pero no se demuestra ocultación permanente o controles inalcanzables. Un control situado detrás de la barra en ese instante necesita desplazarse; no implica que no pueda pulsarse tras scroll. Safe-area/hit-testing no quedan universalmente certificados por una prueba, pero evidencia actual contradice pérdida real en Crear. HistoryDetailView no incorpora el clearance adicional de CreateView; usa ScrollView nativo. Es alcance de smoke final, NO una regresión probada.

Clasificación P2. No corregir antes de1.0 como condición bajo evidencia actual. Solo re-clasificar si aparece caso reproducible donde incluso con scroll máximo un control queda oculto/inaccesible, o foco VoiceOver no permite operarlo. No usar preferencias visuales como P0/P1.

Primer lanzamiento: editor y orientación directa, sin cuenta/configuración obligatoria. No onboarding adicional. Loading de primera creación en botón; actualización con banner independiente del scroll; errors de análisis visibles. Teclado se cierra al crear y permite acción en toolbar; UI GREEN. Copiar carece de confirmación propia (P2 opcional), guardar carece de feedback/errores (P1 concreto). Historial vacío y Ajustes existen. No crear tour, pantallas extra, nuevo sistema de navegación o tab bar custom.

## 11. Final release testing matrix

MANDATORY significa gate de proyecto recomendado por esta auditoría, NO que Apple obligue a cada prueba individual. RECOMMENDED no impide automáticamente publicación si hay evidencia equivalente justificada; OPTIONAL no entra en ruta mínima.

| Prueba | Clase | Alcance mínimo y evidencia reutilizable |
|---|---|---|
| Regresión completa | MANDATORY | Tras cambios/version/configuración autorizados, clean XCTest+24 contratos+20 semantic+12 release+persistence/upgrade+DiscoveryControl/I-L-E+authority+PrimaryJobEvidence+concurrency fast→slow/gen→reanalyze+LocalExpert+ES/EN/literals/IDs+HumanFriendly/build14+regex67; mismos asserts. Hoy no repetir por solo documento. |
| UI grande/compacta | MANDATORY | iPhone17ProMax + iPhone16e Accessibility Large, 11/11 actuales como baseline; smoke final de acciones finales en Crear/Historial. |
| Archive Release/distribution | MANDATORY | Compile Foundation, archive firmado, recursos/iconos/Info.plist/entitlements, privacy report y validación oficial. Nuevo commit/hash solo al autorizar fase. |
| Smoke físico final | MANDATORY | Crear→Copiar/Guardar→Historial→decisión→Reanalyze→reabrir; sin repetir toda batería V6 ya cerrada. |
| Local Expert + modo avión | MANDATORY | Una petición ES y una EN con augmentation no disponible; crear/guardar/reabrir sin conectividad. OS puede intentar descargar modelo, no cliente de app. |
| Foundation físico | MANDATORY si se mantiene promesa de augmentation | Un dispositivo compatible con modelo ready: inferencia real y resultado/badge; offline tras descarga; comprobar fallback unavailable y decisiones. Reusar evidencia12 para amplitud, no repetir casos innecesarios. No exigir finding Apple para toda petición. |
| Instalación limpia | MANDATORY | Launch/editor, vacío, recursos, crear/guardar y política accesible. Usar copia de pruebas sin borrar historia del usuario. |
| Save success/failure/restart | MANDATORY | Cierre P1-01, errors controlados, durabilidad tras relanzar, feedback no falso. |
| Update/persistence | RECOMMENDED | Tests automáticos upgrade obligatorios arriba; una actualización física conservando historial si misma identidad/entitlements lo permiten. Si distribución cambia App ID, no prometer migración desde AltStore ni “probar upgrade” mediante reinstalación destructiva. |
| Hardware real sin Apple Intelligence | RECOMMENDED | iPhone de menor memoria compatible; si no hay disponible usar CI iOS17+ y estado unavailable, documentar limitación sin comprar dispositivo por defecto. |
| iOS mínimo17 | MANDATORY | Launch/smoke local en runtime o hardware válido17; si no disponible, resolver compatibilidad antes de afirmar soporte, no subir deploymenttarget automáticamente. |
| ES/EN | MANDATORY | Smoke conciso outputs/literales/acciones; sistema inglés para detectar residuos de primer arranque, sin rehacer holdout completo físico. |
| Dynamic Type | MANDATORY | CI Accessibility Large más vistazo físico al resultado; tamaños máximos adicionales RECOMMENDED. |
| VoiceOver | RECOMMENDED | Una pasada Crear→resultado→Guardar→Historial→decisión y feedback; labels/selected-state y orden, no todo catálogo. Cualquier barrera reproducible de flujo esencial requiere resolverla antes de publicar. |
| Memoria/latencia | RECOMMENDED | Perfil corto Release: cold/warm local+Foundation, repetir generación/reanálisis y abrir historial representativo; anotar picos, retorno a reposo y responsividad, sin presupuestos inventados. |
| Batería/energía | RECOMMENDED | Sesión corta y reposo: ausencia de trabajo continuo/consumo anómalo. No benchmark extensivo ni requisito de compra hardware. |
| Crash testing | MANDATORY para smoke, OPTIONAL fuzz exhaustivo | Smoke sin crash/hang, resultado antiguo no sustituye nuevo, historial duradero. Corruption/fuzz/largas sesiones son opcionales salvo incidencia. |
| Red y privacidad dinámica | RECOMMENDED | Sesión con observación de tráfico/sin red, no confundir OS/downloads/Share con envío propio; checks estáticos y archive obligatorios arriba. |
| Recuperación backup/fullimport | OPTIONAL | No feature prometida; no construirla para cerrar gate. |

Criterio de salida final: todos los obligatorios PASS, recomendaciones relevantes ejecutadas o limitación documentada, cero regresión conocida de flujo esencial y requisitos App Store completos. El gate de equivalencia CI actual prohíbe cualquier diff de producción desde61; futuras correcciones autorizadas harán fallarlo por diseño. Adaptar explícitamente esa política a una baseline/diff aprobado de1.0 conservando aislamientos y todos los contratos, no quitar assertions ni utilizar run0.2.9 para certificar código diferente.

## 12. Coste real mínimo

| Tipo | Coste y decisión |
|---|---|
| Obligatorio distribución | Apple Developer Program: 99USD/año o precio local donde esté disponible; importe exacto EUR/impuestos depende de checkout. Si membresía ya activa no hay nueva compra inmediata. No se inspeccionó cuenta ni se compró nada. |
| Obligatorio soporte/política | URLs accesibles y canal contacto; pueden alojarse como páginas estáticas gratuitas. Dominio propio NO obligatorio. Trabajo de preparación es coste de tiempo, no API por uso. |
| Entorno build | macOS/Xcode requerido; runners macOS standard de repo público permiten gate sin comprar Mac mientras condiciones de GitHub aplicables se mantengan. Signing secretos deben protegerse y no exponerse en logs. Mac nuevo/hosting pagado no son compras obligatorias. |
| AI variable | 0€ por uso para propietario: Local Expert y modelo on-device, sin keys/cuotas/backend pagado. Apple establece acceso on-device sin pago por inferencia; conservar arquitectura actual. |
| Opcional | Dominio, Mac propio, revisión legal si necesaria, diseño marketing, servicios CI extra, dispositivos adicionales. No presupuestarlos como inevitables. |
| Evitable | API IA, backend, analytics, ads, servidores/sync y herramientas premium. No añadir. |

[Apple membresía](https://developer.apple.com/programs/enroll/) confirma99USD/año; no convertir a una cifra EUR fija sin precio local. [Apple: inferencia gratuita on-device](https://www.apple.com/sg/newsroom/2025/09/apples-foundation-models-framework-unlocks-new-intelligent-app-experiences/) confirma ausencia de coste de inferencia; el código no integra servicio cobrable. Para app gratuita sin IAP, no hay comisión de venta a descontar de ingresos inexistentes. Si se decide monetizar, acuerdos/fiscalidad/comisiones son evaluación nueva, no requisito inferido.

## 13. Ruta mínima 0.2.9 → 1.0

| Fase futura | Objetivo/cambios necesarios | Motivo/riesgo | Pruebas | Criterio de salida |
|---|---|---|---|---|
| A — Preparation decisions | Confirmar titular/equipo/Bundle ID/membresía existente, soporte/política y territorios/DSA; bosquejo metadata fiel. Sin compra ni submission automática. | Necesario para cerrar externos; riesgo bajo, datos legales requieren decisión humana. | Lecturas Connect/account y revisión URLs/textos. | Datos verificados y autorización para cambios mínimos; no identidad/secretos inventados. |
| B — Minimal compliance/reliability remediation | Solo enlace privacidad y feedback/error de Save/Create/History; textos necesarios, sin motor/arquitectura/features. Rama nueva desde candidato; no tocar historial físico. | P0-01/P1-01; riesgo bajo-medio en almacenamiento/UI. | Unit/savefailure UI y gates originales. | Política accesible y save error/success correcto; productiondiff acotado aprobado. |
| C — Release preparation | Solo al autorizar: versión1.0/build adecuado, equipo/configuración Release/archive, manifest si razón real, metadata/screenshots. Ajustar gate freeze a baseline aprobada sin aflojar tests. | P0-02 y requisitos de submission; riesgo medio firma/configuración. | Gate completo y archive validation, privacy/symbol/resource checks. | Candidate exacto GREEN firmado correctamente, hash/evidencia nueva trazable. |
| D — Final bounded physical gate | Smoke pequeño de final, local/offline, Foundation available/unavailable, save/restart, acceso política; recomendaciones de accesibilidad/perfil. | Valida cambios/configuración sin repetir fases pasadas; riesgo bajo. | Matriz11, sin repetir10casos Foundation ni todaV6. | Sin fallo material; limitaciones explicitadas y ficha lista para posterior decisión de envío. |

Ninguna fase autoriza merge/submission/TestFlight/compra por sí sola. Esas acciones requieren instrucciones posteriores. Este audit NO declara1.0READY.

## 14. Qué no merece la pena hacer antes de1.0

No rehacer UX ya PHYSICALPASS ni corregir barra por estética; no onboarding obligado; no backend/cuentas/analytics/ads/OpenAI; no features extra para evitar rechazo hipotético; no refundar persistencia o compilador; no nuevos packs/runtime Relationships/IntentPacks; no naming; no performance refactor sin medición; no repetir suites físicas históricas completas; no solicitar entitlements/permisos o manifest con razones inventadas; no dominio/Mac/AIAPI pagados por defecto.

## 15. Exact recommended next phase

PRE-1.0 PREPARATION DECISIONS + APPROVAL OF MINIMAL COMPLIANCE/RELIABILITY REMEDIATION.

Primero confirmar las lecturas externas de sección7 y el titular/URL pública de privacidad/soporte; después pedir autorización explícita para implementar SOLO P0-01/P1-01 en una nueva rama. No es necesario reabrir motor, Discovery Control, grounding, providers, persistencia de esquema o build14 físico. P0-02 se cierra en preparación Release posterior, no generando otra IPA unsigned ahora.

Cambios realizados por esta fase: únicamente este documento en rama audit/pre-1.0-readiness. NO producción/tests/workflow/version/build; NO nueva IPA/CI/PR/merge; PR#9 y release permanecen intactos.

PRE-1.0 READINESS: BLOCKED

