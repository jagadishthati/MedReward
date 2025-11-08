import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medreward/providers/app_providers.dart';
import 'package:medreward/navigation/main_shell.dart';
import 'package:medreward/screens/login_screen.dart'; // Add this import
import 'theme.dart';

void main() {
  runApp(const ProviderScope(child: MedRewardApp()));
}

class MedRewardApp extends ConsumerWidget {
  const MedRewardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);

    return MaterialApp(
      title: 'MedReward',
      theme: buildMedTheme(),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const MainShell() : const LoginScreen(), // Fixed here
    );
  }
}
