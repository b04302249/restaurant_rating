import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../developer_page.dart';
import 'launcher_view_model.dart';

class LauncherPage extends HookWidget {
  const LauncherPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = useMemoized(() => LauncherViewModel());

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Restaurant Launcher'),
            actions: [
              IconButton(
                onPressed: () => _openDeveloperPage(context, vm),
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
                TextField(
                  controller: vm.baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    border: OutlineInputBorder(),
                    hintText: 'http://192.168.22.22:8080',
                  ),
                  keyboardType: TextInputType.url,
                  enabled: !vm.isLoading,
                  onSubmitted: (_) => vm.loadRestaurants(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: vm.userIdController,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          border: OutlineInputBorder(),
                          hintText: '1',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed:
                          vm.isLoading
                              ? null
                              : vm.loadRestaurants,
                      icon: const Icon(Icons.refresh),
                      label: const Text('載入'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: vm.restaurants.isEmpty
                          ? null
                          : () => _showRandomResult(context, vm, theme),
                      icon: const Icon(Icons.casino),
                      label: const Text('隨機'),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${vm.restaurants.length} 間',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (vm.isLoading) const LinearProgressIndicator(),
                if (vm.isLoading) const SizedBox(height: 8),
                Expanded(child: _buildRestaurantContent(theme, vm)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDeveloperPage(BuildContext context, LauncherViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => DeveloperPage(
              initialBaseUrl: vm.baseUrlController.text,
            ),
      ),
    );
  }

  void _showRandomResult(BuildContext context, LauncherViewModel vm, ThemeData theme) {
    final picked = vm.pickRandomRestaurant();
    if (picked == null) return;

    final avg = vm.averageScoreFor(picked.id);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('🎲 今天吃這間！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(picked.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              if (picked.area != null && picked.area!.trim().isNotEmpty)
                Text('地區：${picked.area}'),
              if (picked.category != null && picked.category!.trim().isNotEmpty)
                Text('分類：${picked.category}'),
              if (picked.address != null && picked.address!.trim().isNotEmpty)
                Text('地址：${picked.address}'),
              const SizedBox(height: 8),
              Text(avg != null ? '平均評分：${avg.toStringAsFixed(1)} 分' : '尚無評分'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showRandomResult(context, vm, theme);
              },
              child: const Text('再抽一次'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('就決定是你了！'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRestaurantContent(ThemeData theme, LauncherViewModel vm) {
    if (vm.errorMessage != null) {
      return Center(
        child: Text(
          vm.errorMessage!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (vm.restaurants.isEmpty) {
      return const Center(child: Text('目前沒有餐廳資料'));
    }

    return ListView.separated(
      itemCount: vm.restaurants.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final restaurant = vm.restaurants[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                if (restaurant.area != null && restaurant.area!.trim().isNotEmpty)
                  Text('地區：${restaurant.area}'),
                if (restaurant.category != null && restaurant.category!.trim().isNotEmpty)
                  Text('分類：${restaurant.category}'),
                if (restaurant.address != null && restaurant.address!.trim().isNotEmpty)
                  Text('地址：${restaurant.address}'),
                if (restaurant.note != null &&
                    restaurant.note!.trim().isNotEmpty)
                  Text('備註：${restaurant.note}'),
                const SizedBox(height: 12),
                _buildRatingRow(context, restaurant.id, theme, vm),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatingRow(BuildContext context, int restaurantId, ThemeData theme, LauncherViewModel vm) {
    final avg = vm.averageScoreFor(restaurantId);
    final count = vm.ratingsFor(restaurantId).length;
    final userRating = vm.userRatingFor(restaurantId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bar_chart, size: 20, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              avg != null ? '平均 ${avg.toStringAsFixed(1)} 分 ($count 則)' : '尚無評分',
              style: theme.textTheme.bodySmall,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: vm.isSubmitting
                  ? null
                  : () => _showRatingDialog(context, restaurantId, vm),
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text('評分'),
            ),
          ],
        ),
        if (userRating != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '你的評分：${userRating.score} 分'
              '${userRating.comment != null && userRating.comment!.trim().isNotEmpty ? '  「${userRating.comment}」' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }

  void _showRatingDialog(BuildContext context, int restaurantId, LauncherViewModel vm) {
    int selectedScore = 50;
    final commentController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('為這間餐廳評分'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$selectedScore 分', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Slider(
                    value: selectedScore.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$selectedScore',
                    onChanged: (value) {
                      setDialogState(() => selectedScore = value.round());
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: '留言（選填）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
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
                    Navigator.of(dialogContext).pop();
                    vm.submitRating(
                      restaurantId: restaurantId,
                      score: selectedScore,
                      comment: commentController.text,
                    );
                  },
                  child: const Text('送出'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
