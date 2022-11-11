import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:tuple/tuple.dart';
import 'fwd_id/fwd_id.dart';
import 'fwd_marker/dynamic/fwd_dynamic_marker.dart';
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_controller.dart';
import 'fwd_marker/static/fwd_static_marker.dart';
import 'fwd_marker/fwd_marker_animation_controller/fwd_marker_animation_widget.dart';
import 'fwd_polygon/fwd_polygon.dart';
import 'fwd_polyline/fwd_polyline.dart';

class FwdMapController {
  final MaplibreMapController _maplibreMapController;

  // ignore: prefer_final_fields
  Map<FwdId, Tuple4<FwdStaticMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget, Symbol>> _staticMarkers =
      {};
  final Function(Map<FwdId, FwdMarkerAnimationWidget>) _updateStaticMarkerAnimationWidgetsCallback;

  // ignore: prefer_final_fields
  Map<FwdId, Tuple3<FwdDynamicMarker, FwdMarkerAnimationController, FwdMarkerAnimationWidget>> _dynamicMarkers = {};
  final Function(Map<FwdId, FwdMarkerAnimationWidget>) _updateDynamicMarkerWidgetsCallback;

  // ignore: prefer_final_fields
  Map<FwdId, Tuple2<FwdPolyline, Line>> _polylines = {};

  // ignore: prefer_final_fields
  Map<FwdId, Tuple3<FwdPolygon, Line, Fill>> _polygons = {};

  FwdMapController(
    this._maplibreMapController,
    this._updateDynamicMarkerWidgetsCallback,
    this._updateStaticMarkerAnimationWidgetsCallback,
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
    _dynamicMarkers[fwdDynamicMarker.id] = Tuple3(
      fwdDynamicMarker,
      fwdMarkerAnimationController,
      fwdMarkerAnimationWidget,
    );
    final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
    _dynamicMarkers.forEach((fwdId, tuple4) {
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

    _staticMarkers[fwdStaticMarker.id] = Tuple4(
      fwdStaticMarker,
      fwdMarkerAnimationController,
      fwdStaticMarkerAnimationWidget,
      symbol,
    );

    final Map<FwdId, FwdMarkerAnimationWidget> animationWidgetsForCallback = {};

    _staticMarkers.forEach((fwdId, tuple4) {
      animationWidgetsForCallback[fwdId] = tuple4.item3;
    });

    _updateStaticMarkerAnimationWidgetsCallback(animationWidgetsForCallback);
  }

  Future<void> deleteById(FwdId fwdId) async {
    if (_staticMarkers.keys.contains(fwdId)) {
      await _maplibreMapController.removeSymbol(_staticMarkers[fwdId]!.item4);
      _staticMarkers.remove(fwdId);
    }
    if (_dynamicMarkers.keys.contains(fwdId)) {
      _dynamicMarkers.removeWhere((id, widget) => id == fwdId);
      final Map<FwdId, FwdMarkerAnimationWidget> dynamicMarkerAnimationWidgetsForCallback = {};
      _dynamicMarkers.forEach((id, tuple4) => dynamicMarkerAnimationWidgetsForCallback[id] = tuple4.item3);
      _updateDynamicMarkerWidgetsCallback(dynamicMarkerAnimationWidgetsForCallback);
    }
    if (_polylines.keys.contains(fwdId)) {
      await _maplibreMapController.removeLine(_polylines[fwdId]!.item2);
      _polylines.remove(fwdId);
    }
    if (_polygons.keys.contains(fwdId)) {
      await _maplibreMapController.removeLine(_polygons[fwdId]!.item2);
      await _maplibreMapController.removeFill(_polygons[fwdId]!.item3);
      _polygons.remove(fwdId);
    }
  }

  Future<void> animateMarker({
    required FwdId markerId,
    required LatLng newLatLng,
    required Duration duration,
  }) async {
    if (_staticMarkers.keys.contains(markerId)) {
      _staticMarkers[markerId]?.item2.animate(point: newLatLng, duration: duration);
    }
    if (_dynamicMarkers.keys.contains(markerId)) {
      _dynamicMarkers[markerId]?.item2.animate(point: newLatLng, duration: duration);
    }
  }

  Future<void> addPolyline(FwdPolyline fwdPolyline) async {
    final line = await _maplibreMapController.addLine(
      LineOptions(
        geometry: fwdPolyline.geometry,
        lineWidth: fwdPolyline.thickness,
        lineColor: fwdPolyline.color?.toHexStringRGB(),
        lineOpacity: fwdPolyline.color?.opacity,
      ),
      {
        "polylineId": fwdPolyline.id,
      },
    );
    _polylines[fwdPolyline.id] = Tuple2(fwdPolyline, line);
  }

  Future<void> addPolygon(FwdPolygon fwdPolygon) async {
    print(fwdPolygon.fillColor != null ? '#${fwdPolygon.fillColor!.value.toRadixString(16)}' : null);
    final line = await _maplibreMapController.addLine(
      LineOptions(
        geometry: fwdPolygon.geometry.first,
        lineWidth: fwdPolygon.borderThickness,
        lineColor: fwdPolygon.borderColor?.toHexStringRGB(),
        lineOpacity: fwdPolygon.borderColor?.opacity,
      ),
      {
        "polygonId": fwdPolygon.id,
      },
    );
    final fill = await _maplibreMapController.addFill(
      FillOptions(
        fillColor: fwdPolygon.fillColor?.toHexStringRGB(),
        fillOpacity: fwdPolygon.fillColor?.opacity,
        geometry: fwdPolygon.geometry,
      ),
      {
        "polygonId": fwdPolygon.id,
      },
    );
    _polygons[fwdPolygon.id] = Tuple3(fwdPolygon, line, fill);
  }

  Future<Point<num>> toScreenLocation(LatLng latLng) async {
    return await _maplibreMapController.toScreenLocation(latLng);
  }
}
