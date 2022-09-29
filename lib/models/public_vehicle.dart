import 'package:maplibre_gl/mapbox_gl.dart';

class PublicVehicleModel {
  final int id;
  final LatLng coords;
  final String routeShortName;
  final double bearing;

  const PublicVehicleModel({
    required this.id,
    required this.coords,
    required this.routeShortName,
    required this.bearing,
  });
}
