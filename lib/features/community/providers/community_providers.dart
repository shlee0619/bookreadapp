import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/community_models.dart';

final communityFeedProvider =
    StateNotifierProvider<CommunityFeedNotifier, List<CommunityActivity>>(
  (ref) => CommunityFeedNotifier(),
);

final readingClubsProvider =
    StateNotifierProvider<ReadingClubNotifier, List<ReadingClub>>(
  (ref) => ReadingClubNotifier(),
);

final trendingTagsProvider = Provider<List<String>>(
  (ref) => const [
    '30min-challenge',
    'mindfulness',
    'classic-literature',
    'deep-work',
    'science-fiction',
  ],
);

class CommunityFeedNotifier extends StateNotifier<List<CommunityActivity>> {
  CommunityFeedNotifier() : super(_seedActivities());

  static List<CommunityActivity> _seedActivities() {
    final now = DateTime.now();
    final uuid = const Uuid();
    return [
      CommunityActivity(
        id: uuid.v4(),
        type: CommunityActivityType.startedBook,
        userName: 'Hana Kim',
        timestamp: now.subtract(const Duration(minutes: 45)),
        headline: 'started reading "Tomorrow, and Tomorrow, and Tomorrow"',
        body: 'Kicked off a co-reading sprint for July. Who wants to join?',
        bookTitle: 'Tomorrow, and Tomorrow, and Tomorrow',
        likes: 12,
        comments: 4,
      ),
      CommunityActivity(
        id: uuid.v4(),
        type: CommunityActivityType.loggedNote,
        userName: 'Noah Park',
        timestamp: now.subtract(const Duration(hours: 2)),
        headline: 'shared a note from "Thinking, Fast and Slow"',
        body:
            'System 1 is great when you need speed, but I realised I rely on it even when accuracy matters.',
        notePreview:
            '"A reliable way to make people believe in falsehoods is frequent repetition."',
        likes: 18,
        comments: 6,
      ),
      CommunityActivity(
        id: uuid.v4(),
        type: CommunityActivityType.milestone,
        userName: 'Booklog Club',
        timestamp: now.subtract(const Duration(hours: 6)),
        headline: 'reached a collective 1,000 pages this month!',
        body:
            'Amazing consistency from everyone in the Morning Deep Work circle.',
        clubName: 'Morning Deep Work',
        likes: 32,
        comments: 9,
      ),
    ];
  }

  void toggleLike(String id) {
    state = state
        .map(
          (activity) => activity.id == id
              ? activity.copyWith(
                  isLiked: !activity.isLiked,
                  likes: activity.isLiked
                      ? activity.likes - 1
                      : activity.likes + 1,
                )
              : activity,
        )
        .toList();
  }

  void addActivity(CommunityActivity activity) {
    state = [activity, ...state];
  }
}

class ReadingClubNotifier extends StateNotifier<List<ReadingClub>> {
  ReadingClubNotifier() : super(_seedClubs());

  static List<ReadingClub> _seedClubs() {
    final uuid = const Uuid();
    return [
      ReadingClub(
        id: uuid.v4(),
        name: 'Morning Deep Work',
        description: 'Read 25 minutes before 8AM. Focus on non-fiction.',
        memberCount: 28,
        currentBook: 'Deep Work',
      ),
      ReadingClub(
        id: uuid.v4(),
        name: 'Speculative Saturdays',
        description: 'Weekly sci-fi picks and spoiler-friendly chats.',
        memberCount: 19,
        currentBook: 'The Three-Body Problem',
        isPrivate: true,
      ),
      ReadingClub(
        id: uuid.v4(),
        name: 'Slow Living Shelf',
        description: 'Memoirs and lifestyle essays to unwind with.',
        memberCount: 34,
        currentBook: 'The Comfort Book',
      ),
    ];
  }

  final _uuid = const Uuid();

  void addClub({
    required String name,
    required String description,
    required bool isPrivate,
    required String currentBook,
  }) {
    final club = ReadingClub(
      id: _uuid.v4(),
      name: name,
      description: description,
      memberCount: 1,
      currentBook: currentBook,
      isPrivate: isPrivate,
    );
    state = [club, ...state];
  }
}
