import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/groups_controller.dart';
import '../group_detail_screen.dart';
import '../models/group.dart';

class MyGroupsSection extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const MyGroupsSection({
    super.key,
    this.title = 'My Groups',
    this.padding = const EdgeInsets.only(top: 6),
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GroupsController>();
    final joined = controller.joinedGroups();

    if (joined.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          ...joined.map((g) => _MyGroupRow(group: g)).toList(),
        ],
      ),
    );
  }
}

class _MyGroupRow extends StatelessWidget {
  final CommunityGroup group;
  const _MyGroupRow({required this.group});

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
                      const SizedBox(height: 3),
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
