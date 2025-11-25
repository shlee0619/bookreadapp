import 'package:equatable/equatable.dart';

class ReadingBook extends Equatable {
  const ReadingBook({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    required this.currentPage,
    this.coverAsset,
    this.coverUrl,
  });

  final String id;
  final String title;
  final String author;
  final int totalPages;
  final int currentPage;
  final String? coverAsset;
  final String? coverUrl;

  double get progress =>
      totalPages == 0 ? 0 : (currentPage / totalPages).clamp(0, 1);

  ReadingBook copyWith({int? currentPage, String? coverUrl}) {
    return ReadingBook(
      id: id,
      title: title,
      author: author,
      totalPages: totalPages,
      currentPage: currentPage ?? this.currentPage,
      coverAsset: coverAsset,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    author,
    totalPages,
    currentPage,
    coverAsset,
    coverUrl,
  ];
}

class ReadingSession extends Equatable {
  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.date,
    required this.duration,
    required this.pagesRead,
    this.note,
  });

  final String id;
  final String bookId;
  final DateTime date;
  final Duration duration;
  final int pagesRead;
  final String? note;

  double get pagesPerHour {
    final hours = duration.inMinutes / 60;
    if (hours == 0) {
      return pagesRead.toDouble();
    }
    return pagesRead / hours;
  }

  @override
  List<Object?> get props => [id, bookId, date, duration, pagesRead, note];
}

class ReadingCalendarDay extends Equatable {
  const ReadingCalendarDay({
    required this.date,
    required this.totalMinutes,
    required this.totalPages,
  });

  final DateTime date;
  final int totalMinutes;
  final int totalPages;

  int get intensity => totalMinutes.clamp(0, 180);

  @override
  List<Object?> get props => [date, totalMinutes, totalPages];
}

class ReadingTrackerState extends Equatable {
  const ReadingTrackerState({
    required this.currentBook,
    required this.sessions,
    required this.calendar,
  });

  final ReadingBook currentBook;
  final List<ReadingSession> sessions;
  final Map<DateTime, ReadingCalendarDay> calendar;

  ReadingTrackerState copyWith({
    ReadingBook? currentBook,
    List<ReadingSession>? sessions,
    Map<DateTime, ReadingCalendarDay>? calendar,
  }) {
    return ReadingTrackerState(
      currentBook: currentBook ?? this.currentBook,
      sessions: sessions ?? this.sessions,
      calendar: calendar ?? this.calendar,
    );
  }

  @override
  List<Object?> get props => [currentBook, sessions, calendar];
}
