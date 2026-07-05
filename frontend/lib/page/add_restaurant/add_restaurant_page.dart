import 'package:flutter/material.dart';

import '../../response/restaurant_response.dart';
import '../../utils/http_request_utils.dart';
import '../launcher/launcher_view_model.dart';

class AddRestaurantPage extends StatefulWidget {
  const AddRestaurantPage({required this.vm, super.key});

  final LauncherViewModel vm;

  @override
  State<AddRestaurantPage> createState() => _AddRestaurantPageState();
}

class _AddRestaurantPageState extends State<AddRestaurantPage> {
  List<RestaurantResponse> _allRestaurants = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _pendingRestaurantId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final api = RestaurantApiClient();
      _allRestaurants = await api.fetchRestaurants(widget.vm.baseUrlController.text);
    } catch (error, stackTrace) {
      _error = '$error\n$stackTrace';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _isInUserList(int restaurantId) {
    return widget.vm.restaurants.any((r) => r.id == restaurantId);
  }

  Future<void> _toggleRestaurant(RestaurantResponse restaurant) async {
    setState(() {
      _isSaving = true;
      _pendingRestaurantId = restaurant.id;
      _error = null;
    });

    try {
      if (_isInUserList(restaurant.id)) {
        await widget.vm.removeRestaurant(restaurant.id);
      } else {
        await widget.vm.addRestaurant(restaurant.id);
      }
      if (widget.vm.errorMessage != null) {
        _error = widget.vm.errorMessage;
      }
    } catch (error, stackTrace) {
      _error = '$error\n$stackTrace';
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _pendingRestaurantId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加餐廳'),
        actions: [
          IconButton(
            onPressed: _isLoading || _isSaving ? null : _loadAll,
            icon: const Icon(Icons.refresh),
            tooltip: '重新整理',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _allRestaurants.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allRestaurants.isEmpty) {
      return Center(
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _loadAll,
          icon: const Icon(Icons.refresh),
          label: const Text('重新載入餐廳列表'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _allRestaurants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final restaurant = _allRestaurants[index];
        final isAdded = _isInUserList(restaurant.id);
        final isPending = _pendingRestaurantId == restaurant.id;

        return Card(
          child: ListTile(
            title: Text(restaurant.name),
            subtitle: restaurant.area == null || restaurant.area!.trim().isEmpty
                ? const Text('未提供地區')
                : Text('地區：${restaurant.area}'),
            trailing: isPending
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton.filledTonal(
                    onPressed: _isSaving ? null : () => _toggleRestaurant(restaurant),
                    icon: Icon(isAdded ? Icons.check : Icons.add),
                    tooltip: isAdded ? '從我的清單移除' : '加入我的清單',
                  ),
          ),
        );
      },
    );
  }
}
