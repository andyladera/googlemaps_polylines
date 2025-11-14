import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  late final DirectionsRepository _directionsRepository;
  Directions? _info;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        // 1. AÑADIMOS BOTONES AL APPBAR
        actions: [
          if (_origin != null)
            TextButton(
              onPressed: () => _animateToMarker(_origin!.position),
              child: const Text('ORIGEN'),
            ),
          if (_destination != null)
            TextButton(
              onPressed: () => _animateToMarker(_destination!.position),
              child: const Text('DESTINO'),
            ),
        ],
      ),
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
            polylines: _polylines,
          ),
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
      // 2. AÑADIMOS EL BOTÓN FLOTANTE
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        onPressed: _resetCamera,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

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

      final directions = await _directionsRepository.getDirections(
        origin: _origin!.position,
        destination: pos,
      );

      if (directions != null) {
        setState(() {
          _info = directions;
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('overview_polyline'),
              color: Colors.red,
              width: 5,
              points: directions.polylinePoints,
            ),
          );
        });

        // 3. ¡ANIMAMOS LA CÁMARA A LOS LÍMITES DE LA RUTA!
        //    (Ver transcripción, 9:05)
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(directions.bounds, 100.0), // 100.0 de padding
        );
      }
    }
  }

  // 4. NUEVO MÉTODO PARA CENTRAR CÁMARA (BOTONES APPBAR)
  void _animateToMarker(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 14.5,
          tilt: 50.0, // (Ver transcripción, 5:39)
        ),
      ),
    );
  }

  // 5. NUEVO MÉTODO PARA RESETEAR CÁMARA (BOTÓN FLOTANTE)
  void _resetCamera() {
    if (_info != null) {
      // Si hay ruta, centramos en la ruta
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_info!.bounds, 100.0),
      );
    } else {
      // Si no hay ruta, volvemos a la posición inicial
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(_initialCameraPosition),
      );
    }
  }
}