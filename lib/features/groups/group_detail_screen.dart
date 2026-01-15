import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/groups_controller.dart';
import 'models/group.dart';
import 'models/group_post.dart';

// Needed for username + anonymous toggle
import 'package:polycool/features/community/controllers/community_controller.dart';

// Post detail screen
import 'post_detail_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final CommunityGroup group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  String _postQuery = '';

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupsController>();

    // Latest group (rules may be edited)
    final group = groups.groups.firstWhere((g) => g.id == widget.group.id);
    final joined = groups.isJoined(group.id);

    final posts = groups.postsFor(group.id);
    final q = _postQuery.trim().toLowerCase();
    final filteredPosts = q.isEmpty
        ? posts
        : posts
            .where(
              (p) =>
                  p.title.toLowerCase().contains(q) ||
                  p.text.toLowerCase().contains(q),
            )
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(group.name, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _BannerHeader(group: group),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              group.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: _RulesSection(
              group: group,
              onEdit: () => _editRules(context, group),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
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
                    onPressed: joined
                        ? () async {
                            final draft = await _newPostDialog(context);
                            if (draft == null) return;

                            final (title, body) = draft;
                            if (title.trim().isEmpty || body.trim().isEmpty) return;

                            final community = context.read<CommunityController>();
                            final username = (community.username ?? 'me').trim();
                            final postAsAnonymous = community.anonymousBrowsing;

                            await context.read<GroupsController>().addPost(
                                  groupId: group.id,
                                  title: title,
                                  body: body,
                                  postAsAnonymous: postAsAnonymous,
                                  username: username,
                                );
                          }
                        : null,
                    child: const Text('Post'),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search conversations',
              ),
              onChanged: (v) => setState(() => _postQuery = v),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Text(
              'Posts',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),

          if (filteredPosts.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Text(
                'No posts yet. Start something supportive.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...filteredPosts.map((p) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _PostCard(
                  post: p,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PostDetailScreen(post: p),
                      ),
                    );
                  },
                ),
              );
            }),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _editRules(BuildContext context, CommunityGroup group) async {
    final updated = await showDialog<String?>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: group.rulesText);
        return AlertDialog(
          title: const Text('Edit Community Rules'),
          content: TextField(
            controller: ctrl,
            maxLength: 4000,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Write rules (one per line is fine).',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (updated == null) return;
    await context.read<GroupsController>().updateRules(group.id, updated);
  }

  Future<(String, String)?> _newPostDialog(BuildContext context) async {
    return showDialog<(String, String)?>(
      context: context,
      builder: (ctx) {
        final titleCtrl = TextEditingController();
        final bodyCtrl = TextEditingController();

        return AlertDialog(
          title: const Text('New post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                maxLength: 80,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Give your post a short title',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bodyCtrl,
                maxLength: 3000,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  hintText: 'Share your story or question…',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you’re browsing anonymously, your post will display as Anonymous.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                ctx,
                (titleCtrl.text.trim(), bodyCtrl.text.trim()),
              ),
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }
}

class _BannerHeader extends StatelessWidget {
  final CommunityGroup group;
  const _BannerHeader({required this.group});

  @override
  Widget build(BuildContext context) {
    final banner = group.bannerPath;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (banner != null &&
              banner.trim().isNotEmpty &&
              File(banner).existsSync())
            Image.file(File(banner), fit: BoxFit.cover)
          else
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: const Center(child: Icon(Icons.photo_outlined, size: 44)),
            ),

          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.45),
                ],
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Text(
              group.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesSection extends StatefulWidget {
  final CommunityGroup group;
  final VoidCallback onEdit;

  const _RulesSection({required this.group, required this.onEdit});

  @override
  State<_RulesSection> createState() => _RulesSectionState();
}

class _RulesSectionState extends State<_RulesSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasRules = widget.group.rulesText.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Community Rules',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              TextButton(onPressed: widget.onEdit, child: const Text('Edit')),
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ),
            ],
          ),
          if (!_expanded)
            Text(
              hasRules
                  ? 'Tap to view rules.'
                  : 'No rules yet. Add a few helpful guidelines.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else ...[
            const SizedBox(height: 8),
            Text(
              hasRules ? widget.group.rulesText : 'No rules yet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final GroupPost post;
  final VoidCallback onTap;

  const _PostCard({
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bodyPreview = post.text.length > 220
        ? '${post.text.substring(0, 220)}…'
        : post.text;

    return Material(
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                post.publicAuthor,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Text(bodyPreview),
            ],
          ),
        ),
      ),
    );
  }
}
