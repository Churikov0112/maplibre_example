import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

class PlaceSymbolBody extends StatefulWidget {
  const PlaceSymbolBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PlaceSymbolBodyState();
}

class PlaceSymbolBodyState extends State<PlaceSymbolBody> {
  PlaceSymbolBodyState();

  static const LatLng center = LatLng(60.1, 30.1);

  MaplibreMapController? controller;
  int _symbolCount = 0;
  Symbol? _selectedSymbol;
  bool _iconAllowOverlap = false;

  void _onMapCreated(MaplibreMapController controller) {
    this.controller = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
  }

  void _onStyleLoaded() {
    addImageFromAsset("custom-marker", "assets/symbols/custom-marker.png");
    addImageFromAsset("assetImage", "assets/symbols/custom-icon.png");
    addImageFromUrl("networkImage", Uri.parse("https://via.placeholder.com/50"));
  }

  @override
  void dispose() {
    controller?.onSymbolTapped.remove(_onSymbolTapped);
    super.dispose();
  }

  /// Adds an asset image to the currently displayed style
  Future<void> addImageFromAsset(String name, String assetName) async {
    final ByteData bytes = await rootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return controller!.addImage(name, list);
  }

  /// Adds a network image to the currently displayed style
  Future<void> addImageFromUrl(String name, Uri uri) async {
    var response = await http.get(uri);
    return controller!.addImage(name, response.bodyBytes);
  }

  void _onSymbolTapped(Symbol symbol) {
    if (_selectedSymbol != null) {
      _updateSelectedSymbol(
        const SymbolOptions(iconSize: 1.0),
      );
    }
    setState(() {
      _selectedSymbol = symbol;
    });
    _updateSelectedSymbol(
      const SymbolOptions(
        iconSize: 1.4,
      ),
    );
  }

  void _updateSelectedSymbol(SymbolOptions changes) async {
    await controller!.updateSymbol(_selectedSymbol!, changes);
  }

  void _add(String iconImage) {
    List<int> availableNumbers = Iterable<int>.generate(12).toList();
    for (var s in controller!.symbols) {
      availableNumbers.removeWhere((i) => i == s.data!['count']);
    }
    if (availableNumbers.isNotEmpty) {
      controller!.addSymbol(_getSymbolOptions(iconImage, availableNumbers.first), {'count': availableNumbers.first});
      setState(() {
        _symbolCount += 1;
      });
    }
  }

  SymbolOptions _getSymbolOptions(String iconImage, int symbolCount) {
    LatLng geometry = LatLng(
      center.latitude + sin(symbolCount * pi / 6.0) / 20.0,
      center.longitude + cos(symbolCount * pi / 6.0) / 20.0,
    );
    return iconImage == 'customFont'
        ? SymbolOptions(
            geometry: geometry,
            iconImage: 'custom-marker', //'airport-15',
            fontNames: ['DIN Offc Pro Bold', 'Arial Unicode MS Regular'],
            textField: 'Airport',
            textSize: 12.5,
            textOffset: const Offset(0, 0.8),
            textAnchor: 'top',
            textColor: '#000000',
            textHaloBlur: 1,
            textHaloColor: '#ffffff',
            textHaloWidth: 0.8,
          )
        : SymbolOptions(
            geometry: geometry,
            textField: 'Airport',
            textOffset: const Offset(0, 0.8),
            iconImage: iconImage,
          );
  }

  Future<void> _addAll(String iconImage) async {
    List<int> symbolsToAddNumbers = Iterable<int>.generate(12).toList();
    for (var s in controller!.symbols) {
      symbolsToAddNumbers.removeWhere((i) => i == s.data!['count']);
    }

    if (symbolsToAddNumbers.isNotEmpty) {
      final List<SymbolOptions> symbolOptionsList = symbolsToAddNumbers.map((i) => _getSymbolOptions(iconImage, i)).toList();
      controller!.addSymbols(symbolOptionsList, symbolsToAddNumbers.map((i) => {'count': i}).toList());

      setState(() {
        _symbolCount += symbolOptionsList.length;
      });
    }
  }

  void _remove() {
    controller!.removeSymbol(_selectedSymbol!);
    setState(() {
      _selectedSymbol = null;
      _symbolCount -= 1;
    });
  }

  void _removeAll() {
    controller!.removeSymbols(controller!.symbols);
    setState(() {
      _selectedSymbol = null;
      _symbolCount = 0;
    });
  }

  void _changePosition() {
    final LatLng current = _selectedSymbol!.options.geometry!;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    _updateSelectedSymbol(
      SymbolOptions(
        geometry: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      ),
    );
  }

  void _changeIconOffset() {
    Offset? currentAnchor = _selectedSymbol!.options.iconOffset;
    currentAnchor ??= const Offset(0.0, 0.0);
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    _updateSelectedSymbol(SymbolOptions(iconOffset: newAnchor));
  }

  Future<void> _changeIconAnchor() async {
    String? current = _selectedSymbol!.options.iconAnchor;
    if (current == null || current == 'center') {
      current = 'bottom';
    } else {
      current = 'center';
    }
    _updateSelectedSymbol(
      SymbolOptions(iconAnchor: current),
    );
  }

