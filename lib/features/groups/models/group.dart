class CommunityGroup {
  final String id;
  final String name;
  final String tagline;
  final String description;
  final List<String> tags;

  const CommunityGroup({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'tagline': tagline,
        'description': description,
        'tags': tags,
      };

  factory CommunityGroup.fromJson(Map<String, dynamic> json) {
    return CommunityGroup(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      tagline: (json['tagline'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }
}
