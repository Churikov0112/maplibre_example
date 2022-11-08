import 'package:maplibre_gl/mapbox_gl.dart';

class FwdStaticMarkerAnimationEvent {
  final LatLng? point;
  final Duration? duration;
  final FwdStaticMarkerAnimationAction action;

  FwdStaticMarkerAnimationEvent.animate({
    this.point,
    this.duration,
  }) : action = FwdStaticMarkerAnimationAction.animate;

  // FwdStaticMarkerAnimationEvent.remove()
  //     : point = null,
  //       duration = null,
  //       action = FwdStaticMarkerAnimationAction.remove;

  // FwdStaticMarkerAnimationEvent.teleport({
  //   this.point,
  // })  : duration = null,
  //       action = FwdStaticMarkerAnimationAction.teleport;
}

enum FwdStaticMarkerAnimationAction {
  animate,
  // remove,
  // teleport,
}
