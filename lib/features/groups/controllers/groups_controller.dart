import 'package:flutter/foundation.dart';

import '../../../shared/persistence/app_storage.dart';
import '../models/group.dart';
import '../models/group_post.dart';

class GroupsController extends ChangeNotifier {
  final AppStorage storage;

  final List<CommunityGroup> _groups = _seedGroups();
  late final Set<String> _joined;
  late List<GroupPost> _posts;

  GroupsController({required this.storage}) {
    _joined = storage.loadJoinedGroupIds().toSet();
    _posts = storage.loadGroupPostsRaw().map(GroupPost.fromJson).toList();
    if (_posts.isEmpty) {
      _posts = _seedPosts();
      storage.saveGroupPostsRaw(_posts.map((p) => p.toJson()).toList());
    }
  }

  List<CommunityGroup> get groups => List.unmodifiable(_groups);
  bool isJoined(String groupId) => _joined.contains(groupId);

  List<GroupPost> postsFor(String groupId) {
    final list = _posts.where((p) => p.groupId == groupId).toList();
    list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return list;
  }

  Future<void> toggleJoin(String groupId) async {
    if (_joined.contains(groupId)) {
      _joined.remove(groupId);
    } else {
      _joined.add(groupId);
    }
    await storage.saveJoinedGroupIds(_joined.toList());
    notifyListeners();
  }

  Future<void> addPost({
    required String groupId,
    required String text,
    String author = 'You',
  }) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    final post = GroupPost(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      groupId: groupId,
      author: author,
      text: cleaned,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    _posts.add(post);

    await storage.saveGroupPostsRaw(_posts.map((p) => p.toJson()).toList());
    notifyListeners();
  }

  static List<CommunityGroup> _seedGroups() => const [
        CommunityGroup(
          id: 'g1',
          name: 'Consent First',
          tagline: 'Practical consent skills + scripts',
          description:
              'A space for learning and practicing consent-first communication. Share scripts, ask questions, and get support.',
          tags: ['Consent', 'Communication', 'Safety'],
        ),
        CommunityGroup(
          id: 'g2',
          name: 'Poly Newcomers',
          tagline: 'Start here, no shame',
          description:
              'New to poly/ENM? Ask anything. The goal is clarity, kindness, and steady growth.',
          tags: ['New to poly', 'Support', 'Resources'],
        ),
        CommunityGroup(
          id: 'g3',
          name: 'Play & Aftercare',
          tagline: 'Kink-friendly, care-forward',
          description:
              'Discuss scenes, boundaries, aftercare, and finding good-fit play partners—without pressure.',
          tags: ['Kink', 'Aftercare', 'Boundaries'],
        ),
      ];

  static List<GroupPost> _seedPosts() => [
        GroupPost(
          id: 'p1',
          groupId: 'g1',
          author: 'Moderator',
          text:
              'Reminder: this space is for learning, not judging. If you’re sharing a hard story, keep details minimal and focus on needs + next steps.',
          createdAtMs: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        ),
        GroupPost(
          id: 'p2',
          groupId: 'g2',
          author: 'Rowan',
          text: 'What’s a good first message to someone when you’re new and nervous?',
          createdAtMs: DateTime.now().subtract(const Duration(hours: 14)).millisecondsSinceEpoch,
        ),
      ];
}
