import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:fwd_map/fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tuple/tuple.dart';
import 'fwd_id/fwd_id.dart';
import 'fwd_marker/static/fwd_static_marker.dart';
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_controller.dart';
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_widget.dart';

class FwdMapController {
  final MaplibreMapController _maplibreMapController;

  // Map<FwdId, Tuple4<FwdStaticMarker, Symbol, FwdMarkerAnimationController, FwdStaticMarkerWidget>> staticMarkers =
  //     {};

  Map<FwdId, Tuple4<FwdStaticMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget, Symbol>> staticMarkers =
      {};
  final Function(Map<FwdId, FwdMarkerAnimationWidget>) _updateStaticMarkerAnimationWidgetsCallback;

  Map<FwdId, Tuple3<FwdDynamicMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget>> dynamicMarkers = {};
  final Function(Map<FwdId, FwdMarkerAnimationWidget>) _updateDynamicMarkerWidgetsCallback;

  FwdMapController(
    this._maplibreMapController,
    this._updateDynamicMarkerWidgetsCallback,
    this._updateStaticMarkerAnimationWidgetsCallback,
    // this._updateStaticMarkerWidgetsCallback,
  );

  Future<void> addDynamicMarker(FwdDynamicMarker fwdDynamicMarker) async {
    FwdMarkerAnimationController fwdMarkerAnimationController = FwdMarkerAnimationController();
    Point initialPosistion = await _maplibreMapController.toScreenLocation(fwdDynamicMarker.initialCoordinate);
    final fwdMarkerAnimationWidget = FwdMarkerAnimationWidget.fromDynamicMarker(
      fwdDynamicMarker: fwdDynamicMarker,
      maplibreMapController: _maplibreMapController,
      fwdMarkerAnimationController: fwdMarkerAnimationController,
      initialMarkerPosition: initialPosistion,
      key: UniqueKey(),
    );
    dynamicMarkers[fwdDynamicMarker.id] = Tuple3(
      fwdDynamicMarker,
      fwdMarkerAnimationController,
      fwdMarkerAnimationWidget,
    );
    final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
    dynamicMarkers.forEach((fwdId, tuple4) {
      dynamicMarkerAnimationWidgetsForCallback[fwdId] = tuple4.item3;
    });
    _updateDynamicMarkerWidgetsCallback(dynamicMarkerAnimationWidgetsForCallback);
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

    FwdMarkerAnimationController fwdMarkerAnimationController = FwdMarkerAnimationController();
    FwdMarkerAnimationWidget fwdStaticMarkerAnimationWidget = FwdMarkerAnimationWidget.fromSymbol(
      symbol: symbol,
      maplibreMapController: _maplibreMapController,
      fwdMarkerAnimationController: fwdMarkerAnimationController,
      key: UniqueKey(),
    );

    staticMarkers[fwdStaticMarker.id] = Tuple4(
      fwdStaticMarker,
      fwdMarkerAnimationController,
      fwdStaticMarkerAnimationWidget,
      symbol,
    );

    final Map<FwdId, FwdMarkerAnimationWidget> animationWidgetsForCallback = {};

    staticMarkers.forEach((fwdId, tuple4) {
      animationWidgetsForCallback[fwdId] = tuple4.item3;
    });

    _updateStaticMarkerAnimationWidgetsCallback(animationWidgetsForCallback);
  }

  Future<void> deleteMarker(FwdId markerId) async {
    if (staticMarkers.keys.contains(markerId)) {
      await _maplibreMapController.removeSymbol(staticMarkers[markerId]!.item4);
      staticMarkers.remove(markerId);
    }
    if (dynamicMarkers.keys.contains(markerId)) {
      dynamicMarkers.removeWhere((id, widget) => id == markerId);
      final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
      dynamicMarkers.forEach((fwdId, tuple4) {
        dynamicMarkerAnimationWidgetsForCallback[fwdId] = tuple4.item3;
      });
      _updateDynamicMarkerWidgetsCallback(dynamicMarkerAnimationWidgetsForCallback);
    }
  }

  Future<void> animateMarker({
    required FwdId markerId,
    required LatLng newLatLng,
    required Duration duration,
  }) async {
    if (staticMarkers.keys.contains(markerId)) {
      staticMarkers[markerId]?.item2.animate(point: newLatLng, duration: duration);
    }
    if (dynamicMarkers.keys.contains(markerId)) {
      dynamicMarkers[markerId]?.item2.animate(point: newLatLng, duration: duration);
    }
  }

  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await _maplibreMapController.toScreenLocation(latLng);
  }
}
