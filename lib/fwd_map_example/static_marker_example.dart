import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fwd_map/fwd_id/fwd_id.dart';
import 'package:fwd_map/fwd_map.dart';
import 'package:fwd_map/fwd_map_controller.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

// ignore: must_be_immutable
class FwdMapStaticMarkerExample extends StatelessWidget {
  FwdMapStaticMarkerExample({Key? key}) : super(key: key);

  late FwdMapController _fwdMapController;

  List<FwdId> staticMarkers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Static marker"),
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
                width: 50,
                height: 50,
                color: Colors.red,
              );

              final id = FwdId.fromString(id: _rnd.nextDouble().toString());

              await _fwdMapController.addStaticMarker(
                await FwdStaticMarker.fromWidget(
                  id: id,
                  coordinate: coordinate,
                  onTap: (symbol) {
                    final lat = _rnd.nextDouble() + 59;
                    final lng = _rnd.nextDouble() + 30;
                    final coordinate = LatLng(lat, lng);
                    _fwdMapController.animateMarker(
                      markerId: symbol.data?['markerId'],
                      newLatLng: coordinate,
                      duration: const Duration(seconds: 2),
                    );
                  },
                  child: widget,
                ),
              );

              staticMarkers.add(id);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              final coordinate = LatLng(Random().nextDouble() + 59, Random().nextDouble() + 30);

              final widget = Container(
                width: 50,
                height: 50,
                color: Colors.green,
              );

              await _fwdMapController.updateStaticMarker(
                markerId: staticMarkers.last,
                newCoordinate: coordinate,
                newWidgetChild: widget,
              );

              // addStaticMarker(
              //   await FwdStaticMarker.fromWidget(
              //     id: FwdId.fromString(id: _rnd.nextDouble().toString()),
              //     coordinate: coordinate,
              //     onTap: (symbol) {
              //       final lat = _rnd.nextDouble() + 59;
              //       final lng = _rnd.nextDouble() + 30;
              //       final coordinate = LatLng(lat, lng);
              //       _fwdMapController.animateMarker(
              //         markerId: symbol.data?['markerId'],
              //         newLatLng: coordinate,
              //         duration: const Duration(seconds: 2),
              //       );
              //     },
              //     child: widget,
              //   ),
              // );
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
