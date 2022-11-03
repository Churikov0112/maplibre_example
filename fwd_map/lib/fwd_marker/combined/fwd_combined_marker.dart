// import 'dart:math';
// import 'package:flutter/widgets.dart' show BuildContext, State, StatefulWidget, Widget;
// import 'package:fwd_map/fwd_marker/abstract/fwd_marker_state.dart';
// import 'package:maplibre_gl/mapbox_gl.dart';
// import '../../fwd_id/fwd_id.dart';
// import '../abstract/fwd_marker.dart';

// class FwdCombinedMarker extends StatefulWidget implements FwdMarker {
//   const FwdCombinedMarker({
//     required this.markerId,
//     required this.addMarkerState,
//     required this.initialCoordinate,
//     required this.initialPosition,
//     required this.widget,
//     super.key,
//   });

//   final FwdId markerId;
//   final Function(FwdId, FwdMarkerState) addMarkerState;
//   final LatLng initialCoordinate;
//   final Point initialPosition;
//   final Widget widget;

//   @override
//   FwdId get id => markerId;

//   @override
//   // ignore: no_logic_in_create_state
//   State<StatefulWidget> createState() {
//     final state = _FwdCombinedMarkerState(initialCoordinate, initialPosition);
//     addMarkerState(id, state);
//     return state;
//   }
// }

// class _FwdCombinedMarkerState extends State<FwdCombinedMarker> implements FwdMarkerState {
//   _FwdCombinedMarkerState(this._coordinate, this._position);

//   LatLng _coordinate;
//   Point _position;

//   @override
//   LatLng getCoordinate() => _coordinate;

//   @override
//   Point<num> getPosition() => _position;

//   @override
//   void updateCoordinate(LatLng newCoordinate) {
//     _coordinate = newCoordinate;
//     setState(() {});
//   }

//   @override
//   void updatePosition(Point<num> newPosition) {
//     _position = newPosition;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget;
//   }
// }
