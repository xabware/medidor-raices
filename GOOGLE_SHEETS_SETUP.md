# Configuración de Google Sign-In para Android e iOS

## IMPORTANTE: Configuración requerida para que funcione la integración con Google Sheets

### Para Android:

1. **Crear proyecto en Google Cloud Console:**
   - Ve a https://console.cloud.google.com/
   - Crea un nuevo proyecto o selecciona uno existente
   - Habilita "Google Sheets API" en APIs & Services > Library

2. **Configurar OAuth 2.0:**
   - Ve a APIs & Services > Credentials
   - Crea credenciales > OAuth 2.0 Client ID
   - Tipo de aplicación: Android
   - Nombre del paquete: `com.example.medidor_raices` (o el que uses en AndroidManifest.xml)
   - SHA-1 certificate fingerprint: Obtén el SHA-1 ejecutando:
     ```
     keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
     ```

3. **Actualizar android/app/build.gradle:**
   Agrega al final del archivo:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

4. **Actualizar android/build.gradle:**
   Agrega en dependencies:
   ```gradle
   classpath 'com.google.gms:google-services:4.3.15'
   ```

### Para iOS:

1. **En Google Cloud Console:**
   - Ve a APIs & Services > Credentials
   - Crea credenciales > OAuth 2.0 Client ID
   - Tipo de aplicación: iOS
   - Bundle ID: El que tengas en tu proyecto iOS (ej: `com.example.medidorRaices`)

2. **Descargar GoogleService-Info.plist**
   - Descarga el archivo GoogleService-Info.plist
   - Agrégalo a la carpeta ios/Runner en Xcode

3. **Actualizar ios/Runner/Info.plist:**
   Agrega antes de `</dict>`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleTypeRole</key>
           <string>Editor</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
           </array>
       </dict>
   </array>
   ```
   Reemplaza YOUR-CLIENT-ID con el Client ID que obtuviste.

### Para Web:

1. **En Google Cloud Console:**
   - Ve a APIs & Services > Credentials
   - Crea credenciales > OAuth 2.0 Client ID
   - Tipo de aplicación: Web application
   - Authorized JavaScript origins: `http://localhost:port` (donde port es el puerto de desarrollo)
   - Authorized redirect URIs: `http://localhost:port/auth` y similares

2. **Actualizar web/index.html:**
   Agrega en el `<head>`:
   ```html
   <meta name="google-signin-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com">
   ```

### Uso de la aplicación:

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Ejecutar la app:**
   ```bash
   flutter run
   ```

3. **Configurar Google Sheets en la app:**
   - Abre la app y ve a Configuración (icono de engranaje)
   - Toca "Iniciar sesión" para autenticarte con Google
   - Elige "Crear nueva" para crear una nueva hoja de cálculo automáticamente
   - O introduce el ID de una hoja existente y toca "Vincular"
   - Activa el switch "Activar integración"

4. **Uso automático:**
   - Desde ese momento, cada vez que captures y guardes una medición
   - Los datos se enviarán automáticamente a tu hoja de Google Sheets

### Obtener el ID de una hoja de cálculo existente:

El ID está en la URL de tu hoja de cálculo:
```
https://docs.google.com/spreadsheets/d/[ESTE_ES_EL_ID]/edit
```

Por ejemplo, en:
```
https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
```
El ID es: `1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms`

### Estructura de datos en Google Sheets:

La hoja tendrá las siguientes columnas:
- Fecha y Hora
- ID Medición
- Número de Raíces
- Longitud Total (mm)
- Longitud Promedio (mm)
- Longitud Mínima (mm)
- Longitud Máxima (mm)
- Calibrado
- Píxeles por mm

### Solución de problemas:

**Error de autenticación:**
- Verifica que el SHA-1 sea correcto (Android)
- Verifica que el Bundle ID coincida (iOS)
- Asegúrate de que Google Sheets API esté habilitada

**No se envían los datos:**
- Verifica que la integración esté activada en Configuración
- Comprueba que tengas conexión a internet
- Revisa que la hoja de cálculo tenga permisos de escritura

**Error "API not enabled":**
- Ve a Google Cloud Console
- Habilita "Google Sheets API" en tu proyecto
