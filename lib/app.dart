import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/chats_page.dart';
import 'pages/login_page.dart';
import 'pages/splash_page.dart';
import 'services/auth_service.dart';

class FlutterChatApp extends StatelessWidget {
  const FlutterChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat',
      theme: ThemeData.light(),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.isInitialized) {
          return const SplashPage();
        }

        if (auth.isAuthenticated) {
          return const ChatsPage();
        }

        return const LoginPage();
      },
    );
  }
}