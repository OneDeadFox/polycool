import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/groups_controller.dart';
import 'models/group.dart';

class GroupDetailScreen extends StatelessWidget {
  final CommunityGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GroupsController>();
    final joined = controller.isJoined(group.id);
    final posts = controller.postsFor(group.id);

    return Scaffold(
      appBar: AppBar(title: Text(group.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            group.tagline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(group.description),
          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Community note: Consent-first, safety-first. Share with care. Growth > judgment.',
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    await context.read<GroupsController>().toggleJoin(group.id);
                  },
                  child: Text(joined ? 'Leave' : 'Join'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final text = await _newPostDialog(context);
                    if (text == null) return;
                    await context.read<GroupsController>().addPost(
                          groupId: group.id,
                          text: text,
                        );
                  },
                  child: const Text('Post'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Text(
            'Recent posts',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),

          if (posts.isEmpty)
            Text(
              'No posts yet. Start something supportive.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...posts.map((p) => _PostCard(author: p.author, text: p.text)).toList(),
        ],
      ),
    );
  }

  Future<String?> _newPostDialog(BuildContext context) async {
    return showDialog<String?>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('New post'),
          content: TextField(
            controller: ctrl,
            maxLength: 400,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Share a question, a script, or a growth win…',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}

class _PostCard extends StatelessWidget {
  final String author;
  final String text;

  const _PostCard({required this.author, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(text),
          ],
        ),
      ),
    );
  }
}
