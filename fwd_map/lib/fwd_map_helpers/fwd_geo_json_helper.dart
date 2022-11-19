import 'package:maplibre_gl/mapbox_gl.dart';

import '../fwd_id/fwd_id.dart';

class FwdGeoJsonHelper {
  // imageId

  static String getImageId(FwdId markerId) => "${markerId}_image";

  // geoJsonSourceId

  static String pointGeoJsonSourceId(FwdId markerId) => "${markerId}_pointGeoJsonSource";
  static String lineGeoJsonSourceId(FwdId markerId) => "${markerId}_lineGeoJsonSource";
  static String fillGeoJsonSourceId(FwdId markerId) => "${markerId}_fillGeoJsonSource";

  // layerId

  static String symbolLayerId(FwdId markerId) => "${markerId}_symbolLayer";
  static String lineLayerId(FwdId markerId) => "${markerId}_polylineLayer";
  static String fillLayerId(FwdId markerId) => "${markerId}_polygonLayer";

  // featureId

  static String pointFeatureId(FwdId markerId) => "${markerId}_pointFeature";
  static String lineFeatureId(FwdId markerId) => "${markerId}_lineFeature";
  static String fillFeatureId(FwdId markerId) => "${markerId}_fillgonFeature";

  static FwdId markerIdFromPointFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().substring(0, featureId.toString().length - 13));

  static FwdId markerIdFromPolylineFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().substring(0, featureId.toString().length - 16));

  static FwdId markerIdFromPolygonFeatureId(dynamic featureId) =>
      FwdId.fromString(featureId.toString().substring(0, featureId.toString().length - 15));

  // toGeoJson

  static Map<String, dynamic> pointGeoJson({
    required FwdId staticMarkerId,
    required double bearing,
    required LatLng geometry,
  }) {
    final Map<String, dynamic> geoJson = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": pointFeatureId(staticMarkerId),
          "properties": {
            "bearing": bearing,
            "fwdId": staticMarkerId.toString(),
          },
          "geometry": {
            "type": "Point",
            "coordinates": [geometry.longitude, geometry.latitude],
          }
        },
      ]
    };
    return geoJson;
  }

  static Map<String, dynamic> lineGeoJson({
    required FwdId polylineId,
    required List<LatLng> geometry,
  }) {
    final Map<String, dynamic> geoJson = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": lineFeatureId(polylineId),
          "properties": {
            "fwdId": polylineId.toString(),
          },
          "geometry": {
            "type": "LineString",
            "coordinates": [
              for (final point in geometry) [point.longitude, point.latitude],
            ]
          }
        },
      ]
    };
    return geoJson;
  }

  static Map<String, dynamic> fillGeoJson({
    required FwdId polygoneId,
    required List<List<LatLng>> geometry,
  }) {
    final Map<String, dynamic> geoJson = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": fillFeatureId(polygoneId),
          "properties": {
            "fwdId": polygoneId.toString(),
          },
          "geometry": {
            "type": "Polygon",
            "coordinates": [
              for (final point in geometry)
                [
                  for (final sub in point) [sub.longitude, sub.latitude],
                ]
            ]
          }
        },
      ]
    };
    return geoJson;
  }

  // parse geoJson and get props

  static double pointBearingFromGeoJson(Map<String, dynamic> geoJson) =>
      (geoJson["features"] as List).first["properties"]["bearing"];

  static String stringFwdIdFromGeoJson(Map<String, dynamic> geoJson) =>
      (geoJson["features"] as List).first["properties"]["fwdId"].toString();

  static LatLng pointLatLngFromGeoJson(Map<String, dynamic> geoJson) => LatLng(
        ((geoJson["features"] as List).first["geometry"]["coordinates"] as List).last,
        ((geoJson["features"] as List).first["geometry"]["coordinates"] as List).first,
      );

  static List<LatLng> polylineLatLngsFromGeoJson(Map<String, dynamic> geoJson) => <LatLng>[
        for (final point in ((geoJson["features"] as List).first["geometry"]["coordinates"] as List))
          LatLng(point.last, point.first)
      ];
}
