import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // ignore: unnecessary_import
import 'package:maplibre_gl/mapbox_gl.dart';

import 'animated_marker.dart';

const randomMarkerNum = 5;

class AnimatedMarkerExample extends StatefulWidget {
  const AnimatedMarkerExample({Key? key}) : super(key: key);

  @override
  State createState() => AnimatedMarkerExampleState();
}

class AnimatedMarkerExampleState extends State<AnimatedMarkerExample> {
  final Random _rnd = Random();

  late MaplibreMapController _mapController;
  final Map<String, Marker> _markers = {};
  final Map<String, MarkerState> _markerStates = {};

  void _addMarkerState(String markerId, MarkerState markerState) {
    _markerStates[markerId] = markerState;
  }

  Future<void> moveMarker(MarkerState markerState) async {
    LatLng oldCoordinate = markerState.getCoordinate();
    LatLng targetCoordinate = LatLng(oldCoordinate.latitude + 0.1, oldCoordinate.longitude + 0.1);

    print(oldCoordinate.toString());
    print(targetCoordinate.toString());

    LatLng dynamicCoordinate = oldCoordinate;

    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      print(timer.tick);
      if (targetCoordinate.latitude == dynamicCoordinate.latitude &&
          targetCoordinate.longitude == dynamicCoordinate.longitude) {
        print("Приехали");
        timer.cancel();
      }

      dynamicCoordinate = LatLng(
        oldCoordinate.latitude + timer.tick * (targetCoordinate.latitude - oldCoordinate.latitude) / 100,
        oldCoordinate.longitude + timer.tick * (targetCoordinate.longitude - oldCoordinate.longitude) / 100,
      );

      print(dynamicCoordinate.toString());

      Point<num> dynamicPoint = await _mapController.toScreenLocation(dynamicCoordinate);

      print(dynamicPoint.toString());

      _markerStates[markerState.widget.id]?.updatePosition(dynamicPoint);
      _markerStates[markerState.widget.id]?.setCoordinate(dynamicCoordinate);

      setState(() {});

      // _updateMarkerPosition();
    });
  }

  Future<void> _onMarkerTap(Marker marker, MarkerState markerState) async {
    print("marker: $marker");
    print("markerState: $markerState");

    await moveMarker(markerState);
  }

  void _onMapCreated(MaplibreMapController controller) {
    _mapController = controller;
    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
  }

  void _onStyleLoadedCallback() {
    print('onStyleLoadedCallback');
  }

  void _onMapLongClickCallback(Point<double> point, LatLng coordinates) {
    _addMarker(point, coordinates);
  }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    _markerStates.forEach((markerId, markerState) {
      coordinates.add(markerState.getCoordinate());
    });

    _mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.forEach((key, value) {
        _markerStates[key]?.updatePosition(points[int.parse(key)]);
      });
    });
  }

  void _addMarker(Point<double> point, LatLng coordinates) {
    final markerId = _markers.length.toString();
    setState(() {
      _markers[markerId] = Marker(
        markerId,
        point,
        coordinates,
        _addMarkerState,
        _onMarkerTap,
        _rnd.nextInt(3),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Widget as marker (Maplibre)"),
      ),
      body: Stack(
        children: [
          MaplibreMap(
            styleString: "https://map.91.team/styles/basic/style.json",
            trackCameraPosition: true,
            onMapCreated: _onMapCreated,
            onMapLongClick: _onMapLongClickCallback,
            onCameraIdle: _onCameraIdleCallback,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            initialCameraPosition: const CameraPosition(target: LatLng(60.0, 30.0), zoom: 8),
          ),
          if (_markers.isNotEmpty) Stack(children: _markers.values.toList()),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Generate random markers
              var param = <LatLng>[];
              for (var i = 0; i < randomMarkerNum; i++) {
                final lat = _rnd.nextDouble() + 59;
                final lng = _rnd.nextDouble() + 30;
                param.add(LatLng(lat, lng));
              }

              _mapController.toScreenLocationBatch(param).then((value) {
                for (var i = 0; i < randomMarkerNum; i++) {
                  var point = Point<double>(value[i].x as double, value[i].y as double);
                  _addMarker(point, param[i]);
                }
              });
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
