import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ChatHomeScreen.dart';
import 'SetupScreen.dart';

class AuthScreen extends StatefulWidget {
	const AuthScreen({super.key});

	@override
	State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
	final TextEditingController _passwordController = TextEditingController();
	int _missCount = 0;
	final int _maxMissCount = 10;
	int? _lockUntilMs;
	bool _showUsername = true;
	String? _username;
	String? _pwSalt;
	String? _pwHash;

	@override
	void initState() {
		super.initState();
		_loadState();
	}

	Future<void> _loadState() async {
		final prefs = await SharedPreferences.getInstance();
		final showUsername = prefs.getBool('show_username_on_auth') ?? true;
		setState(() {
			_username = prefs.getString('username');
			_pwSalt = prefs.getString('pw_salt');
			_pwHash = prefs.getString('pw_hash');
			_missCount = prefs.getInt('miss_count') ?? 0;
			_lockUntilMs = prefs.getInt('lock_until_ms');
			_showUsername = showUsername;
		});

		// If this is the first time showing the auth screen, persist that we've shown the username
		if (showUsername) {
			await prefs.setBool('show_username_on_auth', false);
		}
	}

	String _stretchHash(String password, String salt, {int iterations = 10000}) {
		var input = utf8.encode(salt + password);
		Digest digest = sha256.convert(input);
		for (var i = 0; i < iterations - 1; i++) {
			digest = sha256.convert(digest.bytes);
		}
		return base64Url.encode(digest.bytes);
	}

	bool get _isLocked {
		if (_lockUntilMs == null) return false;
		return DateTime.now().millisecondsSinceEpoch < _lockUntilMs!;
	}

	Future<void> _handleUnlock() async {
		if (_isLocked) {
			final remaining = _lockUntilMs! - DateTime.now().millisecondsSinceEpoch;
			final seconds = (remaining / 1000).ceil();
			_showSnackBar('Locked. Try again in ${seconds}s');
			return;
		}

		final input = _passwordController.text;
		final prefs = await SharedPreferences.getInstance();

		if (_pwSalt == null || _pwHash == null) {
			_showSnackBar('No credentials found. Please setup.');
			if (!mounted) return;
			Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SetupScreen()));
			return;
		}

		final attemptHash = _stretchHash(input, _pwSalt!);
		if (attemptHash == _pwHash) {
			// success
			await prefs.setInt('miss_count', 0);
			await prefs.remove('lock_until_ms');
			setState(() {
				_missCount = 0;
				_lockUntilMs = null;
			});
			_passwordController.clear();
			if (!mounted) return;
			Navigator.of(context).pushReplacement(
				MaterialPageRoute(builder: (context) => const ChatHomeScreen()),
			);
			return;
		}

		// failure
		_missCount++;
		await prefs.setInt('miss_count', _missCount);

		final now = DateTime.now().millisecondsSinceEpoch;
		if (_missCount >= _maxMissCount) {
			// delete data and force setup
			await prefs.clear();
			_showSnackBar('Data deleted after 10 failed attempts. Restarting setup.');
			if (!mounted) return;
			Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SetupScreen()));
			return;
		}

		if (_missCount >= 9) {
			_lockUntilMs = now + 15 * 60 * 1000;
			await prefs.setInt('lock_until_ms', _lockUntilMs!);
			_showSnackBar('Warning: multiple failed attempts. Locked for 15 minutes.');
		} else if (_missCount >= 7) {
			_lockUntilMs = now + 5 * 60 * 1000;
			await prefs.setInt('lock_until_ms', _lockUntilMs!);
			_showSnackBar('Too many attempts. Locked for 5 minutes.');
		} else if (_missCount >= 4) {
			_lockUntilMs = now + 1 * 60 * 1000;
			await prefs.setInt('lock_until_ms', _lockUntilMs!);
			_showSnackBar('Too many attempts. Locked for 1 minute.');
		} else {
			_showSnackBar('Incorrect password. Please try again.');
		}

		setState(() {});
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
									if (_username != null && _showUsername) ...[
										const SizedBox(height: 8),
										Text('User: ' + (_username ?? ''), textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9CA3AF))),
									],
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

