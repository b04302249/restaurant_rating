import 'package:flutter/material.dart';

import '../response/restaurant_response.dart';
import '../utils/http_request_utils.dart';
import 'developer_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Rating',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LauncherPage(),
    );
  }
}

class LauncherPage extends StatefulWidget {
  const LauncherPage({super.key});

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  late final RestaurantApiClient _apiClient;
  late final TextEditingController _baseUrlController;

  bool _isLoading = false;
  String? _errorMessage;
  List<RestaurantResponse> _restaurants = const [];

  @override
  void initState() {
    super.initState();
    _apiClient = RestaurantApiClient();
    _baseUrlController = TextEditingController(text: _apiClient.defaultBaseUrl);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurants();
    });
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final restaurants = await _apiClient.fetchRestaurants(
        _baseUrlController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _restaurants = restaurants;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = '$error';
        _restaurants = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openDeveloperPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeveloperPage(initialBaseUrl: _baseUrlController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Launcher'),
        actions: [
          IconButton(
            onPressed: _openDeveloperPage,
            icon: const Icon(Icons.developer_mode),
            tooltip: 'Developer Page',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '顯示後端 `/api/restaurants` 的所有餐廳',
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
              onSubmitted: (_) => _loadRestaurants(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _isLoading ? null : _loadRestaurants,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新載入餐廳'),
                ),
                const SizedBox(width: 12),
                Text(
                  '目前共 ${_restaurants.length} 間',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const LinearProgressIndicator(),
            if (_isLoading) const SizedBox(height: 16),
            Expanded(child: _buildRestaurantContent(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantContent(ThemeData theme) {
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return const Center(child: Text('目前沒有餐廳資料'));
    }

    return ListView.separated(
      itemCount: _restaurants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = _restaurants[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('地區：${restaurant.area}'),
                Text('分類：${restaurant.category}'),
                Text('地址：${restaurant.address}'),
                if (restaurant.note != null &&
                    restaurant.note!.trim().isNotEmpty)
                  Text('備註：${restaurant.note}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
