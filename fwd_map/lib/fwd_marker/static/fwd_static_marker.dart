import 'dart:math';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/widgets.dart' show Widget;
import 'package:maplibre_gl/mapbox_gl.dart';

import '../../fwd_id/fwd_id.dart';
import '../../fwd_map_helper/fwd_map_helper.dart';
import '../abstract/fwd_marker.dart';
import '../abstract/fwd_marker_state.dart';

class FwdStaticMarker extends FwdMarker {
  late final Uint8List bytes;
  late final FwdMarkerState _markerState;

  @override
  FwdMarkerState get state => _markerState;

  FwdStaticMarker._(
    FwdId markerId,
    this.bytes,
    this._markerState,
  ) : super(id: markerId, state: _markerState);

  static Future<FwdStaticMarker> fromWidget({
    required FwdId id,
    required LatLng initialCoordinate,
    required Point<num> initialPosition,
    required Widget widget,
    // required Function(FwdId, FwdMarkerState) addMarkerState,
  }) async {
    final widgetBytes = await FwdMapMarkerHelper.widgetToBytes(widget);
    final state = FwdStaticMarkerState(initialCoordinate, initialPosition);
    // addMarkerState(id, state);
    return FwdStaticMarker._(id, widgetBytes, state);
  }

  static Future<FwdStaticMarker> fromImageAsset({
    required FwdId id,
    required LatLng initialCoordinate,
    required Point<num> initialPosition,
    required String imageAssetPath,
    // required Function(FwdId, FwdMarkerState) addMarkerState,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageAssetToBytes(imageAssetPath);
    final state = FwdStaticMarkerState(initialCoordinate, initialPosition);
    // addMarkerState(id, state);
    return FwdStaticMarker._(id, imageBytes, state);
  }

  static Future<FwdStaticMarker> fromImageNetwork({
    required FwdId id,
    required LatLng initialCoordinate,
    required Point<num> initialPosition,
    required String imageUrl,
    // required Function(FwdId, FwdMarkerState) addMarkerState,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageNetworkToBytes(imageUrl);
    final state = FwdStaticMarkerState(initialCoordinate, initialPosition);
    // addMarkerState(id, state);
    return FwdStaticMarker._(id, imageBytes, state);
  }
}

class FwdStaticMarkerState implements FwdMarkerState {
  FwdStaticMarkerState(this._coordinate, this._position);

  LatLng _coordinate;
  Point<num> _position;

  @override
  LatLng getCoordinate() => _coordinate;

  @override
  void updateCoordinate(LatLng newCoordinate) {
    _coordinate = newCoordinate;
  }

  @override
  Point<num> getPosition() => _position;

  @override
  void updatePosition(Point<num> newPosition) {
    _position = newPosition;
  }
}
