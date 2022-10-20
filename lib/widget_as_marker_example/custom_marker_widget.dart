import 'package:flutter/material.dart';

class CustomMarkerWidget extends StatelessWidget {
  const CustomMarkerWidget({
    required this.title,
    required this.description,
    Key? key,
  }) : super(key: key);

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.place),
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
