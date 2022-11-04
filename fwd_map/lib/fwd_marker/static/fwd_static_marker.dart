import 'dart:typed_data' show Uint8List;
import 'package:flutter/widgets.dart' show Widget;
import 'package:maplibre_gl/mapbox_gl.dart';

import '../../fwd_id/fwd_id.dart';
import '../../fwd_map_helper/fwd_map_helper.dart';

class FwdStaticMarker {
  final FwdId id;
  final Uint8List bytes;
  final LatLng coordinate;

  const FwdStaticMarker._(
    this.id,
    this.bytes,
    this.coordinate,
  );

  static Future<FwdStaticMarker> fromWidget({
    required FwdId id,
    required LatLng coordinate,
    required Widget child,
  }) async {
    final widgetBytes = await FwdMapMarkerHelper.widgetToBytes(child);
    return FwdStaticMarker._(id, widgetBytes, coordinate);
  }

  static Future<FwdStaticMarker> fromImageAsset({
    required FwdId id,
    required LatLng coordinate,
    required String imageAssetPath,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageAssetToBytes(imageAssetPath);
    return FwdStaticMarker._(id, imageBytes, coordinate);
  }

  static Future<FwdStaticMarker> fromImageNetwork({
    required FwdId id,
    required LatLng coordinate,
    required String imageUrl,
  }) async {
    final imageBytes = await FwdMapMarkerHelper.imageNetworkToBytes(imageUrl);
    return FwdStaticMarker._(id, imageBytes, coordinate);
  }
}
