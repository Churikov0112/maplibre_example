import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

// ignore: must_be_immutable
class FwdMapPolylineExample extends StatelessWidget {
  FwdMapPolylineExample({Key? key}) : super(key: key);

  late FwdMapController _fwdMapController;

  final List<FwdId> polylineIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polyline"),
      ),
      body: FwdMap(
        styleString: "https://map.91.team/styles/basic/style.json",
        trackCameraPosition: true,
        onFwdMapCreated: (fwdMapController) {
          _fwdMapController = fwdMapController;
        },
        onMapLongClick: (position, coordinate) {},
        onCameraIdle: () {},
        onStyleLoadedCallback: () {},
        initialCameraPosition: const CameraPosition(target: LatLng(60.0, 30.0), zoom: 8),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final Random _rnd = Random();
              final List<LatLng> geometry = [];
              for (var i = 0; i < 6; i++) {
                final lat = _rnd.nextDouble() + 59;
                final lng = _rnd.nextDouble() + 30;
                final coordinate = LatLng(lat, lng);
                geometry.add(coordinate);
              }

              final id = FwdId.fromString(_rnd.nextDouble().toString());

              await _fwdMapController.addPolyline(
                FwdPolyline(
                  id: id,
                  geometry: geometry,
                  thickness: 10,
                  color: const Color.fromRGBO(255, 100, 100, 1),
                  onTap: (polylineId, position, latLng) {
                    print(polylineId);
                  },
                ),
              );

              polylineIds.add(id);
            },
            child: const Icon(Icons.line_axis),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              if (polylineIds.isNotEmpty) {
                final id = polylineIds.last;
                await _fwdMapController.deleteById(id);
                polylineIds.remove(id);
              }
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
