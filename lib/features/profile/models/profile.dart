import 'enums.dart';
import 'photo.dart';
import 'preference_item.dart';

class Profile {
  final String id;
  final String displayName;

  final int? age;
  final String? location;

  final String? pronouns;
  final List<String> sexualOrientations;
  final List<String> seeking;

  final List<String> relationshipContextTags;
  final String? about;
  final List<String> interests;

  final List<Photo> photos;

  final List<PreferenceItem> preferences;
  final bool showPreferences;

  final ActivityVisibility activityVisibility;
  final PresenceOptIn presenceOptIn;
  final DateTime? lastActiveAt;

  final String? featuredBadgeId;
  final List<String> secondaryBadgeIds;

  const Profile({
    required this.id,
    required this.displayName,
    this.pronouns,
    this.sexualOrientations = const [],
    this.relationshipContextTags = const [],
    this.seeking = const [],
    this.age,
    this.location,
    this.about,
    this.interests = const [],
    this.photos = const [],
    this.preferences = const [],
    this.showPreferences = true,
    this.activityVisibility = ActivityVisibility.coarse,
    this.presenceOptIn = PresenceOptIn.off,
    this.lastActiveAt,
    this.featuredBadgeId,
    this.secondaryBadgeIds = const [],
  });

  bool get hasPreferences => preferences.isNotEmpty && showPreferences;

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'pronouns': pronouns,
    'sexualOrientations': sexualOrientations,
    'relationshipContextTags': relationshipContextTags,
    'seeking': seeking,
    'age': age,
    'location': location,
    'about': about,
    'interests': interests,
    'photos': photos.map((p) => p.toJson()).toList(),
    'preferences': preferences.map((p) => p.toJson()).toList(),
    'showPreferences': showPreferences,
    'activityVisibility': activityVisibility.name,
    'presenceOptIn': presenceOptIn.name,
    'lastActiveAt': lastActiveAt?.toIso8601String(),
    'featuredBadgeId': featuredBadgeId,
    'secondaryBadgeIds': secondaryBadgeIds,
  };

  static Profile fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      pronouns: json['pronouns'] as String?,
      sexualOrientations:
          (json['sexualOrientations'] as List?)?.cast<String>() ?? const [],
      relationshipContextTags:
          (json['relationshipContextTags'] as List?)?.cast<String>() ??
          const [],
      seeking: (json['seeking'] as List?)?.cast<String>() ?? const [],
      age: (json['age'] as num?)?.toInt(),
      location: json['location'] as String?,
      about: json['about'] as String?,
      interests: (json['interests'] as List?)?.cast<String>() ?? const [],
      photos: ((json['photos'] as List?) ?? const [])
          .map((e) => Photo.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      preferences: ((json['preferences'] as List?) ?? const [])
          .map(
            (e) => PreferenceItem.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      showPreferences: (json['showPreferences'] as bool?) ?? true,
      activityVisibility: ActivityVisibility.values.firstWhere(
        (v) =>
            v.name ==
            (json['activityVisibility'] as String? ??
                ActivityVisibility.coarse.name),
        orElse: () => ActivityVisibility.coarse,
      ),
      presenceOptIn: PresenceOptIn.values.firstWhere(
        (v) =>
            v.name ==
            (json['presenceOptIn'] as String? ?? PresenceOptIn.off.name),
        orElse: () => PresenceOptIn.off,
      ),
      lastActiveAt: (json['lastActiveAt'] as String?) != null
          ? DateTime.tryParse(json['lastActiveAt'] as String)
          : null,
      featuredBadgeId: json['featuredBadgeId'] as String?,
      secondaryBadgeIds:
          (json['secondaryBadgeIds'] as List?)?.cast<String>() ?? const [],
    );
  }
}
