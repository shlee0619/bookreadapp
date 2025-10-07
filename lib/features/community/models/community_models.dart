import 'package:equatable/equatable.dart';

enum CommunityActivityType { startedBook, loggedNote, milestone }

class CommunityActivity extends Equatable {
  const CommunityActivity({
    required this.id,
    required this.type,
    required this.userName,
    required this.timestamp,
    required this.headline,
    required this.body,
    this.bookTitle,
    this.clubName,
    this.notePreview,
    this.comments = 0,
    this.likes = 0,
    this.isLiked = false,
  });

  final String id;
  final CommunityActivityType type;
  final String userName;
  final DateTime timestamp;
  final String headline;
  final String body;
  final String? bookTitle;
  final String? clubName;
  final String? notePreview;
  final int comments;
  final int likes;
  final bool isLiked;

  CommunityActivity copyWith({
    int? comments,
    int? likes,
    bool? isLiked,
  }) {
    return CommunityActivity(
      id: id,
      type: type,
      userName: userName,
      timestamp: timestamp,
      headline: headline,
      body: body,
      bookTitle: bookTitle,
      clubName: clubName,
      notePreview: notePreview,
      comments: comments ?? this.comments,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        userName,
        timestamp,
        headline,
        body,
        bookTitle,
        clubName,
        notePreview,
        comments,
        likes,
        isLiked,
      ];
}

class ReadingClub extends Equatable {
  const ReadingClub({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    required this.currentBook,
    this.isPrivate = false,
  });

  final String id;
  final String name;
  final String description;
  final int memberCount;
  final String currentBook;
  final bool isPrivate;

  ReadingClub copyWith({
    String? description,
    int? memberCount,
    String? currentBook,
    bool? isPrivate,
  }) {
    return ReadingClub(
      id: id,
      name: name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      currentBook: currentBook ?? this.currentBook,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, memberCount, currentBook, isPrivate];
}
