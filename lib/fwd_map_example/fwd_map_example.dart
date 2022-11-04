import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:fwd_map/fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'package:fwd_map/fwd_marker/static/fwd_static_marker.dart';
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
              final lat = _rnd.nextDouble() + 59;
              final lng = _rnd.nextDouble() + 30;
              final coordinate = LatLng(lat, lng);

              final widget = Container(
                height: 50,
                width: 50,
                color: Colors.red,
              );
              await _fwdMapController.addStaticMarker(
                await FwdStaticMarker.fromWidget(
                  id: FwdId.fromString(id: _rnd.nextDouble().toString()),
                  coordinate: coordinate,
                  child: widget,
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              final Random _rnd = Random();
              final lat = _rnd.nextDouble() + 59;
              final lng = _rnd.nextDouble() + 30;
              final coordinate = LatLng(lat, lng);

              final widget = Container(
                height: 50,
                width: 50,
                color: Colors.red,
              );
              await _fwdMapController.addDynamicMarker(
                FwdDynamicMarker(
                  id: FwdId.fromString(id: _rnd.nextDouble().toString()),
                  initialCoordinate: coordinate,
                  child: widget,
                ),
              );
            },
            child: const Icon(Icons.widgets),
          ),
        ],
      ),
    );
  }
}
