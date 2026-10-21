import 'package:flutter/material.dart';

import '../models/event.dart';
import '../l10n/l10n.dart';

/// Colour and icon used to show each category in the UI.
extension CategoryStyle on EventCategory {
  Color get color => switch (this) {
    EventCategory.technology => const Color(0xFF2563EB),
    EventCategory.arts => const Color(0xFFDB2777),
    EventCategory.sports => const Color(0xFFEA580C),
  };

  IconData get icon => switch (this) {
    EventCategory.technology => Icons.memory_rounded,
    EventCategory.arts => Icons.palette_rounded,
    EventCategory.sports => Icons.sports_basketball_rounded,
  };
}

/// Rounded pill with the category icon and name.
class CategoryPill extends StatelessWidget {
  const CategoryPill({super.key, required this.category});

  final EventCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            category.label(context),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
