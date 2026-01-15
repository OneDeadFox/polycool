import 'package:flutter/foundation.dart';

import '../../../shared/persistence/app_storage.dart';

class CommunityController extends ChangeNotifier {
  final AppStorage storage;

  // required identity for community participation
  String? _username;

  // subscriber-only toggle; still requires username
  bool _anonymousBrowsing = false;

  // one-time disclosure
  bool _anonDisclosureShown = false;

  CommunityController({required this.storage}) {
    _username = storage.getCommunityUsername();
    _anonymousBrowsing = storage.getAnonymousBrowsing();
    _anonDisclosureShown = storage.getAnonDisclosureShown();
  }

  String? get username => _username;
  bool get hasUsername => (_username ?? '').trim().isNotEmpty;

  bool get anonymousBrowsing => _anonymousBrowsing;
  bool get anonDisclosureShown => _anonDisclosureShown;

  Future<void> setUsername(String username) async {
    _username = username.trim();
    await storage.setCommunityUsername(_username!);
    notifyListeners();
  }

  Future<void> setAnonymousBrowsing(bool enabled) async {
    _anonymousBrowsing = enabled;
    await storage.setAnonymousBrowsing(enabled);
    notifyListeners();
  }

  Future<void> markAnonDisclosureShown() async {
    _anonDisclosureShown = true;
    await storage.setAnonDisclosureShown(true);
    notifyListeners();
  }
}
