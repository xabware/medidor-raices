import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../models/root_measurement.dart';
import '../services/storage_service.dart';
import 'results_screen.dart';
import 'package:intl/intl.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _storageService = StorageService();
  List<RootMeasurement> _measurements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    setState(() => _isLoading = true);
    
    try {
      final measurements = await _storageService.getMeasurements();
      setState(() {
        _measurements = measurements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar mediciones: $e')),
        );
      }
    }
  }

  Future<void> _deleteMeasurement(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta medición?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storageService.deleteMeasurement(id);
      _loadMeasurements();
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final file = await _storageService.exportToCSV();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportado a: ${file.path}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Mediciones'),
        actions: [
          if (_measurements.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: _exportToCSV,
              tooltip: 'Exportar a CSV',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _measurements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay mediciones guardadas',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toma una foto para comenzar',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMeasurements,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _measurements.length,
                    itemBuilder: (context, index) {
                      final measurement = _measurements[index];
                      return _MeasurementCard(
                        measurement: measurement,
                        onTap: () async {
                          String imagePath;
                          if (kIsWeb) {
                            imagePath = measurement.imagePath;
                          } else {
                            final processedPath = measurement.imagePath
                                .replaceAll('.jpg', '_processed.jpg');
                            
                            // Verificar si existe la imagen procesada
                            final processedFile = File(processedPath);
                            imagePath = await processedFile.exists()
                                ? processedPath
                                : measurement.imagePath;
                          }
                          
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResultsScreen(
                                  measurement: measurement,
                                  processedImagePath: imagePath,
                                ),
                              ),
                            );
                          }
                        },
                        onDelete: () => _deleteMeasurement(measurement.id),
                      );
                    },
                  ),
                ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final RootMeasurement measurement;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MeasurementCard({
    required this.measurement,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalLength = measurement.roots.fold<double>(
      0,
      (sum, root) => sum + root.lengthMm,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRectangle(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? Image.network(
                        measurement.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      )
                    : Image.network(
                        measurement.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey[500],
                            ),
                          );
                        },
                      ),
              ),
              
              const SizedBox(width: 12),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.grass,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${measurement.roots.length} raíces',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (measurement.calibrated) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longitud total: ${totalLength.toStringAsFixed(1)} mm',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(
                        measurement.timestamp,
                      ),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Botón eliminar
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.grey[600],
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClipRRectangle extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;

  const ClipRRectangle({
    super.key,
    required this.borderRadius,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }
}
