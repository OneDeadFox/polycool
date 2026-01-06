import 'package:flutter/material.dart';
import 'theme.dart';
import '../shared/widgets/app_scaffold.dart';


class PolyCoolApp extends StatelessWidget {
  const PolyCoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyCool',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const AppScaffold(),
    );
  }
}
