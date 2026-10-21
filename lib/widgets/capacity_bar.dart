import 'package:flutter/material.dart';

import '../models/event.dart';

/// Rounded progress bar showing how much of the capacity is taken.
class CapacityBar extends StatelessWidget {
  const CapacityBar({
    super.key,
    required this.event,
    required this.color,
    this.height = 8,
  });

  final Event event;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final taken = event.capacity - event.availablePlaces;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: taken / event.capacity,
        minHeight: height,
        color: event.isFull ? Theme.of(context).colorScheme.error : color,
        backgroundColor: color.withValues(alpha: 0.15),
      ),
    );
  }
}
