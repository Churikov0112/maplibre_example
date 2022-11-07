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
    required this.initialCoordinate,
    this.onMarkerTap,
    required this.child,
    super.key,
  });

  final FwdId id;
  final MaplibreMapController maplibreMapController;
  final Function(FwdId, LatLng, Point<num>?)? onMarkerTap;
  final LatLng initialCoordinate;
  final Widget child;

  @override
  State<FwdDynamicMarkerWidget> createState() => FwdDynamicMarkerWidgetState();
}

class FwdDynamicMarkerWidgetState extends State<FwdDynamicMarkerWidget> {
  Point? _position;

  Future<void> maplibreMapListener() async {
    if (widget.maplibreMapController.isCameraMoving) {
      _position = await widget.maplibreMapController.toScreenLocation(widget.initialCoordinate);
      setState(() {});
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await calculatePosition(widget.initialCoordinate);
    });
    widget.maplibreMapController.addListener(maplibreMapListener);
    super.initState();
  }

  Future<void> calculatePosition(LatLng latLng) async {
    _position = await widget.maplibreMapController.toScreenLocation(latLng);
  }

  @override
  void dispose() {
    widget.maplibreMapController.removeListener(maplibreMapListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null) {
      return const SizedBox.shrink();
    }

    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
      left: _position!.x / ratio - 50 / 2,
      top: _position!.y / ratio - 50 / 2,
      child: GestureDetector(
        onTap: () {
          if (widget.onMarkerTap != null && _position != null) {
            widget.onMarkerTap!(widget.id, widget.initialCoordinate, _position);
          }
        },
        child: widget.child,
      ),
    );
  }
}
