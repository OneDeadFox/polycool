import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:polycool/features/groups/controllers/groups_controller.dart';
import 'package:polycool/features/groups/group_detail_screen.dart';
import 'package:polycool/features/groups/models/group.dart';

import 'community_settings_sheet.dart';
import 'controllers/community_controller.dart';

class CommunityHomeScreen extends StatefulWidget {
  const CommunityHomeScreen({super.key});

  @override
  State<CommunityHomeScreen> createState() => _CommunityHomeScreenState();
}

class _CommunityHomeScreenState extends State<CommunityHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(
      length: 3,
      vsync: this,
    ); // in-memory remembers while app runs
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureUsername());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _ensureUsername() async {
    final community = context.read<CommunityController>();

    if (community.hasUsername) return;

    // Required modal
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _UsernameGateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final showAnonPill = community.anonymousBrowsing;
    final username = community.username;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community'),
            if (username != null && username.trim().isNotEmpty)
              Text(
                '@$username',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (_) => const CommunitySettingsSheet(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Communities'),
            Tab(text: 'Groups'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (showAnonPill)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => const CommunitySettingsSheet(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.visibility_off, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Anonymous mode',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _CommunitiesTab(),
                _GroupsTabStub(), // reuse existing groups list for now
                _EventsTabStub(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunitiesTab extends StatefulWidget {
  const _CommunitiesTab();

  @override
  State<_CommunitiesTab> createState() => _CommunitiesTabState();
}

class _CommunitiesTabState extends State<_CommunitiesTab> {
  final _searchCtrl = TextEditingController();
  String _q = '';
  bool _myExpanded = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupsController>();
    final all = groups.groups;

    final q = _q.trim().toLowerCase();
    final joined = groups.joinedGroups();

    final filtered = q.isEmpty
        ? all
        : all.where((g) {
            return g.name.toLowerCase().contains(q) ||
                g.tagline.toLowerCase().contains(q) ||
                g.tags.any((t) => t.toLowerCase().contains(q));
          }).toList();

    // “Smart lookup” suggestions under the search bar (top 5)
    final suggestions = q.isEmpty
        ? <CommunityGroup>[]
        : (filtered.take(5).toList());

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Search communities…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _q.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _q = '';
                        _searchCtrl.clear();
                      });
                      FocusScope.of(context).unfocus();
                    },
                  ),
          ),
          onChanged: (v) => setState(() => _q = v),
        ),

        // Suggestions
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                for (int i = 0; i < suggestions.length; i++) ...[
                  ListTile(
                    title: Text(
                      suggestions[i].name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      suggestions[i].tagline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              GroupDetailScreen(group: suggestions[i]),
                        ),
                      );
                    },
                  ),
                  if (i != suggestions.length - 1)
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // My Communities (collapsible)
        if (joined.isNotEmpty) ...[
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _myExpanded = !_myExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Communities',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(_myExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_myExpanded) ...[
            const SizedBox(height: 6),
            ...joined.map((g) => _CommunityCard(group: g)).toList(),
          ],
          if (_myExpanded) ...[
            const SizedBox(height: 6),
            ...joined.map((g) => _CommunityCard(group: g)).toList(),
          ],

          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withOpacity(0.6),
          ),
          const SizedBox(height: 18),
        ],

        // All Communities
        Text(
          'Communities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),

        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'No communities found.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          ...filtered.map((g) => _CommunityCard(group: g)).toList(),

        const SizedBox(height: 18),

        // Create a Community button (v1 stub)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create a Community (v1 stub)')),
              );
            },
            child: const Text('Create a Community'),
          ),
        ),
      ],
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityGroup group;
  const _CommunityCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupsController>();
    final joined = groups.isJoined(group.id);

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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: joined
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.12)
                            : Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Text(joined ? 'Joined' : 'Open'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  group.tagline,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: group.tags
                      .map((t) => Chip(label: Text(t)))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventsTabStub extends StatelessWidget {
  const _EventsTabStub();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Events (next)\n\nList + filters + create/edit + RSVP + My Events',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _GroupsTabStub extends StatelessWidget {
  const _GroupsTabStub();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Groups (next)\n\nGroup chats + invites + permissions',
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _UsernameGateDialog extends StatefulWidget {
  @override
  State<_UsernameGateDialog> createState() => _UsernameGateDialogState();
}

class _UsernameGateDialogState extends State<_UsernameGateDialog> {
  final _ctrl = TextEditingController();
  String? _error;

  static final _re = RegExp(r'^[a-zA-Z0-9_]{3,20}$');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _ctrl.text.trim();
    if (!_re.hasMatch(raw)) {
      setState(() {
        _error = '3–20 characters. Letters, numbers, underscore only.';
      });
      return;
    }

    await context.read<CommunityController>().setUsername(raw);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose a username'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'To participate in Community spaces, you’ll need a username.\n\n'
            'If you subscribe later, you can browse anonymously — but your account will still be linked to your actions for safety and accountability.',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLength: 20,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'e.g. calm_owl_7',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [FilledButton(onPressed: _save, child: const Text('Continue'))],
    );
  }
}
