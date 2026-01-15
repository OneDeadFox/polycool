import 'package:flutter/foundation.dart';

import '../../../shared/persistence/app_storage.dart';
import '../models/group.dart';
import '../models/group_post.dart';
import '../models/group_reply.dart';

class GroupsController extends ChangeNotifier {
  final AppStorage storage;

  late List<CommunityGroup> _groups;
  late final Set<String> _joined;
  late List<GroupPost> _posts;
  late List<GroupReply> _replies;

  GroupsController({required this.storage}) {
    _joined = storage.loadJoinedGroupIds().toSet();
    _posts = storage.loadGroupPostsRaw().map(GroupPost.fromJson).toList();
    _replies = storage.loadGroupRepliesRaw().map(GroupReply.fromJson).toList();

    // Load groups list (rules/banner persistence)
    final rawGroups = storage.loadGroupsRaw();
    if (rawGroups.isNotEmpty) {
      _groups = List<CommunityGroup>.from(
        rawGroups.map(CommunityGroup.fromJson),
      );
    } else {
      _groups = List<CommunityGroup>.from(_seedGroups());
      storage.saveGroupsRaw(_groups.map((g) => g.toJson()).toList());
    }

    // Seed posts once if empty
    if (_posts.isEmpty) {
      _posts = _seedPosts();
      storage.saveGroupPostsRaw(_posts.map((p) => p.toJson()).toList());
    }
  }

  List<CommunityGroup> get groups => List.unmodifiable(_groups);

  bool isJoined(String groupId) => _joined.contains(groupId);

  List<CommunityGroup> joinedGroups() =>
      _groups.where((g) => _joined.contains(g.id)).toList();

  List<GroupPost> postsFor(String groupId) {
    final list = _posts.where((p) => p.groupId == groupId).toList();
    list.sort((a, b) => b.createdAtMs.compareTo(a.createdAtMs));
    return list;
  }

  List<GroupReply> repliesForPost(String postId) {
    final list = _replies.where((r) => r.postId == postId).toList();
    list.sort(
      (a, b) => a.createdAtMs.compareTo(b.createdAtMs),
    ); // oldest → newest
    return list;
  }

  Future<void> addReply({
    required String postId,
    required String text,
    required bool replyAsAnonymous,
    required String username,

    // reply-to support (optional)
    String? replyToReplyId,
    String? replyToPublicAuthor,
  }) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    final reply = GroupReply(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      postId: postId,
      text: cleaned,
      publicAuthor: replyAsAnonymous ? 'Anonymous' : '@$username',
      internalAuthorKey: username,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      replyToReplyId: replyToReplyId,
      replyToPublicAuthor: replyToPublicAuthor,
    );

    _replies.add(reply);
    await storage.saveGroupRepliesRaw(_replies.map((r) => r.toJson()).toList());
    notifyListeners();
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

  Future<void> updateRules(String groupId, String rulesText) async {
    final i = _groups.indexWhere((g) => g.id == groupId);
    if (i == -1) return;

    _groups[i] = _groups[i].copyWith(rulesText: rulesText.trim());

    await storage.saveGroupsRaw(_groups.map((g) => g.toJson()).toList());
    notifyListeners();
  }

  Future<void> addPost({
    required String groupId,
    required String title,
    required String body,
    required bool postAsAnonymous,
    required String username,
  }) async {
    final t = title.trim();
    final b = body.trim();
    if (t.isEmpty || b.isEmpty) return;

    final post = GroupPost(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      groupId: groupId,
      title: t,
      text: b,
      publicAuthor: postAsAnonymous ? 'Anonymous' : '@$username',
      internalAuthorKey: username,
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
      rulesText:
          'Be kind and specific.\nAsk for consent before giving advice.\nNo harassment or shaming.\nReport unsafe behavior.',
    ),
    CommunityGroup(
      id: 'g2',
      name: 'Poly Newcomers',
      tagline: 'Start here, no shame',
      description:
          'New to poly/ENM? Ask anything. The goal is clarity, kindness, and steady growth.',
      tags: ['New to poly', 'Support', 'Resources'],
      rulesText:
          'Assume good intent.\nOffer gentle feedback.\nNo dogpiling.\nShare resources without gatekeeping.',
    ),
    CommunityGroup(
      id: 'g3',
      name: 'Play & Aftercare',
      tagline: 'Kink-friendly, care-forward',
      description:
          'Discuss scenes, boundaries, aftercare, and finding good-fit play partners—without pressure.',
      tags: ['Kink', 'Aftercare', 'Boundaries'],
      rulesText:
          'Consent-first language.\nNo explicit media.\nNo pressuring.\nRespect boundaries and aftercare needs.',
    ),
  ];

  static List<GroupPost> _seedPosts() => const [
    GroupPost(
      id: 'p1',
      groupId: 'g1',
      title: 'Reminder',
      text:
          'This space is for learning, not judging. Share with care and focus on needs + next steps.',
      publicAuthor: 'Moderator',
      internalAuthorKey: 'seed',
      createdAtMs: 0,
    ),
    GroupPost(
      id: 'p2',
      groupId: 'g2',
      title: 'New and nervous',
      text: 'What’s a good first message when you’re new and nervous?',
      publicAuthor: 'Rowan',
      internalAuthorKey: 'seed',
      createdAtMs: 0,
    ),
  ];
}
