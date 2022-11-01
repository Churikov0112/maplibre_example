import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomToastWidget extends StatelessWidget {
  const CustomToastWidget({
    required this.imageBytes,
    required this.senderName,
    required this.message,
    Key? key,
  }) : super(key: key);

  final Uint8List imageBytes;
  final String senderName;
  final String message;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      width: mediaQuery.size.width,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(
                imageBytes,
                height: 100,
                width: 50,
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(senderName,
                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                    Text(message, style: const TextStyle(color: Colors.black, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
