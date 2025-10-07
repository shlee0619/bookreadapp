import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/reading_note.dart';

final noteListProvider =
    StateNotifierProvider<NoteListNotifier, List<ReadingNote>>(
  (ref) => NoteListNotifier(),
);

final noteTypeFilterProvider = StateProvider<NoteType?>((ref) => null);
final noteTagFilterProvider = StateProvider<String?>((ref) => null);
final noteSearchProvider = StateProvider<String>((ref) => '');

class NoteListNotifier extends StateNotifier<List<ReadingNote>> {
  NoteListNotifier() : super(_seedNotes());

  static List<ReadingNote> _seedNotes() {
    final uuid = const Uuid();
    final now = DateTime.now();
    return [
      ReadingNote(
        id: uuid.v4(),
        bookTitle: 'Atomic Habits',
        page: 42,
        type: NoteType.quote,
        content:
            '"You do not rise to the level of your goals. You fall to the level of your systems."',
        tags: const ['habit', 'motivation'],
        createdAt: now.subtract(const Duration(hours: 6)),
        isPublic: true,
      ),
      ReadingNote(
        id: uuid.v4(),
        bookTitle: 'Ikigai',
        page: 88,
        type: NoteType.reflection,
        content:
            'The idea of a small, daily joy resonates with how I want to slow my mornings.',
        tags: const ['lifestyle', 'wellbeing'],
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ReadingNote(
        id: uuid.v4(),
        bookTitle: 'Project Hail Mary',
        page: 215,
        type: NoteType.question,
        content:
            'Could Grace have evolved to cooperate with other species or is this a unique case?',
        tags: const ['sci-fi', 'discussion'],
        createdAt: now.subtract(const Duration(days: 2, hours: 4)),
        isPublic: true,
      ),
    ];
  }

  final _uuid = const Uuid();

  void addNote({
    required String bookTitle,
    required int page,
    required NoteType type,
    required String content,
    required List<String> tags,
    required bool isPublic,
  }) {
    final note = ReadingNote(
      id: _uuid.v4(),
      bookTitle: bookTitle,
      page: page,
      type: type,
      content: content,
      tags: tags,
      createdAt: DateTime.now(),
      isPublic: isPublic,
    );
    state = [note, ...state];
  }

  void toggleShare(String id) {
    state = state
        .map(
          (note) => note.id == id
              ? note.copyWith(isPublic: !note.isPublic)
              : note,
        )
        .toList();
  }
}

final noteTagsProvider = Provider<List<String>>((ref) {
  final notes = ref.watch(noteListProvider);
  final tags = <String>{};
  for (final note in notes) {
    tags.addAll(note.tags);
  }
  final sorted = tags.toList()..sort();
  return sorted;
});
