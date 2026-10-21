import 'package:flutter/material.dart';

import '../models/event.dart';
import '../theme/category_style.dart';
import '../utils/date_format.dart';
import '../widgets/availability_label.dart';
import '../widgets/capacity_bar.dart';
import '../widgets/info_row.dart';
import 'image_viewer_screen.dart';
import '../l10n/l10n.dart';
import '../theme/app_theme.dart';

/// Shows all information about one event, with favorite and participation
/// controls.
///
/// The app state lives in HomeScreen. This screen reads it through
/// [isFavorite]/[isJoined] and changes it through the callbacks, then calls
/// its own setState so both this screen and the list behind it stay in sync.
class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.isFavorite,
    required this.isJoined,
    required this.onToggleFavorite,
    required this.onJoin,
    required this.onCancel,
    this.onDelete,
  });

  final Event event;
  final bool Function() isFavorite;
  final bool Function() isJoined;
  final VoidCallback onToggleFavorite;

  /// Joins the event; returns false if it could not be joined.
  final bool Function() onJoin;
  final VoidCallback onCancel;

  /// Set only for events the user created; shows a delete button.
  final VoidCallback? onDelete;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  Event get _event => widget.event;

  void _toggleFavorite() {
    widget.onToggleFavorite();
    setState(() {});
  }

  void _openImage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ImageViewerScreen(event: _event)));
  }

  /// Shows a Yes/No dialog with the event title, date/time and venue.
  /// Returns true only when the user taps Yes.
  Future<bool> _confirm(String question, IconData icon) async {
    final color = _event.category.color;
    final lang = context.languageCode;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(icon, color: color, size: 36),
        title: Text(question),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _event.title.of(context),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              InfoRow(
                icon: Icons.schedule_rounded,
                text: formatEventDateTime(_event.dateTime, lang),
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.place_rounded,
                text: _event.venue.of(context),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.no),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(88, 44),
              backgroundColor: color,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );
    // Dismissing the dialog (tap outside / Back) returns null: no change.
    return result ?? false;
  }

  void _showMessage(String message, IconData icon) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  Future<void> _join() async {
    if (!await _confirm(
          context.l10n.joinQuestion,
          Icons.event_available_rounded,
        ) ||
        !mounted) {
      return;
    }
    final joined = widget.onJoin();
    setState(() {});
    final title = _event.title.of(context);
    _showMessage(
      joined
          ? context.l10n.joinedMessage(title)
          : context.l10n.fullMessage(title),
      joined ? Icons.check_circle_rounded : Icons.error_rounded,
    );
  }

  Future<void> _delete() async {
    if (!await _confirm(
          context.l10n.deleteQuestion,
          Icons.delete_outline_rounded,
        ) ||
        !mounted) {
      return;
    }
    final title = _event.title.of(context);
    widget.onDelete!();
    _showMessage(context.l10n.eventDeleted(title), Icons.delete_rounded);
    Navigator.of(context).pop();
  }

  Future<void> _cancel() async {
    if (!await _confirm(
          context.l10n.cancelQuestion,
          Icons.event_busy_rounded,
        ) ||
        !mounted) {
      return;
    }
    widget.onCancel();
    setState(() {});
    _showMessage(
      context.l10n.cancelledMessage(_event.title.of(context)),
      Icons.info_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isJoined = widget.isJoined();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildImageAppBar(),
          SliverToBoxAdapter(child: _buildContent(isJoined)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: _buildParticipationButton(isJoined),
        ),
      ),
    );
  }

  Widget _buildImageAppBar() {
    final isFavorite = widget.isFavorite();
    return SliverAppBar(
      pinned: true,
      expandedHeight: 300,
      backgroundColor: _event.category.color,
      foregroundColor: Colors.white,
      title: Text(context.l10n.eventDetails),
      actions: [
        if (widget.onDelete != null)
          IconButton(
            tooltip: context.l10n.deleteEvent,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _delete,
          ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
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
              onPressed: _toggleFavorite,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onDoubleTap: _openImage,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'event-image-${_event.id}',
                child: Image.asset(_event.imagePath, fit: BoxFit.cover),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.3, 0.7, 1],
                    colors: [
                      Color(0x99000000),
                      Colors.transparent,
                      Colors.transparent,
                      Color(0x66000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.zoom_in_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.doubleTapToEnlarge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isJoined) {
    final theme = Theme.of(context);
    final color = _event.category.color;
    final l10n = context.l10n;
    final lang = context.languageCode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CategoryPill(category: _event.category),
              AvailabilityLabel(event: _event, isJoined: isJoined),
              if (_event.isCustom)
                Chip(
                  avatar: const Icon(Icons.person_rounded, size: 16),
                  label: Text(l10n.createdByYou),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _event.title.of(context),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          // IntrinsicHeight + stretch keeps both tiles the same height.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.calendar_month_rounded,
                    label: l10n.dateLabel,
                    value: formatEventDate(_event.dateTime, lang),
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.schedule_rounded,
                    label: l10n.timeLabel,
                    value: formatEventTime(_event.dateTime, lang),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.place_rounded,
            label: l10n.venueLabel,
            value: _event.venue.of(context),
            color: color,
          ),
          const SizedBox(height: 12),
          _buildCapacityCard(color),
          const SizedBox(height: 24),
          Text(
            l10n.aboutEvent,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _event.description.of(context).isEmpty
                ? l10n.noDescription
                : _event.description.of(context),
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(Color color) {
    final taken = _event.capacity - _event.availablePlaces;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_seat_rounded, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.availablePlaces(
                    _event.availablePlaces,
                    _event.capacity,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CapacityBar(event: _event, color: color, height: 10),
          const SizedBox(height: 8),
          Text(
            context.l10n.placesTaken(taken, _event.capacity),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipationButton(bool isJoined) {
    // A joined student can always cancel, even if they took the last place.
    if (isJoined) {
      return OutlinedButton.icon(
        onPressed: _cancel,
        icon: const Icon(Icons.event_busy_rounded),
        label: Text(context.l10n.cancelParticipation),
      );
    }
    if (_event.isFull) {
      return FilledButton(
        onPressed: null,
        child: Text(context.l10n.statusFull),
      );
    }
    return FilledButton.icon(
      onPressed: _join,
      style: FilledButton.styleFrom(backgroundColor: _event.category.color),
      icon: const Icon(Icons.event_available_rounded),
      label: Text(context.l10n.joinEvent),
    );
  }
}

/// Rounded tile with an icon, a small label and a value.
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
