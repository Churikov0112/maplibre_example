import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import 'package:maplibre_example/widget_as_marker_example/widget_as_marker_example.dart';

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
      home: const WidgetAsMarkerExample(),
    );
  }
}
