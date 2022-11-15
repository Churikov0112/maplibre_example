import 'dart:typed_data' show Uint8List;
import 'package:flutter/widgets.dart' show Widget;
import 'package:maplibre_gl/mapbox_gl.dart';

import '../../fwd_id/fwd_id.dart';
import '../../fwd_map_helpers/fwd_map_marker_helper.dart';

class FwdStaticMarker {
  final FwdId id;
  final LatLng coordinate;
  final bool rotate;
  final double bearing;
  final void Function(Symbol) onTap;
  final Uint8List bytes;

  const FwdStaticMarker._(
    this.id,
    this.coordinate,
    this.onTap,
    this.bytes,
    this.rotate,
    this.bearing,
  );

  static Future<FwdStaticMarker> fromWidget({
    required FwdId id,
    required LatLng coordinate,
    required void Function(Symbol) onTap,
    required Widget child,
    bool rotate = true,
    double bearing = 0.0,
  }) async {
    final widgetBytes = await FwdMapMarkerHelper.widgetToBytes(child);
    return FwdStaticMarker._(id, coordinate, onTap, widgetBytes, rotate, bearing);
  }

  static Future<FwdStaticMarker> fromImageAsset({
    required FwdId id,
    required LatLng coordinate,
    required void Function(Symbol) onTap,
    required String imageAssetPath,
    bool rotate = true,
    double bearing = 0.0,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageAssetToBytes(imageAssetPath);
    return FwdStaticMarker._(id, coordinate, onTap, imageBytes, rotate, bearing);
  }

  static Future<FwdStaticMarker> fromImageNetwork({
    required FwdId id,
    required LatLng coordinate,
    required void Function(Symbol) onTap,
    required String imageUrl,
    bool rotate = true,
    double bearing = 0.0,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageNetworkToBytes(imageUrl);
    return FwdStaticMarker._(id, coordinate, onTap, imageBytes, rotate, bearing);
  }
}