  Future<void> _toggleDraggable() async {
    bool? draggable = _selectedSymbol!.options.draggable;
    draggable ??= false;

    _updateSelectedSymbol(
      SymbolOptions(draggable: !draggable),
    );
  }

  Future<void> _changeAlpha() async {
    double? current = _selectedSymbol!.options.iconOpacity;
    current ??= 1.0;

    _updateSelectedSymbol(
      SymbolOptions(iconOpacity: current < 0.1 ? 1.0 : current * 0.75),
    );
  }

  Future<void> _changeRotation() async {
    double? current = _selectedSymbol!.options.iconRotate;
    current ??= 0;
    _updateSelectedSymbol(
      SymbolOptions(iconRotate: current == 330.0 ? 0.0 : current + 30.0),
    );
  }

  Future<void> _toggleVisible() async {
    double? current = _selectedSymbol!.options.iconOpacity;
    current ??= 1.0;

    _updateSelectedSymbol(
      SymbolOptions(iconOpacity: current == 0.0 ? 1.0 : 0.0),
    );
  }

  Future<void> _changeZIndex() async {
    int? current = _selectedSymbol!.options.zIndex;
    current ??= 0;
    _updateSelectedSymbol(
      SymbolOptions(zIndex: current == 12 ? 0 : current + 1),
    );
  }

  void _getLatLng() async {
    LatLng latLng = await controller!.getSymbolLatLng(_selectedSymbol!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(latLng.toString()),
      ),
    );
  }

  Future<void> _changeIconOverlap() async {
    setState(() {
      _iconAllowOverlap = !_iconAllowOverlap;
    });
    controller!.setSymbolIconAllowOverlap(_iconAllowOverlap);
    controller!.setSymbolTextAllowOverlap(_iconAllowOverlap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("mapbox controller example")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 400,
              child: MaplibreMap(
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
                styleString: "https://map.91.team/styles/basic/style.json",
                initialCameraPosition: const CameraPosition(
                  target: LatLng(60.0, 30.3),
                  zoom: 11.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          TextButton(
                            child: const Text('add'),
                            onPressed: () => (_symbolCount == 12) ? null : _add("custom-marker"),
                          ),
                          TextButton(
                            child: const Text('add all'),
                            onPressed: () => (_symbolCount == 12) ? null : _addAll("custom-marker"),
                          ),
                          TextButton(
                            child: const Text('add (custom icon)'),
                            onPressed: () => (_symbolCount == 12) ? null : _add("assets/symbols/custom-icon.png"),
                          ),
                          TextButton(
                            child: const Text('remove'),
                            onPressed: (_selectedSymbol == null) ? null : _remove,
                          ),
                          TextButton(
                            child: Text('${_iconAllowOverlap ? 'disable' : 'enable'} icon overlap'),
                            onPressed: _changeIconOverlap,
                          ),
                          TextButton(
                            child: const Text('remove all'),
                            onPressed: (_symbolCount == 0) ? null : _removeAll,
                          ),
                          TextButton(
                            child: const Text('add (asset image)'),
                            onPressed: () => (_symbolCount == 12) ? null : _add("assetImage"), //assetImage added to the style in _onStyleLoaded
                          ),
                          TextButton(
                            child: const Text('add (network image)'),
                            onPressed: () => (_symbolCount == 12) ? null : _add("networkImage"), //networkImage added to the style in _onStyleLoaded
                          ),
                          TextButton(
                            child: const Text('add (custom font)'),
                            onPressed: () => (_symbolCount == 12) ? null : _add("customFont"),
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          TextButton(
                            child: const Text('change alpha'),
                            onPressed: (_selectedSymbol == null) ? null : _changeAlpha,
                          ),
                          TextButton(
                            child: const Text('change icon offset'),
                            onPressed: (_selectedSymbol == null) ? null : _changeIconOffset,
                          ),
                          TextButton(
                            child: const Text('change icon anchor'),
                            onPressed: (_selectedSymbol == null) ? null : _changeIconAnchor,
                          ),
                          TextButton(
                            child: const Text('toggle draggable'),
                            onPressed: (_selectedSymbol == null) ? null : _toggleDraggable,
                          ),
                          TextButton(
                            child: const Text('change position'),
                            onPressed: (_selectedSymbol == null) ? null : _changePosition,
                          ),
                          TextButton(
                            child: const Text('change rotation'),
                            onPressed: (_selectedSymbol == null) ? null : _changeRotation,
                          ),
                          TextButton(
                            child: const Text('toggle visible'),
                            onPressed: (_selectedSymbol == null) ? null : _toggleVisible,
                          ),
                          TextButton(
                            child: const Text('change zIndex'),
                            onPressed: (_selectedSymbol == null) ? null : _changeZIndex,
                          ),
                          TextButton(
                            child: const Text('get current LatLng'),
                            onPressed: (_selectedSymbol == null) ? null : _getLatLng,
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
