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

  Future<FwdStaticMarker> generateRandomFwdStaticMarkerWidgetChild(Random random) async {
    final id = FwdId.fromString(id: random.nextDouble().toString());
    final fwdStaticMarker = await FwdStaticMarker.fromWidget(
      id: FwdId.fromString(id: random.nextDouble().toString()),
      coordinate: LatLng(random.nextDouble() + 59, random.nextDouble() + 30),
      onTap: (symbol) {
        _fwdMapController.animateMarker(
          markerId: symbol.data?['markerId'],
          newLatLng: LatLng(random.nextDouble() + 59, random.nextDouble() + 30),
          duration: const Duration(seconds: 2),
        );
      },
      rotate: false,
      bearing: 45,
      child: Container(
        width: 50,
        height: 50,
        color: Color.fromRGBO(random.nextInt(255), random.nextInt(255), random.nextInt(255), 1),
      ),
    );
    staticMarkers.add(id);
    return fwdStaticMarker;
  }

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
              final _rnd = Random();

              final _fwdStaticMarker = await generateRandomFwdStaticMarkerWidgetChild(_rnd);
              _fwdMapController.addStaticMarker(_fwdStaticMarker);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              // Создание маркеров следует распаралеллить

              final _rnd = Random();

              final markers = await Future.wait(
                [
                  for (var i = 0; i < 20; i++) generateRandomFwdStaticMarkerWidgetChild(_rnd),
                ],
              );

              // Добавление маркеров паралеллить не обязательно
              for (var marker in markers) {
                await _fwdMapController.addStaticMarker(marker);
              }
            },
            child: const Text("++"),
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
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
