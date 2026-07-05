part of 'launcher.dart';

class _RestaurantsTab extends StatelessWidget {
  const _RestaurantsTab({required this.vm});

  final LauncherViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: vm.baseUrlController,
            decoration: const InputDecoration(
              labelText: 'Base URL',
              border: OutlineInputBorder(),
              hintText: 'http://192.168.0.116:8080',
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
                onPressed: vm.isLoading ? null : vm.loadRestaurants,
                icon: const Icon(Icons.refresh),
                label: const Text('載入'),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: vm.isLoading ? null : () => _openAddRestaurantPage(context),
                icon: const Icon(Icons.add_business),
                tooltip: '添加餐廳',
              ),
              const SizedBox(width: 4),
              Text(
                '${vm.restaurants.length} 間',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (vm.isLoading) const LinearProgressIndicator(),
          if (vm.isLoading) const SizedBox(height: 8),
          Expanded(child: _buildRestaurantContent(context, theme)),
        ],
      ),
    );
  }

  Widget _buildRestaurantContent(BuildContext context, ThemeData theme) {
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('尚未加入任何餐廳，點擊右上角添加'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: vm.isLoading ? null : () => _openAddRestaurantPage(context),
              icon: const Icon(Icons.add_business),
              label: const Text('添加餐廳'),
            ),
          ],
        ),
      );
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
                if (restaurant.category != null &&
                    restaurant.category!.trim().isNotEmpty)
                  Text('分類：${restaurant.category}'),
                if (restaurant.address != null &&
                    restaurant.address!.trim().isNotEmpty)
                  Text('地址：${restaurant.address}'),
                const SizedBox(height: 12),
                _buildRatingRow(context, restaurant.id, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openAddRestaurantPage(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddRestaurantPage(vm: vm),
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context, int restaurantId, ThemeData theme) {
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
                  : () => _showRatingDialog(context, restaurantId),
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

  void _showRatingDialog(BuildContext context, int restaurantId) {
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
                  Text(
                    '$selectedScore 分',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
