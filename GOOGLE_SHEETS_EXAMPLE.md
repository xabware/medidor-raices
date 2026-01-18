# Ejemplo de datos en Google Sheets

Una vez configurada la integración, tus datos se verán así en la hoja de cálculo:

| Fecha y Hora | ID Medición | Número de Raíces | Longitud Total (mm) | Longitud Promedio (mm) | Longitud Mínima (mm) | Longitud Máxima (mm) | Calibrado | Píxeles por mm |
|--------------|-------------|------------------|---------------------|------------------------|----------------------|----------------------|-----------|----------------|
| 18/01/2026 14:30:25 | abc123 | 5 | 450.50 | 90.10 | 75.20 | 105.30 | Sí | 3.7500 |
| 18/01/2026 15:45:10 | def456 | 3 | 320.75 | 106.92 | 98.40 | 115.50 | Sí | 3.7500 |
| 18/01/2026 16:20:05 | ghi789 | 7 | 580.20 | 82.89 | 60.10 | 110.40 | No | 2.5000 |

## Ventajas de usar Google Sheets

✅ **Análisis en tiempo real**: Los datos se actualizan inmediatamente
✅ **Colaboración**: Comparte la hoja con tu equipo
✅ **Gráficos automáticos**: Crea gráficos y visualizaciones
✅ **Exportación**: Descarga como CSV, Excel, PDF, etc.
✅ **Backup automático**: Google guarda todo en la nube
✅ **Acceso desde cualquier lugar**: Web, móvil, tablet

## Ideas de análisis con tus datos

1. **Crear gráficos de tendencias**:
   - Longitud promedio a lo largo del tiempo
   - Número de raíces por medición
   - Comparación entre mediciones calibradas vs no calibradas

2. **Calcular estadísticas**:
   - Total acumulado de raíces medidas
   - Longitud promedio general
   - Desviación estándar

3. **Filtrar y ordenar**:
   - Ver solo mediciones calibradas
   - Ordenar por fecha más reciente
   - Filtrar por rango de longitudes

4. **Fórmulas útiles**:
   ```
   =AVERAGE(D2:D100)     // Longitud total promedio
   =SUM(C2:C100)         // Total de raíces medidas
   =MAX(E2:E100)         // Mayor longitud promedio
   =COUNTIF(H2:H100,"Sí") // Contar mediciones calibradas
   ```

## Compartir con tu equipo

1. Haz clic en "Compartir" en la esquina superior derecha de Google Sheets
2. Introduce los correos de tus colaboradores
3. Elige los permisos:
   - **Viewer**: Solo pueden ver
   - **Commenter**: Pueden comentar
   - **Editor**: Pueden editar (¡cuidado con los datos!)

## Automatizaciones avanzadas (opcional)

Con Google Apps Script puedes:
- Enviar emails automáticos cuando se agregan datos
- Crear informes automáticos semanales
- Sincronizar con otras herramientas
- Validar datos automáticamente
