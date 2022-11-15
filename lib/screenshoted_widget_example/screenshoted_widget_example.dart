import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_example/screenshoted_widget_example/custom_toast_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import 'package:http/http.dart' as http;

import 'custom_marker_widget.dart';

class ScreenshotedWidgetExample extends StatefulWidget {
  const ScreenshotedWidgetExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScreenshotedWidgetExampleState();
}

class ScreenshotedWidgetExampleState extends State<ScreenshotedWidgetExample> {
  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(59.974941, 30.337769), // LatLng
    zoom: 13.0,
  );
  late MaplibreMapController controller;

  /// {
  ///   "featureId": {
  ///     "symbol": Symbol(...),
  ///     "imageBytes": Uint8List(...)
  ///   }
  /// }
  ///
  /// NOTE: imageBytes is Uint8List of image from feature["properties"]["imageURL"]
  Map<String, dynamic> symbols = {};

  ScreenshotController screenshotController = ScreenshotController();

  // для показа анимаций
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screenshoted Widhet as marker"),
      ),
      body: Stack(
        children: [
          MaplibreMap(
            dragEnabled: false,
            styleString: "https://map.91.team/styles/basic/style.json",
            onMapCreated: _onMapCreated,
            onStyleLoadedCallback: _onStyleLoadedCallback,
            initialCameraPosition: initialCameraPosition,
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              dynamic newFeature = {
                "type": "Feature",
                "id": "0",
                "properties": {
                  "title": "Ben 10",
                  "description": "Эй зацените мою новую аватарку",
                  "isTyping": false,
                  "notificationsNumber": 0,
                  "imageURL": "https://purepng.com/public/uploads/large/ben-ten-cartoon-character-vbs.png",
                },
                "geometry": {
                  "type": "Point",
                  "coordinates": [30.337769 + 0.02, 59.974941 + 0.02] // LngLat
                }
              };

              Timer.periodic(const Duration(milliseconds: 10), (timer) async {
                final Symbol symbolToUpdate = symbols[newFeature["id"]]["symbol"];

                LatLng currentLocation = symbolToUpdate.options.geometry as LatLng; // LatLng of Symbol you want update

                LatLng dynamicLocation = LatLng(
                  currentLocation.latitude +
                      ((newFeature["geometry"]["coordinates"] as List).last - currentLocation.latitude) / 200,
                  currentLocation.longitude +
                      ((newFeature["geometry"]["coordinates"] as List).first - currentLocation.longitude) / 200,
                );

                try {
                  await controller.updateSymbol(
                    symbolToUpdate,
                    SymbolOptions(geometry: dynamicLocation),
                  );
                } catch (e) {
                  timer.cancel();
                  return;
                }
              });

              // await updateMarker(newFeature: newFeature);
            },
            child: const Center(child: Icon(Icons.join_right)),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              // new feature with new image and same id
              dynamic newFeature = {
                "type": "Feature",
                "id": "0",
                "properties": {
                  "title": "Ben 10",
                  "description": "Эй зацените мою новую аватарку",
                  "isTyping": false,
                  "notificationsNumber": 1,
                  "imageURL":
                      "https://purepng.com/public/uploads/large/purepng.com-arkham-batmanbatmansuperherocomicdc-comicsbob-kanebat-manbruce-wayne-1701528523679pnser.png",
                },
                "geometry": {
                  "type": "Point",
                  "coordinates": [30.337769 + 0.01, 59.974941 + 0.01] // LngLat
                }
              };

              late Uint8List imageBytes;

              // проверка, чтобы не загружать одну картинку дважды
              if (newFeature["properties"]["imageURL"] !=
                  (_points["features"] as List).firstWhere((feat) => feat["id"] == newFeature["id"])["properties"]
                      ["imageURL"]) {
                imageBytes = await getUint8ListFromImageUrl(
                  url: newFeature["properties"]["imageURL"],
                );
              } else {
                imageBytes = symbols[newFeature["id"]]["imageBytes"];
              }

              await updateMarker(
                newFeature: newFeature,
                loadedImageBytes: imageBytes,
              );

              // какое-то уведомление после перерисовки виджета
              BotToast.showAttachedWidget(
                target: const Offset(0, 16),
                attachedBuilder: (_) {
                  return CustomToastWidget(
                    imageBytes: imageBytes,
                    senderName: (_points["features"] as List).first["properties"]["title"],
                    message: (_points["features"] as List).first["properties"]["description"],
                  );
                },
              );
            },
            child: const Center(child: Icon(Icons.update)),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              await deleteMarker(featureId: "0");
            },
            child: const Center(child: Icon(Icons.delete)),
          ),
        ],
      ),
    );
  }

  Future<void> _onMapCreated(MaplibreMapController maplibreMapController) async {
    controller = maplibreMapController;
    controller.onSymbolTapped.add(_onSymbolTapped);
    await controller.setSymbolIconAllowOverlap(true);
    await controller.setSymbolIconIgnorePlacement(true);
  }

  void _onSymbolTapped(Symbol symbol) {}

  // метод удаяяет с карты маркер по id
  Future<void> deleteMarker({
    required String featureId,
  }) async {
    final symbol = symbols[featureId]["symbol"];

    if (symbol != null) {
      await controller.removeSymbol(symbol);
    }
  }

  // метод обновляет на карте маркер по id
  Future<void> updateMarker({
    required dynamic newFeature,
    Uint8List? loadedImageBytes,
    Uint8List? screenshotedWidgetBytes,
  }) async {
    final imageBytes = loadedImageBytes ?? await getUint8ListFromImageUrl(url: newFeature["properties"]["imageURL"]);

    final widgetBytes = screenshotedWidgetBytes ??
        await getUint8ListFromWidgetWithImageBytes(
          title: newFeature["properties"]["title"],
          description: newFeature["properties"]["description"],
          notificationsNumber: newFeature["properties"]["notificationsNumber"],
          isTyping: newFeature["properties"]["isTyping"],
          imageBytes: imageBytes,
        );

    await deleteMarker(featureId: "0");

    // Посмотрим на примере первого маркера (Ben 10)
    (_points["features"] as List).first = newFeature;

    await addSymbolByWidget(
      feature: (_points["features"] as List).first,
      loadedImageBytes: imageBytes,
      screenshotedWidgetBytes: widgetBytes,
    );
  }

  // метод возвращает Uint8List  картинки из интернета
  Future<Uint8List> getUint8ListFromImageUrl({
    required String url,
  }) async {
    http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  // метод возвращает Uint8List скриншота виджета
  Future<Uint8List> getUint8ListFromWidgetWithImageBytes({
    required String title,
    required String description,
    required int notificationsNumber,
    required bool isTyping,
    required Uint8List imageBytes,
  }) async {
    final thisWidget = CustomMarkerWidget(
      title: title,
      description: description,
      notificationsNumber: notificationsNumber,
      isTyping: isTyping,
      imageBytes: imageBytes,
    );

    Uint8List widgetBytes = await screenshotController.captureFromWidget(
      thisWidget,
      delay: const Duration(milliseconds: 1000),
    );

    return widgetBytes;
  }

  // метод добавляет маркер на карту
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
          notificationsNumber: feature["properties"]["notificationsNumber"],
          isTyping: feature["properties"]["isTyping"],
          imageBytes: imageBytes,
        );

    await controller.addImage(feature['id'], widgetBytes);

    symbols[feature['id']] = {};

    symbols[feature['id']]["symbol"] = await controller.addSymbol(
      SymbolOptions(
        iconAnchor: "bottom-left",
        iconImage: feature["id"],
        geometry: LatLng(
          (feature["geometry"]["coordinates"] as List<double>).last,
          (feature["geometry"]["coordinates"] as List<double>).first,
        ),
      ),
    );

    symbols[feature['id']]["imageBytes"] = imageBytes;
  }

  void _onStyleLoadedCallback() async {
    // распараллеленное добавление маркеров
    await Future.wait([for (final feature in (_points['features'] as List)) addSymbolByWidget(feature: feature)]);
  }
}

