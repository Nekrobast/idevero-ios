# Instalar IDEVERO en iPhone desde Windows con AltStore Classic

Esta ruta instala el IPA privado de IDEVERO 0.2.2 build 4 sin Apple Developer Program. El IPA sale deliberadamente sin firma de CI; AltServer lo firma con el Apple Account introducido **solo en AltServer/Apple**. No escribas contraseñas, códigos 2FA ni tokens en ChatGPT, GitHub o este documento.

## Requisitos

- Windows 10 o posterior.
- iPhone 17 Pro Max, cable USB y conexión a Internet.
- Apple Account gratuito.
- AltServer para Windows descargado de `https://altstore.io/`.
- iTunes e iCloud descargados directamente desde Apple, no desde Microsoft Store. Si ya usas la versión Microsoft Store de iCloud, consulta la alternativa oficial de AltStore.
- Artifact privado `idevero-device-build` descargado desde la ejecución de GitHub Actions.

## Opción recomendada: AltStore Classic

1. Descarga el artifact `idevero-device-build` desde **GitHub > Nekrobast/idevero-ios > Actions > Idevero iPhoneOS unsigned device build > Artifacts** y descomprímelo.
2. Compara el SHA-256 del IPA con `Idevero-iOS-0.2.2-DeviceUnsigned.ipa.sha256` usando PowerShell:

   ```powershell
   Get-FileHash .\Idevero-iOS-0.2.2-DeviceUnsigned.ipa -Algorithm SHA256
   ```

3. Instala iTunes e iCloud desde los enlaces directos indicados en la guía oficial de AltStore y reinicia Windows si se solicita.
4. Descarga AltServer para Windows desde `https://altstore.io/`, extrae `AltInstaller.zip`, ejecuta `Setup.exe` y después ejecuta AltServer como administrador.
5. Conecta el iPhone por USB, desbloquéalo y acepta **Confiar en este ordenador**.
6. Abre iTunes, selecciona el iPhone y activa **Sincronizar con este iPhone mediante Wi‑Fi**.
7. En el icono de AltServer de la bandeja, selecciona **Install AltStore** y el iPhone.
8. Introduce el Apple Account únicamente en el diálogo de AltServer. La autenticación y cualquier 2FA se completan allí.
9. En iPhone abre **Ajustes > General > VPN y gestión de dispositivos** y confía en el perfil si iOS lo solicita.
10. En iOS 16 o posterior abre **Ajustes > Privacidad y seguridad > Modo de desarrollador**, actívalo, reinicia y confirma.
11. Abre AltStore Classic en el iPhone. En **My Apps**, pulsa `+`, selecciona el IPA desde Archivos y espera a que AltStore/AltServer lo firme e instale.

## Alternativa: IPA directa desde AltServer

AltServer también documenta sideload directo: mantén pulsada **Shift** mientras haces clic en el icono de AltServer para mostrar **Sideload .ipa…**, elige el IPA y el iPhone. Esta vía exige reinstalación manual cada siete días. AltStore Classic permite refresco con AltServer.

## Por qué no AltStore PAL

AltStore PAL es el marketplace alternativo europeo basado en distribución/notarización. No es la ruta para instalar este IPA privado sin notarizar. Para esta prueba utiliza **AltStore Classic/AltServer**.

## Primer arranque y prueba local

1. Abre IDEVERO. Si iOS vuelve a pedir confianza, complétala en **VPN y gestión de dispositivos**.
2. Introduce `Escribe un email corto de agradecimiento`.
3. Confirma launch sin crash, Knowledge cargado, prompt visible y Local Expert operativo.
4. Después ejecuta los diez casos de `PHYSICAL-IPHONE-TEST-PLAN.md`, empezando por `Quiero crear una app para apicultores`.
5. Completa `WINDOWS-PHYSICAL-TEST-REPORT.md` sin anotar Apple ID, serial, UDID ni credenciales.

## Límites de la cuenta gratuita

- Los perfiles/apps gratuitos caducan a los siete días y deben refrescarse o reinstalarse.
- Apple limita a tres apps sideloaded activas por dispositivo y diez App IDs; AltStore cuenta dentro del límite.
- El PC con AltServer debe estar accesible por USB o la misma Wi‑Fi para refrescar.
- Esta ruta permite prueba manual de runtime, pero no ejecuta XCTest físico.

## Si falla

- **Device not found:** desbloquea el iPhone, reconecta USB, acepta confianza y comprueba iTunes.
- **Developer Mode required:** actívalo y completa el reinicio.
- **Maximum apps/App IDs:** desactiva/elimina otra app o espera la caducidad del App ID.
- **Bundle identifier conflict:** AltServer normalmente reescribe los identificadores para la firma. Guarda el error exacto sanitizado; no cambies el bundle del repositorio sin evidencia.
- **Foundation unavailable:** es un resultado válido; confirma que Local Expert genera el prompt sin crash.

Fuentes primarias: `https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows`, `https://faq.altstore.io/altstore-classic/your-altstore`, `https://faq.altstore.io/release-notes/altserver`, `https://developer.apple.com/help/account/basics/about-your-developer-account/`.

