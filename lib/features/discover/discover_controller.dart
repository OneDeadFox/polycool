import 'package:flutter/foundation.dart';

import '../../shared/persistence/app_storage.dart';
import '../profile/models/profile.dart';
import '../profile/models/photo.dart';
import '../profile/models/preference_item.dart';
import '../profile/models/enums.dart';

class DiscoverController extends ChangeNotifier {
  final AppStorage storage;

  final List<Profile> _all;
  final Map<String, int> _dismissedUntilMs; // profileId -> epochMs (until)

  int _index = 0;

  // for undo
  _LastDismiss? _lastDismiss;

  DiscoverController({required this.storage})
    : _all = _seed(),
      _dismissedUntilMs = storage.loadDiscoverDismissedUntil() {
    _pruneExpired();
  }

  int get index => _index;

  List<Profile> get visible {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _all.where((p) {
      final until = _dismissedUntilMs[p.id] ?? 0;
      return until <= now;
    }).toList();
  }

  Profile get current {
    final list = visible;
    if (list.isEmpty) {
      // Should never happen in v1 seed, but safe anyway.
      return _all.first;
    }
    final safeIndex = _index.clamp(0, list.length - 1);
    return list[safeIndex];
  }

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }

  /// Dismiss current profile for 14 days.
  /// Returns the index we should navigate to after dismissal.
  Future<int> dismissCurrentForTwoWeeks() async {
    final list = visible;
    if (list.isEmpty) return 0;

    final currentIndex = _index.clamp(0, list.length - 1);
    final p = list[currentIndex];

    final until = DateTime.now()
        .add(const Duration(days: 14))
        .millisecondsSinceEpoch;
    _dismissedUntilMs[p.id] = until;
    await storage.saveDiscoverDismissedUntil(_dismissedUntilMs);

    _lastDismiss = _LastDismiss(
      profileId: p.id,
      untilMs: until,
      previousIndex: currentIndex,
    );

    // After removal, compute new visible list and pick next sensible index.
    final nextList = visible;
    if (nextList.isEmpty) {
      _index = 0;
      notifyListeners();
      return 0;
    }

    final nextIndex = currentIndex.clamp(0, nextList.length - 1);
    _index = nextIndex;
    notifyListeners();
    return nextIndex;
  }

  Future<void> devResetDiscover() async {
    _dismissedUntilMs.clear();
    _lastDismiss = null;
    _index = 0;
    await storage.saveDiscoverDismissedUntil(_dismissedUntilMs);
    notifyListeners();
  }

  Future<void> undoLastDismiss() async {
    final last = _lastDismiss;
    if (last == null) return;

    // Only undo if it still matches the stored until
    final currentUntil = _dismissedUntilMs[last.profileId];
    if (currentUntil == last.untilMs) {
      _dismissedUntilMs.remove(last.profileId);
      await storage.saveDiscoverDismissedUntil(_dismissedUntilMs);

      // Restore index to where it was if possible
      final list = visible;
      if (list.isNotEmpty) {
        _index = last.previousIndex.clamp(0, list.length - 1);
      } else {
        _index = 0;
      }
      notifyListeners();
    }

    _lastDismiss = null;
  }

  void _pruneExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expired = _dismissedUntilMs.entries
        .where((e) => e.value <= now)
        .map((e) => e.key)
        .toList();
    for (final id in expired) {
      _dismissedUntilMs.remove(id);
    }
    // Save only if something changed
    if (expired.isNotEmpty) {
      storage.saveDiscoverDismissedUntil(_dismissedUntilMs);
    }
  }

  static List<Profile> _seed() {
    return [
      Profile(
        id: 'u1',
        displayName: 'Rowan',
        age: 29,
        location: 'Austin',
        pronouns: 'they/them',
        relationshipContextTags: ['Poly', 'Open to dating'],
        seeking: ['Seeking partner', 'Seeking friends'],
        about: 'Warm, curious, loves long walks and honest conversation.',
        interests: ['Board games', 'Live music', 'Cooking'],
        photos: const <Photo>[],
        preferences: const <PreferenceItem>[
          PreferenceItem(
            id: 'Roleplay',
            label: 'Roleplay',
            intensity: PreferenceIntensity.enjoys,
            isVisible: true,
          ),
        ],
        showPreferences: true,
      ),
      Profile(
        id: 'u2',
        displayName: 'Sam',
        age: 35,
        location: 'Seattle',
        pronouns: 'he/him',
        relationshipContextTags: ['ENM', 'Kink-friendly'],
        seeking: ['Seeking playmate'],
        about: 'Soft dom energy. Big on consent and aftercare.',
        interests: ['Hiking', 'Museums', 'Coffee'],
        photos: const <Photo>[],
        preferences: const <PreferenceItem>[
          PreferenceItem(
            id: 'Impact play',
            label: 'Impact play',
            intensity: PreferenceIntensity.deeplyEnjoys,
            isVisible: true,
          ),
        ],
        showPreferences: true,
      ),
    ];
  }
}

class _LastDismiss {
  final String profileId;
  final int untilMs;
  final int previousIndex;

  _LastDismiss({
    required this.profileId,
    required this.untilMs,
    required this.previousIndex,
  });
}
