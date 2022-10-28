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

  Map<String, Symbol> symbols = {};

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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await deleteMarker(featureId: "0");

              (_points["features"] as List).first = {
                "type": "Feature",
                "id": "0",
                "properties": {
                  "assetId": "0",
                  "title": "title 0",
                  "description": "description 0",
                  "imageURL": "https://www.kindpng.com/picc/m/307-3077167_earth-small-icon-hd-png-download.png",
                },
                "geometry": {
                  "type": "Point",
                  "coordinates": [151.184913929732943 - 0.01 * 1, -33.874874486427181 - 0.01 * 1]
                }
              };

              await addMarkerByWidget(feature: (_points["features"] as List).first);
            },
            child: const Center(
              child: Icon(Icons.update),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
              // (_points["features"] as List).first = {
              //   "type": "Feature",
              //   "id": 0,
              //   "properties": {
              //     "assetId": "0",
              //     "title": "title 0",
              //     "description": "description 0",
              //     "imageURL": "https://www.kindpng.com/picc/m/307-3077167_earth-small-icon-hd-png-download.png",
              //   },
              //   "geometry": {
              //     "type": "Point",
              //     "coordinates": [151.184913929732943 + 0.01 * 0, -33.874874486427181 + 0.01 * 0]
              //   }
              // };
              await deleteMarker(featureId: "0");
            },
            child: const Center(
              child: Icon(Icons.delete),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
    controller.onFeatureTapped.add(onFeatureTap);
    controller.symbolManager?.setIconAllowOverlap(true);
    controller.symbolManager?.setIconIgnorePlacement(true);
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {}

  Future<void> deleteMarker({
    required String featureId,
  }) async {
    // final feature = (_points["features"] as List).firstWhere((feat) => feat['id'] == featureId);
    final symbol = symbols[featureId];
    if (symbol != null) {
      await controller.symbolManager?.remove(symbol);
    }
  }

  Future<void> addMarkerByWidget({
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
      delay: const Duration(milliseconds: 1000),
    );
    await controller.addImage(feature['id'], imageBytes);
    symbols[feature['id']] = await controller.addSymbol(
      SymbolOptions(
        iconImage: feature["properties"]["assetId"],
        geometry: LatLng(
          (feature["geometry"]["coordinates"] as List<double>).last,
          (feature["geometry"]["coordinates"] as List<double>).first,
        ),
      ),
    );
  }

  void _onStyleLoadedCallback() async {
    // await controller.addGeoJsonSource("points", _points);
    Stopwatch stopwatch = Stopwatch()..start();

    await Future.wait(
      [
        for (final feature in (_points['features'] as List))
          addMarkerByWidget(
            feature: feature,
          ),
      ],
    );
    print('doSomething() executed in ${stopwatch.elapsed}');

    // await controller.addSymbolLayer(
    //   "points",
    //   "symbols",
    //   const SymbolLayerProperties(
    //     // iconRotationAlignment: "map",
    //     iconImage: [Expressions.get, "assetId"],
    //     iconAllowOverlap: true, // не скрывать маркеры при наложении
    //     iconAnchor: "bottom-left",
    //   ),
    // );
  }
}

Map<String, dynamic> _points = {
  "type": "FeatureCollection",
  "features": [
    for (var i = 0; i < 50; i++)
      {
        "type": "Feature",
        "id": i.toString(),
        "properties": {
          "assetId": i.toString(),
          "title": "title $i",
          "description": "description $i",
          "imageURL": "https://img.lovepik.com/element/40116/9419.png_300.png",
        },
        "geometry": {
          "type": "Point",
          "coordinates": [151.184913929732943 + 0.01 * i, -33.874874486427181 + 0.01 * i]
        }
      },
  ]
};
