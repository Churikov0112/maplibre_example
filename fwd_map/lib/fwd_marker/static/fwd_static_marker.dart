import 'dart:typed_data' show Uint8List;
import 'package:flutter/widgets.dart' show Widget;
import 'package:maplibre_gl/mapbox_gl.dart';

import '../../fwd_id/fwd_id.dart';
import '../../fwd_map_helpers/fwd_map_marker_helper.dart';

class FwdStaticMarker {
  final FwdId id;
  final LatLng coordinate;
  final void Function(Symbol) onTap;
  final Uint8List bytes;

  const FwdStaticMarker._(
    this.id,
    this.coordinate,
    this.onTap,
    this.bytes,
  );

  static Future<FwdStaticMarker> fromWidget({
    required FwdId id,
    required LatLng coordinate,
    required void Function(Symbol) onTap,
    required Widget child,
  }) async {
    final widgetBytes = await FwdMapMarkerHelper.widgetToBytes(child);
    return FwdStaticMarker._(id, coordinate, onTap, widgetBytes);
  }

  static Future<FwdStaticMarker> fromImageAsset({
    required FwdId id,
    required LatLng coordinate,
    required void Function(Symbol) onTap,
    required String imageAssetPath,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageAssetToBytes(imageAssetPath);
    return FwdStaticMarker._(id, coordinate, onTap, imageBytes);
  }

  static Future<FwdStaticMarker> fromImageNetwork({
    required FwdId id,
    required LatLng coordinate,
    required void Function(Symbol) onTap,
    required String imageUrl,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageNetworkToBytes(imageUrl);
    return FwdStaticMarker._(id, coordinate, onTap, imageBytes);
  }
}
