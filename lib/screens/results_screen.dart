import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import '../models/root_measurement.dart';
import 'package:intl/intl.dart';

class ResultsScreen extends StatelessWidget {
  final RootMeasurement measurement;
  final String processedImagePath;

  const ResultsScreen({
    super.key,
    required this.measurement,
    required this.processedImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final totalLength = measurement.roots.fold<double>(
      0,
      (sum, root) => sum + root.lengthMm,
    );
    final averageLength = measurement.roots.isEmpty
        ? 0.0
        : totalLength / measurement.roots.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implementar compartir resultados
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de compartir próximamente')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen procesada
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  kIsWeb
                      ? Image.network(
                          processedImagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Image.network(
                          processedImagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          measurement.calibrated
                              ? Icons.check_circle
                              : Icons.warning,
                          color: measurement.calibrated
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          measurement.calibrated
                              ? 'Calibrado con ArUco'
                              : 'Sin calibración - mediciones aproximadas',
                          style: TextStyle(
                            color: measurement.calibrated
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Estadísticas generales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _StatRow(
                      icon: Icons.grass,
                      label: 'Raíces detectadas',
                      value: '${measurement.roots.length}',
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.straighten,
                      label: 'Longitud total',
                      value: '${totalLength.toStringAsFixed(1)} mm',
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.show_chart,
                      label: 'Longitud promedio',
                      value: '${averageLength.toStringAsFixed(1)} mm',
                    ),
                    const Divider(height: 24),
                    _StatRow(
                      icon: Icons.calendar_today,
                      label: 'Fecha',
                      value: DateFormat('dd/MM/yyyy HH:mm').format(
                        measurement.timestamp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lista de raíces individuales
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mediciones Individuales',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (measurement.roots.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No se detectaron raíces',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ...measurement.roots.asMap().entries.map((entry) {
                        final index = entry.key;
                        final root = entry.value;
                        return Column(
                          children: [
                            if (index > 0) const Divider(height: 24),
                            _RootRow(
                              rootNumber: index + 1,
                              root: root,
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botón volver
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text('Volver al Inicio'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RootRow extends StatelessWidget {
  final int rootNumber;
  final RootData root;

  const _RootRow({
    required this.rootNumber,
    required this.root,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$rootNumber',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Raíz $rootNumber',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Longitud: ${root.lengthMm.toStringAsFixed(1)} mm',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (root.area > 0) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.crop_square,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Área: ${root.area.toStringAsFixed(1)} mm²',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
