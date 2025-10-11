import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';
import 'navigation/main_shell.dart';

void main() {
  runApp(const ProviderScope(child: MedRewardApp()));
}

class MedRewardApp extends StatelessWidget {
  const MedRewardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedReward',
      theme: buildMedTheme(),
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}
