import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatHomeScreen.dart';

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
  String? _generatedId;

  String _generateSalt([int length = 16]) {
    final rnd = Random.secure();
    final bytes = List<int>.generate(length, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _generateId([int length = 12]) {
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

  @override
  void initState() {
    super.initState();
    _initGeneratedId();
  }

  Future<void> _initGeneratedId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('user_id');
    if (existing != null) {
      setState(() => _generatedId = existing);
      return;
    }
    final id = _generateId();
    await prefs.setString('user_id', id);
    setState(() => _generatedId = id);
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final prefs = await SharedPreferences.getInstance();
    final username = _nameCtrl.text.trim();
    final salt = _generateSalt();
    final hash = _stretchHash(_pwCtrl.text, salt);
    final id = _generatedId ?? _generateId();

    await prefs.setString('username', username);
    await prefs.setString('pw_salt', salt);
    await prefs.setString('pw_hash', hash);
    await prefs.setString('user_id', id);
    await prefs.setBool('is_setup', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ChatHomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Initial Setup'), backgroundColor: const Color(0xFF161B26)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      if (_generatedId != null) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Your ID: ', style: TextStyle(color: Color(0xFF9CA3AF))),
                            Expanded(child: SelectableText(_generatedId!, style: const TextStyle(color: Colors.white))),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Username',
                          hintStyle: TextStyle(color: Color(0xFF64748B)),
                          isDense: true,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        maxLength: 32,
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pwCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Color(0xFF64748B)),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v == null || v.length < 6) return 'Password must be >= 6 chars';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pwConfirmCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(color: Color(0xFF64748B)),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        ),
                        obscureText: true,
                        validator: (v) {
                          if (v != _pwCtrl.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _saveCredentials,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: Colors.black),
                          child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save and Continue'),
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
