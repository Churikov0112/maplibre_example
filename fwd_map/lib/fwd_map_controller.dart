import 'dart:math';

import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tuple/tuple.dart';
import 'fwd_id/fwd_id.dart';
import 'fwd_marker/abstract/fwd_marker.dart';
import 'fwd_marker/abstract/fwd_marker_state.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'fwd_marker/static/fwd_static_marker.dart';

class FwdMapController {
  final MaplibreMapController _maplibreMapController;
  Map<FwdId, Tuple2<FwdMarker, FwdMarkerState>> markersAndStates = {};
  final Function(Map<FwdId, Tuple2<FwdMarker, FwdMarkerState>>) _updateDynamicMarkersCallback;

  Map<FwdId, FwdMarkerState> _markerStates = {};

  FwdMapController(
    this._maplibreMapController,
    this._updateDynamicMarkersCallback,
  );

  void addMarkerStateCallback(FwdId fwdId, FwdMarkerState fwdMarkerState) {
    _markerStates[fwdId] = fwdMarkerState;
  }

  Future<void> addMarker({
    required FwdMarker marker,
  }) async {
    if (_markerStates[marker.id] != null) {
      markersAndStates[marker.id] = Tuple2(marker, _markerStates[marker.id]!);
    } else {
      print("_markerStates[marker.id] == null");
    }

    if (marker is FwdStaticMarker) {
      await _maplibreMapController.addImage(marker.id.toString(), marker.bytes);
      await _maplibreMapController.addSymbol(
        SymbolOptions(
          iconImage: marker.id.toString(),
          geometry: markersAndStates[marker.id]?.item2.getCoordinate(),
        ),
      );
    } else if (marker.runtimeType is FwdDynamicMarker) {
      final Map<FwdId, Tuple2<FwdMarker, FwdMarkerState>> dynamicMarkers = {};
      markersAndStates.forEach((markerId, tuple) {
        if (tuple.item1.runtimeType is FwdDynamicMarker) {
          dynamicMarkers[markerId] = tuple;
        }
      });
      _updateDynamicMarkersCallback(dynamicMarkers);
    }
  }

  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await _maplibreMapController.toScreenLocation(latLng);
  }
}
