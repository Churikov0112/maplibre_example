import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../fwd_id/fwd_id.dart';

class FwdDynamicMarker {
  const FwdDynamicMarker({
    required this.id,
    required this.initialCoordinate,
    required this.child,
  });

  final FwdId id;
  final LatLng initialCoordinate;
  final Widget child;
}
