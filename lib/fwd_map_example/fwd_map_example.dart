import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:fwd_map/fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

// ignore: must_be_immutable
class FwdMapExample extends StatelessWidget {
  FwdMapExample({Key? key}) : super(key: key);

  late FwdMapController _fwdMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Widget as marker (Maplibre)"),
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
              // Generate random markers
              var latLngs = <LatLng>[];
              for (var i = 0; i < 1; i++) {
                final lat = _rnd.nextDouble() + 59;
                final lng = _rnd.nextDouble() + 30;
                latLngs.add(LatLng(lat, lng));
                final initialPosition = await _fwdMapController.toScreenLocation(latLngs[i]);
                final widget = FwdDynamicMarker(
                  addMarkerStateCallback: _fwdMapController.addMarkerStateCallback,
                  markerId: FwdId.fromString(id: i.toString()),
                  initialCoordinate: latLngs[i],
                  initialPosition: initialPosition,
                  widget: Container(
                    height: 50,
                    width: 50,
                    color: Colors.red,
                  ),
                  key: UniqueKey(),
                );
                await _fwdMapController.addMarker(marker: widget);
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
