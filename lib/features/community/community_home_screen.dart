import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Community'),
            Text(
              '@${context.watch<CommunityController>().username}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
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
                _CommunitiesTabStub(),
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

class _CommunitiesTabStub extends StatelessWidget {
  const _CommunitiesTabStub();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Communities (next)\n\nSearch + My Communities + community list + create',
        textAlign: TextAlign.center,
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
