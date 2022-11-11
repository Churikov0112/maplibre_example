import 'dart:ui';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../fwd_id/fwd_id.dart';

class FwdPolyline {
  final FwdId id;
  final List<LatLng> geometry;
  final double? thickness;
  final Color? color;

  FwdPolyline({
    required this.id,
    required this.geometry,
    this.thickness,
    this.color,
  });
}
