import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/community_models.dart';
import '../providers/community_providers.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(communityFeedProvider);
    final clubs = ref.watch(readingClubsProvider);
    final tags = ref.watch(trendingTagsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CommunitySummary(
            totalClubs: clubs.length,
            onCreateClub: () async {
              await _showCreateClubSheet(
                context,
                ref.read(readingClubsProvider.notifier),
              );
            },
          ),
          const SizedBox(height: 16),
          _TrendingTags(tags: tags),
          const SizedBox(height: 16),
          _ClubList(
            clubs: clubs,
            onCreateClub: () async {
              await _showCreateClubSheet(
                context,
                ref.read(readingClubsProvider.notifier),
              );
            },
          ),
          const SizedBox(height: 16),
          _ActivityFeed(
            activities: activities,
            onToggleLike: (id) =>
                ref.read(communityFeedProvider.notifier).toggleLike(id),
          ),
        ],
      ),
    );
  }
}

class _CommunitySummary extends StatelessWidget {
  const _CommunitySummary({
    required this.totalClubs,
    required this.onCreateClub,
  });

  final int totalClubs;
  final Future<void> Function() onCreateClub;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(31),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.groups,
                    color: Theme.of(context).colorScheme.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Booklog community',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join $totalClubs+ reader clubs or start your own reading sprint.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCreateClub,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create a club'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingTags extends StatelessWidget {
  const _TrendingTags({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending hashtags',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in tags)
              ActionChip(
                label: Text('#$tag'),
                onPressed: () {},
              ),
          ],
        ),
      ],
    );
  }
}

class _ClubList extends StatelessWidget {
  const _ClubList({
    required this.clubs,
    required this.onCreateClub,
  });

  final List<ReadingClub> clubs;
  final Future<void> Function() onCreateClub;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active clubs',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: onCreateClub,
              child: const Text('Start a club'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (clubs.isEmpty)
          Text(
            'No clubs yet. Create one and invite your reading buddies!',
            style: TextStyle(color: Colors.grey.shade600),
          )
        else
          Column(
            children: [
              for (final club in clubs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                club.isPrivate
                                    ? Icons.lock_outlined
                                    : Icons.public,
                                size: 18,
                                color: club.isPrivate
                                    ? Colors.orange.shade400
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  club.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              FilledButton.tonalIcon(
                                onPressed: () {},
                                icon: const Icon(Icons.group_add),
                                label: const Text('Join'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            club.description,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.people_outline, size: 18),
                                  const SizedBox(width: 4),
                                  Text('${club.memberCount} members'),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.menu_book_outlined, size: 18),
                                  const SizedBox(width: 4),
                                  Text('Now reading ${club.currentBook}'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({
    required this.activities,
    required this.onToggleLike,
  });

  final List<CommunityActivity> activities;
  final void Function(String id) onToggleLike;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Community feed',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (final activity in activities)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityCard(
              activity: activity,
              onToggleLike: onToggleLike,
            ),
          ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.onToggleLike,
  });

  final CommunityActivity activity;
  final void Function(String id) onToggleLike;

  @override
  Widget build(BuildContext context) {
    final initials = activity.userName.isNotEmpty
        ? activity.userName.trim()[0].toUpperCase()
        : '?';
    final timeLabel = _timeAgo(activity.timestamp);
    final accent = _activityColor(activity.type, context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: accent.withAlpha(38),
                  foregroundColor: accent,
                  child: Text(initials),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: activity.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(text: activity.headline),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_horiz),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              activity.body,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (activity.notePreview != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  activity.notePreview!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            if (activity.bookTitle != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.menu_book_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(activity.bookTitle!),
                ],
              ),
            ],
            if (activity.clubName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.groups_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(activity.clubName!),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _ActivityButton(
                  icon: activity.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: activity.isLiked
                      ? Colors.redAccent
                      : Colors.grey.shade700,
                  label: '${activity.likes} likes',
                  onPressed: () => onToggleLike(activity.id),
                ),
                const SizedBox(width: 12),
                _ActivityButton(
                  icon: Icons.chat_bubble_outline,
                  label: '${activity.comments} comments',
                  onPressed: () {},
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, HH:mm').format(activity.timestamp),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
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

class _ActivityButton extends StatelessWidget {
  const _ActivityButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(color: color ?? Colors.grey.shade700),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}

Future<void> _showCreateClubSheet(
  BuildContext context,
  ReadingClubNotifier notifier,
) async {
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
        child: _CreateClubSheet(notifier: notifier),
      );
    },
  );
}

class _CreateClubSheet extends StatefulWidget {
  const _CreateClubSheet({required this.notifier});

  final ReadingClubNotifier notifier;

  @override
  State<_CreateClubSheet> createState() => _CreateClubSheetState();
}

class _CreateClubSheetState extends State<_CreateClubSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isPrivate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bookController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  'Create a reading club',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Club name',
                    hintText: 'e.g. Lunch Break Non-fiction',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please choose a club name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bookController,
                  decoration: const InputDecoration(
                    labelText: 'Current book or theme',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Club description',
                    hintText: 'Share the rhythm, goals, or vibe of the group.',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                  title: const Text('Private club'),
                  subtitle: const Text('Only invited members can see posts.'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      widget.notifier.addClub(
                        name: _nameController.text.trim(),
                        description: _descriptionController.text.trim(),
                        isPrivate: _isPrivate,
                        currentBook: _bookController.text.trim().isEmpty
                            ? 'TBD'
                            : _bookController.text.trim(),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Create club'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Color _activityColor(
  CommunityActivityType type,
  BuildContext context,
) {
  final scheme = Theme.of(context).colorScheme;
  switch (type) {
    case CommunityActivityType.startedBook:
      return scheme.primary;
    case CommunityActivityType.loggedNote:
      return Colors.green;
    case CommunityActivityType.milestone:
      return Colors.deepOrange;
  }
}

String _timeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final diff = now.difference(timestamp);
  if (diff.inMinutes < 1) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} d ago';
  }
  return DateFormat('y-MM-dd').format(timestamp);
}

