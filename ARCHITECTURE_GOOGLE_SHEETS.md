# Flujo de Integración con Google Sheets

```
┌─────────────────────────────────────────────────────────────────────┐
│                        MEDIDOR DE RAÍCES APP                        │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ 1. Captura y procesa imagen
                                   ▼
                    ┌──────────────────────────────┐
                    │   RootMeasurement creada     │
                    │  (datos de las raíces)       │
                    └──────────────────────────────┘
                                   │
                                   │ 2. Guarda localmente
                                   ▼
                    ┌──────────────────────────────┐
                    │    StorageService            │
                    │  saveMeasurement()           │
                    └──────────────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                             │
         3a. Local │                             │ 3b. Si está habilitado
                    ▼                             ▼
        ┌─────────────────────┐    ┌──────────────────────────────┐
        │ SharedPreferences   │    │  GoogleSheetsService         │
        │ (almacenamiento     │    │  sendMeasurement()           │
        │  local del device)  │    └──────────────────────────────┘
        └─────────────────────┘                  │
                                                 │ 4. Autenticación
                                                 ▼
                                   ┌──────────────────────────────┐
                                   │   Google Sign-In API         │
                                   │   (OAuth 2.0)                │
                                   └──────────────────────────────┘
                                                 │
                                                 │ 5. Envía datos
                                                 ▼
                                   ┌──────────────────────────────┐
                                   │   Google Sheets API          │
                                   │   (spreadsheets.values.      │
                                   │    append)                   │
                                   └──────────────────────────────┘
                                                 │
                                                 ▼
                    ┌────────────────────────────────────────────┐
                    │         GOOGLE SHEETS                      │
                    │  ┌──────────────────────────────────────┐  │
                    │  │ Fecha | ID | Raíces | Longitud | ... │  │
                    │  ├──────────────────────────────────────┤  │
                    │  │ Datos actualizados en tiempo real    │  │
                    │  └──────────────────────────────────────┘  │
                    └────────────────────────────────────────────┘
```

## Componentes principales

### 1. **GoogleSheetsService**
- Maneja la autenticación con Google
- Crea nuevas hojas de cálculo
- Valida hojas existentes
- Envía datos formateados

### 2. **StorageService** (modificado)
- Guarda localmente (como antes)
- **NUEVO**: Llama automáticamente a GoogleSheetsService
- Maneja errores sin interrumpir el guardado local

### 3. **SettingsScreen** (nueva)
- Interfaz para configurar la integración
- Login/Logout con Google
- Crear o vincular hojas de cálculo
- Activar/Desactivar sincronización

### 4. **Datos que se envían**
```dart
{
  'Fecha y Hora': '18/01/2026 14:30:25',
  'ID Medición': 'abc123',
  'Número de Raíces': 5,
  'Longitud Total (mm)': 450.50,
  'Longitud Promedio (mm)': 90.10,
  'Longitud Mínima (mm)': 75.20,
  'Longitud Máxima (mm)': 105.30,
  'Calibrado': 'Sí',
  'Píxeles por mm': 3.7500
}
```

## Seguridad y Privacidad

✅ **OAuth 2.0**: Autenticación segura de Google
✅ **Permisos específicos**: Solo acceso a Sheets API
✅ **Local first**: Los datos se guardan localmente primero
✅ **Control total**: Puedes desactivar en cualquier momento
✅ **Sin contraseñas**: Google maneja la autenticación
✅ **Revocable**: Puedes revocar permisos desde tu cuenta de Google

## Configuración de red requerida

- ✅ Conexión a internet activa
- ✅ Acceso a `accounts.google.com`
- ✅ Acceso a `sheets.googleapis.com`
- ⚠️ No funciona en modo offline (los datos se guardan local hasta que haya conexión)

## Manejo de errores

```
Si falla el envío a Google Sheets:
├─ Los datos SE GUARDAN localmente de todas formas
├─ Se muestra un log de error (no interrumpe la app)
├─ El usuario puede reintentar manualmente
└─ La app sigue funcionando normalmente
```

## Próximas mejoras posibles

- [ ] Cola de reintento automático cuando recupere conexión
- [ ] Sincronización de datos históricos
- [ ] Múltiples hojas de cálculo (por proyecto)
- [ ] Notificaciones cuando se envían datos
- [ ] Modo batch (enviar múltiples mediciones a la vez)
