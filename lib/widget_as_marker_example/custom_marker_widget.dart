import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomMarkerWidget extends StatelessWidget {
  const CustomMarkerWidget({
    required this.imageBytes,
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  final Uint8List imageBytes;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.memory(
          imageBytes,
          height: 100,
          width: 50,
        ),
        const SizedBox(width: 10),
        Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),
                Text(description, style: const TextStyle(color: Colors.black, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
