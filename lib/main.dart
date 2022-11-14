import 'dart:core';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_example/fwd_map_example/static_marker_example.dart';
import 'fwd_map_example/dynamic_marker_example.dart';
import 'fwd_map_example/polygon_example.dart';
import 'fwd_map_example/polyline_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const MenuPage(),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Maplibre example")),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FwdMapStaticMarkerExample(),
                ),
              );
            },
            title: const Text("Static marker"),
            trailing: const Icon(Icons.security),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FwdMapDynamicMarkerExample(),
                ),
              );
            },
            title: const Text("Dynamic marker"),
            trailing: const Icon(Icons.now_widgets),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FwdMapPolylineExample(),
                ),
              );
            },
            title: const Text("Polyline example"),
            trailing: const Icon(Icons.line_axis),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FwdMapPolygonExample(),
                ),
              );
            },
            title: const Text("Polygon example"),
            trailing: const Icon(Icons.square),
          ),
        ],
      ),
    );
  }
}
