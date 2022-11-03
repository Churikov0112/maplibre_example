import '../../fwd_id/fwd_id.dart';
import 'fwd_marker_state.dart';

abstract class FwdMarker {
  const FwdMarker({
    required this.id,
    required this.state,
  });

  final FwdId id;
  final FwdMarkerState state;
}
