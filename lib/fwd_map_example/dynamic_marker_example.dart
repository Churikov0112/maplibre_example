import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

// ignore: must_be_immutable
class FwdMapDynamicMarkerExample extends StatelessWidget {
  FwdMapDynamicMarkerExample({Key? key}) : super(key: key);

  late FwdMapController _fwdMapController;

  List<FwdId> markerIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic marker"),
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

              final widget = Image.asset(
                'assets/gif/dancing_pinguin_2.gif',
                height: 50,
              );

              final id = FwdId.fromString(id: _rnd.nextDouble().toString());

              await _fwdMapController.addDynamicMarker(
                FwdDynamicMarker(
                  id: id,
                  initialCoordinate: coordinate,
                  onMarkerTap: (markerId, coordinate, position) {
                    // _fwdMapController.deleteMarker(markerId);

                    // final lat = _rnd.nextDouble() + 59;
                    // final lng = _rnd.nextDouble() + 30;
                    // final coordinate = LatLng(lat, lng);
                    // _fwdMapController.animateMarker(
                    //   markerId: markerId,
                    //   newLatLng: coordinate,
                    //   duration: const Duration(seconds: 2),
                    // );
                  },
                  child: widget,
                ),
              );

              markerIds.add(id);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              if (markerIds.isNotEmpty) {
                final id = markerIds.last;
                final coordinate = LatLng(Random().nextDouble() + 59, Random().nextDouble() + 30);
                // final oldMarker = _fwdMapController.getFwdDynamicMarkerById(id);

                await _fwdMapController.updateDynamicMarker(
                  markerId: id,
                  newCoordinate: coordinate,
                  newOnMarkerTap: (markerId, coordinate, position) {
                    print("hello from $markerId");
                  },
                  newChild: Container(
                    height: 50,
                    width: 50,
                    color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                  ),
                );

                // await _fwdMapController.deleteById(id);
                // await _fwdMapController.addDynamicMarker(
                //   FwdDynamicMarker(
                //     id: oldMarker!.id,
                //     initialCoordinate: oldMarker.initialCoordinate,
                //     onMarkerTap: oldMarker.onMarkerTap,
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.red,
                //     ),
                //   ),
                // );
              }
            },
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              if (markerIds.isNotEmpty) {
                final id = markerIds.last;
                final coordinate = LatLng(Random().nextDouble() + 59, Random().nextDouble() + 30);
                await _fwdMapController.animateMarker(
                  markerId: id,
                  newLatLng: coordinate,
                  duration: const Duration(seconds: 1),
                );
              }
            },
            child: const Icon(Icons.animation),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              if (markerIds.isNotEmpty) {
                final id = markerIds.last;
                await _fwdMapController.deleteById(id);
                markerIds.remove(id);
              }
            },
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}