# Guía Rápida: Configurar Google Cloud Console

## ⚡ Pasos Rápidos (15 minutos aprox.)

### 1️⃣ Crear Proyecto en Google Cloud

1. Ve a https://console.cloud.google.com/
2. Clic en el selector de proyectos (arriba a la izquierda)
3. Clic en "Nuevo Proyecto"
4. Nombre: `Medidor Raices` (o el que prefieras)
5. Clic en "Crear"

### 2️⃣ Habilitar Google Sheets API

1. En el menú lateral > "APIs y servicios" > "Biblioteca"
2. Busca "Google Sheets API"
3. Clic en el resultado
4. Clic en "HABILITAR"

### 3️⃣ Configurar Pantalla de Consentimiento OAuth

1. En el menú lateral > "APIs y servicios" > "Pantalla de consentimiento de OAuth"
2. Selecciona "Externo" (o "Interno" si tienes Google Workspace)
3. Clic en "Crear"

**Información de la aplicación:**
- Nombre de la aplicación: `Medidor de Raíces`
- Correo electrónico de asistencia: tu email
- Logo: (opcional)

**Ámbitos:**
- Clic en "Agregar o quitar ámbitos"
- Busca y selecciona: `.../auth/spreadsheets`
- Guarda y continúa

**Usuarios de prueba** (si es Externa):
- Agrega tu email y los de las personas que probarán la app
- Guarda y continúa

### 4️⃣ Crear Credenciales para Android

1. En el menú lateral > "APIs y servicios" > "Credenciales"
2. Clic en "+ CREAR CREDENCIALES" > "ID de cliente de OAuth"
3. Tipo de aplicación: **Android**

**Configuración:**
- Nombre: `Medidor Raices Android`
- Nombre del paquete: `com.example.medidor_raices`
  
**Obtener SHA-1 (importante):**

En tu terminal de PowerShell, ejecuta:

```powershell
# Para debug (desarrollo):
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Busca la línea que dice `SHA1:` y copia ese valor (ejemplo: `A1:B2:C3:D4...`)

- Pega el SHA-1 en "Huella digital del certificado SHA-1"
- Clic en "Crear"

### 5️⃣ Crear Credenciales para iOS (si vas a usar iOS)

1. Clic en "+ CREAR CREDENCIALES" > "ID de cliente de OAuth"
2. Tipo de aplicación: **iOS**
3. Nombre: `Medidor Raices iOS`
4. ID del paquete: `com.example.medidorRaices` (verifica el tuyo en Xcode)
5. Clic en "Crear"

### 6️⃣ Crear Credenciales para Web (opcional)

1. Clic en "+ CREAR CREDENCIALES" > "ID de cliente de OAuth"
2. Tipo de aplicación: **Aplicación web**
3. Nombre: `Medidor Raices Web`
4. Orígenes autorizados de JavaScript:
   - `http://localhost`
   - `http://localhost:8080`
   - (agrega otros puertos si usas diferentes)
5. URI de redireccionamiento autorizados:
   - `http://localhost`
   - `http://localhost:8080/auth`
6. Clic en "Crear"

## ✅ Verificación

Tu página de Credenciales debería mostrar:
```
📱 Medidor Raices Android (Android)
🍎 Medidor Raices iOS (iOS)
🌐 Medidor Raices Web (Aplicación web)
```

## 📋 Para producción (release)

Cuando vayas a publicar la app:

1. **Genera el keystore de release:**
```powershell
keytool -genkey -v -keystore release.keystore -alias release -keyalg RSA -keysize 2048 -validity 10000
```

2. **Obtén el SHA-1 de release:**
```powershell
keytool -list -v -keystore release.keystore -alias release
```

3. **Agrega otra credencial Android** con el SHA-1 de release

4. **En la Pantalla de Consentimiento:**
   - Cambia el estado de "En producción" si es Externa
   - O mantén en "Prueba" y agrega usuarios específicos

## 🚨 Problemas comunes

### Error: "API not enabled"
- ✅ Verifica que Google Sheets API esté habilitada
- ✅ Espera 1-2 minutos después de habilitarla

### Error: "Invalid client"
- ✅ Verifica que el nombre del paquete coincida exactamente
- ✅ Verifica que el SHA-1 sea correcto

### No aparece pantalla de login
- ✅ Verifica que agregaste tu email en "Usuarios de prueba"
- ✅ Revisa que la Pantalla de Consentimiento esté completa

### "Error 400: redirect_uri_mismatch"
- ✅ Verifica los URIs de redireccionamiento en las credenciales Web
- ✅ Asegúrate de incluir el puerto correcto

## 📱 Siguientes pasos

Después de configurar Google Cloud:

1. Instala las dependencias: `flutter pub get`
2. Ejecuta la app: `flutter run`
3. Ve a Configuración en la app
4. Inicia sesión con Google
5. Crea o vincula una hoja de cálculo
6. ¡Activa la integración!

## 🔐 Seguridad

- ❌ NUNCA compartas tu archivo keystore de producción
- ❌ NUNCA subas credenciales a Git (están en .gitignore)
- ✅ Mantén tu proyecto de Google Cloud privado
- ✅ Revoca acceso a usuarios que ya no lo necesiten
- ✅ Monitorea el uso de la API en Google Cloud Console

## 💰 Costos

Google Sheets API es **GRATUITA** para uso normal:
- ✅ Cuota diaria: 500 peticiones por proyecto por día
- ✅ Cuota por minuto: 100 peticiones por usuario por minuto

Para esta app, cada medición = 1 petición.
**Suficiente para ~500 mediciones al día por usuario.**

Si necesitas más, puedes solicitar aumento de cuota (también gratis generalmente).

## 📚 Recursos adicionales

- [Documentación Google Sheets API](https://developers.google.com/sheets/api)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [OAuth 2.0 Google](https://developers.google.com/identity/protocols/oauth2)
