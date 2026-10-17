import 'package:flutter/material.dart';

import 'state/app_state.dart';
import 'ui/home_shell.dart';
import 'ui/onboarding_screen.dart';
import 'ui/theme.dart';

void main() {
  final state = AppState()..load();
  runApp(SaathiApp(state: state));
}

class SaathiApp extends StatelessWidget {
  const SaathiApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'Saathi AI',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light, state.lang),
        darkTheme: buildTheme(Brightness.dark, state.lang),
        home: !state.loaded
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : state.profile == null
                ? OnboardingScreen(key: const ValueKey('signup'), state: state)
                : HomeShell(state: state),
      ),
    );
  }
}
