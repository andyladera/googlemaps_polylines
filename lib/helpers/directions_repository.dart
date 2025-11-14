// lib/helpers/directions_repository.dart

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemaps_polylines/helpers/.env.dart'; // 1. Importamos nuestra API key
import 'package:googlemaps_polylines/models/directions_model.dart'; // 2. Importamos nuestro modelo

class DirectionsRepository {
  // 3. URL base de la API de Direcciones
  //    (Ver transcripción, 6:17)
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  // 4. Instancia de Dio para hacer las llamadas
  final Dio _dio;

  // 5. Constructor
  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  // 6. El método principal para obtener las direcciones
  //    (Ver transcripción, 6:26)
  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {

    // 7. Definimos los parámetros de la solicitud
    final Map<String, dynamic> queryParameters = {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': googleAPIKey, // 8. ¡Usamos nuestra API Key!
    };

    try {
      // 9. Hacemos la llamada GET
      //    (Ver transcripción, 6:37)
      final response = await _dio.get(
        _baseUrl,
        queryParameters: queryParameters,
      );

      // 10. Comprobamos si la respuesta fue exitosa
      //     (Ver transcripción, 7:01)
      if (response.statusCode == 200) {
        // 11. Usamos nuestro 'factory' para convertir el JSON en un objeto Directions
        //     (Ver transcripción, 7:02)
        return Directions.fromMap(response.data);
      }
      return null;
    } catch (e) {
      // 12. Manejo de errores (en una app real, esto sería más robusto)
      print('Error en DirectionsRepository: $e');
      return null;
    }
  }
}