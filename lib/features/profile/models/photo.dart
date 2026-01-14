class Photo {
  final String id;
  final String? localPath;
  final String? remoteUrl;
  final DateTime createdAt;

  const Photo({
    required this.id,
    this.localPath,
    this.remoteUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'localPath': localPath,
    'remoteUrl': remoteUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  static Photo fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'] as String,
      localPath: json['localPath'] as String?,
      remoteUrl: json['remoteUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
