import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../models/root_measurement.dart';
import '../services/image_processing_service.dart';
import '../services/storage_service.dart';
import 'results_screen.dart';

class ProcessingScreen extends StatefulWidget {
  final String imagePath;

  const ProcessingScreen({super.key, required this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final _processingService = ImageProcessingService();
  final _storageService = StorageService();
  bool _isProcessing = true;
  String _status = 'Analizando imagen...';
  double _progress = 0.0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      setState(() {
        _status = 'Detectando marcadores ArUco...';
        _progress = 0.2;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _status = 'Segmentando raíces...';
        _progress = 0.4;
      });

      // Procesar imagen
      final measurement = await _processingService.processImage(widget.imagePath);

      setState(() {
        _status = 'Calculando mediciones...';
        _progress = 0.7;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      // Guardar imagen procesada
      final processedPath = await _processingService.saveProcessedImage(
        widget.imagePath,
        measurement,
      );

      setState(() {
        _status = 'Guardando resultados...';
        _progress = 0.9;
      });

      // Intentar guardar medición (puede fallar en web por límite de storage)
      try {
        await _storageService.saveMeasurement(measurement);
      } catch (e) {
        print('Advertencia: No se pudo guardar en historial: $e');
        // Continuar de todas formas
      }

      setState(() {
        _progress = 1.0;
        _isProcessing = false;
      });

      // Navegar a resultados
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(
              measurement: measurement,
              processedImagePath: processedPath,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _error = 'Error al procesar imagen: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Preview de imagen
            Expanded(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          widget.imagePath,
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          widget.imagePath,
                          fit: BoxFit.contain,
                        ),
                ),
              ),
            ),
            
            // Panel de procesamiento
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_error != null) ...[
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ] else if (_isProcessing) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Procesamiento completo!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
