import 'package:flutter/material.dart';

import '../models/event.dart';
import '../l10n/l10n.dart';

/// Full-screen view of an event image. Pinch to zoom; Back returns to details.
class ImageViewerScreen extends StatelessWidget {
  const ImageViewerScreen({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(event.title.of(context), overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 4,
          child: Hero(
            tag: 'event-image-${event.id}',
            child: Image.asset(event.imagePath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
