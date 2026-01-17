import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../models/root_measurement.dart';

class StorageService {
  static const String _measurementsKey = 'measurements';

  /// Guarda una medición en el almacenamiento local
  Future<void> saveMeasurement(RootMeasurement measurement) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final measurements = await getMeasurements();
      
      measurements.insert(0, measurement);
      
      // En web, limitar más agresivamente para evitar exceder cuota
      final maxMeasurements = kIsWeb ? 10 : 50;
      if (measurements.length > maxMeasurements) {
        measurements.removeRange(maxMeasurements, measurements.length);
      }
      
      final jsonList = measurements.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      // Verificar tamaño antes de guardar en web
      if (kIsWeb && jsonString.length > 4000000) { // ~4MB límite
        // Si es muy grande, guardar solo las últimas 5
        final reducedList = measurements.take(5).map((m) => m.toJson()).toList();
        await prefs.setString(_measurementsKey, jsonEncode(reducedList));
      } else {
        await prefs.setString(_measurementsKey, jsonString);
      }
    } catch (e) {
      print('Error guardando medición: $e');
      // En caso de error de cuota, limpiar e intentar guardar solo esta medición
      if (e.toString().contains('QuotaExceededError') || 
          e.toString().contains('exceeded')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_measurementsKey);
        final jsonList = [measurement.toJson()];
        await prefs.setString(_measurementsKey, jsonEncode(jsonList));
      }
    }
  }

  /// Obtiene todas las mediciones guardadas
  Future<List<RootMeasurement>> getMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_measurementsKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => RootMeasurement.fromJson(json)).toList();
  }

  /// Elimina una medición
  Future<void> deleteMeasurement(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final measurements = await getMeasurements();
    
    measurements.removeWhere((m) => m.id == id);
    
    final jsonList = measurements.map((m) => m.toJson()).toList();
    await prefs.setString(_measurementsKey, jsonEncode(jsonList));
  }

  /// Elimina todas las mediciones
  Future<void> clearAllMeasurements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_measurementsKey);
  }

  /// Obtiene el directorio de almacenamiento de imágenes
  Future<Directory> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/images');
    
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    
    return imagesDir;
  }

  /// Exporta las mediciones a un archivo CSV
  Future<File> exportToCSV() async {
    final measurements = await getMeasurements();
    final buffer = StringBuffer();
    
    // Cabecera
    buffer.writeln('ID,Fecha,Raíces Detectadas,Longitud Total (mm),Calibrado');
    
    // Datos
    for (final m in measurements) {
      final totalLength = m.roots.fold<double>(0, (sum, r) => sum + r.lengthMm);
      buffer.writeln(
        '${m.id},'
        '${m.timestamp.toIso8601String()},'
        '${m.roots.length},'
        '${totalLength.toStringAsFixed(2)},'
        '${m.calibrated}',
      );
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/mediciones_raices.csv');
    await file.writeAsString(buffer.toString());
    
    return file;
  }
}
