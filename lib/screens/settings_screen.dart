import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/google_sheets_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GoogleSheetsService _sheetsService = GoogleSheetsService();
  final TextEditingController _webhookUrlController = TextEditingController();
  
  bool _isEnabled = false;
  bool _isLoading = true;
  String? _currentWebhookUrl;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _webhookUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    final enabled = await _sheetsService.isEnabled();
    final webhookUrl = await _sheetsService.getWebhookUrl();

    setState(() {
      _isEnabled = enabled;
      _currentWebhookUrl = webhookUrl;
      _webhookUrlController.text = webhookUrl ?? '';
      _isLoading = false;
    });
  }

  Future<void> _validateAndSaveWebhookUrl() async {
    final url = _webhookUrlController.text.trim();
    
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce la URL del webhook')),
      );
      return;
    }

    if (!url.startsWith('https://script.google.com/')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La URL debe empezar con https://script.google.com/')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final isValid = await _sheetsService.validateWebhookUrl(url);
    
    if (!mounted) return;
    
    if (isValid) {
      await _sheetsService.setWebhookUrl(url);
      
      setState(() {
        _currentWebhookUrl = url;
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Webhook configurado correctamente')),
      );
    } else {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo validar el webhook. Verifica la URL.')),
      );
    }
  }

  Future<void> _toggleIntegration(bool value) async {
    if (value && (_currentWebhookUrl == null || _currentWebhookUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero debes configurar el webhook')),
      );
      return;
    }

    await _sheetsService.setEnabled(value);
    setState(() => _isEnabled = value);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value 
          ? 'Integración con Google Sheets activada' 
          : 'Integración con Google Sheets desactivada'
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de Google Sheets
          const Text(
            'Integración con Google Sheets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Envía automáticamente las mediciones a una hoja de cálculo de Google',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Configuración del webhook
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.webhook, color: Colors.blue),
                      const SizedBox(width: 12),
                      const Text(
                        'Configuración del Webhook',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_currentWebhookUrl != null && _currentWebhookUrl!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Webhook configurado correctamente',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _webhookUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL del Webhook',
                      hintText: 'https://script.google.com/macros/s/...',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.help_outline),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('¿Cómo obtener la URL?'),
                              content: const SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '1. Abre o crea una hoja de Google Sheets\n\n'
                                      '2. Ve a Extensiones > Apps Script\n\n'
                                      '3. Copia el código del script (ver documentación)\n\n'
                                      '4. Despliega > Nueva implementación\n\n'
                                      '5. Tipo: Aplicación web\n\n'
                                      '6. Copia la URL que te da\n\n'
                                      '7. Pégala aquí',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Entendido'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _validateAndSaveWebhookUrl,
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar y Validar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Activar/Desactivar integración
          Card(
            child: SwitchListTile(
              value: _isEnabled,
              onChanged: _toggleIntegration,
              title: const Text('Activar integración'),
              subtitle: Text(
                _isEnabled
                    ? 'Las mediciones se enviarán automáticamente'
                    : 'Las mediciones no se enviarán a Google Sheets',
              ),
              secondary: Icon(
                _isEnabled ? Icons.cloud_upload : Icons.cloud_off,
                color: _isEnabled ? Colors.green : Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Información
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Información',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• No necesitas configurar Google Cloud Console\n\n'
                    '• Solo copia el script a tu hoja de Google Sheets\n\n'
                    '• Funciona en web, Android e iOS\n\n'
                    '• Ver documentación completa: GOOGLE_SHEETS_SETUP_SIMPLE.md',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
