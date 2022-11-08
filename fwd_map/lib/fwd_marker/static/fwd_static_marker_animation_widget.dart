import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/mapbox_gl.dart';

import 'fwd_static_marker_animation_controller/fwd_static_marker_animation_controller.dart';
import 'fwd_static_marker_animation_controller/fwd_static_marker_animation_event.dart';
import 'fwd_static_marker_animation_controller/fwd_static_marker_animation_state.dart';

class FwdStaticMarkerAnimationWidget extends StatefulWidget {
  const FwdStaticMarkerAnimationWidget({
    required this.symbol,
    required this.maplibreMapController,
    required this.fwdStaticMarkerAnimationController,
    super.key,
  });

  final Symbol symbol;
  final MaplibreMapController? maplibreMapController;
  final FwdStaticMarkerAnimationController fwdStaticMarkerAnimationController;

  @override
  State<FwdStaticMarkerAnimationWidget> createState() => _FwdStaticMarkerAnimationWidgetState();
}

class _FwdStaticMarkerAnimationWidgetState extends State<FwdStaticMarkerAnimationWidget>
    with SingleTickerProviderStateMixin {
  // Анимация
  late AnimationController _animationController;
  late Tween<double> _latTween;
  late Tween<double> _lngTween;
  late Animation<double> _animation;
  late LatLng currentPoint;

  bool get isProcessing => widget.fwdStaticMarkerAnimationController.state == FwdStaticMarkerAnimationState.processing;

  Future<void> _handleAction(FwdStaticMarkerAnimationEvent event) {
    switch (event.action) {
      case FwdStaticMarkerAnimationAction.animate:
        return _animate(event.point!, event.duration!);
      // case FwdStaticMarkerAnimationEvent.remove:
      //   return _remove();
      // case FwdStaticMarkerAnimationEvent.teleport:
      //   return _teleport(event.point!, event.vehicle!);
    }
  }

  Future<void> _animate(LatLng point, Duration duration) async {
    if (isProcessing) return;
    _updateState(FwdStaticMarkerAnimationState.processing);
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
    _updateState(FwdStaticMarkerAnimationState.ended);
  }

  void _updateState(FwdStaticMarkerAnimationState moveState) {
    widget.fwdStaticMarkerAnimationController.state = moveState;
  }

  @override
  void initState() {
    super.initState();

    if (widget.symbol.options.geometry != null) {
      currentPoint = widget.symbol.options.geometry!;
    }

    widget.fwdStaticMarkerAnimationController.streamController =
        StreamController<FwdStaticMarkerAnimationEvent>.broadcast();
    widget.fwdStaticMarkerAnimationController.streamController.stream.listen(_handleAction);

    _updateState(FwdStaticMarkerAnimationState.init);

    _animationController = AnimationController(duration: const Duration(seconds: 5), vsync: this)
      ..addListener(() {
        // обновляем значения текущий координаты каждый раз, когда запускается анимация
        final latLng = LatLng(_latTween.evaluate(_animation), _lngTween.evaluate(_animation));
        setState(() {
          currentPoint = latLng;
        });

        widget.maplibreMapController
            ?.updateSymbol(widget.symbol, SymbolOptions(geometry: LatLng(latLng.latitude, latLng.longitude)));
      });

    // Устанавливаем линейную анимацию
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.linear);

    // Устанавливаем текущей координате значение координаты маркера
    _latTween = Tween(end: currentPoint.latitude)..animate(_animation);
    _lngTween = Tween(end: currentPoint.longitude)..animate(_animation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.fwdStaticMarkerAnimationController.streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
