import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../fwd_id/fwd_id.dart';

class FwdDynamicMarker {
  const FwdDynamicMarker({
    required this.id,
    required this.initialCoordinate,
    this.onMarkerTap,
    this.rotate = true,
    this.bearing = 0.0,
    required this.child,
  });

  final FwdId id;
  final LatLng initialCoordinate;
  final Function(FwdId, LatLng, Point<num>?)? onMarkerTap;
  final Widget child;
  final bool rotate;
  final double bearing;
}
