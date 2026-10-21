import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sample_events.dart';
import '../l10n/l10n.dart';
import '../models/event.dart';
import '../theme/app_theme.dart';
import '../theme/category_style.dart';
import '../utils/date_format.dart';

/// Form for creating a new event. Pops with the created [Event], or with
/// null when the user goes back without saving.
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _venueController = TextEditingController();
  final _capacityController = TextEditingController(text: '30');
  final _descriptionController = TextEditingController();
  final _imageScrollController = ScrollController();

  EventCategory _category = EventCategory.technology;
  String _imagePath = defaultImageFor[EventCategory.technology]!;
  bool _imageChosenByUser = false;

  // Tomorrow at 18:00 by default, so a quick event needs no date picking.
  DateTime _dateTime = () {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 18);
  }();

  @override
  void dispose() {
    _titleController.dispose();
    _venueController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _imageScrollController.dispose();
    super.dispose();
  }

  void _selectCategory(EventCategory category) {
    setState(() {
      _category = category;
      if (!_imageChosenByUser) _imagePath = defaultImageFor[category]!;
    });
    // Bring the (possibly new) selected image into view.
    const itemExtent = 126.0 + 10.0; // thumbnail + border, plus separator
    final position = _imageScrollController.position;
    _imageScrollController.animateTo(
      (eventImages.indexOf(_imagePath) * itemExtent).clamp(
        0.0,
        position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime.isBefore(now) ? now : _dateTime,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (!_dateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.pastDate)));
      return;
    }
    final capacity = int.parse(_capacityController.text.trim());
    final event = Event(
      id: 'u${DateTime.now().microsecondsSinceEpoch}',
      title: LocalizedText.same(_titleController.text.trim()),
      category: _category,
      dateTime: _dateTime,
      venue: LocalizedText.same(_venueController.text.trim()),
      description: LocalizedText.same(_descriptionController.text.trim()),
      imagePath: _imagePath,
      capacity: capacity,
      availablePlaces: capacity,
      isCustom: true,
    );
    Navigator.of(context).pop(event);
  }

  String? _required(String? value) => (value == null || value.trim().isEmpty)
      ? context.l10n.requiredField
      : null;

  String? _validateCapacity(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    return (n == null || n < 1 || n > 1000)
        ? context.l10n.invalidCapacity
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = context.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newEvent)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _SectionLabel(l10n.fieldImage),
            SizedBox(
              height: 92,
              child: ListView.separated(
                controller: _imageScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: eventImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final path = eventImages[index];
                  final selected = path == _imagePath;
                  return GestureDetector(
                    key: ValueKey(path),
                    onTap: () => setState(() {
                      _imagePath = path;
                      _imageChosenByUser = true;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? _category.color
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(path, width: 120, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.fieldTitle,
                prefixIcon: const Icon(Icons.title_rounded),
              ),
              validator: _required,
            ),
            const SizedBox(height: 20),
            _SectionLabel(l10n.fieldCategory),
            Wrap(
              spacing: 8,
              children: [
                for (final category in EventCategory.values)
                  ChoiceChip(
                    avatar: Icon(
                      category.icon,
                      size: 18,
                      color: category == _category
                          ? Colors.white
                          : category.color,
                    ),
                    label: Text(category.label(context)),
                    selected: category == _category,
                    showCheckmark: false,
                    selectedColor: category.color,
                    labelStyle: TextStyle(
                      color: category == _category
                          ? Colors.white
                          : category.color,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: const StadiumBorder(),
                    onSelected: (_) => _selectCategory(category),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PickerTile(
                    icon: Icons.calendar_month_rounded,
                    label: l10n.dateLabel,
                    value: formatEventDate(_dateTime, lang),
                    color: _category.color,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerTile(
                    icon: Icons.schedule_rounded,
                    label: l10n.timeLabel,
                    value: formatEventTime(_dateTime, lang),
                    color: _category.color,
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _venueController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.venueLabel,
                prefixIcon: const Icon(Icons.place_rounded),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.fieldCapacity,
                prefixIcon: const Icon(Icons.event_seat_rounded),
              ),
              validator: _validateCapacity,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.fieldDescription,
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: _save,
            style: FilledButton.styleFrom(backgroundColor: _category.color),
            icon: const Icon(Icons.check_rounded),
            label: Text(l10n.saveEvent),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

/// Tappable tile that shows the chosen date or time.
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
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
        ),
      ),
    );
  }
}
