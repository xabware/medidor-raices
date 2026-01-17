import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class ArucoPdfScreen extends StatelessWidget {
  const ArucoPdfScreen({super.key});

  Future<Uint8List> _generateArucoPdf() async {
    final pdf = pw.Document();

    // Generar PDF con marcadores ArUco en las esquinas y fondo negro
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Container(
            color: PdfColors.black,
            child: pw.Stack(
              children: [
              // Título e instrucciones en el centro
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Medidor de Raíces',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'Coloca las raíces claras sobre esta hoja negra',
                      style: pw.TextStyle(fontSize: 16, color: PdfColors.white),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Asegúrate que los 4 marcadores ArUco sean visibles',
                      style: pw.TextStyle(fontSize: 12, color: PdfColors.white),
                    ),
                  ],
                ),
              ),
              
              // Marcador ArUco - Esquina superior izquierda
              pw.Positioned(
                left: 0,
                top: 0,
                child: _buildArucoMarker(0),
              ),
              
              // Marcador ArUco - Esquina superior derecha
              pw.Positioned(
                right: 0,
                top: 0,
                child: _buildArucoMarker(1),
              ),
              
              // Marcador ArUco - Esquina inferior izquierda
              pw.Positioned(
                left: 0,
                bottom: 0,
                child: _buildArucoMarker(2),
              ),
              
              // Marcador ArUco - Esquina inferior derecha
              pw.Positioned(
                right: 0,
                bottom: 0,
                child: _buildArucoMarker(3),
              ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildArucoMarker(int id) {
    // Generar patrón ArUco simple (diccionario 4x4)
    // Los patrones están codificados para ArUco 4x4_50
    final patterns = [
      // ID 0
      [
        [0, 0, 0, 0, 0, 0],
        [0, 1, 0, 1, 1, 0],
        [0, 1, 1, 1, 0, 0],
        [0, 0, 1, 0, 1, 0],
        [0, 1, 0, 0, 1, 0],
        [0, 0, 0, 0, 0, 0],
      ],
      // ID 1
      [
        [0, 0, 0, 0, 0, 0],
        [0, 1, 0, 0, 1, 0],
        [0, 0, 1, 1, 1, 0],
        [0, 1, 1, 0, 0, 0],
        [0, 1, 0, 1, 0, 0],
        [0, 0, 0, 0, 0, 0],
      ],
      // ID 2
      [
        [0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 0],
        [0, 0, 1, 0, 1, 0],
        [0, 1, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0],
      ],
      // ID 3
      [
        [0, 0, 0, 0, 0, 0],
        [0, 1, 1, 1, 0, 0],
        [0, 1, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 0],
        [0, 0, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0],
      ],
    ];

    final pattern = patterns[id % patterns.length];
    const size = 80.0;
    const cellSize = size / 6;

    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 2, color: PdfColors.white),
        color: PdfColors.black,
      ),
      child: pw.Column(
        children: List.generate(6, (row) {
          return pw.Row(
            children: List.generate(6, (col) {
              return pw.Container(
                width: cellSize,
                height: cellSize,
                color: pattern[row][col] == 1
                    ? PdfColors.white
                    : PdfColors.black,
              );
            }),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Marcadores ArUco'),
      ),
      body: PdfPreview(
        build: (format) => _generateArucoPdf(),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: 'aruco_markers_a4.pdf',
        actionBarTheme: PdfActionBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
