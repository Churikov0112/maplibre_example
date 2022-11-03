import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:screenshot/screenshot.dart';
import 'package:http/http.dart' as http;

class FwdMapMarkerHelper {
  static Future<Uint8List> widgetToBytes(Widget widget) async {
    final bytes = await ScreenshotController().captureFromWidget(
      widget,
      delay: const Duration(milliseconds: 1000),
    );
    return bytes;
  }

  static Future<Uint8List> imageAssetToBytes(String imageAssetPath) async {
    Uint8List bytes = (await rootBundle.load(imageAssetPath)).buffer.asUint8List();
    return bytes;
  }

  static Future<Uint8List> imageNetworkToBytes(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    return response.bodyBytes;
  }
}
