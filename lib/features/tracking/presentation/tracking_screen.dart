import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/reading_models.dart';
import '../providers/tracking_providers.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracker = ref.watch(readingTrackerProvider);
    final timer = ref.watch(readingTimerProvider);
    final trackerNotifier = ref.read(readingTrackerProvider.notifier);
    final timerNotifier = ref.read(readingTimerProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _CurrentBookCard(book: tracker.currentBook),
          _TimerCard(
            elapsed: timer.elapsed,
            isRunning: timer.isRunning,
            onStart: timerNotifier.start,
            onReset: timerNotifier.reset,
            onStop: () async {
              final elapsed = timerNotifier.stop();
              await _showLogReadingSheet(
                context,
                trackerNotifier: trackerNotifier,
                defaultDuration: elapsed,
              );
            },
            onManualLog: () async {
              await _showLogReadingSheet(
                context,
                trackerNotifier: trackerNotifier,
                defaultDuration: const Duration(minutes: 30),
              );
            },
          ),
          _WeeklySummaryCard(sessions: tracker.sessions),
          _CalendarCard(calendar: tracker.calendar),
          _RecentSessionsCard(sessions: tracker.sessions),
        ],
      ),
    );
  }
}

class _CurrentBookCard extends StatelessWidget {
  const _CurrentBookCard({required this.book});

  final ReadingBook book;

