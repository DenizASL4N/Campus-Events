import 'package:flutter/material.dart';

import '../models/event.dart';
import '../l10n/l10n.dart';

/// Small coloured badge showing whether an event is joined, full or how many
/// places are left. Used on cards and on the details screen.
class AvailabilityLabel extends StatelessWidget {
  const AvailabilityLabel({
    super.key,
    required this.event,
    required this.isJoined,
  });

  final Event event;
  final bool isJoined;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final (
      String text,
      IconData icon,
      Color background,
      Color foreground,
    ) = switch (event.availablePlaces) {
      _ when isJoined => (
        context.l10n.statusJoined,
        Icons.check_circle,
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      0 => (
        context.l10n.statusFull,
        Icons.block,
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      1 => (
        context.l10n.statusOnePlaceLeft,
        Icons.warning_amber,
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      final n => (
        context.l10n.statusPlacesLeft(n),
        Icons.event_seat,
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
