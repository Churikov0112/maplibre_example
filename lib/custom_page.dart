import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'models/public_vehicle.dart';

class MarkersPage extends StatefulWidget {
  const MarkersPage({Key? key}) : super(key: key);

  @override
  State<MarkersPage> createState() => _MarkersPageState();
}

class _MarkersPageState extends State<MarkersPage> {
  MaplibreMapController? controller;
  Symbol? _selectedSymbol;

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  @override
  void dispose() {
    controller?.onSymbolTapped.remove(_onSymbolTapped);
    super.dispose();
  }

  void _onStyleLoaded() {}

  void _addPublicVehicleMarker({
    required List<PublicVehicleModel> publicVehicles,
  }) async {
    // final _points = {
    //   {
    //     "type": "Feature",
    //     "properties": {
    //       "name": "Van Dorn Street",
    //       "marker-color": "#0000ff",
    //       "marker-symbol": "rail-metro",
    //       "line": "blue",
    //     },
    //     "geometry": {
    //       "type": "Point",
    //       "coordinates": [60.0, 30.0]
    //     }
    //   },
    // };

    // await controller!.addSource("points", GeojsonSourceProperties(data: _points));

    // await controller.addSymbolLayer(
    //   "points",
    //   "publicVehicles",
    //   SymbolLayerProperties(
    //     lineColor: Colors.indigo.toHexStringRGB(),
    //     lineCap: "round",
    //     lineJoin: "round",
    //     lineWidth: 3,
    //   ),
    // );
    // }

    // controller!.addSymbols(
    //   [
    //     for (var publicVehicle in publicVehicles)
    //       SymbolOptions(
    //         iconRotate: controller!.cameraPosition?.bearing,
    //         geometry: publicVehicle.coords,
    //         textHaloWidth: 20.0,
    //         textHaloColor: '#FFFFFF',
    //         textField: publicVehicle.routeShortName,
    //         textOffset: const Offset(2.0, 2.0),
    //         iconImage: "assets/raster/markers/vehicle_marker.png",
    //       ),
    //   ],
    // );
  }

  void _updateSymbol(Symbol symbol, SymbolOptions changes) async {
    await controller!.updateSymbol(symbol, changes);
  }

  void _onMapRotate() {
    final vehicleSymbols = controller!.symbolManager!.annotations;
    for (final symbol in vehicleSymbols) {
      if (symbol.options.iconRotate != null) {
        _updateSymbol(
          symbol,
          SymbolOptions(
            iconRotate: symbol.options.iconRotate! + controller!.cameraPosition!.bearing,
          ),
        );
      }
    }
  }

  void _clearSymbols() {
    controller!.clearSymbols();
    _selectedSymbol = null;
    setState(() {});
  }

  void _changePosition({
    required Symbol symbol,
    required LatLng newCoords,
  }) async {
    await controller!.updateSymbol(
      symbol,
      SymbolOptions(geometry: newCoords),
    );
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSymbol(
        _selectedSymbol!,
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSymbol(
      _selectedSymbol!,
      const SymbolOptions(
        iconSize: 1.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<PublicVehicleModel> publicVehicles = [
      PublicVehicleModel(
        id: 0,
        coords: LatLng(60.0, 30.28),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              _addPublicVehicleMarker(publicVehicles: publicVehicles);
            },
            child: const Text("Добавить"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _clearSymbols, child: const Text("Очистить")),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (_selectedSymbol != null) {
                _changePosition(symbol: _selectedSymbol!, newCoords: const LatLng(60.0, 30.30));
              }
            },
            child: const Text("Двигать выбранный"),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              controller?.moveCamera(CameraUpdate.bearingTo(75));
            },
            child: const Text("Поворот камеры"),
          ),
        ],
      ),
    );
  }
}
