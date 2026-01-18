# 🚀 Configuración SIMPLE de Google Sheets

## ✨ Sin Google Cloud Console, Sin OAuth, Sin complicaciones

Esta es la forma **más simple** de conectar tu app con Google Sheets.

## 📋 Requisitos

- Una cuenta de Google
- 5 minutos de tu tiempo

## 🎯 Paso 1: Crear o abrir una hoja de Google Sheets

1. Ve a https://sheets.google.com
2. Crea una nueva hoja o abre una existente
3. Dale un nombre (ej: "Mediciones de Raíces")

## 📝 Paso 2: Abrir el editor de Apps Script

1. En tu hoja de Google Sheets, ve al menú **Extensiones**
2. Click en **Apps Script**
3. Se abrirá una nueva pestaña con el editor de código

## 💻 Paso 3: Copiar el código del script

**Borra todo el código que aparece** y pega este:

```javascript
function doPost(e) {
  try {
    // Obtener la hoja activa
    var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
    
    // Verificar que hay datos
    if (!e || !e.postData || !e.postData.contents) {
      return createCorsResponse({
        'status': 'error',
        'message': 'No se recibieron datos'
      });
    }
    
    var data = JSON.parse(e.postData.contents);
    
    // Si es una petición de prueba, responder OK
    if (data.test === true) {
      return createCorsResponse({
        'status': 'success',
        'message': 'Webhook funcionando correctamente'
      });
    }
    
    // Verificar si la primera fila tiene encabezados
    var firstRow = sheet.getRange(1, 1, 1, 9).getValues()[0];
    var isEmpty = firstRow.every(function(cell) { return cell === ''; });
    
    // Si la primera fila está vacía, agregar encabezados
    if (isEmpty) {
      var headers = [
        'Fecha y Hora',
        'ID Medición',
        'Número de Raíces',
        'Longitud Total (mm)',
        'Longitud Promedio (mm)',
        'Longitud Mínima (mm)',
        'Longitud Máxima (mm)',
        'Calibrado',
        'Píxeles por mm'
      ];
      sheet.getRange(1, 1, 1, headers.length).setValues([headers]);
      
      // Formatear encabezados
      var headerRange = sheet.getRange(1, 1, 1, headers.length);
      headerRange.setBackground('#4285F4');
      headerRange.setFontColor('#FFFFFF');
      headerRange.setFontWeight('bold');
      headerRange.setHorizontalAlignment('center');
    }
    
    // Agregar los datos
    var row = [
      data.fecha || '',
      data.id || '',
      data.numeroRaices || 0,
      data.longitudTotal || 0,
      data.longitudPromedio || 0,
      data.longitudMinima || 0,
      data.longitudMaxima || 0,
      data.calibrado || 'No',
      data.pixelesPorMm || 0
    ];
    
    sheet.appendRow(row);
    
    // Autoajustar columnas
    sheet.autoResizeColumns(1, 9);
    
    return createCorsResponse({
      'status': 'success',
      'message': 'Datos agregados correctamente',
      'row': sheet.getLastRow()
    });
    
  } catch (error) {
    return createCorsResponse({
      'status': 'error',
      'message': error.toString()
    });
  }
}

// Para manejar peticiones GET (cuando alguien abre la URL en el navegador)
function doGet(e) {
  return createCorsResponse({
    'status': 'success',
    'message': 'Webhook activo. Use POST para enviar datos.'
  });
}

// Función auxiliar para crear respuestas con CORS habilitado
function createCorsResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}

// Función de prueba (opcional)
function test() {
  var testData = {
    postData: {
      contents: JSON.stringify({
        fecha: '18/01/2026 14:30:25',
        id: 'test-123',
        numeroRaices: 5,
        longitudTotal: '450.50',
        longitudPromedio: '90.10',
        longitudMinima: '75.20',
        longitudMaxima: '105.30',
        calibrado: 'Sí',
        pixelesPorMm: '3.7500'
      })
    }
  };
  
  var result = doPost(testData);
  Logger.log(result.getContent());
}
```

## 🚀 Paso 4: Desplegar como aplicación web

1. Click en el botón **Implementar** (arriba a la derecha)
2. Selecciona **Nueva implementación**
3. En "Tipo", selecciona **Aplicación web**
4. Configuración:
   - **Descripción**: "Webhook para Medidor de Raíces" (o lo que quieras)
   - **Ejecutar como**: Tu cuenta
   - **Quién tiene acceso**: **Cualquier usuario** (importante!)
5. Click en **Implementar**
6. Si te pide permisos, acepta:
   - Click en **Revisar permisos**
   - Selecciona tu cuenta
   - Click en **Avanzado**
   - Click en **Ir a [nombre del proyecto] (no seguro)**
   - Click en **Permitir**

## 📋 Paso 5: Copiar la URL del webhook

1. Después de desplegar, verás una pantalla con **URL de la aplicación web**
2. Copia esa URL completa (ejemplo: `https://script.google.com/macros/s/ABC123.../exec`)
3. **¡Guárdala!** La necesitas para la app

## 📱 Paso 6: Configurar en la app

1. Abre la app Medidor de Raíces
2. Ve a **⚙️ Configuración** (icono de engranaje arriba)
3. En "URL del Webhook", pega la URL que copiaste
4. Click en **Guardar y Validar**
5. Si todo está bien, verás "Webhook configurado correctamente"
6. Activa el switch **"Activar integración"**
7. **¡Listo!** 🎉

## 🧪 Probar que funciona

1. Toma una foto y mide raíces en la app
2. Guarda la medición
3. Ve a tu hoja de Google Sheets
4. **¡Deberías ver los datos!**

## 📊 Resultado en Google Sheets

Tu hoja se verá así:

