import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:polycool/features/groups/controllers/groups_controller.dart';
import 'package:polycool/features/groups/group_detail_screen.dart';
import 'package:polycool/features/groups/models/group.dart';

class MyCommunitiesSection extends StatefulWidget {
  final String title;

  const MyCommunitiesSection({
    super.key,
    this.title = 'My Communities',
  });

  @override
  State<MyCommunitiesSection> createState() => _MyCommunitiesSectionState();
}

class _MyCommunitiesSectionState extends State<MyCommunitiesSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupsController>();
    final joined = groups.joinedGroups();

    if (joined.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 6),
          ...joined.map((g) => _CommunityRow(group: g)).toList(),
        ],
      ],
    );
  }
}

class _CommunityRow extends StatelessWidget {
  final CommunityGroup group;
  const _CommunityRow({required this.group});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GroupDetailScreen(group: group),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        group.tagline,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
