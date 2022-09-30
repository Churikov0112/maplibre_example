import 'package:flutter/material.dart';
import 'package:maplibre_example/layer_page.dart';
import 'dart:core';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LayerPage(),
    );
  }
}
