class MatchThread {
  final String profileId;
  final String displayName;
  final String? photoPath; // optional local path
  final String? lastMessage;
  final int updatedAtMs;

  const MatchThread({
    required this.profileId,
    required this.displayName,
    this.photoPath,
    this.lastMessage,
    required this.updatedAtMs,
  });

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'displayName': displayName,
        'photoPath': photoPath,
        'lastMessage': lastMessage,
        'updatedAtMs': updatedAtMs,
      };

  factory MatchThread.fromJson(Map<String, dynamic> json) {
    return MatchThread(
      profileId: (json['profileId'] ?? '') as String,
      displayName: (json['displayName'] ?? '') as String,
      photoPath: json['photoPath'] as String?,
      lastMessage: json['lastMessage'] as String?,
      updatedAtMs: (json['updatedAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}
