import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomMarkerWidget extends StatelessWidget {
  const CustomMarkerWidget({
    required this.imageBytes,
    required this.title,
    required this.description,
    required this.notificationsNumber,
    required this.isTyping,
    Key? key,
  }) : super(key: key);

  final Uint8List imageBytes;
  final String title;
  final String description;
  final int notificationsNumber;
  final bool isTyping;

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
        Stack(
          children: [
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.only(top: 12, right: 12),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(description, style: const TextStyle(color: Colors.black, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            if (notificationsNumber > 0 && !isTyping)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  // transform: Matrix4.translationValues(10.0, -10.0, 0.0),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.all(Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Center(
                      child: Text(
                        notificationsNumber > 99 ? "99+" : notificationsNumber.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        // if (isTyping)
        //   Positioned(
        //     top: 0,
        //     right: 0,
        //     child: Container(
        //       height: 32,
        //       width: 80,
        //       transform: Matrix4.translationValues(10.0, -10.0, 0.0),
        //       decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(32))),
        //       child: ClipRRect(
        //         child: Image.asset("assets/gif/typing.gif"),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
