import 'package:flutter/material.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _TopBar(title: 'Matches'),
      body: Center(child: Text('Matches + chat list goes here')),
    );
  }
}

class _TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(title));
  }
}
