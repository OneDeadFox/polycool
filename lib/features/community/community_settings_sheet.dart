import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../shared/controllers/monetization_controller.dart';
import 'controllers/community_controller.dart';

class CommunitySettingsSheet extends StatelessWidget {
  const CommunitySettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final monetization = context.watch<MonetizationController>();

    final isSub = monetization.isSubscriber;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Community settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Blocked users'),
              subtitle: const Text('Applies across the entire app (v1 stub).'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Blocked users (v1 stub)')),
                );
              },
            ),

            const Divider(height: 18),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Anonymous browsing'),
              subtitle: Text(
                isSub
                    ? 'Browse Communities without showing your username.'
                    : 'Subscriber-only (v1 paywall later).',
              ),
              value: community.anonymousBrowsing && isSub,
              onChanged: isSub
                  ? (v) async {
                      await community.setAnonymousBrowsing(v);
                    }
                  : null,
            ),

            const SizedBox(height: 6),
            Text(
              'Note: even in anonymous mode, your activity is still tied to your account for safety and accountability.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
