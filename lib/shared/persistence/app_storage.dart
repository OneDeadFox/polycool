import 'package:shared_preferences/shared_preferences.dart';

import 'json.dart';
import 'dart:convert';

import '../../features/profile/models/profile.dart';
import '../../features/profile/models/reflection.dart';

class AppStorage {
  static const _kProfileMe = 'profile.me';
  static const _kReflections = 'profile.reflections';

  static const _kIsSubscriber = 'monetization_isSubscriber';
  static const _kSuperLikes = 'monetization_superLikes';
  static const _kRenewalEpochMs = 'monetization_renewalEpochMs';
  static const _kDiscoverDismissed = 'discover_dismissed_until';
  static const _kLikedProfiles =
      'discover_liked_profiles'; // Map<String, dynamic>
  static const _kMatches = 'matches_threads'; // List<Map<String, dynamic>>
  static const _kChatPrefix = 'chat_thread_'; // chat_thread_<profileId>
  static const _kCommunityUsername = 'community_username';
  static const _kAnonymousBrowsing = 'community_anonymous_browsing';
  static const _kAnonDisclosureShown = 'community_anon_disclosure_shown';
  static const _kJoinedGroups = 'groups_joined_ids';
  static const _kGroupPosts = 'groups_posts'; // json list
  static const _kGroupsList =
      'groups_list_v1'; // json list of CommunityGroup maps
  static const _kGroupReplies = 'group_replies_v1';
  static const _kBlockedUserIds = 'blocked_user_ids';
  static const _kReports = 'reports_v1';

  List<String> loadBlockedUserIds() {
    final raw = _prefs.getString(_kBlockedUserIds);
    if (raw == null || raw.isEmpty) return const [];
    final list = decodeJsonList(raw);
    return list.map((e) => e.toString()).toList();
  }

  Future<void> saveBlockedUserIds(List<String> ids) async {
    await _prefs.setString(_kBlockedUserIds, encodeJsonList(ids));
  }

  List<Map<String, dynamic>> loadReportsRaw() {
    final raw = _prefs.getString(_kReports);
    if (raw == null || raw.isEmpty) return const [];
    return decodeJsonList(raw).cast<Map<String, dynamic>>();
  }

  Future<void> saveReportsRaw(List<Map<String, dynamic>> reports) async {
    await _prefs.setString(_kReports, encodeJsonList(reports));
  }

  List<Map<String, dynamic>> loadGroupRepliesRaw() {
    final raw = _prefs.getString(_kGroupReplies);
    if (raw == null || raw.isEmpty) return [];
    return decodeJsonList(raw);
  }

  Future<void> saveGroupRepliesRaw(List<Map<String, dynamic>> replies) async {
    await _prefs.setString(_kGroupReplies, encodeJsonList(replies));
  }

  Future<void> clearGroupRepliesRaw() async {
    await _prefs.remove(_kGroupReplies);
  }

  List<Map<String, dynamic>> loadGroupsRaw() {
    final raw = _prefs.getString(_kGroupsList);
    if (raw == null || raw.isEmpty) return [];
    return decodeJsonList(raw);
  }

  Future<void> saveGroupsRaw(List<Map<String, dynamic>> groups) async {
    await _prefs.setString(_kGroupsList, encodeJsonList(groups));
  }

  Future<void> clearGroupsRaw() async {
    await _prefs.remove(_kGroupsList);
  }

  List<String> loadJoinedGroupIds() {
    return _prefs.getStringList(_kJoinedGroups) ?? <String>[];
  }

  Future<void> saveJoinedGroupIds(List<String> ids) async {
    await _prefs.setStringList(_kJoinedGroups, ids);
  }

  List<Map<String, dynamic>> loadGroupPostsRaw() {
    final raw = _prefs.getString(_kGroupPosts);
    if (raw == null || raw.isEmpty) return [];
    final decoded = decodeJsonList(raw);
    return decoded;
  }

  Future<void> saveGroupPostsRaw(List<Map<String, dynamic>> posts) async {
    await _prefs.setString(_kGroupPosts, encodeJsonList(posts));
  }

