import 'package:flutter/material.dart';

import '../models/event.dart';
import '../theme/category_style.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Rounded title search field shown in the header.
class EventSearchField extends StatelessWidget {
  const EventSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(18),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.l10n.searchHint,
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: context.l10n.clearSearch,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                ),
          filled: true,
          fillColor: cardColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// "All" plus one chip per category, each in its category colour.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final EventCategory? selectedCategory; // null means "All"
  final ValueChanged<EventCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    // Fixed violet so white text stays readable in dark mode too.
    const primary = AppColors.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _chip(
            context,
            context.l10n.categoryAll,
            Icons.apps_rounded,
            primary,
            selectedCategory == null,
            () => onSelected(null),
          ),
          for (final category in EventCategory.values)
            _chip(
              context,
              category.label(context),
              category.icon,
              category.color,
              selectedCategory == category,
              () => onSelected(category),
            ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    bool selected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18, color: selected ? Colors.white : color),
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: color,
        backgroundColor: cardColor(context),
        side: BorderSide(
          color: selected ? color : color.withValues(alpha: 0.3),
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : color,
          fontWeight: FontWeight.w600,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
