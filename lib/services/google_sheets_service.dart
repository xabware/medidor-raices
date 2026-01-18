import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/root_measurement.dart';
import 'package:intl/intl.dart';

class GoogleSheetsService {
  static const String _webhookUrlKey = 'google_sheets_webhook_url';
  static const String _enabledKey = 'google_sheets_enabled';

  /// Verifica si la integración está habilitada
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Habilita o deshabilita la integración
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }

  /// Obtiene la URL del webhook configurada
  Future<String?> getWebhookUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_webhookUrlKey);
  }

  /// Guarda la URL del webhook
  Future<void> setWebhookUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_webhookUrlKey, url);
  }

  /// Envía una medición a Google Sheets vía webhook
  Future<bool> sendMeasurement(RootMeasurement measurement) async {
    if (!await isEnabled()) return false;

    final webhookUrl = await getWebhookUrl();
    if (webhookUrl == null || webhookUrl.isEmpty) return false;

    try {
      final totalLength = measurement.roots.fold<double>(
        0,
        (sum, root) => sum + root.lengthMm,
      );
      final averageLength = measurement.roots.isEmpty
          ? 0.0
          : totalLength / measurement.roots.length;
      final minLength = measurement.roots.isEmpty
          ? 0.0
          : measurement.roots.map((r) => r.lengthMm).reduce((a, b) => a < b ? a : b);
      final maxLength = measurement.roots.isEmpty
          ? 0.0
          : measurement.roots.map((r) => r.lengthMm).reduce((a, b) => a > b ? a : b);

      final dateFormat = DateFormat('dd/MM/yyyy HH:mm:ss');
      
      final data = {
        'fecha': dateFormat.format(measurement.timestamp),
        'id': measurement.id,
        'numeroRaices': measurement.roots.length,
        'longitudTotal': totalLength.toStringAsFixed(2),
        'longitudPromedio': averageLength.toStringAsFixed(2),
        'longitudMinima': minLength.toStringAsFixed(2),
        'longitudMaxima': maxLength.toStringAsFixed(2),
        'calibrado': measurement.calibrated ? 'Sí' : 'No',
        'pixelesPorMm': measurement.pixelsPerMm.toStringAsFixed(4),
      };

      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'text/plain'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return true;
      } else {
        print('Error al enviar a Google Sheets: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error al enviar medición a Google Sheets: $e');
      return false;
    }
  }

  /// Valida que la URL del webhook sea correcta
  Future<bool> validateWebhookUrl(String url) async {
    if (!url.startsWith('https://script.google.com/')) {
      return false;
    }
    
    try {
      // Intenta hacer una petición de prueba
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'text/plain',
        },
        body: jsonEncode({'test': true}),
      ).timeout(const Duration(seconds: 15));
      
      print('Validation response status: ${response.statusCode}');
      print('Validation response body: ${response.body}');
      
      // Aceptar códigos de éxito comunes
      if (response.statusCode >= 200 && response.statusCode < 400) {
        try {
          final jsonResponse = jsonDecode(response.body);
          // Verificar que la respuesta tenga el formato esperado
          return jsonResponse['status'] == 'success';
        } catch (e) {
          print('Error parsing JSON response: $e');
          return true; // Si no podemos parsear pero el código es 200, asumir que funciona
        }
      }
      
      return false;
    } catch (e) {
      print('Error al validar webhook: $e');
      return false;
    }
  }
}
