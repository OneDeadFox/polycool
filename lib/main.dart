import 'package:flutter/material.dart';
import 'app/app.dart';
import 'shared/persistence/app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await AppStorage.create();
  runApp(PolycoolApp(storage: storage));
}
