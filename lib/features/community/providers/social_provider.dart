import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/social_model.dart';

final socialProvider = StateNotifierProvider<SocialNotifier, List<Review>>((
  ref,
) {
  return SocialNotifier();
});

class SocialNotifier extends StateNotifier<List<Review>> {
  SocialNotifier() : super(_initialReviews);

  static final _uuid = Uuid();

  static final List<Review> _initialReviews = [
    Review(
      id: _uuid.v4(),
      bookTitle: 'The Great Gatsby',
      authorName: 'Alice',
      content: 'A classic that never gets old. The symbolism is profound.',
      rating: 5.0,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      comments: [
        Comment(
          id: _uuid.v4(),
          authorName: 'Bob',
          content: 'Totally agree! The green light scene is iconic.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    Review(
      id: _uuid.v4(),
      bookTitle: '1984',
      authorName: 'Charlie',
      content: 'Scary how relevant this book still is today.',
      rating: 4.5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      comments: [],
    ),
    Review(
      id: _uuid.v4(),
      bookTitle: 'Project Hail Mary',
      authorName: 'Dave',
      content: 'Amazing sci-fi! Rocky is the best character ever.',
      rating: 5.0,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      comments: [],
    ),
  ];

  void addReview(String bookTitle, String content, double rating) {
    final newReview = Review(
      id: _uuid.v4(),
      bookTitle: bookTitle,
      authorName: 'Me', // Simulated current user
      content: content,
      rating: rating,
      createdAt: DateTime.now(),
    );
    state = [newReview, ...state];
  }

  void addComment(String reviewId, String content) {
    state = [
      for (final review in state)
        if (review.id == reviewId)
          review.copyWith(
            comments: [
              ...review.comments,
              Comment(
                id: _uuid.v4(),
                authorName: 'Me',
                content: content,
                createdAt: DateTime.now(),
              ),
            ],
          )
        else
          review,
    ];
  }
}
