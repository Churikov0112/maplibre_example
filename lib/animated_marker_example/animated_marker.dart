import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class Marker extends StatefulWidget {
  final String id; // Он же key
  final Point _initialPosition;
  final LatLng _initialCoordinate;
  final void Function(String, MarkerState) _addMarkerState;
  final void Function(Marker, MarkerState) _onMarkerTap;
  final int assetNumber;

  Marker(
    this.id,
    this._initialPosition,
    this._initialCoordinate,
    this._addMarkerState,
    this._onMarkerTap,
    this.assetNumber,
  ) : super(key: Key(id));

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    final state = MarkerState(_initialPosition, _initialCoordinate);
    _addMarkerState(id, state);
    return state;
  }
}

// with TickerProviderStateMixin
class MarkerState extends State<Marker> {
  Point _position;
  LatLng _coordinate;

  LatLng getCoordinate() {
    return _coordinate;
  }

  void updatePosition(Point<num> point) {
    _position = point;
    setState(() {});
  }

  void setCoordinate(LatLng newCoordinate) {
    _coordinate = newCoordinate;
    setState(() {});
  }

  MarkerState(
    this._position,
    this._coordinate,
  );

  @override
  Widget build(BuildContext context) {
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
        behavior: HitTestBehavior.translucent,
        onTap: () {
          widget._onMarkerTap(widget, this);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              widget.assetNumber == 0
                  ? 'assets/gif/dancing_pinguin.gif'
                  : (widget.assetNumber == 1)
                      ? 'assets/gif/dancing_pinguin_2.gif'
                      : 'assets/gif/pinguin_footballer.gif',
              height: 50,
            ),
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(top: 12, right: 12),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("title", style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text("description", style: TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
