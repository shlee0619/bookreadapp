import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/reading_models.dart';

final readingTrackerProvider =
    StateNotifierProvider<ReadingTrackerNotifier, ReadingTrackerState>(
      (ref) => ReadingTrackerNotifier(),
    );

class ReadingTrackerNotifier extends StateNotifier<ReadingTrackerState> {
  ReadingTrackerNotifier()
    : super(
        ReadingTrackerState(
          currentBook: const ReadingBook(
            id: 'book-1',
            title: '미움받을 용기',
            author: '기시미 이치로, 고가 후미타케',
            totalPages: 324,
            currentPage: 172,
            coverAsset: 'assets/logo.png',
          ),
          sessions: const [],
          calendar: const {},
        ),
      ) {
    _seedSessions();
  }

  final _uuid = const Uuid();

  void _seedSessions() {
    final today = DateTime.now();
    final generatedSessions = List<ReadingSession>.generate(8, (index) {
      final date = today.subtract(Duration(days: index));
      final duration = Duration(minutes: 25 + (index * 5));
      final pages = 18 + index;
      return ReadingSession(
        id: _uuid.v4(),
        bookId: state.currentBook.id,
        date: date,
        duration: duration,
        pagesRead: pages,
        note: index.isEven ? '인상 깊은 문장을 발견했어요.' : null,
      );
    });

    _assignSessions(generatedSessions);
  }

  void logSession({
    required DateTime date,
    required Duration duration,
    required int pagesRead,
    String? note,
  }) {
    final session = ReadingSession(
      id: _uuid.v4(),
      bookId: state.currentBook.id,
      date: date,
      duration: duration,
      pagesRead: pagesRead,
      note: note,
    );

    final updatedSessions = List<ReadingSession>.from(state.sessions)
      ..add(session)
      ..sort((a, b) => b.date.compareTo(a.date));

    final updatedBook = state.currentBook.copyWith(
      currentPage: (state.currentBook.currentPage + pagesRead).clamp(
        0,
        state.currentBook.totalPages,
      ),
    );

    state = state.copyWith(
      currentBook: updatedBook,
      sessions: updatedSessions,
      calendar: _rebuildCalendar(updatedSessions),
    );
  }

  void updateCurrentPage(int page) {
    final constrainedPage = page.clamp(0, state.currentBook.totalPages);
    final updatedBook = state.currentBook.copyWith(
      currentPage: constrainedPage,
    );
    state = state.copyWith(currentBook: updatedBook);
  }

  void setBook(ReadingBook book) {
    state = state.copyWith(currentBook: book, sessions: [], calendar: {});
  }

  void _assignSessions(List<ReadingSession> sessions) {
    sessions.sort((a, b) => b.date.compareTo(a.date));
    state = state.copyWith(
      sessions: sessions,
      calendar: _rebuildCalendar(sessions),
    );
  }

  Map<DateTime, ReadingCalendarDay> _rebuildCalendar(
    List<ReadingSession> sessions,
  ) {
    final grouped = <DateTime, List<ReadingSession>>{};
    for (final session in sessions) {
      final key = DateTime(
        session.date.year,
        session.date.month,
        session.date.day,
      );
      grouped.putIfAbsent(key, () => []).add(session);
    }

    return grouped.map((date, entries) {
      final totalMinutes = entries.fold<int>(
        0,
        (sum, entry) => sum + entry.duration.inMinutes,
      );
      final totalPages = entries.fold<int>(
        0,
        (sum, entry) => sum + entry.pagesRead,
      );
      return MapEntry(
        date,
        ReadingCalendarDay(
          date: date,
          totalMinutes: totalMinutes,
          totalPages: totalPages,
        ),
      );
    });
  }
}

final readingTimerProvider =
    StateNotifierProvider<ReadingTimerNotifier, ReadingTimerState>(
      (ref) => ReadingTimerNotifier(),
    );

class ReadingTimerState {
  const ReadingTimerState({required this.isRunning, required this.elapsed});

  final bool isRunning;
  final Duration elapsed;
}

class ReadingTimerNotifier extends StateNotifier<ReadingTimerState> {
  ReadingTimerNotifier()
    : super(const ReadingTimerState(isRunning: false, elapsed: Duration.zero));

  Timer? _ticker;
  DateTime? _startedAt;

  void start() {
    if (state.isRunning) {
      return;
    }
    _startedAt = DateTime.now();
    state = const ReadingTimerState(isRunning: true, elapsed: Duration.zero);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt == null) {
        return;
      }
      final elapsed = DateTime.now().difference(_startedAt!);
      state = ReadingTimerState(isRunning: true, elapsed: elapsed);
    });
  }

  Duration stop() {
    _ticker?.cancel();
    _ticker = null;
    final elapsed = state.elapsed;
    state = ReadingTimerState(isRunning: false, elapsed: elapsed);
    return elapsed;
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _startedAt = null;
    state = const ReadingTimerState(isRunning: false, elapsed: Duration.zero);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
