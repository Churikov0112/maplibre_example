library fwd_map;

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tuple/tuple.dart';

import 'fwd_id/fwd_id.dart';
import 'fwd_map_controller.dart';
import 'fwd_marker/abstract/fwd_marker.dart';
import 'fwd_marker/abstract/fwd_marker_state.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker.dart';

class FwdMap extends StatefulWidget {
  const FwdMap({
    required this.styleString,
    required this.initialCameraPosition,
    required this.trackCameraPosition,
    required this.onFwdMapCreated,
    required this.onMapLongClick,
    required this.onCameraIdle,
    required this.onStyleLoadedCallback,
    super.key,
  });

  final String styleString;
  final CameraPosition initialCameraPosition;
  final bool trackCameraPosition;

  final Function(FwdMapController fwdMapController) onFwdMapCreated;
  final Function(Point<double> point, LatLng coordinates) onMapLongClick;
  final Function() onCameraIdle;
  final Function() onStyleLoadedCallback;

  @override
  State<FwdMap> createState() => _FwdMapState();
}

class _FwdMapState extends State<FwdMap> {
  late FwdMapController fwdMapController;

  Map<FwdId, Tuple2<FwdMarker, FwdMarkerState>> _dynamicMarkers = {};

  void _updateDynamicMarkers(Map<FwdId, Tuple2<FwdMarker, FwdMarkerState>> newDynamicMarkers) async {
    _dynamicMarkers = newDynamicMarkers;
    setState(() {});
  }

  void _updateMarkerPosition() {
    _dynamicMarkers.forEach((fwdId, tuple) async {
      final coordinate = tuple.item2.getCoordinate();
      final newPosition = await fwdMapController.toScreenLocation(coordinate);
      tuple.item2.updatePosition(newPosition);
    });
    setState(() {});
  }

  void _onMapCreated(MaplibreMapController maplibreMapController) {
    fwdMapController = FwdMapController(maplibreMapController, _updateDynamicMarkers);
    maplibreMapController.addListener(() {
      if (maplibreMapController.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
    widget.onFwdMapCreated(fwdMapController);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MaplibreMap(
          styleString: "https://map.91.team/styles/basic/style.json",
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          onMapLongClick: widget.onMapLongClick,
          onCameraIdle: widget.onCameraIdle,
          onStyleLoadedCallback: widget.onStyleLoadedCallback,
          initialCameraPosition: widget.initialCameraPosition,
        ),
        if (_dynamicMarkers.isNotEmpty)
          ..._dynamicMarkers.values.map((tuple) => tuple.item1 as FwdDynamicMarker).toList(),
      ],
    );
  }
}
