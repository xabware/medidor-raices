# ✅ Integración con Google Sheets - COMPLETADA

## 🎉 ¿Qué se ha implementado?

Tu aplicación ahora puede enviar automáticamente los datos de mediciones a Google Sheets. Cada vez que captures y guardes una medición, los datos se subirán a una hoja de cálculo online.

## 📁 Archivos creados/modificados

### Nuevos archivos:
1. ✅ `lib/services/google_sheets_service.dart` - Servicio para manejar Google Sheets API
2. ✅ `lib/screens/settings_screen.dart` - Pantalla de configuración para la integración
3. ✅ `GOOGLE_SHEETS_SETUP.md` - Guía completa de configuración
4. ✅ `GOOGLE_CLOUD_SETUP_QUICKSTART.md` - Guía rápida para Google Cloud Console
5. ✅ `GOOGLE_SHEETS_EXAMPLE.md` - Ejemplos de uso y análisis de datos
6. ✅ `ARCHITECTURE_GOOGLE_SHEETS.md` - Arquitectura técnica de la integración

### Archivos modificados:
1. ✅ `pubspec.yaml` - Agregadas dependencias de Google APIs
2. ✅ `lib/services/storage_service.dart` - Envío automático a Google Sheets
3. ✅ `lib/screens/home_screen.dart` - Botón de configuración agregado
4. ✅ `README.md` - Documentación actualizada

## 🚀 Próximos pasos

### 1. Configurar Google Cloud Console (OBLIGATORIO)

Antes de usar la función, debes configurar las credenciales de Google:

📖 **Sigue la guía:** [GOOGLE_CLOUD_SETUP_QUICKSTART.md](GOOGLE_CLOUD_SETUP_QUICKSTART.md)

**Resumen rápido:**
1. Crear proyecto en https://console.cloud.google.com/
2. Habilitar Google Sheets API
3. Configurar OAuth (pantalla de consentimiento)
4. Crear credenciales para Android/iOS/Web
5. Obtener SHA-1 para Android

⏱️ Tiempo estimado: **15 minutos**

### 2. Ejecutar la aplicación

```powershell
flutter pub get
flutter run
```

Las dependencias ya están instaladas, solo ejecuta la app.

### 3. Configurar en la app

1. Abre la app
2. Toca el icono **⚙️ Configuración** (arriba derecha)
3. Toca **"Iniciar sesión"**
4. Autentícate con tu cuenta de Google
5. Opciones:
   - **"Crear nueva"**: Crea automáticamente una hoja de cálculo
   - O introduce el **ID** de una hoja existente y toca **"Vincular"**
6. Activa el switch **"Activar integración"**
7. ✅ ¡Listo! Los datos se enviarán automáticamente

## 📊 ¿Qué datos se envían?

Cada medición guardará en Google Sheets:
- Fecha y hora
- ID de la medición
- Número de raíces detectadas
- Longitud total, promedio, mínima y máxima
- Si estaba calibrado o no
- Píxeles por milímetro

## 🔐 Seguridad

- ✅ Autenticación segura con OAuth 2.0
- ✅ Solo acceso a Google Sheets API
- ✅ Los datos se guardan localmente primero
- ✅ Puedes desactivar en cualquier momento
- ✅ Control total sobre tus datos

## 🎯 Funcionalidades clave

### En la app:
- ✅ Iniciar/Cerrar sesión con Google
- ✅ Crear nueva hoja de cálculo automáticamente
- ✅ Vincular hoja existente por ID
- ✅ Activar/Desactivar sincronización
- ✅ Envío automático al guardar mediciones
- ✅ Manejo de errores sin interrumpir el guardado local

### En Google Sheets:
- ✅ Datos actualizados en tiempo real
- ✅ Formato con encabezados y colores
- ✅ Compartir con colaboradores
- ✅ Crear gráficos y análisis
- ✅ Exportar a CSV, Excel, PDF
- ✅ Acceso desde cualquier dispositivo

## 📱 Capturas de pantalla (dónde encontrar cada cosa)

