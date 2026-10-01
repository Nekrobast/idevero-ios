# Instalar IDEVERO en un iPhone gratis

Esta guía usa Xcode y un Apple Account con **Personal Team**. No requiere comprar Apple Developer Program. Sí requiere un Mac, un iPhone, conexión inicial y Xcode compatible con el SDK del proyecto.

## 1. Preparar el Mac

1. Instala Xcode desde el Mac App Store o Apple Developer Downloads.
2. Abre Xcode una vez y acepta la licencia y la instalación de componentes.
3. En Terminal, clona el repositorio privado:

   ```bash
   git clone https://github.com/Nekrobast/idevero-ios.git
   cd idevero-ios
   open Idevero.xcodeproj
   ```

4. Si GitHub solicita autenticación, usa tu sesión/credencial autorizada. No guardes tokens en el repositorio.

## 2. Añadir el Apple Account

1. En Xcode abre **Xcode > Settings… > Accounts** (en versiones recientes puede mostrarse como **Apple Accounts**).
2. Pulsa `+` y añade tu Apple Account.
3. No compres ninguna membresía.
4. Xcode debe mostrar un equipo llamado **Personal Team**.

## 3. Conectar el iPhone

1. Desbloquea el iPhone y conéctalo al Mac por cable.
2. Si aparece **¿Confiar en este ordenador?**, pulsa **Confiar** e introduce el código del iPhone.
3. En Xcode abre **Window > Devices and Simulators** o **Xcode > Open Developer Tool > Device Hub** y espera a que termine la preparación.
4. Si iOS solicita Developer Mode, abre **Ajustes > Privacidad y seguridad > Modo de desarrollador**, actívalo, reinicia el iPhone y confirma después del reinicio.

## 4. Configurar la firma local

1. En el navegador del proyecto selecciona el proyecto **Idevero**.
2. Selecciona el target **Idevero** y abre **Signing & Capabilities**.
3. Activa **Automatically manage signing**.
4. En **Team**, selecciona tu **Personal Team**.
5. Mantén el bundle ID `com.aitor93.idevero` si Xcode lo acepta.
6. No introduzcas Team ID, certificado, UDID ni provisioning profile en GitHub.

### Si el Bundle Identifier no está disponible

No cambies el identificador del repositorio. Para una prueba local, modifica temporalmente en tu copia de Xcode el bundle ID por uno único, por ejemplo:

```text
com.[tu-identificador-local].idevero.dev
```

Haz lo mismo para el test bundle si Xcode lo solicita. No hagas commit de ese cambio.

### Si falla el provisioning

1. Comprueba que el iPhone está desbloqueado y visible en Device Hub.
2. Verifica que **Personal Team** está seleccionado en app y tests.
3. Pulsa **Try Again** en Signing & Capabilities.
4. En Xcode > Settings > Accounts, selecciona la cuenta y actualiza credenciales si se solicita.
5. Recuerda los límites gratuitos: 10 App IDs, 3 dispositivos y 3 apps por dispositivo; App IDs, dispositivos y perfiles caducan a los 7 días.
6. Tras la caducidad, vuelve a compilar e instalar desde Xcode.

## 5. Ejecutar IDEVERO

1. En la barra superior selecciona el esquema **Idevero**.
2. Selecciona tu iPhone como run destination.
3. Pulsa **Product > Run** (`⌘R`).
4. Espera a que Xcode compile, firme e instale.
5. Si aparece **Untrusted Developer**, abre en el iPhone **Ajustes > General > VPN y gestión de dispositivos**, selecciona el perfil asociado a tu Apple Account y pulsa **Confiar**. Después vuelve a ejecutar desde Xcode.

## 6. Probar Foundation Models

1. Confirma que el iPhone es compatible, usa iOS 26+ y tiene Apple Intelligence activado.
2. Configura dispositivo y Siri con un idioma compatible y deja finalizar la descarga de modelos.
3. Selecciona el iPhone, abre el Test navigator y ejecuta:
   `FoundationModelsDeviceTests/testRealFoundationModelOnCompatibleDeviceOnly`.
4. El test consulta la disponibilidad real. En hardware incompatible o modelo no preparado se omite; cuando está disponible ejecuta una inferencia real estructurada.

Comando equivalente, sin guardar el UDID:

```bash
xcodebuild \
  -project Idevero.xcodeproj \
  -scheme Idevero \
  -destination 'platform=iOS,id=[DEVICE_ID]' \
  -only-testing:IdeveroTests/FoundationModelsDeviceTests/testRealFoundationModelOnCompatibleDeviceOnly \
  test
```

## 7. Recoger diagnóstico

- Conserva modelo de iPhone, versión de iOS, idioma, región, estado de Apple Intelligence y estado de Foundation Models.
- No copies Apple ID, correo, número de serie ni UDID al informe.
- En Xcode usa **View > Debug Area > Activate Console**.
- Copia el error exacto eliminando rutas, cuentas o identificadores personales.
- Guarda el `.xcresult` local si el test falla.

Fuentes oficiales: https://developer.apple.com/help/account/basics/about-your-developer-account y https://developer.apple.com/documentation/xcode/running-your-app-on-simulated-or-physical-devices

