import 'package:equatable/equatable.dart';

enum NoteType { quote, reflection, question }

class ReadingNote extends Equatable {
  const ReadingNote({
    required this.id,
    required this.bookTitle,
    required this.page,
    required this.type,
    required this.content,
    required this.tags,
    required this.createdAt,
    this.isPublic = false,
  });

  final String id;
  final String bookTitle;
  final int page;
  final NoteType type;
  final String content;
  final List<String> tags;
  final DateTime createdAt;
  final bool isPublic;

  ReadingNote copyWith({
    String? content,
    List<String>? tags,
    bool? isPublic,
  }) {
    return ReadingNote(
      id: id,
      bookTitle: bookTitle,
      page: page,
      type: type,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props =>
      [id, bookTitle, page, type, content, tags, createdAt, isPublic];
}
