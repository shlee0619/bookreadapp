import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final String id;
  final String authorName;
  final String content;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.authorName,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, authorName, content, createdAt];
}

class Review extends Equatable {
  final String id;
  final String bookTitle;
  final String authorName;
  final String content;
  final double rating;
  final DateTime createdAt;
  final List<Comment> comments;

  const Review({
    required this.id,
    required this.bookTitle,
    required this.authorName,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.comments = const [],
  });

  Review copyWith({
    String? id,
    String? bookTitle,
    String? authorName,
    String? content,
    double? rating,
    DateTime? createdAt,
    List<Comment>? comments,
  }) {
    return Review(
      id: id ?? this.id,
      bookTitle: bookTitle ?? this.bookTitle,
      authorName: authorName ?? this.authorName,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }

  @override
  List<Object?> get props => [
    id,
    bookTitle,
    authorName,
    content,
    rating,
    createdAt,
    comments,
  ];
}
