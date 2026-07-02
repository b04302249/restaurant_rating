import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/http_request_utils.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key, required this.initialBaseUrl});

  final String initialBaseUrl;

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  late final RestaurantApiClient _apiClient;
  late final TextEditingController _baseUrlController;

  bool _isLoading = false;
  String _result = '按下按鈕後會顯示 192.168.22.22:8080 的回應';

  @override
  void initState() {
    super.initState();
    _apiClient = RestaurantApiClient();
    _baseUrlController = TextEditingController(text: widget.initialBaseUrl);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadPing() async {
    await _runRequest(
      label: 'GET /api/ping',
      request: () async =>
          (await _apiClient.fetchPing(_baseUrlController.text)).toJson(),
    );
  }

  Future<void> _loadRoutes() async {
    await _runRequest(
      label: 'GET /api/routes',
      request: () async =>
          (await _apiClient.fetchRoutes(_baseUrlController.text)).toJson(),
    );
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _result = '讀取中...\n${_baseUrlController.text}';
    });

    try {
      final users = await _apiClient.fetchUsers(_baseUrlController.text);
      const encoder = JsonEncoder.withIndent('  ');

      if (!mounted) return;

      setState(() {
        _result = 'GET /api/users\n${encoder.convert(users)}';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _result = 'GET /api/users\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _runRequest({
    required String label,
    required Future<Map<String, dynamic>> Function() request,
  }) async {
    setState(() {
      _isLoading = true;
      _result = '讀取中...\n${_baseUrlController.text}';
    });

    try {
      final response = await request();
      const encoder = JsonEncoder.withIndent('  ');

      if (!mounted) {
        return;
      }

      setState(() {
        _result = '$label\n${encoder.convert(response)}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _result = '$label\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreateRestaurantDialog() {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    final categoryController = TextEditingController();
    final addressController = TextEditingController();
    final noteController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('新增餐廳'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '餐廳名稱 *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: areaController,
                  decoration: const InputDecoration(
                    labelText: '地區（選填）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: '分類（選填）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: '地址（選填）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    labelText: '備註（選填）',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final area = areaController.text.trim();
                final category = categoryController.text.trim();
                final address = addressController.text.trim();
                final note = noteController.text.trim();

                if (name.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop();
                _createRestaurant(
                  name: name,
                  area: area.isEmpty ? null : area,
                  category: category.isEmpty ? null : category,
                  address: address.isEmpty ? null : address,
                  note: note.isEmpty ? null : note,
                );
              },
              child: const Text('新增'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createRestaurant({
    required String name,
    String? area,
    String? category,
    String? address,
    String? note,
  }) async {
    await _runRequest(
      label: 'POST /api/restaurants',
      request: () async => (await _apiClient.createRestaurant(
        _baseUrlController.text,
        name: name,
        area: area,
        category: category,
        address: address,
        note: note,
      )).toJson(),
    );
  }

  void _showCreateUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('註冊 User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '名稱 *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();

                if (name.isEmpty || email.isEmpty) return;

                Navigator.of(dialogContext).pop();
                _createUser(name: name, email: email);
              },
              child: const Text('註冊'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createUser({
    required String name,
    required String email,
  }) async {
    setState(() {
      _isLoading = true;
      _result = '讀取中...\n${_baseUrlController.text}';
    });

    try {
      final response = await _apiClient.createUser(
        _baseUrlController.text,
        name: name,
        email: email,
      );
      const encoder = JsonEncoder.withIndent('  ');

      if (!mounted) return;

      setState(() {
        _result = 'POST /api/users\n${encoder.convert(response)}';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _result = 'POST /api/users\n$error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Developer Page')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '預設 Base URL: ${_apiClient.defaultBaseUrl}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _baseUrlController,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(),
                hintText: 'http://192.168.22.22:8080',
              ),
              keyboardType: TextInputType.url,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 8),
            Text(
              '後端可用 API：/api/ping、/api/routes、/api/users、/api/restaurants、/api/ratings、/api/events',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '預設會連到 192.168.22.22:8080，需要時可手動改成其他位址。',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: _isLoading ? null : _loadPing,
                  child: const Text('測試 /api/ping'),
                ),
                OutlinedButton(
                  onPressed: _isLoading ? null : _loadRoutes,
                  child: const Text('讀取 /api/routes'),
                ),

                FilledButton.icon(
                  onPressed: _isLoading ? null : _showCreateRestaurantDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('新增餐廳'),
                ),
                OutlinedButton(
                  onPressed: _isLoading ? null : _loadUsers,
                  child: const Text('查看 Users'),
                ),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _showCreateUserDialog,
                  icon: const Icon(Icons.person_add),
                  label: const Text('註冊 User'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_isLoading) const LinearProgressIndicator(),
            if (_isLoading) const SizedBox(height: 16),
            Text('回應內容', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
