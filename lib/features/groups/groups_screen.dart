import 'package:flutter/material.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _TopBar(title: 'Groups'),
      body: Center(child: Text('Groups feed goes here')),
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
