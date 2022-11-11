import 'dart:ui';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../fwd_id/fwd_id.dart';

class FwdPolygon {
  final FwdId id;
  final List<List<LatLng>> geometry;
  final double? borderThickness;
  final Color? fillColor;
  final Color? borderColor;

  FwdPolygon({
    required this.id,
    required this.geometry,
    this.borderThickness,
    this.borderColor,
    this.fillColor,
  });
}