Map<String, dynamic> _points = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "id": "0",
      "properties": {
        "title": "Ben 10",
        "description": "Your bestie",
        "notificationsNumber": 0,
        "isTyping": false,
        "imageURL": "https://purepng.com/public/uploads/large/ben-ten-cartoon-character-vbs.png",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [30.337769 + 0.01, 59.974941 + 0.01] // LngLat
      }
    },
    {
      "type": "Feature",
      "id": "1",
      "properties": {
        "title": "Spider man",
        "notificationsNumber": 0,
        "isTyping": false,
        "description": "aka Peter Parker",
        "imageURL":
            "https://purepng.com/public/uploads/large/purepng.com-spiderman-shieldspider-manspidermansuperherocomic-bookmarvel-comicscharacterstan-lee-1701528655285vlah5.png",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [30.337769 - 0.01, 59.974941 - 0.01] // LngLat
      }
    },
    {
      "type": "Feature",
      "id": "2",
      "properties": {
        "title": "Prapor",
        "notificationsNumber": 999999999,
        "isTyping": false,
        "description": "Spam bot",
        "imageURL":
            "https://purepng.com/public/uploads/large/91508275292qqpbl65lhlqy30d26sfrotv52cy0pt0alirajq6imwdv3fnqbsnttzjeqsokvgyjp7avvxglzbrxp1ber72euhdwjojorpvnvxju.png",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [30.337769 - 0.01, 59.974941 + 0.01] // LngLat
      }
    },
    {
      "type": "Feature",
      "id": "3",
      "properties": {
        "notificationsNumber": 0,
        "isTyping": false,
        "title": "Donald Dick",
        "description": "кря-кря",
        "imageURL":
            "https://purepng.com/public/uploads/large/purepng.com-donald-duckdonald-duckdonaldduckcartooncharacter1934walt-disneywhite-duck-1701528546230t1ite.png",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [30.337769 + 0.01, 59.974941 - 0.01] // LngLat
      }
    },
    {
      "type": "Feature",
      "id": "4",
      "properties": {
        "title": "Leo",
        "notificationsNumber": 0,
        "isTyping": false,
        "description": "U're my friend now",
        "imageURL":
            "https://purepng.com/public/uploads/large/purepng.com-ninja-tutle-leonardoninja-turtlesninjaturtleseenage-mutanttmntteenagedanthropomorphicturtlescartoon-seriesfilmsvideo-gamestoys-1701528652740rqojd.png",
      },
      "geometry": {
        "type": "Point",
        "coordinates": [30.337769, 59.974941] // LngLat
      }
    },
  ]
};
