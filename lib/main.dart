import 'package:flutter/material.dart';

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
          surface: const Color(0xFF161B26),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _passwordController = TextEditingController();
  int _missCount = 0;
  final int _maxMissCount = 10;
  bool _isLocked = false;

  void _handleUnlock() {
    if (_isLocked) return;

    final input = _passwordController.text;

    if (input == "secret123") {
      setState(() {
        _missCount = 0;
      });
      _passwordController.clear();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else {
      setState(() {
        _missCount++;
        if (_missCount >= _maxMissCount) {
          _isLocked = true;
        }
      });

      _showSnackBar(
        _isLocked 
          ? 'The date was completely deleted after 10 failed attempts.' 
          : 'Incorrect password. Please try again.'
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: const Color(0xFF161B26)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    enabled: !_isLocked,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter password...',
                      hintStyle: TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: Color(0xFF0B0F19),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLocked ? null : _handleUnlock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isLocked ? 'LOCKED' : 'UNLOCK', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (_missCount > 0) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Failed Attempts: $_missCount / $_maxMissCount',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _isLocked ? Colors.red : Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mope'),
        backgroundColor: const Color(0xFF161B26),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to Mope!',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
        ),
      ),
    );
  }
}