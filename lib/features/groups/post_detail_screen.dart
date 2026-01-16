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
                  _ConversationSection(
                    roots: threads,
                    onReplyTap: _setReplyTarget,
                  ),
              ],
            ),
          ),

          // Composer
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

  // Sort chronologically (oldest -> newest) for natural reading
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

/// Layout row data used by the global painter.
class CommentLayout {
  final GroupReply reply;
  final int depth; // true depth in tree (0..)
  final bool hasChildren;
  final int parentIndex; // -1 if none
  int index;

  CommentLayout({
    required this.reply,
    required this.depth,
    required this.hasChildren,
    required this.parentIndex,
    required this.index,
  });

  int vDepth(int maxDepth) => depth.clamp(0, maxDepth);
}

/* ───────────────────────── Conversation UI ───────────────────────── */

class _ConversationSection extends StatefulWidget {
  final List<_ThreadNode> roots;
  final ValueChanged<GroupReply> onReplyTap;

  const _ConversationSection({required this.roots, required this.onReplyTap});

  @override
  State<_ConversationSection> createState() => _ConversationSectionState();
}

class _ConversationSectionState extends State<_ConversationSection> {
  // Visual tuning
  static const double _indent = 14.0;
  static const int _maxVDepth = 6; // ✅ now 6

  // gutter geometry
  static const double _gutterBase = 18.0; // padding before first trunk
  static const double _lineOffset = 10.0; // x inside gutter where trunks sit
  static const double _elbowLen = 14.0;

  late List<CommentLayout> _layout;
  final List<GlobalKey> _rowKeys = <GlobalKey>[];
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _recompute();

    // repaint once layout is available (row rects)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant _ConversationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roots != widget.roots) {
      _recompute();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  void _recompute() {
    _layout = _flatten(widget.roots);
    _rowKeys
      ..clear()
      ..addAll(List.generate(_layout.length, (_) => GlobalKey()));
  }

  List<CommentLayout> _flatten(List<_ThreadNode> roots) {
    final rows = <CommentLayout>[];

    void rec(_ThreadNode node, int depth, int parentIndex) {
      final i = rows.length;
      rows.add(
        CommentLayout(
          reply: node.reply,
          depth: depth,
          hasChildren: node.children.isNotEmpty,
          parentIndex: parentIndex,
          index: i,
        ),
      );
      for (final child in node.children) {
        rec(child, depth + 1, i);
      }
    }

    for (final root in roots) {
      rec(root, 0, -1);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Stack(
        key: _stackKey,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConversationPainter(
                  layouts: _layout,
                  rowKeys: _rowKeys,
                  stackKey: _stackKey,
                  indent: _indent,
                  gutterBase: _gutterBase,
                  lineOffset: _lineOffset,
                  elbowLen: _elbowLen,
                  maxVDepth: _maxVDepth,
                ),
              ),
            ),
          ),

