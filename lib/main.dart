import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'models/public_vehicle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MarkersPage(),
    );
  }
}

class MarkersPage extends StatefulWidget {
  const MarkersPage({Key? key}) : super(key: key);

  @override
  State<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  MaplibreMapController? controller;

  void _onMapCreated(MaplibreMapController controller) {
    print("map created");
    this.controller = controller;
  }

  void _onStyleLoaded() {
    print("style loaded");
  }

  void _addPublicVehicleMarker({
    required PublicVehicleModel publicVehicle,
  }) {
    controller!.addSymbol(_getPublicVehicleSymbolOptions(publicVehicle: publicVehicle));
  }

  SymbolOptions _getPublicVehicleSymbolOptions({
    required PublicVehicleModel publicVehicle,
  }) {
    return SymbolOptions(
      iconRotate: publicVehicle.bearing,
      geometry: publicVehicle.coords,
      textHaloWidth: 20.0,
      textHaloColor: '#FFFFFF',
      textField: publicVehicle.routeShortName,
      textOffset: const Offset(1.0, 1.0),
      iconImage: "assets/raster/markers/vehicle_marker.png",
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<PublicVehicleModel> publicVehicles = [
      PublicVehicleModel(
        id: 0,
        coords: LatLng(60.0, 30.3),
        routeShortName: "22",
        bearing: 56,
      ),
      PublicVehicleModel(
        id: 0,
        coords: LatLng(60.0, 30.32),
        routeShortName: "24",
        bearing: 28,
      ),
    ];

    return Scaffold(
      body: MaplibreMap(
        styleString: "https://map.91.team/styles/basic/style.json",
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoaded,
        initialCameraPosition: const CameraPosition(
          target: LatLng(60.0, 30.3),
          zoom: 11.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (var publicVehicle in publicVehicles) {
            _addPublicVehicleMarker(publicVehicle: publicVehicle);
          }
        },
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
