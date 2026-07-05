import 'package:flutter/material.dart';

import 'launcher/launcher.dart';

class IdentityGatePage extends StatefulWidget {
  const IdentityGatePage({super.key});

  @override
  State<IdentityGatePage> createState() => _IdentityGatePageState();
}

class _IdentityGatePageState extends State<IdentityGatePage> {
  final TextEditingController _userIdController = TextEditingController();
  String? _errorText;

  void _enterLauncher() {
    final input = _userIdController.text.trim();
    final userId = int.tryParse(input);
    if (userId == null) {
      setState(() {
        _errorText = '請輸入有效的 User ID';
      });
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => LauncherPage(initialUserId: userId),
      ),
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '確認身份',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _userIdController,
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      border: const OutlineInputBorder(),
                      errorText: _errorText,
                    ),
                    keyboardType: TextInputType.number,
                    onSubmitted: (_) => _enterLauncher(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _enterLauncher,
                    child: const Text('進入 Launcher'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
