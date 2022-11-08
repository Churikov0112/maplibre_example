import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:fwd_map/fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tuple/tuple.dart';
import 'fwd_id/fwd_id.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker_widget.dart';
import 'fwd_marker/static/fwd_static_marker.dart';
import 'fwd_marker/static/fwd_static_marker_animation_controller/fwd_static_marker_animation_controller.dart';
import 'fwd_marker/static/fwd_static_marker_animation_widget.dart';

class FwdMapController {
  final MaplibreMapController _maplibreMapController;

  // Map<FwdId, Tuple4<FwdStaticMarker, Symbol, FwdStaticMarkerAnimationController, FwdStaticMarkerWidget>> staticMarkers =
  //     {};

  Map<FwdId, Tuple4<FwdStaticMarker, Symbol, FwdStaticMarkerAnimationController, FwdStaticMarkerAnimationWidget>>
      staticMarkers = {};
  final Function(Map<FwdId, FwdStaticMarkerAnimationWidget>) _updateStaticMarkerAnimationWidgetsCallback;

  Map<FwdId, FwdDynamicMarkerWidget> dynamicMarkerWidgets = {};
  final Function(Map<FwdId, FwdDynamicMarkerWidget>) _updateDynamicMarkerWidgetsCallback;

  FwdMapController(
    this._maplibreMapController,
    this._updateDynamicMarkerWidgetsCallback,
    this._updateStaticMarkerAnimationWidgetsCallback,
    // this._updateStaticMarkerWidgetsCallback,
  );

  Future<void> addDynamicMarker(FwdDynamicMarker fwdDynamicMarker) async {
    final fwdDynamicMarkerWidget = FwdDynamicMarkerWidget(
      maplibreMapController: _maplibreMapController,
      id: fwdDynamicMarker.id,
      initialCoordinate: fwdDynamicMarker.initialCoordinate,
      onMarkerTap: fwdDynamicMarker.onMarkerTap,
      key: UniqueKey(),
      child: fwdDynamicMarker.child,
    );
    dynamicMarkerWidgets[fwdDynamicMarker.id] = fwdDynamicMarkerWidget;
    _updateDynamicMarkerWidgetsCallback(dynamicMarkerWidgets);
  }

  Future<void> addStaticMarker(FwdStaticMarker fwdStaticMarker) async {
    _maplibreMapController.onSymbolTapped.add(fwdStaticMarker.onTap);
    await _maplibreMapController.addImage(fwdStaticMarker.id.toString(), fwdStaticMarker.bytes);
    final symbol = await _maplibreMapController.addSymbol(
      SymbolOptions(
        iconImage: fwdStaticMarker.id.toString(),
        geometry: fwdStaticMarker.coordinate,
      ),
      {
        "markerId":
            fwdStaticMarker.id, // приходится засовывать markerId в Data of Symbol, чтобы хоть как-то его возвращать
      },
    );

    FwdStaticMarkerAnimationController fwdStaticMarkerAnimationController = FwdStaticMarkerAnimationController();
    FwdStaticMarkerAnimationWidget fwdStaticMarkerAnimationWidget = FwdStaticMarkerAnimationWidget(
      symbol: symbol,
      maplibreMapController: _maplibreMapController,
      fwdStaticMarkerAnimationController: fwdStaticMarkerAnimationController,
    );

    staticMarkers[fwdStaticMarker.id] = Tuple4(
      fwdStaticMarker,
      symbol,
      fwdStaticMarkerAnimationController,
      fwdStaticMarkerAnimationWidget,
    );

    final Map<FwdId, FwdStaticMarkerAnimationWidget> animationWidgetsForCallback = {};

    staticMarkers.forEach((fwdId, tuple4) {
      animationWidgetsForCallback[fwdId] = tuple4.item4;
    });

    _updateStaticMarkerAnimationWidgetsCallback(animationWidgetsForCallback);
  }

  Future<void> deleteMarker(FwdId markerId) async {
    if (staticMarkers.keys.contains(markerId)) {
      await _maplibreMapController.removeSymbol(staticMarkers[markerId]!.item2);
      staticMarkers.remove(markerId);
    }
    if (dynamicMarkerWidgets.keys.contains(markerId)) {
      dynamicMarkerWidgets.removeWhere((id, widget) => id == markerId);
      _updateDynamicMarkerWidgetsCallback(dynamicMarkerWidgets);
    }
  }

  Future<void> animateMarker({
    required FwdId markerId,
    required LatLng newLatLng,
    required Duration duration,
  }) async {
    if (staticMarkers.keys.contains(markerId)) {
      staticMarkers[markerId]?.item3.animate(point: newLatLng, duration: duration);
    }
    // if (dynamicMarkerWidgets.keys.contains(markerId)) {
    //   dynamicMarkerWidgets.removeWhere((id, widget) => id == markerId);
    //   _updateDynamicMarkerWidgetsCallback(dynamicMarkerWidgets);
    // }
  }

  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await _maplibreMapController.toScreenLocation(latLng);
  }
}
