class ReflectionInsight {
  final String title;
  final String statement;
  final double value; // 0.0 to 1.0
  final String? prompt;

  const ReflectionInsight({
    required this.title,
    required this.statement,
    required this.value,
    this.prompt,
  });
}
