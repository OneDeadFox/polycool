class GroupPost {
  final String id;
  final String groupId;
  final String author;
  final String text;
  final int createdAtMs;

  const GroupPost({
    required this.id,
    required this.groupId,
    required this.author,
    required this.text,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'author': author,
        'text': text,
        'createdAtMs': createdAtMs,
      };

  factory GroupPost.fromJson(Map<String, dynamic> json) {
    return GroupPost(
      id: (json['id'] ?? '') as String,
      groupId: (json['groupId'] ?? '') as String,
      author: (json['author'] ?? 'Anonymous') as String,
      text: (json['text'] ?? '') as String,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
    );
  }
}
