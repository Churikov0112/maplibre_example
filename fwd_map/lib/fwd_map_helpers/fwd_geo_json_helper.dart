import '../fwd_id/fwd_id.dart';

class FwdGeoJsonHelper {
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
          "id": "${staticMarkerId.toString()}_feature",
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

  static String getImageId(FwdId markerId) => "${markerId}_image";

  static String getGeoJsonSourceId(FwdId markerId) => "${markerId}_geoJsonSource";

  static String getSymbolLayerId(FwdId markerId) => "${markerId}_symbolLayer";

  static String geFeatureId(FwdId markerId) => "${markerId}_feature";
}
