import 'package:flutter/foundation.dart';

@immutable
class ReflectionInsight {
  final String categoryKey; // communication, reliability, personality, reflection
  final String statement;
  final double barValue; // 0..1 (UI caps visual)
  final String? gentlePrompt;
  final DateTime updatedAt;

  const ReflectionInsight({
    required this.categoryKey,
    required this.statement,
    required this.barValue,
    this.gentlePrompt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'categoryKey': categoryKey,
        'statement': statement,
        'barValue': barValue,
        'gentlePrompt': gentlePrompt,
        'updatedAt': updatedAt.toIso8601String(),
      };

  static ReflectionInsight fromJson(Map<String, dynamic> json) {
    return ReflectionInsight(
      categoryKey: json['categoryKey'] as String,
      statement: json['statement'] as String,
      barValue: (json['barValue'] as num).toDouble(),
      gentlePrompt: json['gentlePrompt'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ReflectionCategories {
  static const communication = 'communication';
  static const reliability = 'reliability';
  static const personality = 'personality';
  static const reflection = 'reflection';

  static const ordered = [
    communication,
    reliability,
    personality,
    reflection,
  ];
}
