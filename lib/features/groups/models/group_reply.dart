class GroupReply {
  final String id;
  final String postId;

  final String text;

  // What others see (Anonymous or @username)
  final String publicAuthor;

  // Internal key for accountability (later maps to user account)
  final String internalAuthorKey;

  // v1 threading (optional): reply to another reply
  final String? replyToReplyId;
  final String? replyToPublicAuthor;

  final int createdAtMs;

  const GroupReply({
    required this.id,
    required this.postId,
    required this.text,
    required this.publicAuthor,
    required this.internalAuthorKey,
    required this.createdAtMs,
    this.replyToReplyId,
    this.replyToPublicAuthor,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'text': text,
        'publicAuthor': publicAuthor,
        'internalAuthorKey': internalAuthorKey,
        'createdAtMs': createdAtMs,
        'replyToReplyId': replyToReplyId,
        'replyToPublicAuthor': replyToPublicAuthor,
      };

  factory GroupReply.fromJson(Map<String, dynamic> json) {
    return GroupReply(
      id: (json['id'] ?? '') as String,
      postId: (json['postId'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      publicAuthor: (json['publicAuthor'] ?? 'Anonymous') as String,
      internalAuthorKey: (json['internalAuthorKey'] ?? '') as String,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      replyToReplyId: json['replyToReplyId'] as String?,
      replyToPublicAuthor: json['replyToPublicAuthor'] as String?,
    );
  }
}
