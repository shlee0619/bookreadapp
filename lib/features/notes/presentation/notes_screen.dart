import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/reading_note.dart';
import '../providers/note_providers.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(noteListProvider);
    final selectedType = ref.watch(noteTypeFilterProvider);
    final selectedTag = ref.watch(noteTagFilterProvider);
    final searchQuery = ref.watch(noteSearchProvider);
    final tags = ref.watch(noteTagsProvider);

    final filtered = notes.where((note) {
      if (selectedType != null && note.type != selectedType) {
        return false;
      }
      if (selectedTag != null && !note.tags.contains(selectedTag)) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final haystack = '${note.bookTitle} ${note.content}'.toLowerCase();
        if (!haystack.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();

    final publicCount =
        notes.where((note) => note.isPublic).length;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotesHeader(
                totalNotes: notes.length,
                publicNotes: publicCount,
              ),
              const SizedBox(height: 16),
              _SearchField(
                initialValue: searchQuery,
                onChanged: (value) =>
                    ref.read(noteSearchProvider.notifier).state = value,
              ),
              const SizedBox(height: 16),
              _TypeFilterRow(
                selectedType: selectedType,
                onSelected: (type) =>
                    ref.read(noteTypeFilterProvider.notifier).state = type,
              ),
              const SizedBox(height: 12),
              _TagFilterRow(
                tags: tags,
                selectedTag: selectedTag,
                onSelected: (tag) =>
                    ref.read(noteTagFilterProvider.notifier).state = tag,
              ),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                _EmptyState(
                  onReset: () {
                    ref.read(noteSearchProvider.notifier).state = '';
                    ref.read(noteTypeFilterProvider.notifier).state = null;
                    ref.read(noteTagFilterProvider.notifier).state = null;
                  },
                )
              else
                _NotesList(
                  notes: filtered,
                  onToggleShare: (id) =>
                      ref.read(noteListProvider.notifier).toggleShare(id),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () async {
              await _showCreateNoteSheet(
                context,
                ref.read(noteListProvider.notifier),
              );
            },
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Add note'),
          ),
        ),
      ],
    );
  }
}

class _NotesHeader extends StatelessWidget {
  const _NotesHeader({
    required this.totalNotes,
    required this.publicNotes,
  });

  final int totalNotes;
  final int publicNotes;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total notes',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalNotes',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Notes captured across all books.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Shared to community',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$publicNotes',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visible to your club members.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search notes or books',
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                icon: const Icon(Icons.clear),
              ),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _TypeFilterRow extends StatelessWidget {
  const _TypeFilterRow({
    required this.selectedType,
    required this.onSelected,
  });

  final NoteType? selectedType;
  final ValueChanged<NoteType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All types'),
          selected: selectedType == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final type in NoteType.values)
          ChoiceChip(
            label: Text(noteTypeLabel(type)),
            selected: selectedType == type,
            selectedColor: noteTypeColor(context, type).withAlpha(38),
            onSelected: (_) => onSelected(type),
          ),
      ],
    );
  }
}

class _TagFilterRow extends StatelessWidget {
  const _TagFilterRow({
    required this.tags,
    required this.selectedTag,
    required this.onSelected,
  });

  final List<String> tags;
  final String? selectedTag;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: const Text('All tags'),
          selected: selectedTag == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final tag in tags)
          ChoiceChip(
            label: Text('#$tag'),
            selected: selectedTag == tag,
            onSelected: (selected) =>
                onSelected(selected ? tag : null),
          ),
      ],
    );
  }
}

class _NotesList extends StatelessWidget {
  const _NotesList({
    required this.notes,
    required this.onToggleShare,
  });

  final List<ReadingNote> notes;
  final void Function(String id) onToggleShare;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        return _NoteCard(
          note: note,
          onToggleShare: onToggleShare,
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onToggleShare,
  });

  final ReadingNote note;
  final void Function(String id) onToggleShare;

  @override
  Widget build(BuildContext context) {
    final typeColor = noteTypeColor(context, note.type);
    final dateLabel = DateFormat('y-MM-dd HH:mm').format(note.createdAt);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(41),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    noteTypeIcon(note.type),
                    color: typeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.bookTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Page ${note.page} • ${noteTypeLabel(note.type)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => onToggleShare(note.id),
                  icon: Icon(
                    note.isPublic ? Icons.public : Icons.lock_outline,
                  ),
                  tooltip: note.isPublic
                      ? 'Visible to community'
                      : 'Private note',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              note.content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in note.tags)
                    Chip(
                      label: Text('#$tag'),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No notes match the current filter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting the keyword, note type, or tag filters to see more notes.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showCreateNoteSheet(
  BuildContext context,
  NoteListNotifier notifier,
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
        child: _CreateNoteSheet(notifier: notifier),
      );
    },
  );
}

class _CreateNoteSheet extends StatefulWidget {
  const _CreateNoteSheet({required this.notifier});

  final NoteListNotifier notifier;

  @override
  State<_CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<_CreateNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bookController = TextEditingController();
  final TextEditingController _pageController = TextEditingController(text: '1');
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  bool _isPublic = true;
  NoteType _type = NoteType.quote;

  @override
  void dispose() {
    _bookController.dispose();
    _pageController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
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
                  'Add reading note',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bookController,
                  decoration: const InputDecoration(
                    labelText: 'Book title',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a book title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Page',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid page number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<NoteType>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Note type'),
                  items: NoteType.values
                      .map(
                        (type) => DropdownMenuItem<NoteType>(
                          value: type,
                          child: Text(noteTypeLabel(type)),
                        ),
                      )
                      .toList(),
                  onChanged: (type) {
                    if (type != null) {
                      setState(() {
                        _type = type;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contentController,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Summarise the idea, quote, or question.',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please capture the content of your note.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Separate tags with comma or space',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  title: const Text('Share with community'),
                  subtitle: const Text('Public notes appear in club feeds.'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      final page = int.parse(_pageController.text);
                      final tags = _parseTags(_tagsController.text);
                      widget.notifier.addNote(
                        bookTitle: _bookController.text.trim(),
                        page: page,
                        type: _type,
                        content: _contentController.text.trim(),
                        tags: tags,
                        isPublic: _isPublic,
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save note'),
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

String noteTypeLabel(NoteType type) {
  switch (type) {
    case NoteType.quote:
      return 'Quote';
    case NoteType.reflection:
      return 'Reflection';
    case NoteType.question:
      return 'Question';
  }
}

IconData noteTypeIcon(NoteType type) {
  switch (type) {
    case NoteType.quote:
      return Icons.format_quote;
    case NoteType.reflection:
      return Icons.lightbulb_outline;
    case NoteType.question:
      return Icons.help_outline;
  }
}

Color noteTypeColor(BuildContext context, NoteType type) {
  final scheme = Theme.of(context).colorScheme;
  switch (type) {
    case NoteType.quote:
      return scheme.primary;
    case NoteType.reflection:
      return Colors.teal;
    case NoteType.question:
      return Colors.deepPurple;
  }
}

List<String> _parseTags(String raw) {
  return raw
      .split(RegExp(r'[ ,]+'))
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList();
}

