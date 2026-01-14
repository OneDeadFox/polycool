import 'package:flutter/foundation.dart';

import '../../../shared/persistence/app_storage.dart';
import 'dart:io';
import '../models/photo.dart';

import '../models/preference_item.dart';
import '../models/profile.dart';

class ProfileController extends ChangeNotifier {
  final AppStorage storage;
  Profile _me;

  ProfileController({required this.storage, required Profile initialProfile})
    : _me = initialProfile {
    final loaded = storage.loadMe();
    if (loaded != null) _me = loaded;
  }

  Profile get me => _me;

  Future<void> _persist() async {
    await storage.saveMe(_me);
  }

  Future<void> addPhotoFromPath(String path) async {
    final newPhoto = Photo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      localPath: path,
      createdAt: DateTime.now(),
    );

    final updated = List<Photo>.from(_me.photos)..add(newPhoto);

    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: updated,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> reorderPhotos(int oldIndex, int newIndex) async {
    final list = List.of(_me.photos);
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex < 0 || newIndex >= list.length) return;

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: list,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> updateAge(int? age) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> updateLocation(String? location) async {
    final cleaned = (location ?? '').trim();

    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: cleaned.isEmpty ? null : cleaned,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> deletePhotoById(String id) async {
    final updated = _me.photos.where((p) => p.id != id).toList();

    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: updated,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> updateDisplayName(String name) async {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return;

    _me = Profile(
      id: _me.id,
      displayName: cleaned,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> updateAbout(String? about) async {
    final cleaned = (about ?? '').trim();

    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: cleaned.isEmpty ? null : cleaned,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> updatePronouns(String? pronouns) async {
    final cleaned = (pronouns ?? '').trim();

    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: cleaned.isEmpty ? null : cleaned,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> setSexualOrientations(List<String> values) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: values,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> setRelationshipContextTags(List<String> values) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: values,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> setInterests(List<String> values) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: values,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> setPreferences(List<PreferenceItem> values) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: values,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> setSeeking(List<String> values) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: _me.showPreferences,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,

      // ✅ new
      seeking: values,
    );

    await _persist();
    notifyListeners();
  }

  Future<void> setShowPreferences(bool show) async {
    _me = Profile(
      id: _me.id,
      displayName: _me.displayName,
      pronouns: _me.pronouns,
      sexualOrientations: _me.sexualOrientations,
      relationshipContextTags: _me.relationshipContextTags,
      seeking: _me.seeking,
      about: _me.about,
      interests: _me.interests,
      photos: _me.photos,
      preferences: _me.preferences,
      showPreferences: show,
      activityVisibility: _me.activityVisibility,
      presenceOptIn: _me.presenceOptIn,
      lastActiveAt: _me.lastActiveAt,
      featuredBadgeId: _me.featuredBadgeId,
      secondaryBadgeIds: _me.secondaryBadgeIds,
      age: _me.age,
      location: _me.location,
    );

    await _persist();
    notifyListeners();
  }
}
