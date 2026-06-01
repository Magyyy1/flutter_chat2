import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/pocketbase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PocketBaseService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController()..initialize(),
      child: const FlutterChatApp(),
    ),
  );
}
