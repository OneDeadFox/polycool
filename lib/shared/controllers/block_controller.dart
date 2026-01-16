import 'package:flutter/foundation.dart';
import '../persistence/app_storage.dart';

class BlockController extends ChangeNotifier {
  final AppStorage storage;

  late final Set<String> _blocked;

  BlockController({required this.storage}) {
    _blocked = storage.loadBlockedUserIds().toSet();
  }

  Set<String> get blocked => Set.unmodifiable(_blocked);

  bool isBlocked(String userId) => _blocked.contains(userId);

  Future<void> block(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return;
    if (_blocked.add(id)) {
      await storage.saveBlockedUserIds(_blocked.toList());
      notifyListeners();
    }
  }

  Future<void> unblock(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return;
    if (_blocked.remove(id)) {
      await storage.saveBlockedUserIds(_blocked.toList());
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _blocked.clear();
    await storage.saveBlockedUserIds(const []);
    notifyListeners();
  }
}
