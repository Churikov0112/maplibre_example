import 'dart:ui';
import 'package:maplibre_gl/mapbox_gl.dart';

/// Defines a camera move, supporting absolute moves as well as moves relative
/// the current position.
class FwdCameraUpdate {
  FwdCameraUpdate._(this._json);

  /// Returns a camera update that moves the camera to the specified position.
  static FwdCameraUpdate newCameraPosition(CameraPosition cameraPosition) {
    return FwdCameraUpdate._(
      <dynamic>['newCameraPosition', cameraPosition.toMap()],
    );
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location.
  static FwdCameraUpdate newLatLng(LatLng latLng) {
    return FwdCameraUpdate._(<dynamic>['newLatLng', latLng.toJson()]);
  }

  /// Returns a camera update that transforms the camera so that the specified
  /// geographical bounding box is centered in the map view at the greatest
  /// possible zoom level. A non-zero [left], [top], [right] and [bottom] padding
  /// insets the bounding box from the map view's edges.
  /// The camera's new tilt and bearing will both be 0.0.
  static FwdCameraUpdate newLatLngBounds(LatLngBounds bounds,
      {double left = 0, double top = 0, double right = 0, double bottom = 0}) {
    return FwdCameraUpdate._(<dynamic>[
      'newLatLngBounds',
      bounds.toList(),
      left,
      top,
      right,
      bottom,
    ]);
  }

  /// Returns a camera update that moves the camera target to the specified
  /// geographical location and zoom level.
  static FwdCameraUpdate newLatLngZoom(LatLng latLng, double zoom) {
    return FwdCameraUpdate._(
      <dynamic>['newLatLngZoom', latLng.toJson(), zoom],
    );
  }

  /// Returns a camera update that moves the camera target the specified screen
  /// distance.
  ///
  /// For a camera with bearing 0.0 (pointing north), scrolling by 50,75 moves
  /// the camera's target to a geographical location that is 50 to the east and
  /// 75 to the south of the current location, measured in screen coordinates.
  static FwdCameraUpdate scrollBy(double dx, double dy) {
    return FwdCameraUpdate._(
      <dynamic>['scrollBy', dx, dy],
    );
  }

  /// Returns a camera update that modifies the camera zoom level by the
  /// specified amount. The optional [focus] is a screen point whose underlying
  /// geographical location should be invariant, if possible, by the movement.
  static FwdCameraUpdate zoomBy(double amount, [Offset? focus]) {
    if (focus == null) {
      return FwdCameraUpdate._(<dynamic>['zoomBy', amount]);
    } else {
      return FwdCameraUpdate._(<dynamic>[
        'zoomBy',
        amount,
        <double>[focus.dx, focus.dy],
      ]);
    }
  }

  /// Returns a camera update that zooms the camera in, bringing the camera
  /// closer to the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(1.0)`.
  static FwdCameraUpdate zoomIn() {
    return FwdCameraUpdate._(<dynamic>['zoomIn']);
  }

  /// Returns a camera update that zooms the camera out, bringing the camera
  /// further away from the surface of the Earth.
  ///
  /// Equivalent to the result of calling `zoomBy(-1.0)`.
  static FwdCameraUpdate zoomOut() {
    return FwdCameraUpdate._(<dynamic>['zoomOut']);
  }

  /// Returns a camera update that sets the camera zoom level.
  static FwdCameraUpdate zoomTo(double zoom) {
    return FwdCameraUpdate._(<dynamic>['zoomTo', zoom]);
  }

  /// Returns a camera update that sets the camera bearing.
  static FwdCameraUpdate bearingTo(double bearing) {
    return FwdCameraUpdate._(<dynamic>['bearingTo', bearing]);
  }

  /// Returns a camera update that sets the camera bearing.
  static FwdCameraUpdate tiltTo(double tilt) {
    return FwdCameraUpdate._(<dynamic>['tiltTo', tilt]);
  }

  final dynamic _json;

  dynamic toJson() => _json;
}
