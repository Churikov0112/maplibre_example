import 'dart:core';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_example/fwd_map_example/fwd_map_example.dart';
import 'animated_marker_example/animated_marker_example.dart';
import 'screenshoted_widget_example/screenshoted_widget_example.dart';

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
                  builder: (BuildContext context) => const ScreenshotedWidgetExample(),
                ),
              );
            },
            title: const Text("Screenshoted Widget as marker"),
            trailing: const Icon(Icons.chevron_right_outlined),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const AnimatedMarkerExample(),
                ),
              );
            },
            title: const Text("Flutter Widget as marker"),
            trailing: const Icon(Icons.chevron_right_outlined),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => FwdMapExample(),
                ),
              );
            },
            title: const Text("Fwd Map example"),
            trailing: const Icon(Icons.chevron_right_outlined),
          ),
        ],
      ),
    );
  }
}
