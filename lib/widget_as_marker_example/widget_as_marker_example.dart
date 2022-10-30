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
  ScreenshotController screenshotController = ScreenshotController();
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
              dynamic newFeature = {
                "type": "Feature",
                "id": "0",
                "properties": {
                  "title": "Планета",
                  "description": "Земля",
                  "imageURL": "https://www.kindpng.com/picc/m/307-3077167_earth-small-icon-hd-png-download.png",
                },
                "geometry": {
                  "type": "Point",
                  "coordinates": [151.184913929732943 - 0.01 * 1, -33.874874486427181 - 0.01 * 1]
                }
              };

              final loadedImageBytes = await getUint8ListFromImageUrl(
                url: newFeature["properties"]["imageURL"],
              );

              final screenshotedWidgetBytes = await getUint8ListFromWidgetWithImageBytes(
                title: newFeature["properties"]["title"],
                description: newFeature["properties"]["description"],
                imageBytes: loadedImageBytes,
              );

              await deleteMarker(featureId: "0");

              (_points["features"] as List).first = newFeature;

              await addSymbolByWidget(
                feature: (_points["features"] as List).first,
                loadedImageBytes: loadedImageBytes,
                screenshotedWidgetBytes: screenshotedWidgetBytes,
              );
            },
            child: const Center(
              child: Icon(Icons.update),
            ),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () async {
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

  Future<Uint8List> getUint8ListFromImageUrl({
    required String url,
  }) async {
    http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<Uint8List> getUint8ListFromWidgetWithImageBytes({
    required String title,
    required String description,
    required Uint8List imageBytes,
  }) async {
    final thisWidget = CustomMarkerWidget(
      title: title,
      description: description,
      imageBytes: imageBytes,
    );
    Uint8List widgetBytes = await screenshotController.captureFromWidget(
      thisWidget,
      delay: const Duration(milliseconds: 1000),
    );
    return widgetBytes;
  }

  Future<void> addSymbolByWidget({
    required dynamic feature,
    Uint8List? loadedImageBytes,
    Uint8List? screenshotedWidgetBytes,
  }) async {
    final imageBytes = loadedImageBytes ?? await getUint8ListFromImageUrl(url: feature["properties"]["imageURL"]);
    final widgetBytes = screenshotedWidgetBytes ??
        await getUint8ListFromWidgetWithImageBytes(
          title: feature["properties"]["title"],
          description: feature["properties"]["description"],
          imageBytes: imageBytes,
        );
    await controller.addImage(feature['id'], widgetBytes);
    symbols[feature['id']] = await controller.addSymbol(
      SymbolOptions(
        iconImage: feature["id"],
        geometry: LatLng(
          (feature["geometry"]["coordinates"] as List<double>).last,
          (feature["geometry"]["coordinates"] as List<double>).first,
        ),
      ),
    );
    // Stopwatch stopwatch = Stopwatch()..start();

    // print('doSomething() executed in ${stopwatch.elapsed}');
  }

  void _onStyleLoadedCallback() async {
    await Future.wait(
      [
        for (final feature in (_points['features'] as List)) addSymbolByWidget(feature: feature),
      ],
    );
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
