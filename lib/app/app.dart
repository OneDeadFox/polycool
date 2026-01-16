import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/persistence/app_storage.dart';
import '../shared/controllers/block_controller.dart';
import '../shared/controllers/report_controller.dart';
import '../shared/controllers/monetization_controller.dart';

import '../features/discover/discover_controller.dart';
import '../features/profile/controllers/profile_controller.dart';
import '../features/profile/controllers/reflection_controller.dart';
import '../features/matches/controllers/matches_controller.dart';
import '../features/groups/controllers/groups_controller.dart';
import '../features/community/controllers/community_controller.dart';
import '../features/profile/models/profile.dart';

import 'theme/app_theme.dart';
import 'shell/main_shell.dart';

class PolycoolApp extends StatelessWidget {
  final AppStorage storage;
  const PolycoolApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Make storage available app-wide (important for v1 persistence)
        Provider<AppStorage>.value(value: storage),

        // Profile (self)
        ChangeNotifierProvider(
          create: (_) => ProfileController(
            storage: storage,
            initialProfile: const Profile(id: 'me', displayName: 'Your Name'),
          ),
        ),

        // Community reflections
        ChangeNotifierProvider(
          create: (_) => ReflectionController(storage: storage),
        ),

        // Discover feed state
        ChangeNotifierProvider(
          create: (_) => DiscoverController(storage: storage),
        ),

        ChangeNotifierProvider(
          create: (_) => MatchesController(storage: storage),
        ),

        ChangeNotifierProvider(
          create: (_) => CommunityController(storage: storage),
        ),

        ChangeNotifierProvider(
          create: (_) => GroupsController(storage: storage),
        ),

        ChangeNotifierProvider(
          create: (_) => BlockController(storage: storage),
        ),
        
        ChangeNotifierProvider(
          create: (_) => ReportController(storage: storage),
        ),

        // Monetization / Super Likes / Subscription
        ChangeNotifierProvider(
          create: (_) => MonetizationController(storage: storage),
        ),
      ],
      child: MaterialApp(
        title: 'Polycool',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const MainShell(),
      ),
    );
  }
}
