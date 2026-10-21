import 'package:flutter/material.dart';

import '../models/event.dart';
import '../theme/category_style.dart';
import '../utils/date_format.dart';
import 'availability_label.dart';
import 'capacity_bar.dart';
import 'info_row.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Reusable card for one event, used by Explore, Favorites and My Events.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.isFavorite,
    required this.isJoined,
    required this.onFavoriteToggle,
    this.onOpenDetails,
  });

  final Event event;
  final bool isFavorite;
  final bool isJoined;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final color = event.category.color;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpenDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageHeader(context),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InfoRow(
                      icon: Icons.schedule_rounded,
                      text: formatEventDateTime(
                        event.dateTime,
                        context.languageCode,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InfoRow(
                      icon: Icons.place_rounded,
                      text: event.venue.of(context),
                    ),
                    const SizedBox(height: 14),
                    CapacityBar(event: event, color: color),
                    const SizedBox(height: 10),
                    // Wrap instead of Row so narrow screens never overflow;
                    // full width so spaceBetween pushes Details to the right.
                    SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 8,
                        children: [
                          AvailabilityLabel(event: event, isJoined: isJoined),
                          FilledButton.tonalIcon(
                            onPressed: onOpenDetails,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 40),
                              backgroundColor: color.withValues(alpha: 0.12),
                              foregroundColor: color,
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            iconAlignment: IconAlignment.end,
                            label: Text(context.l10n.details),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(event.imagePath, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.35, 1],
                colors: [Colors.transparent, Color(0xCC000000)],
              ),
            ),
          ),
          Positioned(left: 14, top: 14, child: _DateTile(event: event)),
          Positioned(
            right: 10,
            top: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                tooltip: isFavorite
                    ? context.l10n.removeFromFavorites
                    : context.l10n.addToFavorites,
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: Colors.redAccent,
                ),
                onPressed: onFavoriteToggle,
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryPill(category: event.category),
                const SizedBox(height: 6),
                Text(
                  event.title.of(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small calendar tile with the day and month.
class _DateTile extends StatelessWidget {
  const _DateTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            '${event.dateTime.day}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: Colors.black87,
            ),
          ),
          Text(
            formatMonthShort(event.dateTime, context.languageCode),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: event.category.color,
            ),
          ),
        ],
      ),
    );
  }
}
