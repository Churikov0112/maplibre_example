import 'package:maplibre_gl/mapbox_gl.dart';

import '../fwd_id/fwd_id.dart';

class FwdGeoJsonHelper {
  static String getImageId(FwdId markerId) => "${markerId}_image";

  static String getGeoJsonSourceId(FwdId markerId) => "${markerId}_geoJsonSource";

  static String getSymbolLayerId(FwdId markerId) => "${markerId}_symbolLayer";

  static String getFeatureId(FwdId markerId) => "${markerId}_feature";

  static FwdId getMarkerIdFromFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().substring(0, featureId.toString().length - 8));

  static Map<String, dynamic> pointToGeoJson({
    required FwdId staticMarkerId,
    required double bearing,
    required double latitude,
    required double longitude,
  }) {
    final Map<String, dynamic> geoJson = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": getFeatureId(staticMarkerId),
          "properties": {
            "bearing": bearing,
            "markerId": staticMarkerId.toString(),
          },
          "geometry": {
            "type": "Point",
            "coordinates": [longitude, latitude],
          }
        },
      ]
    };
    return geoJson;
  }

  static double getPointBearing(Map<String, dynamic> geoJson) =>
      (geoJson["features"] as List).first["properties"]["bearing"];

  static String getPointMarkerId(Map<String, dynamic> geoJson) =>
      (geoJson["features"] as List).first["properties"]["markerId"].toString();

  static LatLng getPointLatLng(Map<String, dynamic> geoJson) => LatLng(
        ((geoJson["features"] as List).first["geometry"]["coordinates"] as List).last,
        ((geoJson["features"] as List).first["geometry"]["coordinates"] as List).first,
      );
}
