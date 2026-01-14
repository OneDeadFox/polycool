import 'package:flutter/foundation.dart';

import '../../../shared/persistence/app_storage.dart';
import '../../profile/models/profile.dart';
import '../models/match_thread.dart';

class MatchesController extends ChangeNotifier {
  final AppStorage storage;

  // profileId -> { type: 'like'|'superlike', message?: String, atMs: int }
  late Map<String, dynamic> _liked;

  late List<MatchThread> _matches;

  MatchesController({required this.storage}) {
    _liked = storage.loadLikedProfiles();
    _matches = storage.loadMatchesRaw().map(MatchThread.fromJson).toList();
    _sort();
  }

  List<MatchThread> get matches => List.unmodifiable(_matches);

  bool isLiked(String profileId) => _liked.containsKey(profileId);

  Future<void> devClearLikes() async {
    _liked.clear();
    await storage.saveLikedProfiles(_liked);
    notifyListeners();
  }

  Future<void> devClearMatches() async {
    _matches.clear();
    await storage.clearMatches();
    notifyListeners();
  }

  Future<void> updateThreadLastMessage({
    required String profileId,
    required String? lastMessage,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final idx = _matches.indexWhere((m) => m.profileId == profileId);
    if (idx == -1) return;

    final current = _matches[idx];
    final updated = MatchThread(
      profileId: current.profileId,
      displayName: current.displayName,
      photoPath: current.photoPath,
      lastMessage: (lastMessage ?? '').trim(),
      updatedAtMs: now,
    );

    _matches[idx] = updated;
    _matches.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));

    await storage.saveMatchesRaw(_matches.map((m) => m.toJson()).toList());
    notifyListeners();
  }

  Future<void> like(Profile p) async {
    _liked[p.id] = {
      'type': 'like',
      'atMs': DateTime.now().millisecondsSinceEpoch,
    };
    await storage.saveLikedProfiles(_liked);
    notifyListeners();
  }

  Future<void> superLike(Profile p, {String? message}) async {
    _liked[p.id] = {
      'type': 'superlike',
      'message': (message ?? '').trim(),
      'atMs': DateTime.now().millisecondsSinceEpoch,
    };
    await storage.saveLikedProfiles(_liked);
    notifyListeners();
  }

  /// Manual dev flow: turn a liked profile into a match thread.
  /// If not liked yet, we still allow match creation (v1 dev convenience).
  Future<void> simulateMatch(Profile p) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final lastMsg = () {
      final entry = _liked[p.id];
      if (entry is Map && entry['type'] == 'superlike') {
        final msg = (entry['message'] ?? '').toString().trim();
        return msg.isEmpty ? null : msg;
      }
      return null;
    }();

    final photoPath = p.photos.isNotEmpty ? p.photos.first.localPath : null;

    // Upsert (avoid duplicates)
    _matches.removeWhere((m) => m.profileId == p.id);
    _matches.insert(
      0,
      MatchThread(
        profileId: p.id,
        displayName: p.displayName,
        photoPath: photoPath,
        lastMessage: lastMsg,
        updatedAtMs: now,
      ),
    );

    await storage.saveMatchesRaw(_matches.map((m) => m.toJson()).toList());
    _sort();
    notifyListeners();
  }

  String snippetFor(MatchThread t) {
    final msg = (t.lastMessage ?? '').trim();
    if (msg.isEmpty) return 'Be bold and make the first move.';
    return msg.length <= 30 ? msg : msg.substring(0, 30);
  }

  void _sort() {
    _matches.sort((a, b) => b.updatedAtMs.compareTo(a.updatedAtMs));
  }
}
