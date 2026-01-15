class CommunityGroup {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> tags;

  // v1: banner is optional local path (file picker later)
  final String? bannerPath;

  // v1: editable rules stored as one string (newline-separated)
  final String rulesText;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.tags,
    this.bannerPath,
    this.rulesText = '',
  });

  CommunityGroup copyWith({
    String? name,
    String? tagline,
    String? description,
    List<String>? tags,
    String? bannerPath,
    String? rulesText,
  }) {
    return CommunityGroup(
      id: id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      bannerPath: bannerPath ?? this.bannerPath,
      rulesText: rulesText ?? this.rulesText,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'description': description,
        'tags': tags,
        'bannerPath': bannerPath,
        'rulesText': rulesText,
      };

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      tagline: (json['tagline'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      bannerPath: json['bannerPath'] as String?,
      rulesText: (json['rulesText'] ?? '') as String,
    );
  }
}
