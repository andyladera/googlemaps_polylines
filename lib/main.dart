import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// 1. IMPORTAMOS NUESTRO REPOSITORIO Y MODELO
//    (Usando el nombre de tu proyecto "googlemaps_polylines")
import 'package:googlemaps_polylines/helpers/directions_repository.dart';
import 'package:googlemaps_polylines/models/directions_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Maps Directions',
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.773972, -122.431297), // San Francisco
    zoom: 12,
  );

  GoogleMapController? _mapController;

  Marker? _origin;
  Marker? _destination;

  // 2. INSTANCIAMOS EL REPOSITORIO
  late final DirectionsRepository _directionsRepository;

  // 3. VARIABLE PARA GUARDAR LA INFORMACIÓN DE LA RUTA
  Directions? _info;

  // 4. VARIABLE PARA GUARDAR LAS POLILÍNEAS
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    // Inicializamos el repositorio
    _directionsRepository = DirectionsRepository();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps Directions'),
      ),
      // 5. ENVOLVEMOS EL MAPA EN UN STACK
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },
            onLongPress: _addMarker,
            
            // 6. AÑADIMOS LAS POLILÍNEAS AL MAPA
            polylines: _polylines,
          ),

          // 7. MOSTRAMOS LA INFORMACIÓN DE RUTA (SI EXISTE)
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    )
                  ],
                ),
                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 8. MODIFICAMOS _addMarker PARA QUE SEA 'async'
  Future<void> _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      // Caso 1: Origen
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origen'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
        _destination = null;
        
        // Reseteamos la info y las polilíneas
        _info = null;
        _polylines.clear();
      });
    } else {
      // Caso 2: Destino
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destino'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      // 9. ¡OBTENEMOS LAS DIRECCIONES!
      final directions = await _directionsRepository.getDirections(
        origin: _origin!.position,
        destination: pos,
      );

      // 10. DIBUJAMOS LA POLILÍNEA
      if (directions != null) {
        setState(() {
          _info = directions; // Guardamos la info
          _polylines.clear(); // Limpiamos polilíneas anteriores
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('overview_polyline'),
              color: Colors.red,
              width: 5,
              points: directions.polylinePoints, // ¡Los puntos de la ruta!
            ),
          );
        });
      }
    }
  }
}