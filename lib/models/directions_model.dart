// lib/models/directions_model.dart

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Esta clase contendrá toda la información de la ruta
class Directions {
  // Los límites geográficos de la ruta (para hacer zoom)
  final LatLngBounds bounds;

  // La lista de coordenadas para dibujar la polilínea
  final List<LatLng> polylinePoints;

  // La distancia total (ej. "10 km")
  final String totalDistance;

  // La duración total (ej. "15 min")
  final String totalDuration;

  // Constructor
  const Directions({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  // 1. Constructor 'factory' para crear una instancia desde el JSON de la API
  //    (Esto sigue la transcripción, 7:06)
  factory Directions.fromMap(Map<String, dynamic> map) {
    // 2. Comprobamos si hay rutas
    //    (Ver transcripción, 7:51)
    if ((map['routes'] as List).isEmpty) {
      // Si no hay rutas, podríamos devolver nulo o un objeto vacío,
      // pero para este caso lanzaremos un error o devolveremos 
      // un objeto 'default'. Por ahora, asumimos que siempre hay ruta.
      // En un app real, aquí deberías manejar el error.
    }

    // 3. Obtenemos la primera ruta de la lista
    final data = Map<String, dynamic>.from(map['routes'][0]);

    // 4. Obtenemos los límites (bounds)
    //    (Ver transcripción, 7:56)
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );

    // 5. Obtenemos distancia y duración
    //    (Ver transcripción, 8:02)
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }

    // 6. Obtenemos la polilínea codificada
    //    (Ver transcripción, 8:14)
    final String polylineEncoded = data['overview_polyline']['points'];

    // 7. Decodificamos la polilínea
    //    (Ver transcripción, 8:16)
    final List<LatLng> polylinePoints = PolylinePoints()
        .decodePolyline(polylineEncoded)
        .map((PointLatLng point) => LatLng(point.latitude, point.longitude))
        .toList();

    // 8. Retornamos el objeto 'Directions'
    //    (Ver transcripción, 8:09)
    return Directions(
      bounds: bounds,
      polylinePoints: polylinePoints,
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}