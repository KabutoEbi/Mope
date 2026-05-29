import 'package:flutter/material.dart';
import 'src/screens/AuthScreen.dart';
import 'src/screens/SetupScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Mope());
}

class Mope extends StatelessWidget {
  const Mope({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mope',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          surface: Color(0xFF161B26),
        ),
      ),
      // Development helper: set `forceShowSetup` true to always show setup on startup.
      home: FutureBuilder<bool>(
        future: _isSetup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final isSetup = snapshot.data ?? false;
          const bool forceShowSetup = true; // <-- set to false to restore normal behavior
          return (!forceShowSetup && isSetup) ? const AuthScreen() : const SetupScreen();
        },
      ),
    );
  }

  Future<bool> _isSetup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_setup') ?? false;
  }
}