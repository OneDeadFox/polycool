import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/controllers/monetization_controller.dart';
import '../../shared/persistence/app_storage.dart';

import '../discover/discover_controller.dart';
import '../matches/controllers/matches_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monetization = context.watch<MonetizationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _Section(
            title: 'Account',
            children: const [
              _RowItem(
                title: 'Email',
                subtitle: 'Coming in v2 (no backend in v1).',
              ),
              _RowItem(
                title: 'Password',
                subtitle: 'Coming in v2 (no backend in v1).',
              ),
            ],
          ),

          const SizedBox(height: 14),

          _Section(
            title: 'Privacy & Safety',
            children: const [
              _RowItem(
                title: 'Block & report',
                subtitle: 'Coming soon.',
              ),
              _RowItem(
                title: 'Visibility controls',
                subtitle: 'Privacy is never paywalled in Polycool.',
              ),
            ],
          ),

          const SizedBox(height: 14),

          _Section(
            title: 'Membership',
            children: [
              _RowItem(
                title: 'Subscription status',
                subtitle: monetization.isSubscriber ? 'Subscriber' : 'Free',
                trailing: monetization.isSubscriber
                    ? const Icon(Icons.verified, size: 18)
                    : const Icon(Icons.lock_outline, size: 18),
              ),
              _RowItem(
                title: 'Super Likes',
                subtitle: '${monetization.superLikes} available',
              ),
              _RowItem(
                title: 'Next replenish',
                subtitle: '${monetization.daysUntilRenewal} days',
              ),
              const _RowItem(
                title: 'Manage subscription',
                subtitle: 'Paywall screen (next step).',
              ),
            ],
          ),

          if (kDebugMode) ...[
            const SizedBox(height: 18),
            const _DevHeader(),
            const SizedBox(height: 10),
            _DevToolsCard(),
          ],
        ],
      ),
    );
  }
}

class _DevHeader extends StatelessWidget {
  const _DevHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Dev tools',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _DevToolsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final monetization = context.read<MonetizationController>();
    final discover = context.read<DiscoverController>();
    final matches = context.read<MatchesController>();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _DevButton(
            title: 'Toggle subscriber',
            subtitle: 'Currently: ${monetization.isSubscriber ? "Subscriber" : "Free"}',
            onTap: () async {
              await monetization.setSubscriber(!monetization.isSubscriber);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Subscriber: ${context.read<MonetizationController>().isSubscriber}',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _DevButton(
            title: 'Add 5 Super Likes',
            subtitle: 'For testing purchase & depletion flows.',
            onTap: () async {
              await monetization.addSuperLikes(5);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added 5 Super Likes.')),
              );
            },
          ),
          const SizedBox(height: 10),

          _DevButton(
            title: 'Reset Discover',
            subtitle: 'Clears 2-week mutes + resets carousel.',
            onTap: () async {
              ScaffoldMessenger.of(context).clearSnackBars();
              await discover.devResetDiscover();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Discover reset.')),
              );
            },
          ),
          const SizedBox(height: 10),

          _DevButton(
            title: 'Clear likes & matches',
            subtitle: 'Resets interactions without reinstalling.',
            onTap: () async {
              await matches.devClearLikes();
              await matches.devClearMatches();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cleared likes & matches.')),
              );
            },
          ),
          const SizedBox(height: 10),

          _DevButton(
            title: 'Clear ALL app storage',
            subtitle: 'Hard reset (profile, chats, everything).',
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear all local data?'),
                  content: const Text('This will wipe all local v1 state.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (ok != true) return;

              await context.read<AppStorage>().clearAll();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cleared all local data. Restart app.')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DevButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Future<void> Function() onTap;

  const _DevButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Divider(height: 1, color: Theme.of(context).dividerColor),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RowItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _RowItem({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
