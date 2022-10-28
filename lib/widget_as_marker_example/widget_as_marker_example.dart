import 'dart:math';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

import 'custom_marker_widget.dart';

class WidgetAsMarkerExample extends StatefulWidget {
  const WidgetAsMarkerExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LayerState();
}

class LayerState extends State<WidgetAsMarkerExample> {
  static const LatLng center = LatLng(-33.86711, 151.1947171);

  late MaplibreMapController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MaplibreMap(
            dragEnabled: false,
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            initialCameraPosition: const CameraPosition(
              target: center,
              zoom: 11.0,
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
    controller.onFeatureTapped.add(onFeatureTap);
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {}

  Future<void> setImageByWidget({
    required String assetName,
    required dynamic feature,
  }) async {
    http.Response response = await http.get(
      Uri.parse(feature["properties"]["imageURL"]),
    );
    ScreenshotController screenshotController = ScreenshotController();
    final thisWidget = CustomMarkerWidget(
      title: feature["properties"]["title"],
      description: feature["properties"]["description"],
      imageBytes: response.bodyBytes,
    );
    Uint8List imageBytes = await screenshotController.captureFromWidget(
      thisWidget,
      delay: const Duration(milliseconds: 500),
    );
    await controller.addImage(assetName, imageBytes);
  }

  void _onStyleLoadedCallback() async {
    await controller.addGeoJsonSource("points", _points);
    Stopwatch stopwatch = Stopwatch()..start();

    for (final feature in (_points['features'] as List)) {
      controller.addSymbol(
        SymbolOptions(
          iconImage: feature["properties"]["assetId"],
          geometry: LatLng(
            (feature["geometry"]["coordinates"] as List<double>).first,
            (feature["geometry"]["coordinates"] as List<double>).last,
          ),
        ),
      );
    }

    await Future.wait(
      [
        for (final feature in (_points['features'] as List))
          setImageByWidget(
            assetName: '${feature['id']}',
            feature: feature,
          ),
      ],
    );
    print('doSomething() executed in ${stopwatch.elapsed}');

    await controller.addSymbolLayer(
      "points",
      "symbols",
      const SymbolLayerProperties(
        // iconRotationAlignment: "map",
        iconImage: [Expressions.get, "assetId"],
        iconAllowOverlap: true, // не скрывать маркеры при наложении
        iconAnchor: "bottom-left",
      ),
    );
  }
}

Map<String, dynamic> _points = {
  "type": "FeatureCollection",
  "features": [
    for (var i = 0; i < 50; i++)
      {
        "type": "Feature",
        "id": i,
        "properties": {
          "assetId": i.toString(),
          "title": "title 2",
          "description": "description 2",
          "imageURL":
              "https://purepng.com/public/uploads/large/purepng.com-sitting-mansitting-manmansittingresting-1421526921786ju8nx.png",
        },
        "geometry": {
          "type": "Point",
          "coordinates": [151.184913929732943 + 0.01 * i, -33.874874486427181 + 0.01 * i]
        }
      },
  ]
};
