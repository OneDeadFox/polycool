import 'package:flutter/foundation.dart';
import '../persistence/app_storage.dart';

class MonetizationController extends ChangeNotifier {
  final AppStorage storage;

  late bool _isSubscriber;
  late int _superLikes;
  DateTime? _renewal;

  MonetizationController({required this.storage}) {
    _isSubscriber = storage.loadIsSubscriber();
    _superLikes = storage.loadSuperLikes();
    _renewal = storage.loadRenewalDate();

    // Sensible v1 defaults (you can tweak later)
    _superLikes = _superLikes == 0 ? 1 : _superLikes;
    _renewal ??= DateTime.now().add(const Duration(days: 14));
  }

  bool get isSubscriber => _isSubscriber;
  int get superLikes => _superLikes;
  DateTime get renewalDate => _renewal ?? DateTime.now().add(const Duration(days: 14));

  int get daysUntilRenewal {
    final d = renewalDate.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  Future<void> setSubscriber(bool v) async {
    _isSubscriber = v;
    await storage.saveIsSubscriber(v);
    notifyListeners();
  }

  Future<void> setSuperLikes(int v) async {
    _superLikes = v < 0 ? 0 : v;
    await storage.saveSuperLikes(_superLikes);
    notifyListeners();
  }

  Future<void> consumeSuperLike() async {
    if (_superLikes <= 0) return;
    await setSuperLikes(_superLikes - 1);
  }

  Future<void> addSuperLikes(int amount) async {
    await setSuperLikes(_superLikes + amount);
  }

  Future<void> setRenewalDate(DateTime dt) async {
    _renewal = dt;
    await storage.saveRenewalDate(dt);
    notifyListeners();
  }
}
