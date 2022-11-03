import 'dart:math';

import 'package:maplibre_gl/mapbox_gl.dart';

abstract class FwdMarkerState {
  LatLng getCoordinate();
  Point<num> getPosition();

  void updateCoordinate(LatLng newCoordinate);
  void updatePosition(Point<num> newPosition);
}