### Pantalla Principal → HomeScreen
```
┌─────────────────────────────────┐
│  Medidor de Raíces    ⚙️  📜   │ <- ⚙️ = Configuración (NUEVA)
├─────────────────────────────────┤
│                                 │
│   [Información sobre la app]    │
│                                 │
│   🎯 Generar PDF ArUco          │
│   📸 Tomar Foto                 │
│   🖼️  Seleccionar de Galería    │
│                                 │
└─────────────────────────────────┘
```

### Pantalla de Configuración (NUEVA)
```
┌─────────────────────────────────┐
│  ← Configuración                │
├─────────────────────────────────┤
│  Integración con Google Sheets  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ ✅ Sesión iniciada       │  │
│  │ usuario@gmail.com        │  │
│  │          [Cerrar sesión] │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ Hoja de cálculo          │  │
│  │                          │  │
│  │ [+ Crear nueva]          │  │
│  │                          │  │
│  │ O vincular existente     │  │
│  │ [ID: ____________]  [?]  │  │
│  │      [Vincular]          │  │
│  └──────────────────────────┘  │
│                                 │
│  ┌──────────────────────────┐  │
│  │ ☁️ Activar integración   │  │
│  │             ────●         │  │
│  └──────────────────────────┘  │
└─────────────────────────────────┘
```

## 🔄 Flujo de trabajo

```
1. Usuario toma foto de raíces
2. App procesa imagen y detecta raíces
3. Usuario ve resultados y guarda
4. App guarda localmente ✅
5. Si Google Sheets está activado:
   → App envía datos a Google Sheets automáticamente ✅
6. Los datos están en ambos lugares (local + cloud)
```

## 🆘 Solución de problemas

### "No puedo iniciar sesión"
- Verifica que configuraste Google Cloud Console correctamente
- Agrega tu email en "Usuarios de prueba" (si la app es Externa)
- Revisa que el SHA-1 sea correcto (Android)

### "Los datos no se envían"
- Verifica que la integración esté **activada** (switch verde)
- Comprueba que tengas **conexión a internet**
- Revisa que la hoja de cálculo tenga **permisos de escritura**

### "API not enabled"
- Ve a Google Cloud Console
- Habilita **"Google Sheets API"** en tu proyecto
- Espera 1-2 minutos para que se propague

### Más ayuda
Consulta: [GOOGLE_SHEETS_SETUP.md](GOOGLE_SHEETS_SETUP.md) - Sección "Solución de problemas"

## 📚 Recursos adicionales

- [Arquitectura técnica](ARCHITECTURE_GOOGLE_SHEETS.md) - Para desarrolladores
- [Ejemplos de uso](GOOGLE_SHEETS_EXAMPLE.md) - Ideas de análisis de datos
- [Guía de Google Cloud](GOOGLE_CLOUD_SETUP_QUICKSTART.md) - Configuración paso a paso

## 💡 Tips útiles

1. **Crea una hoja por proyecto**: Puedes tener diferentes hojas para diferentes experimentos
2. **Comparte con tu equipo**: Todos pueden ver los datos en tiempo real
3. **Haz gráficos**: Google Sheets puede crear visualizaciones automáticamente
4. **Exporta los datos**: Descarga como CSV para análisis en otras herramientas
5. **Desactiva si no necesitas**: El switch permite activar/desactivar fácilmente

## 🎓 ¿Necesitas ayuda?

Si tienes problemas con la configuración:
1. Lee [GOOGLE_CLOUD_SETUP_QUICKSTART.md](GOOGLE_CLOUD_SETUP_QUICKSTART.md)
2. Revisa la sección de solución de problemas
3. Verifica los errores en la consola: `flutter run` muestra logs detallados

---

## ✨ ¡Eso es todo!

Tu app ahora tiene integración completa con Google Sheets. Disfruta de:
- 📊 Análisis de datos en tiempo real
- ☁️ Backup automático en la nube  
- 🤝 Colaboración con tu equipo
- 📈 Visualizaciones y gráficos
- 🌍 Acceso desde cualquier lugar

**¡Feliz medición de raíces! 🌱**
