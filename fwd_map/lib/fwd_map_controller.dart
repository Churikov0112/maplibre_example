import 'dart:math';
import 'package:fwd_map/fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tuple/tuple.dart';
import 'fwd_id/fwd_id.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker_widget.dart';
import 'fwd_marker/static/fwd_static_marker.dart';

class FwdMapController {
  final MaplibreMapController _maplibreMapController;

  // Map<FwdId, Tuple4<FwdStaticMarker, Symbol, FwdStaticMarkerAnimationController, FwdStaticMarkerWidget>> staticMarkers =
  //     {};

  Map<FwdId, Tuple2<FwdStaticMarker, Symbol>> staticMarkers = {};

  Map<FwdId, FwdDynamicMarkerWidget> dynamicMarkerWidgets = {};

  final Function(Map<FwdId, FwdDynamicMarkerWidget>) _updateDynamicMarkerWidgetsCallback;
  // final Function(Map<FwdId, Widget>) _updateStaticMarkerWidgetsCallback;

  FwdMapController(
    this._maplibreMapController,
    this._updateDynamicMarkerWidgetsCallback,
    // this._updateStaticMarkerWidgetsCallback,
  );

  Future<void> addDynamicMarker(FwdDynamicMarker fwdDynamicMarker) async {
    final fwdDynamicMarkerWidget = FwdDynamicMarkerWidget(
      maplibreMapController: _maplibreMapController,
      id: fwdDynamicMarker.id,
      initialCoordinate: fwdDynamicMarker.initialCoordinate,
      child: fwdDynamicMarker.child,
    );
    dynamicMarkerWidgets[fwdDynamicMarker.id] = fwdDynamicMarkerWidget;
    _updateDynamicMarkerWidgetsCallback(dynamicMarkerWidgets);
  }

  Future<void> addStaticMarker(FwdStaticMarker fwdStaticMarker) async {
    await _maplibreMapController.addImage(fwdStaticMarker.id.toString(), fwdStaticMarker.bytes);
    final symbol = await _maplibreMapController.addSymbol(
      SymbolOptions(
        iconImage: fwdStaticMarker.id.toString(),
        geometry: fwdStaticMarker.coordinate,
      ),
    );
    staticMarkers[fwdStaticMarker.id] = Tuple2(fwdStaticMarker, symbol);
    // _updateStaticMarkerWidgetsCallback(staticMarkers);
  }

  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await _maplibreMapController.toScreenLocation(latLng);
  }
}
