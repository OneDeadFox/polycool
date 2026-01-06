import 'package:flutter/material.dart';

enum BadgeCategory {
  communication,
  consent,
  care,
  reliability,
  orientation,
  growth,
  community,
  misc,
}

class AppBadge {
  final String id;
  final String name;
  final BadgeCategory category;
  final String description;
  final IconData icon;

  const AppBadge({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.icon,
  });
}
