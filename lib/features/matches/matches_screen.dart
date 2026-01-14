import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../profile/controllers/reflection_controller.dart';
import '../profile/models/profile.dart';
import '../profile/other_profile/other_profile_screen.dart';

import '../discover/discover_controller.dart';
import 'controllers/matches_controller.dart';
import 'models/match_thread.dart';
import 'chat/chat_thread_screen.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final threads = context.watch<MatchesController>().matches;
    final matches = context.read<MatchesController>();
    final reflections = context.read<ReflectionController>().orderedInsights;
    final discover = context.read<DiscoverController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Matches')),
      body: threads.isEmpty
          ? Center(
              child: Text(
                'Be bold and make the first move.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final t = threads[i];
                final subtitle = matches.snippetFor(t);

                return _MatchRow(
                  thread: t,
                  subtitle: subtitle,
                  onOpenChat: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatThreadScreen(
                          profileId: t.profileId,
                          title: t.displayName,
                        ),
                      ),
                    );
                  },
                  onOpenProfile: () {
                    // Prefer the full profile from Discover seed list
                    final full = discover.getById(t.profileId);

                    final p =
                        full ??
                        Profile(
                          id: t.profileId,
                          displayName: t.displayName,
                          photos: const [],
                          interests: const [],
                          relationshipContextTags: const [],
                          seeking: const [],
                          preferences: const [],
                          showPreferences: false,
                        );

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OtherProfileScreen(
                          profile: p,
                          reflections: reflections,
                          superLikesAvailable: 0,
                          viewerIsSubscriber: false,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final MatchThread thread;
  final String subtitle;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenProfile;

  const _MatchRow({
    required this.thread,
    required this.subtitle,
    required this.onOpenChat,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final path = thread.photoPath;
    final hasPhoto = path != null && File(path).existsSync();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpenChat,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              GestureDetector(
                onTap: onOpenProfile,
                child: CircleAvatar(
                  radius: 26,
                  backgroundImage: hasPhoto ? FileImage(File(path!)) : null,
                  child: hasPhoto ? null : const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thread.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
