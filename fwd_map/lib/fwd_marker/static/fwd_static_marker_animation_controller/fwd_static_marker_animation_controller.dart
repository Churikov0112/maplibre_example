import 'dart:async';

import 'package:maplibre_gl/mapbox_gl.dart';

import 'fwd_static_marker_animation_event.dart';
import 'fwd_static_marker_animation_state.dart';

class FwdStaticMarkerAnimationController {
  StreamController<FwdStaticMarkerAnimationEvent> streamController = StreamController<FwdStaticMarkerAnimationEvent>();

  FwdStaticMarkerAnimationState? state;

  void _addEvent(FwdStaticMarkerAnimationEvent event) {
    if (streamController.isClosed) {
      return;
    }
    streamController.add(event);
  }

  void animate({
    required LatLng point,
    required Duration duration,
  }) {
    _addEvent(FwdStaticMarkerAnimationEvent.animate(point: point, duration: duration));
  }

  // void remove() {
  //   _addEvent(FwdStaticMarkerAnimationEvent.remove());
  // }

  // void teleport({
  //   required Coordinate point,
  //   required VehicleMovement vehicle,
  // }) {
  //   _addEvent(FwdStaticMarkerAnimationEvent.teleport(point: point, vehicle: vehicle));
  // }
}
