import 'dart:typed_data';
import 'dart:math' as dart_math;
import 'dart:convert' show base64Encode;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/root_measurement.dart';
import 'dart:io' show File;
export 'dart:io' show File;

class ImageProcessingService {
  /// Lee los bytes de una imagen (compatible con web)
  Future<Uint8List> _readImageBytes(String imagePath) async {
    if (kIsWeb) {
      // En web, la imagePath es una URL de blob
      final response = await http.get(Uri.parse(imagePath));
      return response.bodyBytes;
    } else {
      // En móvil, leer desde archivo
      return await File(imagePath).readAsBytes();
    }
  }

  /// Detecta marcadores ArUco en la imagen y calcula la escala
  Future<double> detectArucoAndCalculateScale(String imagePath) async {
    try {
      final imageBytes = await _readImageBytes(imagePath);
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // TODO: Implementar detección de ArUco con OpenCV
      // Por ahora, retornar un valor por defecto (80mm = tamaño del marcador)
      // Esto asume que el marcador ArUco tiene 80mm de lado
      
      // Simulación: 80 píxeles = 80mm, entonces 1 pixel = 1mm
      // En producción, esto se calculará detectando los marcadores ArUco
      return 1.0; // pixels per mm
    } catch (e) {
      print('Error detectando ArUco: $e');
      rethrow;
    }
  }

  /// Procesa la imagen para detectar y medir raíces
  Future<RootMeasurement> processImage(String imagePath) async {
    try {
      final imageBytes = await _readImageBytes(imagePath);
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // 1. Detectar ArUco y calcular escala
      final pixelsPerMm = await detectArucoAndCalculateScale(imagePath);
      
      // 2. Convertir a escala de grises
      final gray = img.grayscale(image);
      
      // 3. Aplicar umbral para segmentar raíces
      final binary = _applyThreshold(gray, threshold: 100);
      
      // 4. Detectar componentes conectados (raíces individuales)
      final roots = _detectRoots(binary, pixelsPerMm);
      
      // 5. Crear medición
      final measurement = RootMeasurement(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        timestamp: DateTime.now(),
        roots: roots,
        pixelsPerMm: pixelsPerMm,
        calibrated: pixelsPerMm != 1.0,
      );

      return measurement;
    } catch (e) {
      print('Error procesando imagen: $e');
      rethrow;
    }
  }

