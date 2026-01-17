class RootMeasurement {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final List<RootData> roots;
  final double pixelsPerMm;
  final bool calibrated;

  RootMeasurement({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    required this.roots,
    required this.pixelsPerMm,
    this.calibrated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': '', // No guardar ruta de imagen para ahorrar espacio
      'timestamp': timestamp.toIso8601String(),
      'roots': roots.map((r) => r.toJson(includePoints: false)).toList(),
      'pixelsPerMm': pixelsPerMm,
      'calibrated': calibrated,
    };
  }

  factory RootMeasurement.fromJson(Map<String, dynamic> json) {
    return RootMeasurement(
      id: json['id'],
      imagePath: json['imagePath'],
      timestamp: DateTime.parse(json['timestamp']),
      roots: (json['roots'] as List)
          .map((r) => RootData.fromJson(r))
          .toList(),
      pixelsPerMm: json['pixelsPerMm'],
      calibrated: json['calibrated'] ?? false,
    );
  }
}

class RootData {
  final int id;
  final double lengthMm;
  final List<Point> points;
  final double area;

  RootData({
    required this.id,
    required this.lengthMm,
    required this.points,
    this.area = 0.0,
  });

  Map<String, dynamic> toJson({bool includePoints = false}) {
    return {
      'id': id,
      'lengthMm': lengthMm,
      // No guardar puntos por defecto para ahorrar espacio
      if (includePoints) 'points': points.map((p) => p.toJson()).toList(),
      'area': area,
      'pointCount': points.length, // Solo guardar el conteo
    };
  }

  factory RootData.fromJson(Map<String, dynamic> json) {
    return RootData(
      id: json['id'],
      lengthMm: json['lengthMm'],
      points: json['points'] != null
          ? (json['points'] as List).map((p) => Point.fromJson(p)).toList()
          : [], // Si no hay puntos guardados, lista vacía
      area: json['area'] ?? 0.0,
    );
  }
}

class Point {
  final double x;
  final double y;

  Point(this.x, this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(json['x'], json['y']);
  }
}

class ArucoMarker {
  final int id;
  final List<Point> corners;
  final Point center;

  ArucoMarker({
    required this.id,
    required this.corners,
    required this.center,
  });
}
