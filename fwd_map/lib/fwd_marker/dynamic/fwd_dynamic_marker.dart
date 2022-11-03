import 'dart:math';
import 'package:flutter/widgets.dart' show BuildContext, State, StatefulWidget, Widget;
import 'package:fwd_map/fwd_marker/abstract/fwd_marker_state.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../fwd_id/fwd_id.dart';
import '../abstract/fwd_marker.dart';

// ignore: must_be_immutable
class FwdDynamicMarker extends StatefulWidget implements FwdMarker {
  FwdDynamicMarker({
    required this.markerId,
    required this.initialCoordinate,
    required this.initialPosition,
    required this.addMarkerStateCallback,
    required this.widget,
    super.key,
  }) {
    print("print");
  }

  final FwdId markerId;
  final Function(FwdId, FwdMarkerState) addMarkerStateCallback;
  // ignore: library_private_types_in_public_api
  late FwdDynamicMarkerState _markerState;
  final LatLng initialCoordinate;
  final Point initialPosition;
  final Widget widget;

  @override
  FwdId get id => markerId;

  @override
  FwdMarkerState get state => _markerState;

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    _markerState = FwdDynamicMarkerState(initialCoordinate, initialPosition);
    print("object");
    addMarkerStateCallback(id, _markerState);
    return _markerState;
  }
}

class FwdDynamicMarkerState extends State<FwdDynamicMarker> implements FwdMarkerState {
  FwdDynamicMarkerState(this._coordinate, this._position);

  LatLng _coordinate;
  Point _position;

  @override
  LatLng getCoordinate() => _coordinate;

  @override
  Point<num> getPosition() => _position;

  @override
  void updateCoordinate(LatLng newCoordinate) {
    _coordinate = newCoordinate;
    setState(() {});
  }

  @override
  void updatePosition(Point<num> newPosition) {
    _position = newPosition;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget;
  }
}
