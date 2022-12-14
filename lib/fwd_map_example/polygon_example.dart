import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:fwd_map/fwd_polygon/fwd_polygon.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

// ignore: must_be_immutable
class FwdMapPolygonExample extends StatelessWidget {
  FwdMapPolygonExample({Key? key}) : super(key: key);

  late FwdMapController _fwdMapController;

  final List<FwdId> polygonIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Polygon"),
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
              final List<LatLng> points = [];
              final List<List<LatLng>> geometry = [];
              geometry.add(<LatLng>[]);
              for (var i = 0; i < 4; i++) {
                final lat = _rnd.nextDouble() + 59;
                final lng = _rnd.nextDouble() + 30;
                final coordinate = LatLng(lat, lng);
                points.add(coordinate);
              }
              points.add(points.first);
              geometry.first.addAll(points);

              final id = FwdId.fromString(_rnd.nextDouble().toString());

              await _fwdMapController.addPolygon(
                FwdPolygon(
                  id: id,
                  geometry: geometry,
                  fillColor: const Color.fromRGBO(255, 100, 100, 0.2),
                  borderColor: const Color.fromRGBO(255, 100, 100, 1),
                  borderThickness: 2,
                  onTap: (polygonId, position, latLng) {
                    print(polygonId);
                  },
                ),
              );

              polygonIds.add(id);
            },
            child: const Icon(Icons.square),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              if (polygonIds.isNotEmpty) {
                final id = polygonIds.last;
                await _fwdMapController.deleteById(id);
                polygonIds.remove(id);
              }
            },
            child: const Icon(Icons.delete),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              await _fwdMapController.clearMap();
              polygonIds.clear();
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
