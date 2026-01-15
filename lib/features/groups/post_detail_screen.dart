import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/groups_controller.dart';
import 'models/group_post.dart';
import 'models/group_reply.dart';

import 'package:polycool/features/community/controllers/community_controller.dart';

class PostDetailScreen extends StatefulWidget {
  final GroupPost post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _replyCtrl = TextEditingController();
  bool _expandedBody = false;

  // Reply target
  String? _replyToReplyId;
  String? _replyToPublicAuthor;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  void _setReplyTarget(GroupReply r) {
    setState(() {
      _replyToReplyId = r.id;
      _replyToPublicAuthor = r.publicAuthor;
    });
  }

  void _clearReplyTarget() {
    setState(() {
      _replyToReplyId = null;
      _replyToPublicAuthor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupsController>();
    final replies = groups.repliesForPost(widget.post.id);

    final threads = _buildThreads(replies);

    final body = widget.post.text;
    final showTruncate = !_expandedBody && body.length > 500;
    final bodyText = showTruncate ? '${body.substring(0, 500)}…' : body;

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                Text(
                  widget.post.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.post.publicAuthor,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(bodyText),
                if (showTruncate) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _expandedBody = true),
                    child: const Text('Continue reading'),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Conversation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),

                if (threads.isEmpty)
                  Text(
                    'Add something supportive to start the conversation.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...threads.map(
                    (root) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ThreadCard(
                        root: root,
                        onReplyTap: _setReplyTarget,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyToReplyId != null && _replyToPublicAuthor != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Replying to ${_replyToPublicAuthor!}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: _clearReplyTarget,
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Cancel reply',
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyCtrl,
                          maxLength: 500,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Add to the conversation…',
                            counterText: '',
                          ),
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () async {
                          final txt = _replyCtrl.text.trim();
                          if (txt.isEmpty) return;

                          final community = context.read<CommunityController>();
                          final username = (community.username ?? 'me').trim();
                          final replyAsAnonymous = community.anonymousBrowsing;

                          await context.read<GroupsController>().addReply(
                            postId: widget.post.id,
                            text: txt,
                            replyAsAnonymous: replyAsAnonymous,
                            username: username,
                            replyToReplyId: _replyToReplyId,
                            replyToPublicAuthor: _replyToPublicAuthor,
                          );

                          _replyCtrl.clear();
                          _clearReplyTarget();
                          FocusScope.of(context).unfocus();
                        },
                        child: const Text('Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Thread building ───────────────────────── */

class _ThreadNode {
  final GroupReply reply;
  final List<_ThreadNode> children = [];

  _ThreadNode(this.reply);
}

/// Builds root threads, then attaches children under their parent.
/// Sorts roots and children by createdAt (oldest → newest) so conversation reads naturally.
List<_ThreadNode> _buildThreads(List<GroupReply> replies) {
  final byId = <String, _ThreadNode>{};
  for (final r in replies) {
    byId[r.id] = _ThreadNode(r);
  }

  final roots = <_ThreadNode>[];

  for (final r in replies) {
    final node = byId[r.id]!;
    final parentId = (r.replyToReplyId ?? '').trim();

    if (parentId.isNotEmpty && byId.containsKey(parentId)) {
      byId[parentId]!.children.add(node);
    } else {
      roots.add(node);
    }
  }

  void sortRec(_ThreadNode n) {
    n.children.sort(
      (a, b) => a.reply.createdAtMs.compareTo(b.reply.createdAtMs),
    );
    for (final c in n.children) {
      sortRec(c);
    }
  }

  roots.sort((a, b) => a.reply.createdAtMs.compareTo(b.reply.createdAtMs));
  for (final r in roots) {
    sortRec(r);
  }

  return roots;
}

/* ───────────────────────── UI ───────────────────────── */

class _ThreadCard extends StatelessWidget {
  final _ThreadNode root;
  final ValueChanged<GroupReply> onReplyTap;

  const _ThreadCard({required this.root, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: _ThreadTree(
        node: root,
        depth: 0,
        onReplyTap: onReplyTap,
        // for a “reddit-ish” feel, we cap depth spacing but still indent each level
        indentStep: 14,
      ),
    );
  }
}

class _ThreadTree extends StatelessWidget {
  final _ThreadNode node;
  final int depth;
  final ValueChanged<GroupReply> onReplyTap;
  final double indentStep;

  const _ThreadTree({
    required this.node,
    required this.depth,
    required this.onReplyTap,
    required this.indentStep,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CompactReplyRow(
          reply: node.reply,
          depth: depth.clamp(0, 3),
          indentStep: indentStep,
          lineColor: lineColor,
          onReplyTap: () => onReplyTap(node.reply),
        ),

        // children render directly under parent (conversation continuity)
        for (final child in node.children)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _ThreadTree(
              node: child,
              depth: depth + 1,
              onReplyTap: onReplyTap,
              indentStep: indentStep,
            ),
          ),
      ],
    );
  }
}

class _CompactReplyRow extends StatelessWidget {
  final GroupReply reply;
  final int depth;
  final double indentStep;
  final Color lineColor;
  final VoidCallback onReplyTap;

  const _CompactReplyRow({
    required this.reply,
    required this.depth,
    required this.indentStep,
    required this.lineColor,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    // Clamp indentation visually to max 3 levels (per your spec)
    final d = depth.clamp(0, 3);

    // No thread lines for replies to the original post
    // i.e., depth == 0 should have no gutter/lines.
    final showLines = d > 0;

    final replyingTo = (reply.replyToPublicAuthor ?? '').trim();
    final gutterWidth = showLines ? (d * indentStep + 18) : 0.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLines)
            SizedBox(
              width: gutterWidth,
              child: CustomPaint(
                painter: _ThreadGutterPainter(
                  depth: d,
                  indentStep: indentStep,
                  lineColor: lineColor,
                  // the elbow should be drawn at the deepest visible level
                  elbowLevel: d,
                  elbowY: 18,
                ),
              ),
            ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withValues(alpha: 0.32),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.75),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          reply.publicAuthor,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.78),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: onReplyTap,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Reply'),
                      ),
                    ],
                  ),

                  if (replyingTo.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'replying to $replyingTo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),
                  Text(
                    reply.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreadGutterPainter extends CustomPainter {
  final int depth; // already clamped 1..3
  final double indentStep;
  final Color lineColor;

  /// Which level should get the elbow into the bubble (usually == depth)
  final int elbowLevel;

  /// Vertical position for elbow line (pixels from top)
  final double elbowY;

  _ThreadGutterPainter({
    required this.depth,
    required this.indentStep,
    required this.lineColor,
    required this.elbowLevel,
    required this.elbowY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw connected vertical lines for ALL levels up to depth.
    // This creates "columns" that connect replies on the same indent level.
    for (int level = 1; level <= depth; level++) {
      final x = (level - 1) * indentStep + 8;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw the elbow (horizontal) into the bubble for the deepest level
    final elbowX = (elbowLevel - 1) * indentStep + 8;
    canvas.drawLine(Offset(elbowX, elbowY), Offset(elbowX + 12, elbowY), paint);
  }

  @override
  bool shouldRepaint(covariant _ThreadGutterPainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.indentStep != indentStep ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.elbowLevel != elbowLevel ||
        oldDelegate.elbowY != elbowY;
  }
}
