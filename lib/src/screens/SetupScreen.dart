import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatScreen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _pwCtrl = TextEditingController();
  final TextEditingController _pwConfirmCtrl = TextEditingController();
  bool _saving = false;

  String _generateSalt([int length = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _stretchHash(String password, String salt, {int iterations = 10000}) {
    var input = utf8.encode(salt + password);
    Digest digest = sha256.convert(input);
    for (var i = 0; i < iterations - 1; i++) {
      digest = sha256.convert(digest.bytes);
    }
    return base64Url.encode(digest.bytes);
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    final username = _nameCtrl.text.trim();
    final salt = _generateSalt();
    final hash = _stretchHash(_pwCtrl.text, salt);

    await prefs.setString('username', username);
    await prefs.setString('pw_salt', salt);
    await prefs.setString('pw_hash', hash);
    await prefs.setBool('is_setup', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ChatScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initial Setup'), backgroundColor: const Color(0xFF161B26)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Create username and password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Username'),
                        maxLength: 32,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                      ),
                      TextFormField(
                        controller: _pwCtrl,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.length < 6) return 'Password must be >= 6 chars';
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _pwConfirmCtrl,
                        decoration: const InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: (v) {
                          if (v != _pwCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveCredentials,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
                          child: _saving ? const CircularProgressIndicator() : const Text('Save and Continue'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
