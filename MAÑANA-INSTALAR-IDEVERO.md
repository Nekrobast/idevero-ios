# Mañana: instalar IDEVERO en el iPhone

1. Abre el run privado `36812157876` de GitHub Actions y descarga `idevero-device-build`.
2. Extrae el ZIP. Debe aparecer `Idevero-iOS-0.2.2-DeviceUnsigned.ipa`.
3. Descarga también `Tools/Verify-IdeveroIPA.ps1` desde el repositorio y déjalo junto al IPA. Verifica desde PowerShell:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Verify-IdeveroIPA.ps1 -Path .
   ```

   O manualmente:

   ```powershell
   Get-FileHash .\Idevero-iOS-0.2.2-DeviceUnsigned.ipa -Algorithm SHA256
   ```

   Debe dar `bcc26abf2266f81afa251077507957e453220b81dc9a04be178296221e7aaaad`.

4. Instala iTunes e iCloud desde Apple —no Microsoft Store— y AltServer desde `https://altstore.io/`.
5. Ejecuta AltServer como administrador.
6. Conecta y desbloquea el iPhone; acepta **Confiar en este ordenador**.
7. Método directo: mantén `Shift`, pulsa el icono de AltServer y elige **Sideload .ipa…**. Selecciona el IPA y el iPhone. Introduce Apple Account/2FA solo en AltServer o Apple.
8. Si la opción directa no aparece, instala AltStore Classic desde **Install AltStore**, ábrelo en el iPhone y usa **My Apps > +** para seleccionar el IPA.
9. En el iPhone activa **Ajustes > Privacidad y seguridad > Modo de desarrollador**, reinicia y confirma. Si se solicita, confía en el desarrollador en **General > VPN y gestión de dispositivos**.
10. Abre IDEVERO.
11. Test Local: `Escribe un email corto de agradecimiento`. Debe mostrar `Local Expert` y generar un prompt compacto.
12. Test Foundation: `Quiero crear una app para apicultores`. Si Apple está disponible, debe mostrar `Apple Foundation Models` y discoveries `APPLE MODEL INFERENCE`; si no, Local Expert debe funcionar sin crash.

No compartas contraseña, 2FA, Apple ID, UDID, número de serie ni perfiles.