  @override
  Widget build(BuildContext context) {
    final progressPercent = (book.progress * 100).toStringAsFixed(1);
    final remainingPages = book.totalPages - book.currentPage;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(26),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: book.coverAsset != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            book.coverAsset!,
                            fit: BoxFit.cover,
                            height: 72,
                            width: 72,
                          ),
                        )
                      : Icon(
                          Icons.menu_book,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: book.progress,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$progressPercent% complete (${book.currentPage}/${book.totalPages} pages)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _StatChip(
                  icon: Icons.auto_stories,
                  label: 'Pages read',
                  value: '${book.currentPage} p',
                ),
                _StatChip(
                  icon: Icons.hourglass_bottom_outlined,
                  label: 'Pages left',
                  value: '$remainingPages p',
                ),
                _StatChip(
                  icon: Icons.flag_outlined,
                  label: 'ETA',
                  value: remainingPages <= 0
                      ? 'Finished'
                      : '${(remainingPages / 30).ceil()} days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.elapsed,
    required this.isRunning,
    required this.onStart,
    required this.onStop,
    required this.onReset,
    required this.onManualLog,
  });

  final Duration elapsed;
  final bool isRunning;
  final VoidCallback onStart;
  final Future<void> Function() onStop;
  final VoidCallback onReset;
  final Future<void> Function() onManualLog;

  String _format(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Reading timer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset timer',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _format(elapsed),
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isRunning ? onStop : onStart,
                    icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(isRunning ? 'Stop reading' : 'Start reading'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onManualLog,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Log manually'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.sessions});

  final List<ReadingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formatter = DateFormat('E');
    final last7Days = List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index));
      final totals = sessions.where((session) {
        return session.date.year == date.year &&
            session.date.month == date.month &&
            session.date.day == date.day;
      }).toList();
      final minutes = totals.fold<int>(
        0,
        (sum, session) => sum + session.duration.inMinutes,
      );
      final pages = totals.fold<int>(
        0,
        (sum, session) => sum + session.pagesRead,
      );
      return _WeeklyStat(date: date, minutes: minutes, pages: pages);
    });

    final totalMinutes =
        last7Days.fold<int>(0, (sum, entry) => sum + entry.minutes);
    final totalPages =
        last7Days.fold<int>(0, (sum, entry) => sum + entry.pages);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This week at a glance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(totalMinutes / 60).toStringAsFixed(1)} h',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total time',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalPages pages',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total pages',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= last7Days.length) {
                            return const SizedBox.shrink();
                          }
                          final label = formatter.format(last7Days[index].date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(label),
                          );
                        },
                        reservedSize: 36,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: last7Days
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.minutes.toDouble(),
                              width: 18,
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha(140),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarCard extends StatefulWidget {
  const _CalendarCard({required this.calendar});

  final Map<DateTime, ReadingCalendarDay> calendar;

  @override
  State<_CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<_CalendarCard> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.calendar;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                'Reading calendar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TableCalendar<ReadingCalendarDay>(
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) =>
                  _selectedDay != null && isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return _CalendarCell(
                    day: day,
                    entry: entries[_stripTime(day)],
                    isSelected: isSameDay(day, _selectedDay),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return _CalendarCell(
                    day: day,
                    entry: entries[_stripTime(day)],
                    isSelected: isSameDay(day, _selectedDay),
                    isToday: true,
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return _CalendarCell(
                    day: day,
                    entry: entries[_stripTime(day)],
                    isSelected: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedDay != null)
              _DaySummary(entry: entries[_stripTime(_selectedDay!)])
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    this.entry,
    this.isSelected = false,
    this.isToday = false,
  });

  final DateTime day;
  final ReadingCalendarDay? entry;
  final bool isSelected;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final intensity = entry?.intensity ?? 0;
    final color = intensity == 0
        ? Colors.grey.shade200
        : Color.lerp(
            Colors.green.shade200,
            Colors.green.shade700,
            (intensity / 180).clamp(0.0, 1.0),
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withAlpha(217)
            : color,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.4,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({this.entry});

  final ReadingCalendarDay? entry;

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          'No log for this day yet.',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMM d').format(entry!.date),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              _SummaryChip(
                icon: Icons.timer_outlined,
                label: '${entry!.totalMinutes} min',
              ),
              _SummaryChip(
                icon: Icons.auto_stories_outlined,
                label: '${entry!.totalPages} pages',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentSessionsCard extends StatelessWidget {
  const _RecentSessionsCard({required this.sessions});

  final List<ReadingSession> sessions;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d (E) • HH:mm');
    final recent = sessions.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent sessions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            for (final session in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 42,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withAlpha(153),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.menu_book, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatter.format(session.date),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.duration.inMinutes} min • ${session.pagesRead} pages',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          if (session.note != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              session.note!,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (recent.isEmpty)
              Text(
                'No reading session yet. Start logging!',
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _WeeklyStat {
  const _WeeklyStat({
    required this.date,
    required this.minutes,
    required this.pages,
  });

  final DateTime date;
  final int minutes;
  final int pages;
}

Future<void> _showLogReadingSheet(
  BuildContext context, {
  required ReadingTrackerNotifier trackerNotifier,
  required Duration defaultDuration,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _LogReadingSheet(
          trackerNotifier: trackerNotifier,
          defaultDuration: defaultDuration,
        ),
      );
    },
  );
}

class _LogReadingSheet extends StatefulWidget {
  const _LogReadingSheet({
    required this.trackerNotifier,
    required this.defaultDuration,
  });

  final ReadingTrackerNotifier trackerNotifier;
  final Duration defaultDuration;

  @override
  State<_LogReadingSheet> createState() => _LogReadingSheetState();
}

class _LogReadingSheetState extends State<_LogReadingSheet> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late int _selectedDurationMinutes;
  final TextEditingController _pagesController =
      TextEditingController(text: '20');
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final defaultMinutes = widget.defaultDuration.inMinutes;
    _selectedDate = DateTime.now();
    _selectedDurationMinutes = defaultMinutes == 0 ? 30 : defaultMinutes;
  }

  @override
  void dispose() {
    _pagesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 42,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add reading log',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Reading date'),
                subtitle: Text(DateFormat('y-MM-dd').format(_selectedDate)),
                onTap: () async {
                  final now = DateTime.now();
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 1),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedDate = selected;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Reading minutes',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                min: 10,
                max: 240,
                divisions: 46,
                label: '$_selectedDurationMinutes min',
                value: _selectedDurationMinutes.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _selectedDurationMinutes = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedDurationMinutes min',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDurationMinutes = 30;
                      });
                    },
                    child: const Text('Snap to 30 mins'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pages read',
                  suffixText: 'pages',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter at least one page.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Optional note',
                  hintText: 'Capture reflections or memorable quotes.',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final pages = int.parse(_pagesController.text);
                    widget.trackerNotifier.logSession(
                      date: DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        DateTime.now().hour,
                        DateTime.now().minute,
                      ),
                      duration: Duration(minutes: _selectedDurationMinutes),
                      pagesRead: pages,
                      note: _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save log'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

