import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../fwd_id/fwd_id.dart';

class FwdDynamicMarkerWidget extends StatefulWidget {
  const FwdDynamicMarkerWidget({
    required this.maplibreMapController,
    required this.id,
    required this.coordinate,
    required this.initialPosition,
    this.onMarkerTap,
    required this.child,
    super.key,
  });

  final FwdId id;
  final MaplibreMapController maplibreMapController;
  final Function(FwdId, LatLng, Point<num>?)? onMarkerTap;
  final LatLng coordinate;
  final Point initialPosition;

  final Widget child;

  @override
  State<FwdDynamicMarkerWidget> createState() => FwdDynamicMarkerWidgetState();
}

class FwdDynamicMarkerWidgetState extends State<FwdDynamicMarkerWidget> {
  late Point _position;

  Future<void> maplibreMapListener() async {
    if (widget.maplibreMapController.isCameraMoving) {
      await calculatePosition();
      setState(() {});
    }
  }

  Future<void> calculatePosition() async {
    _position = await widget.maplibreMapController.toScreenLocation(widget.coordinate);
  }

  @override
  void initState() {
    _position = widget.initialPosition;
    widget.maplibreMapController.addListener(maplibreMapListener);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant FwdDynamicMarkerWidget oldWidget) {
    if (oldWidget.coordinate != widget.coordinate) {
      _position = widget.initialPosition;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.maplibreMapController.removeListener(maplibreMapListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (_position == null) {
    //   return const SizedBox.shrink();
    // }

    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
      left: _position.x / ratio - 50 / 2,
      top: _position.y / ratio - 50 / 2,
      child: GestureDetector(
        onTap: () {
          if (widget.onMarkerTap != null) {
            widget.onMarkerTap!(widget.id, widget.coordinate, _position);
          }
        },
        child: widget.child,
      ),
    );
  }
}
