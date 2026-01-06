import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: _TopBar(title: 'Discover'),
      body: Center(child: Text('Discover (profiles list goes here)')),
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
    return AppBar(
      title: Text(title),
    );
  }
}
