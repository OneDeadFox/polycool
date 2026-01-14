import 'enums.dart';

class PreferenceItem {
  final String id;
  final String label;
  final PreferenceIntensity intensity;
  final bool isVisible;
  

  const PreferenceItem({
    required this.id,
    required this.label,
    required this.intensity,
    this.isVisible = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'intensity': intensity.name,
    'isVisible': isVisible,
  };

  static PreferenceItem fromJson(Map<String, dynamic> json) {
    return PreferenceItem(
      id: json['id'] as String,
      label: json['label'] as String,
      intensity: PreferenceIntensity.values.firstWhere(
        (v) => v.name == (json['intensity'] as String? ?? PreferenceIntensity.enjoys.name),
        orElse: () => PreferenceIntensity.enjoys,
      ),
      isVisible: (json['isVisible'] as bool?) ?? true,
    );
  }
}
