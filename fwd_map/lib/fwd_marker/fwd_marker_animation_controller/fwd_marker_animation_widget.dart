import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import '../dynamic/fwd_dynamic_marker.dart';
import '../dynamic/fwd_dynamic_marker_widget.dart';
import 'fwd_marker_animation_controller.dart';
import 'fwd_marker_animation_event.dart';
import 'fwd_marker_animation_state.dart';

enum FwdMarkerAnimationWidgetType { static, dynamic }

class FwdMarkerAnimationWidget extends StatefulWidget {
  // const FwdMarkerAnimationWidget._({
  //   required this.symbol,
  //   required this.maplibreMapController,
  //   required this.fwdMarkerAnimationController,
  //   super.key,
  // }) : super();

  final Symbol? symbol;
  final FwdDynamicMarker? fwdDynamicMarker;
  final MaplibreMapController maplibreMapController;
  final FwdMarkerAnimationController fwdMarkerAnimationController;
  final FwdMarkerAnimationWidgetType type;

  final Point? initialMarkerPosition;

  const FwdMarkerAnimationWidget.fromSymbol({
    required this.symbol,
    required this.maplibreMapController,
    required this.fwdMarkerAnimationController,
    super.key,
  })  : type = FwdMarkerAnimationWidgetType.static,
        initialMarkerPosition = null,
        fwdDynamicMarker = null;

  const FwdMarkerAnimationWidget.fromDynamicMarker({
    required this.fwdDynamicMarker,
    required this.maplibreMapController,
    required this.fwdMarkerAnimationController,
    required this.initialMarkerPosition,
    super.key,
  })  : type = FwdMarkerAnimationWidgetType.dynamic,
        symbol = null;

  @override
  State<FwdMarkerAnimationWidget> createState() => _FwdMarkerAnimationWidgetState();
}

class _FwdMarkerAnimationWidgetState extends State<FwdMarkerAnimationWidget> with SingleTickerProviderStateMixin {
  // Анимация
  late AnimationController _animationController;
  late Tween<double> _latTween;
  late Tween<double> _lngTween;
  late Animation<double> _animation;

  late LatLng _currentCoordinate;
  late Point _dynamicMarkerCurrentPosition;

  bool get isProcessing => widget.fwdMarkerAnimationController.state == FwdMarkerAnimationState.processing;

  Future<void> _handleAction(FwdMarkerAnimationEvent event) {
    switch (event.action) {
      case FwdMarkerAnimationAction.animate:
        return _animate(event.point!, event.duration!);
      // case FwdMarkerAnimationEvent.remove:
      //   return _remove();
      // case FwdMarkerAnimationEvent.teleport:
      //   return _teleport(event.point!, event.vehicle!);
    }
  }

  Future<void> _animate(LatLng point, Duration duration) async {
    if (isProcessing) return;
    _updateState(FwdMarkerAnimationState.processing);
    _animationController.duration = duration;
    _latTween.begin = _latTween.end;
    _lngTween.begin = _lngTween.end;
    _latTween.end = point.latitude;
    _lngTween.end = point.longitude;
    try {
      _animationController.reset();
      await _animationController.forward(from: 0.0);
    } on Object catch (e) {
      debugPrint(e.toString());
      return;
    }
    _updateState(FwdMarkerAnimationState.ended);
  }

  void _updateState(FwdMarkerAnimationState moveState) {
    widget.fwdMarkerAnimationController.state = moveState;
  }

  Future<void> calculateDynamicMarkerCurrentPosition() async {
    _dynamicMarkerCurrentPosition = await widget.maplibreMapController.toScreenLocation(_currentCoordinate);
  }

  @override
  void initState() {
    super.initState();

    if (widget.type == FwdMarkerAnimationWidgetType.static) {
      if (widget.symbol!.options.geometry != null) {
        _currentCoordinate = widget.symbol!.options.geometry!;
      }
    }

    if (widget.type == FwdMarkerAnimationWidgetType.dynamic) {
      _currentCoordinate = widget.fwdDynamicMarker!.initialCoordinate;
      _dynamicMarkerCurrentPosition = widget.initialMarkerPosition!;
    }

    widget.fwdMarkerAnimationController.streamController = StreamController<FwdMarkerAnimationEvent>.broadcast();
    widget.fwdMarkerAnimationController.streamController.stream.listen(_handleAction);

    _updateState(FwdMarkerAnimationState.init);

    _animationController = AnimationController(duration: const Duration(seconds: 5), vsync: this)
      ..addListener(() async {
        // обновляем значения текущий координаты каждый раз, когда запускается анимация
        final latLng = LatLng(_latTween.evaluate(_animation), _lngTween.evaluate(_animation));

        _currentCoordinate = latLng;

        if (widget.type == FwdMarkerAnimationWidgetType.static) {
          widget.maplibreMapController
              .updateSymbol(widget.symbol!, SymbolOptions(geometry: LatLng(latLng.latitude, latLng.longitude)));
        }

        if (widget.type == FwdMarkerAnimationWidgetType.dynamic) {
          _dynamicMarkerCurrentPosition = await widget.maplibreMapController.toScreenLocation(_currentCoordinate);
        }

        setState(() {});
      });

    // Устанавливаем линейную анимацию
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear);

    // Устанавливаем текущей координате значение координаты маркера
    _latTween = Tween(end: _currentCoordinate.latitude)..animate(_animation);
    _lngTween = Tween(end: _currentCoordinate.longitude)..animate(_animation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.fwdMarkerAnimationController.streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == FwdMarkerAnimationWidgetType.dynamic) {
      return FwdDynamicMarkerWidget(
        maplibreMapController: widget.maplibreMapController,
        id: widget.fwdDynamicMarker!.id,
        coordinate: _currentCoordinate,
        initialPosition: _dynamicMarkerCurrentPosition,
        onMarkerTap: widget.fwdDynamicMarker!.onMarkerTap,
        child: widget.fwdDynamicMarker!.child,
      );
    }
    return const SizedBox.shrink();
  }
}
