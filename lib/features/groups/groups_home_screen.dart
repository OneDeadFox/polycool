import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/groups_controller.dart';
import 'group_detail_screen.dart';
import 'models/group.dart';
import 'widgets/my_groups_section.dart';

import 'package:polycool/features/settings/settings_screen.dart';

class GroupsHomeScreen extends StatefulWidget {
  const GroupsHomeScreen({super.key});

  @override
  State<GroupsHomeScreen> createState() => _GroupsHomeScreenState();
}

class _GroupsHomeScreenState extends State<GroupsHomeScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GroupsController>();
    final all = controller.groups;

    final q = _q.trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((g) {
            return g.name.toLowerCase().contains(q) ||
                g.tagline.toLowerCase().contains(q) ||
                g.tags.any((t) => t.toLowerCase().contains(q));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search groups…',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 14),

          const MyGroupsSection(),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: Text(
                  'All Groups',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              // FIX: finite width button to avoid infinite width constraints
              SizedBox(
                width: 96,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Create group (v1 stub)')),
                    );
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(
                'No groups found.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...filtered.map((g) => _GroupCard(group: g)).toList(),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final CommunityGroup group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GroupsController>();
    final joined = controller.isJoined(group.id);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        group.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: joined
                            ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                            : Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Text(joined ? 'Joined' : 'Open'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(group.tagline, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.tags.map((t) => Chip(label: Text(t))).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
