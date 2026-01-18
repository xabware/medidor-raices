# Medidor de Raíces

Aplicación móvil para medir raíces mediante procesamiento de imágenes usando marcadores ArUco como referencia.

## Características

- 📸 Captura de fotos con cámara o desde galería
- 🎯 Detección automática de marcadores ArUco para calibración
- 📏 Medición precisa de longitud de raíces
- 📄 Generador de PDF con marcadores ArUco para imprimir (A4)
- 💾 Procesamiento local (sin backend)
- 📊 Historial de mediciones
- ☁️ **Integración con Google Sheets** - Envío automático de datos a hojas de cálculo online

## Requisitos

- Flutter SDK >= 3.0.0
- Android Studio / Xcode
- Dispositivo físico con cámara (recomendado)

## Instalación

```bash
flutter pub get
flutter run
```

## Uso

1. **Generar marcadores ArUco**: Desde la app, genera el PDF con marcadores y imprime en hoja A4
2. **Colocar raíces**: Coloca las raíces sobre el papel impreso con los marcadores ArUco
3. **Capturar foto**: Toma una foto asegurándote que los marcadores ArUco sean visibles
4. **Ver resultados**: La app detectará automáticamente la escala y medirá cada raíz

### Configurar Google Sheets (opcional)

5. **Ir a Configuración**: Toca el icono de engranaje en la pantalla principal
6. **Crear Google Apps Script**: Sigue la guía [GOOGLE_SHEETS_SETUP_SIMPLE.md](GOOGLE_SHEETS_SETUP_SIMPLE.md)
7. **Pegar URL del webhook**: Introduce la URL que te da Google Apps Script
8. **Activar integración**: Activa el switch para envío automático
9. **¡Listo!**: Todas las mediciones se guardarán automáticamente en Google Sheets

**⚡ Configuración en 5 minutos** - Sin Google Cloud Console, sin OAuth, sin complicaciones.

Ver [GOOGLE_SHEETS_SETUP_SIMPLE.md](GOOGLE_SHEETS_SETUP_SIMPLE.md) para instrucciones paso a paso.

## Tecnologías

- Flutter
- OpenCV (opencv_dart)
- ArUco markers
- PDF generation
- Google Apps Script (webhook)
- HTTP requests
