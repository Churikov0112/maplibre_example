library fwd_map;

import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'fwd_id/fwd_id.dart';
import 'fwd_map_controller.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker_widget.dart';

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

  Map<FwdId, FwdDynamicMarkerWidget> _dynamicMarkerWidgets = {};

  void _updateDynamicMarkerWidgets(Map<FwdId, FwdDynamicMarkerWidget> newDynamicMarkerWidgets) async {
    print(newDynamicMarkerWidgets);
    _dynamicMarkerWidgets = newDynamicMarkerWidgets;
    print(_dynamicMarkerWidgets);
    setState(() {});
  }

  void _onMapCreated(MaplibreMapController maplibreMapController) {
    fwdMapController = FwdMapController(maplibreMapController, _updateDynamicMarkerWidgets);
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
        if (_dynamicMarkerWidgets.isNotEmpty)
          ..._dynamicMarkerWidgets.values.map((dynamicMarkerWidget) => dynamicMarkerWidget).toList(),
      ],
    );
  }
}