          // Rows
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _layout.length,
            itemBuilder: (context, i) {
              final item = _layout[i];
              final v = item.vDepth(_maxVDepth);

              final showGutter = v > 0;
              final gutterWidth = showGutter
                  ? (v * _indent) + _gutterBase
                  : 0.0;

              return Container(
                key: _rowKeys[i],
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showGutter) SizedBox(width: gutterWidth),
                    Expanded(
                      child: _CommentBubble(
                        reply: item.reply,
                        onReplyTap: () => widget.onReplyTap(item.reply),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── Global painter ───────────────────────── */

class _ConversationPainter extends CustomPainter {
  final List<CommentLayout> layouts;
  final List<GlobalKey> rowKeys;
  final GlobalKey stackKey;

  final double indent;
  final double gutterBase;
  final double lineOffset;
  final double elbowLen;
  final int maxVDepth;

  static const double _rowVPad =
      6.0; // must match row padding in ListView.builder

  _ConversationPainter({
    required this.layouts,
    required this.rowKeys,
    required this.stackKey,
    required this.indent,
    required this.gutterBase,
    required this.lineOffset,
    required this.elbowLen,
    required this.maxVDepth,
  });

  // Where the elbow hits inside a row (relative to row top).
  // Keep this aligned with your bubble padding + header height.
  double _elbowY(Rect rowRect) => rowRect.top + _rowVPad + 22;

  // X position of the trunk for a visual depth d (1..maxVDepth)
  double _trunkX(int d) => gutterBase + ((d - 1) * indent) + lineOffset;

  // X position of the bubble start for visual depth d
  double _bubbleLeftX(int d) => gutterBase + (d * indent);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // continuous rainbow shader down the entire conversation height
    p.shader = const LinearGradient(
      colors: [
        Colors.red,
        Colors.orange,
        Colors.yellow,
        Colors.green,
        Colors.blue,
        Colors.indigo,
        Colors.purple,
      ],
      stops: [0.0, 0.14, 0.28, 0.42, 0.56, 0.70, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, 1, size.height));

    // Convert row rects into Stack-local coordinates (so we don’t depend on global screen coords).
    final stackCtx = stackKey.currentContext;
    final stackBox = stackCtx?.findRenderObject() as RenderBox?;
    if (stackBox == null || !stackBox.hasSize) return;

    final stackGlobal = stackBox.localToGlobal(Offset.zero);

    final rects = <int, Rect>{};
    for (int i = 0; i < rowKeys.length; i++) {
      final ctx = rowKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;

      final rowGlobal = box.localToGlobal(Offset.zero);
      final local = rowGlobal - stackGlobal;
      rects[i] = local & box.size;
    }
    if (rects.isEmpty) return;

    // We open/close vertical trunk segments per depth as we walk the flattened list.
    // FIX 1: trunk STARTS at the *bottom of the parent bubble* (not inside the parent, not at child top).
    // FIX 2: trunk ENDS exactly at the final elbow of that depth chain (no overshoot past branch end).

    final openStartY = <int, double>{}; // depth -> startY
    final lastElbowAtDepth = <int, double>{}; // depth -> last elbow we saw

    // Helper: close a specific depth at a given endY.
    void closeDepth(int d, double endY) {
      final start = openStartY[d];
      if (start == null) return;
      canvas.drawLine(Offset(_trunkX(d), start), Offset(_trunkX(d), endY), p);
      openStartY.remove(d);
    }

    // Iterate in visual order.
    for (int i = 0; i < layouts.length; i++) {
      final rowRect = rects[i];
      if (rowRect == null) continue;

      final v = layouts[i].vDepth(maxVDepth);

      // Track elbows per depth for accurate closures.
      if (v > 0) {
        lastElbowAtDepth[v] = _elbowY(rowRect);
      }

      // Open depth trunk if needed.
      if (v > 0 && !openStartY.containsKey(v)) {
        final parentIdx = layouts[i].parentIndex;
        final parentRect = parentIdx >= 0 ? rects[parentIdx] : null;

        // ✅ start trunk at bottom of parent bubble (or fallback to this row elbow if missing)
        final startY = parentRect != null
            ? (parentRect.bottom - _rowVPad) // ✅ bottom of parent bubble
            : _elbowY(rowRect);
        openStartY[v] = startY;
      }

      // Determine next visible row depth (skipping rows without rects).
      int nextV = 0;
      for (int j = i + 1; j < layouts.length; j++) {
        if (!rects.containsKey(j)) continue;
        nextV = layouts[j].vDepth(maxVDepth);
        break;
      }

      // If depth decreases, close all depths that should end here.
      if (nextV < v) {
        // close deeper trunks first
        for (int d = v; d > nextV; d--) {
          // ✅ end at this row’s elbow (the branch-end horizontal mark)
          final endY = _elbowY(rowRect);
          closeDepth(d, endY);
        }
      }
    }

    // Close any trunks still open at the end using the last elbow per depth (prevents overshoot).
    final remaining = openStartY.keys.toList()..sort();
    for (final d in remaining) {
      final endY = lastElbowAtDepth[d];
      if (endY == null) continue;
      closeDepth(d, endY);
    }

    // Draw elbows (horizontal lines) that touch the bubble.
    for (int i = 0; i < layouts.length; i++) {
      final rowRect = rects[i];
      if (rowRect == null) continue;

      final v = layouts[i].vDepth(maxVDepth);
      if (v <= 0) continue;

      final y = _elbowY(rowRect);
      final startX = _trunkX(v);
      final endX = _bubbleLeftX(v); // touches bubble

      canvas.drawLine(Offset(startX, y), Offset(endX, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ConversationPainter old) {
    return old.layouts != layouts ||
        old.rowKeys != rowKeys ||
        old.stackKey != stackKey ||
        old.indent != indent ||
        old.gutterBase != gutterBase ||
        old.lineOffset != lineOffset ||
        old.elbowLen != elbowLen ||
        old.maxVDepth != maxVDepth;
  }
}

/* ───────────────────────── Reply bubble ───────────────────────── */

class _CommentBubble extends StatelessWidget {
  final GroupReply reply;
  final VoidCallback onReplyTap;

  const _CommentBubble({required this.reply, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {
    final authorStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.78),
    );

    final replyingTo = (reply.replyToPublicAuthor ?? '').trim();
    final hasReplyingTo = replyingTo.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.75),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reply.publicAuthor,
                  style: authorStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onReplyTap,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Reply'),
              ),
            ],
          ),
          if (hasReplyingTo) ...[
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
          Text(reply.text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
