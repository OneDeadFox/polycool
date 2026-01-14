import 'package:flutter/foundation.dart';

import '../../../shared/persistence/app_storage.dart';
import '../models/reflection.dart';

class ReflectionController extends ChangeNotifier {
  final AppStorage storage;
  final Map<String, ReflectionInsight> _insights = {};

  ReflectionController({required this.storage}) {
    final loaded = storage.loadReflections();
    final initial = loaded ?? _defaultSeed();
    for (final i in initial) {
      _insights[i.categoryKey] = i;
    }
  }

  List<ReflectionInsight> get orderedInsights {
    return ReflectionCategories.ordered.map((key) {
      final found = _insights[key];
      if (found != null) return found;

      return ReflectionInsight(
        categoryKey: key,
        statement: 'Community insights will appear here over time.',
        barValue: 0.12,
        gentlePrompt: null,
        updatedAt: DateTime.now(),
      );
    }).toList();
  }

  Future<void> _persist() async {
    await storage.saveReflections(orderedInsights);
  }

  void setInsight(ReflectionInsight insight) {
    _insights[insight.categoryKey] = insight;
    _persist();
    notifyListeners();
  }

  void clearCategory(String key) {
    _insights.remove(key);
    _persist();
    notifyListeners();
  }

  List<ReflectionInsight> _defaultSeed() {
    return [
      ReflectionInsight(
        categoryKey: ReflectionCategories.communication,
        statement: 'Users say you communicate clearly and thoughtfully.',
        barValue: 0.78,
        gentlePrompt:
            'A good opener: “How do you like to handle check-ins and boundaries?”',
        updatedAt: DateTime.now(),
      ),
      ReflectionInsight(
        categoryKey: ReflectionCategories.reliability,
        statement: 'Users say you tend to follow through and show up consistently.',
        barValue: 0.66,
        gentlePrompt: null,
        updatedAt: DateTime.now(),
      ),
      ReflectionInsight(
        categoryKey: ReflectionCategories.personality,
        statement: 'Users say you bring warmth and curiosity into new connections.',
        barValue: 0.71,
        gentlePrompt: null,
        updatedAt: DateTime.now(),
      ),
      ReflectionInsight(
        categoryKey: ReflectionCategories.reflection,
        statement: 'Users say you’re open to feedback and personal growth.',
        barValue: 0.64,
        gentlePrompt: 'Try: “What helps you feel most supported in relationships?”',
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
