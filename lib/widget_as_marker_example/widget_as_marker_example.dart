import 'dart:math';
import 'package:flutter/services.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

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
      body: MaplibreMap(
        dragEnabled: false,
        onMapCreated: _onMapCreated,
        onStyleLoadedCallback: _onStyleLoadedCallback,
        initialCameraPosition: const CameraPosition(
          target: center,
          zoom: 11.0,
        ),
      ),
    );
  }

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
    controller.onFeatureTapped.add(onFeatureTap);
  }

  void onFeatureTap(dynamic featureId, Point<double> point, LatLng latLng) {}

  Future<void> setImageByWidget(
    String name,
    Widget widget,
  ) async {
    ScreenshotController screenshotController = ScreenshotController();
    Uint8List imageBytes = await screenshotController.captureFromWidget(widget, delay: Duration.zero);
    controller.addImage(name, imageBytes);
  }

  void _onStyleLoadedCallback() async {
    await controller.addGeoJsonSource("points", _points);

    for (final feature in (_points['features'] as List)) {
      await setImageByWidget(
        '${feature['id']}',
        CustomMarkerWidget(
          title: feature["properties"]["title"],
          description: feature["properties"]["description"],
        ),
      );
    }

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

const _points = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": 2,
      "properties": {
        "assetId": "2",
        "title": "title 2",
        "description": "description 2",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.184913929732943, -33.874874486427181]
      }
    },
    {
      "type": "Feature",
      "id": 3,
      "properties": {
        "assetId": "3",
        "title": "title 3",
        "description": "description 3",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.215730044667879, -33.874616048776858]
      }
    },
    {
      "type": "Feature",
      "id": 4,
      "properties": {
        "assetId": "4",
        "title": "title 4",
        "description": "description 4",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.228803547973598, -33.892188026142584]
      }
    },
    {
      "type": "Feature",
      "id": 5,
      "properties": {
        "assetId": "5",
        "title": "title 5",
        "description": "description 5",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [151.186470299174118, -33.902781145804774]
      }
    }
  ]
};