  /// Aplica umbralización automática usando método Otsu
  img.Image _applyThreshold(img.Image image, {int threshold = 128}) {
    // Calcular histograma
    final histogram = List<int>.filled(256, 0);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel).toInt();
        histogram[luminance]++;
      }
    }
    
    // Calcular umbral óptimo usando método Otsu
    final totalPixels = image.width * image.height;
    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }
    
    double sumB = 0;
    int wB = 0;
    int wF = 0;
    double maxVariance = 0;
    int optimalThreshold = 128;
    
    for (int t = 0; t < 256; t++) {
      wB += histogram[t];
      if (wB == 0) continue;
      
      wF = totalPixels - wB;
      if (wF == 0) break;
      
      sumB += t * histogram[t];
      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;
      
      final variance = wB * wF * (mB - mF) * (mB - mF);
      
      if (variance > maxVariance) {
        maxVariance = variance;
        optimalThreshold = t;
      }
    }
    
    // Aplicar umbral
    final result = img.Image(width: image.width, height: image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel).toInt();
        
        // Negro si está por encima del umbral (raíces claras sobre fondo oscuro)
        final newPixel = luminance > optimalThreshold
            ? img.ColorRgb8(0, 0, 0)
            : img.ColorRgb8(255, 255, 255);
        
        result.setPixel(x, y, newPixel);
      }
    }
    
    return result;
  }

  /// Detecta raíces individuales usando componentes conectados
  List<RootData> _detectRoots(img.Image binary, double pixelsPerMm) {
    final roots = <RootData>[];
    final visited = List.generate(
      binary.height,
      (_) => List.filled(binary.width, false),
    );

    int rootId = 0;

    for (int y = 0; y < binary.height; y++) {
      for (int x = 0; x < binary.width; x++) {
        final pixel = binary.getPixel(x, y);
        final isBlack = img.getLuminance(pixel) < 128;
        
        if (isBlack && !visited[y][x]) {
          final points = _floodFill(binary, x, y, visited);
          
          // Filtrar componentes más agresivamente
          // Raíces deben tener al menos 200 píxeles y ser elongadas
          if (points.length > 200) {
            final bounds = _getBounds(points);
            final width = bounds['maxX']! - bounds['minX']!;
            final height = bounds['maxY']! - bounds['minY']!;
            final aspectRatio = height > width ? height / width : width / height;
            
            // Solo considerar componentes elongados (raíces son alargadas)
            // Rechazar manchas redondas que probablemente sean ruido
            if (aspectRatio > 2.0) {
              // Esqueletizar para calcular longitud real
              final skeleton = _skeletonize(points, bounds);
              final length = _calculateSkeletonLength(skeleton, pixelsPerMm);
              final area = points.length / (pixelsPerMm * pixelsPerMm);
              
              roots.add(RootData(
                id: rootId++,
                lengthMm: length,
                points: points,
                area: area,
              ));
            }
          }
        }
      }
    }

    return roots;
  }

  /// Obtiene los límites de un conjunto de puntos
  Map<String, double> _getBounds(List<Point> points) {
    double minX = points.first.x;
    double maxX = points.first.x;
    double minY = points.first.y;
    double maxY = points.first.y;

    for (final point in points) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }

    return {
      'minX': minX,
      'maxX': maxX,
      'minY': minY,
      'maxY': maxY,
    };
  }

  /// Esqueletiza un conjunto de puntos usando adelgazamiento morfológico
  List<Point> _skeletonize(List<Point> points, Map<String, double> bounds) {
    // Crear imagen binaria pequeña del componente
    final width = (bounds['maxX']! - bounds['minX']! + 3).toInt();
    final height = (bounds['maxY']! - bounds['minY']! + 3).toInt();
    final offsetX = bounds['minX']!.toInt() - 1;
    final offsetY = bounds['minY']!.toInt() - 1;
    
    final binary = List.generate(height, (_) => List.filled(width, false));
    
    for (final point in points) {
      final x = point.x.toInt() - offsetX;
      final y = point.y.toInt() - offsetY;
      if (x >= 0 && x < width && y >= 0 && y < height) {
        binary[y][x] = true;
      }
    }
    
    // Algoritmo de adelgazamiento iterativo (Zhang-Suen)
    bool changed = true;
    int iterations = 0;
    while (changed && iterations < 50) {
      changed = false;
      final toRemove = <List<int>>[];
      
      // Sub-iteración 1
      for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
          if (binary[y][x] && _shouldRemovePixel(binary, x, y, true)) {
            toRemove.add([x, y]);
            changed = true;
          }
        }
      }
      for (final coord in toRemove) {
        binary[coord[1]][coord[0]] = false;
      }
      
      toRemove.clear();
      
      // Sub-iteración 2
      for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
          if (binary[y][x] && _shouldRemovePixel(binary, x, y, false)) {
            toRemove.add([x, y]);
            changed = true;
          }
        }
      }
      for (final coord in toRemove) {
        binary[coord[1]][coord[0]] = false;
      }
      
      iterations++;
    }
    
    // Convertir de vuelta a puntos
    final skeleton = <Point>[];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (binary[y][x]) {
          skeleton.add(Point((x + offsetX).toDouble(), (y + offsetY).toDouble()));
        }
      }
    }
    
    return skeleton;
  }

  /// Determina si un píxel debe ser removido en el adelgazamiento
  bool _shouldRemovePixel(List<List<bool>> binary, int x, int y, bool firstSubIteration) {
    // Vecinos: P2, P3, P4, P5, P6, P7, P8, P9
    final p2 = binary[y - 1][x];
    final p3 = binary[y - 1][x + 1];
    final p4 = binary[y][x + 1];
    final p5 = binary[y + 1][x + 1];
    final p6 = binary[y + 1][x];
    final p7 = binary[y + 1][x - 1];
    final p8 = binary[y][x - 1];
    final p9 = binary[y - 1][x - 1];
    
    final neighbors = [p2, p3, p4, p5, p6, p7, p8, p9];
    final blackCount = neighbors.where((n) => n).length;
    
    // Número de transiciones 0->1
    int transitions = 0;
    for (int i = 0; i < 8; i++) {
      if (!neighbors[i] && neighbors[(i + 1) % 8]) {
        transitions++;
      }
    }
    
    // Condiciones de Zhang-Suen
    if (blackCount < 2 || blackCount > 6) return false;
    if (transitions != 1) return false;
    
    if (firstSubIteration) {
      return (!p2 || !p4 || !p6) && (!p4 || !p6 || !p8);
    } else {
      return (!p2 || !p4 || !p8) && (!p2 || !p6 || !p8);
    }
  }

  /// Flood fill para encontrar componente conectado
  List<Point> _floodFill(
    img.Image image,
    int startX,
    int startY,
    List<List<bool>> visited,
  ) {
    final points = <Point>[];
    final stack = <List<int>>[[startX, startY]];

    while (stack.isNotEmpty) {
      final coord = stack.removeLast();
      final x = coord[0];
      final y = coord[1];

      if (x < 0 || x >= image.width || y < 0 || y >= image.height) continue;
      if (visited[y][x]) continue;

      final pixel = image.getPixel(x, y);
      final isBlack = img.getLuminance(pixel) < 128;
      
      if (!isBlack) continue;

      visited[y][x] = true;
      points.add(Point(x.toDouble(), y.toDouble()));

      // Agregar vecinos (8-conectividad)
      stack.add([x + 1, y]);
      stack.add([x - 1, y]);
      stack.add([x, y + 1]);
      stack.add([x, y - 1]);
      stack.add([x + 1, y + 1]);
      stack.add([x + 1, y - 1]);
      stack.add([x - 1, y + 1]);
      stack.add([x - 1, y - 1]);
    }

    return points;
  }

  /// Calcula la longitud del esqueleto (medición real de la raíz)
  double _calculateSkeletonLength(List<Point> skeleton, double pixelsPerMm) {
    if (skeleton.isEmpty) return 0.0;
    if (skeleton.length == 1) return 1.0 / pixelsPerMm;
    
    // Encontrar punto inicial (extremo del esqueleto)
    Point? startPoint;
    for (final point in skeleton) {
      final neighbors = _countNeighbors(point, skeleton);
      if (neighbors == 1) {
        startPoint = point;
        break;
      }
    }
    
    // Si no hay extremo claro, usar el primer punto
    startPoint ??= skeleton.first;
    
    // Recorrer el esqueleto calculando distancia
    final visited = <Point>{};
    double totalLength = 0.0;
    Point current = startPoint;
    visited.add(current);
    
    while (true) {
      // Encontrar vecino más cercano no visitado
      Point? nextPoint;
      double minDist = double.infinity;
      
      for (final point in skeleton) {
        if (visited.contains(point)) continue;
        
        final dist = _distance(current, point);
        if (dist < 2.0 && dist < minDist) { // Vecinos a distancia <= sqrt(2)
          minDist = dist;
          nextPoint = point;
        }
      }
      
      if (nextPoint == null) break;
      
      totalLength += minDist;
      visited.add(nextPoint);
      current = nextPoint;
    }
    
    // Convertir píxeles a mm
    return totalLength / pixelsPerMm;
  }

  /// Cuenta vecinos de un punto en el esqueleto
  int _countNeighbors(Point point, List<Point> skeleton) {
    int count = 0;
    for (final other in skeleton) {
      if (other == point) continue;
      final dist = _distance(point, other);
      if (dist <= 1.5) count++; // Vecino directo o diagonal
    }
    return count;
  }

  /// Calcula distancia euclidiana entre dos puntos
  double _distance(Point p1, Point p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return dart_math.sqrt(dx * dx + dy * dy);
  }

  /// Calcula el centro de una raíz desde sus puntos
  Map<String, int> _calculateCenter(List<Point> points) {
    if (points.isEmpty) return {'x': 0, 'y': 0};
    
    double sumX = 0;
    double sumY = 0;
    for (final point in points) {
      sumX += point.x;
      sumY += point.y;
    }
    
    return {
      'x': (sumX / points.length).toInt(),
      'y': (sumY / points.length).toInt(),
    };
  }

  /// Guarda la imagen procesada con anotaciones
  Future<String> saveProcessedImage(
    String originalPath,
    RootMeasurement measurement,
  ) async {
    try {
      final imageBytes = await _readImageBytes(originalPath);
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Dibujar raíces detectadas con transparencia
      for (final root in measurement.roots) {
        // Calcular color único para cada raíz
        final color = _getColorForRoot(root.id);
        
        // Dibujar puntos de la raíz con semi-transparencia
        for (final point in root.points) {
          if (point.x >= 0 && point.x < image.width &&
              point.y >= 0 && point.y < image.height) {
            final originalPixel = image.getPixel(point.x.toInt(), point.y.toInt());
            final oldColor = originalPixel.toList();
            
            // Mezclar color con 50% de transparencia
            final r = ((oldColor[0] + color[0]) / 2).toInt();
            final g = ((oldColor[1] + color[1]) / 2).toInt();
            final b = ((oldColor[2] + color[2]) / 2).toInt();
            
            image.setPixel(
              point.x.toInt(),
              point.y.toInt(),
              img.ColorRgb8(r, g, b),
            );
          }
        }
        
        // Dibujar número de la raíz en el centro
        if (root.points.isNotEmpty) {
          final center = _calculateCenter(root.points);
          _drawNumber(image, center['x']!, center['y']!, root.id + 1, color);
        }
      }

      // Guardar imagen procesada
      final processedBytes = img.encodeJpg(image);
      
      if (kIsWeb) {
        // En web, convertir bytes a data URL para mostrar la imagen procesada
        final base64String = base64Encode(processedBytes);
        return 'data:image/jpeg;base64,$base64String';
      } else {
        // En móvil, guardar en archivo
        final processedPath = originalPath.replaceAll('.jpg', '_processed.jpg');
        await File(processedPath).writeAsBytes(processedBytes);
        return processedPath;
      }
    } catch (e) {
      print('Error guardando imagen procesada: $e');
      rethrow;
    }
  }

  /// Dibuja un número en la imagen con fondo
  void _drawNumber(img.Image image, int x, int y, int number, List<int> color) {
    final text = number.toString();
    
    // Tamaño del texto (simplificado, cada dígito ~5x7 pixels)
    final width = text.length * 7 + 4;
    final height = 11;
    
    // Dibujar fondo blanco con borde
    for (int dy = -height ~/ 2; dy <= height ~/ 2; dy++) {
      for (int dx = -width ~/ 2; dx <= width ~/ 2; dx++) {
        final px = x + dx;
        final py = y + dy;
        if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
          // Borde del color de la raíz
          if (dy == -height ~/ 2 || dy == height ~/ 2 || 
              dx == -width ~/ 2 || dx == width ~/ 2) {
            image.setPixel(px, py, img.ColorRgb8(color[0], color[1], color[2]));
          } else {
            image.setPixel(px, py, img.ColorRgb8(255, 255, 255));
          }
        }
      }
    }
    
    // Dibujar cada dígito
    for (int i = 0; i < text.length; i++) {
      final digit = int.parse(text[i]);
      final digitX = x - (text.length * 7 ~/ 2) + (i * 7) + 3;
      _drawDigit(image, digitX, y, digit, color);
    }
  }

  /// Dibuja un dígito usando una fuente simple
  void _drawDigit(img.Image image, int x, int y, int digit, List<int> color) {
    // Fuente 5x7 simplificada para dígitos
    final patterns = [
      // 0
      [
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
      ],
      // 1
      [
        [0, 0, 1, 0, 0],
        [0, 1, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 0, 1, 0, 0],
        [0, 1, 1, 1, 0],
      ],
      // 2
      [
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0],
        [0, 1, 0, 0, 0],
        [1, 1, 1, 1, 1],
      ],
      // 3
      [
        [1, 1, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 1],
        [1, 1, 1, 1, 0],
      ],
      // 4
      [
        [0, 0, 0, 1, 0],
        [0, 0, 1, 1, 0],
        [0, 1, 0, 1, 0],
        [1, 0, 0, 1, 0],
        [1, 1, 1, 1, 1],
        [0, 0, 0, 1, 0],
        [0, 0, 0, 1, 0],
      ],
      // 5
      [
        [1, 1, 1, 1, 1],
        [1, 0, 0, 0, 0],
        [1, 1, 1, 1, 0],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
      ],
      // 6
      [
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 0],
        [1, 0, 0, 0, 0],
        [1, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
      ],
      // 7
      [
        [1, 1, 1, 1, 1],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 1, 0],
        [0, 0, 1, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
        [0, 1, 0, 0, 0],
      ],
      // 8
      [
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
      ],
      // 9
      [
        [0, 1, 1, 1, 0],
        [1, 0, 0, 0, 1],
        [1, 0, 0, 0, 1],
        [0, 1, 1, 1, 1],
        [0, 0, 0, 0, 1],
        [0, 0, 0, 0, 1],
        [0, 1, 1, 1, 0],
      ],
    ];

    final pattern = patterns[digit];
    
    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 5; col++) {
        if (pattern[row][col] == 1) {
          final px = x + col - 2;
          final py = y + row - 3;
          if (px >= 0 && px < image.width && py >= 0 && py < image.height) {
            image.setPixel(px, py, img.ColorRgb8(color[0], color[1], color[2]));
          }
        }
      }
    }
  }

  /// Genera un color único para cada raíz
  List<int> _getColorForRoot(int rootId) {
    final colors = [
      [255, 0, 0],    // Rojo
      [0, 255, 0],    // Verde
      [0, 0, 255],    // Azul
      [255, 255, 0],  // Amarillo
      [255, 0, 255],  // Magenta
      [0, 255, 255],  // Cian
      [255, 128, 0],  // Naranja
      [128, 0, 255],  // Púrpura
    ];
    
    return colors[rootId % colors.length];
  }


}
