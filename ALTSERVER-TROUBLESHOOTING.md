# AltServer / AltStore Classic — resolución de problemas

| Error / síntoma | Causa probable | Acción |
|---|---|---|
| El iPhone no aparece | Cable, bloqueo o controlador Apple | Desbloquea, reconecta, prueba otro puerto/cable y confirma que iTunes ve el dispositivo. |
| No aparece “Confiar” | Confianza ya decidida o conexión incompleta | Reconecta desbloqueado. Si es necesario, restablece ubicación y privacidad en el iPhone y conecta otra vez. |
| AltServer no detecta el iPhone | Apple Mobile Device Support o AltServer no activo | Abre iTunes, activa sincronización Wi‑Fi, reinicia AltServer como administrador y mantén USB conectado. |
| iTunes/iCloud incorrectos | Versiones Microsoft Store incompatibles con la ruta estándar | Desinstálalas e instala las descargas directas de Apple indicadas por AltStore; usa la alternativa oficial si conservas iCloud Store. |
| Developer Mode missing | Modo de desarrollador desactivado | Ajustes > Privacidad y seguridad > Modo de desarrollador; activa, reinicia y confirma. |
| Provisioning failed | Sesión, límite gratuito o servicio Apple | Reintenta con Internet, comprueba fecha/hora y revisa los límites de apps/App IDs. No copies credenciales al informe. |
| App ID registration failed | Límite o identificador no disponible | Espera a que caduque un App ID o usa temporalmente un bundle único solo para la prueba local. |
| Bundle ID unavailable | `com.aitor93.idevero` ya está registrado para otro equipo | No cambies el repositorio. En una copia temporal usa `com.aitor93.idevero.dev.[sufijo-unico]` y vuelve a empaquetar solo si AltServer no lo reescribe automáticamente. |
| Maximum apps reached | Cuenta gratuita con tres apps activas | Desactiva o elimina otra app sideloaded; AltStore también ocupa una plaza. |
| Maximum App IDs reached | Diez App IDs activos | Espera hasta siete días a su caducidad o elimina extensiones/apps prescindibles. IDEVERO no tiene extensiones. |
| Apple authentication failed | Cuenta, contraseña, conectividad o bloqueo Apple | Autentícate únicamente en AltServer/Apple; revisa Internet, estado de la cuenta y vuelve a intentar. |
| Solicita 2FA | Protección normal de Apple | Introduce el código únicamente en el diálogo legítimo de AltServer/Apple. Nunca en ChatGPT, GitHub o documentación. |
| Could not install app | Firma, provisioning, IPA o conexión | Verifica primero SHA y ZIP con `Verify-IdeveroIPA.ps1`; después reintenta con USB y AltServer actualizado. |
| Integrity could not be verified | Perfil caducado, certificado sin verificar o falta de Internet | Conecta el iPhone a Internet, verifica el desarrollador en VPN y gestión de dispositivos y vuelve a firmar/instalar. |
| Untrusted Developer | Perfil gratuito aún no autorizado | Ajustes > General > VPN y gestión de dispositivos > perfil del Apple Account > Confiar/Verificar. |
| La app se abre y se cierra | Firma inválida/caducada, runtime o recurso | Vuelve a firmar. Si persiste, anota versión iOS y error sanitizado; no compartas identificadores personales. |
| Instala pero Foundation aparece unavailable | Apple Intelligence apagado, modelo descargando, idioma/locale o sistema incompatible | Confirma iOS, Apple Intelligence, idioma del dispositivo/Siri y espera a que finalice la descarga. Local Expert debe seguir funcionando. |
| Apple Intelligence downloading/not ready | Modelo aún no preparado | Mantén el iPhone con Wi‑Fi y alimentación, espera y vuelve a probar. No fuerces cambios de región. |
| Unsupported language/locale | Idioma del dispositivo o Siri no compatible | Usa temporalmente una combinación admitida por Apple solo si quieres probarlo; Local Expert no depende de ello. |
| La app caduca a los siete días | Límite normal del Apple Account gratuito | Refresca con AltStore/AltServer antes de caducar o vuelve a hacer sideload. |

## Regla de seguridad

Conserva Apple ID, contraseña, 2FA, PAT, UDID, serial, certificados y provisioning profiles únicamente en las interfaces locales correspondientes. No los subas al repositorio ni los pegues en chats o informes.