  String? getCommunityUsername() => _prefs.getString(_kCommunityUsername);

  Future<void> setCommunityUsername(String username) async {
    await _prefs.setString(_kCommunityUsername, username);
  }

  bool getAnonymousBrowsing() => _prefs.getBool(_kAnonymousBrowsing) ?? false;

  Future<void> setAnonymousBrowsing(bool enabled) async {
    await _prefs.setBool(_kAnonymousBrowsing, enabled);
  }

  bool getAnonDisclosureShown() =>
      _prefs.getBool(_kAnonDisclosureShown) ?? false;

  Future<void> setAnonDisclosureShown(bool shown) async {
    await _prefs.setBool(_kAnonDisclosureShown, shown);
  }

  List<Map<String, dynamic>> loadChatMessages(String profileId) {
    final raw = _prefs.getString('$_kChatPrefix$profileId');
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveChatMessages(
    String profileId,
    List<Map<String, dynamic>> data,
  ) async {
    await _prefs.setString('$_kChatPrefix$profileId', jsonEncode(data));
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }

  Future<void> clearChatMessages(String profileId) async {
    await _prefs.remove('$_kChatPrefix$profileId');
  }

  Map<String, dynamic> loadLikedProfiles() {
    final raw = _prefs.getString(_kLikedProfiles);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map((k, v) => MapEntry(k.toString(), v));
  }

  Future<void> saveLikedProfiles(Map<String, dynamic> map) async {
    await _prefs.setString(_kLikedProfiles, jsonEncode(map));
  }

  List<Map<String, dynamic>> loadMatchesRaw() {
    final raw = _prefs.getString(_kMatches);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveMatchesRaw(List<Map<String, dynamic>> list) async {
    await _prefs.setString(_kMatches, jsonEncode(list));
  }

  Future<void> clearMatches() async {
    await _prefs.remove(_kMatches);
  }

  Future<void> clearDiscoverDismissed() async {
    await _prefs.remove(_kDiscoverDismissed);
  }

  Future<void> clearLikedProfiles() async {
    await _prefs.remove(_kLikedProfiles);
  }

  Map<String, int> loadDiscoverDismissedUntil() {
    final raw = _prefs.getString(_kDiscoverDismissed);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return {};
    return decoded.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }

  Future<void> saveDiscoverDismissedUntil(Map<String, int> map) async {
    await _prefs.setString(_kDiscoverDismissed, jsonEncode(map));
  }

  bool loadIsSubscriber() => _prefs.getBool(_kIsSubscriber) ?? false;
  Future<void> saveIsSubscriber(bool v) => _prefs.setBool(_kIsSubscriber, v);

  int loadSuperLikes() => _prefs.getInt(_kSuperLikes) ?? 0;
  Future<void> saveSuperLikes(int v) => _prefs.setInt(_kSuperLikes, v);

  DateTime? loadRenewalDate() {
    final ms = _prefs.getInt(_kRenewalEpochMs);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> saveRenewalDate(DateTime? dt) async {
    if (dt == null) {
      await _prefs.remove(_kRenewalEpochMs);
    } else {
      await _prefs.setInt(_kRenewalEpochMs, dt.millisecondsSinceEpoch);
    }
  }

  AppStorage._(this._prefs);

  final SharedPreferences _prefs;

  static Future<AppStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppStorage._(prefs);
  }

  Future<void> saveMe(Profile profile) async {
    await _prefs.setString(_kProfileMe, encodeJson(profile.toJson()));
  }

  Profile? loadMe() {
    final raw = _prefs.getString(_kProfileMe);
    if (raw == null) return null;
    try {
      return Profile.fromJson(decodeJson(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveReflections(List<ReflectionInsight> insights) async {
    final List<Map<String, dynamic>> data = insights
        .map((i) => i.toJson())
        .toList();

    await _prefs.setString(_kReflections, encodeJsonList(data));
  }

  List<ReflectionInsight>? loadReflections() {
    final raw = _prefs.getString(_kReflections);
    if (raw == null) return null;
    try {
      return decodeJsonList(raw).map(ReflectionInsight.fromJson).toList();
    } catch (_) {
      return null;
    }
  }
}