| Fecha y Hora | ID Medición | Número de Raíces | Longitud Total (mm) | Longitud Promedio (mm) | ... |
|--------------|-------------|------------------|---------------------|------------------------|-----|
| 18/01/2026 14:30:25 | abc123 | 5 | 450.50 | 90.10 | ... |
| 18/01/2026 15:45:10 | def456 | 3 | 320.75 | 106.92 | ... |

Con encabezados azules y datos automáticamente formateados.

## 🔄 Actualizar el script

Si necesitas cambiar el código:

1. Ve a Apps Script
2. Modifica el código
3. Click en **Implementar** > **Administrar implementaciones**
4. Click en el icono de editar (lápiz)
5. En "Versión", selecciona **Nueva versión**
6. Click en **Implementar**
7. **La URL sigue siendo la misma** (no necesitas cambiarla en la app)

## ❓ Problemas comunes

### "No se pudo validar el webhook"

**Solución:**
- Verifica que la URL empiece con `https://script.google.com/`
- Asegúrate de haber desplegado el script correctamente
- Verifica que "Quién tiene acceso" esté en "Cualquier usuario"
- Intenta copiar la URL de nuevo (sin espacios al principio/final)

**🔍 Para debugging avanzado:**

1. **Abre la URL en el navegador**: Pega la URL del webhook en tu navegador
   - Debería mostrar: `{"status":"success","message":"Webhook activo. Use POST para enviar datos."}`
   - Si no aparece nada o hay error, el webhook no está bien desplegado

2. **Revisa los permisos**: 
   - Ve a Apps Script > Implementar > Administrar implementaciones
   - Verifica que "Quién tiene acceso" sea **"Cualquier usuario"** (no "Solo yo")

3. **Crea una nueva implementación**:
   - A veces ayuda eliminar la implementación anterior y crear una nueva
   - Implementar > Administrar implementaciones > Archivar la anterior
   - Luego: Implementar > Nueva implementación

4. **Prueba manualmente el script**:
   - En Apps Script, selecciona la función `test` en el menú desplegable
   - Click en "Ejecutar" (▶️)
   - Ve a tu hoja de Google Sheets, debería aparecer una fila de prueba
   - Si aparece, el script funciona. El problema es la configuración del webhook.

### "Los datos no aparecen en la hoja"

**Solución:**
- Verifica que la integración esté **activada** (switch verde)
- Comprueba que tengas internet en el dispositivo
- Revisa que la URL del webhook sea correcta
- Ve a Apps Script > Ejecuciones para ver si hay errores

### "Error de permisos"

**Solución:**
- Cuando desplegaste, ¿aceptaste todos los permisos?
- Intenta de nuevo: Implementar > Nueva implementación
- Acepta los permisos cuando te los pida

### "La app dice que el webhook funciona pero no veo datos"

**Solución:**
- Ve a Apps Script > Ejecuciones
- Mira si hay errores en las ejecuciones recientes
- Verifica que el nombre de la hoja sea el correcto

## 💡 Tips útiles

1. **Múltiples hojas**: Puedes crear diferentes scripts para diferentes proyectos
2. **Compartir**: Comparte la hoja de Google Sheets con tu equipo (ellos no necesitan la URL del webhook)
3. **Gráficos**: Usa Google Sheets para crear gráficos automáticos de tus datos
4. **Exportar**: Descarga como CSV o Excel cuando quieras
5. **Historial**: Google Sheets guarda un historial de cambios

## 🔒 Seguridad

- ✅ Solo tú puedes ver el código del script
- ✅ Solo tú puedes modificar la hoja (si no la compartes)
- ✅ El webhook solo puede **agregar** datos, no leer ni modificar
- ✅ La URL del webhook es única para tu hoja
- ⚠️ No compartas la URL del webhook públicamente

## 🎓 ¿Qué hace el script?

1. Recibe los datos de la app (fecha, mediciones, etc.)
2. Si es la primera vez, crea los encabezados automáticamente
3. Agrega una nueva fila con los datos
4. Formatea la hoja (colores, ajuste de columnas)
5. Responde a la app confirmando que todo salió bien

## 🆚 Ventajas vs Google Cloud Console

| Google Apps Script | Google Cloud Console |
|-------------------|---------------------|
| ✅ 5 minutos setup | ❌ 30+ minutos setup |
| ✅ Sin configuración compleja | ❌ Múltiples pasos |
| ✅ Funciona en web/Android/iOS | ⚠️ Requiere config por plataforma |
| ✅ Sin credenciales | ❌ Necesita Client IDs |
| ✅ Sin OAuth | ❌ Necesita OAuth |
| ✅ Sin SHA-1 | ❌ Necesita SHA-1 |
| ✅ Gratis siempre | ✅ Gratis (con límites) |

## 🔗 Recursos adicionales

- [Documentación de Google Apps Script](https://developers.google.com/apps-script)
- [Límites de Google Apps Script](https://developers.google.com/apps-script/guides/services/quotas)

## ⚡ Límites de uso

Google Apps Script es gratis y tiene límites generosos:

- ✅ **20,000 invocaciones por día** (más que suficiente)
- ✅ **6 minutos por ejecución** (cada medición toma <1 segundo)
- ✅ Sin límite de hojas o datos

Para uso normal de esta app, **nunca llegarás a los límites**.

---

## ✨ ¡Ya está!

Ahora cada vez que guardes una medición en la app:
1. Se guarda localmente en tu dispositivo ✅
2. Se envía automáticamente a Google Sheets ✅
3. Puedes verla desde cualquier lugar 🌍
4. Puedes compartirla con tu equipo 🤝
5. Puedes analizarla con gráficos 📊

**¡Feliz medición de raíces! 🌱**
