import 'package:flutter/material.dart';

import '../../response/event_response.dart';
import '../../response/restaurant_response.dart';
import '../launcher/launcher_view_model.dart';

class EventDetailPage extends StatefulWidget {
  const EventDetailPage({
    required this.event,
    required this.vm,
    super.key,
  });

  final EventResponse event;
  final LauncherViewModel vm;

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  RestaurantResponse? _pickedRestaurant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final event = widget.event;
    final vm = widget.vm;

    final restaurantName = vm.restaurants
        .where((r) => r.id == event.restaurantId)
        .firstOrNull
        ?.name;

    final probabilities = vm.computeProbabilities();
    // Sort by probability descending
    final sortedRestaurants = [...vm.restaurants]
      ..sort((a, b) =>
          (probabilities[b.id] ?? 0).compareTo(probabilities[a.id] ?? 0));

    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(event.title),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event info section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('日期：${event.eventDate}'),
                        if (event.restaurantId != null)
                          Text(restaurantName != null
                              ? '餐廳：$restaurantName'
                              : '餐廳 ID：${event.restaurantId}'),
                        if (event.participantUserIds.isNotEmpty)
                          Text('參加者：${event.participantUserIds.join(', ')}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Random picker section
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: vm.restaurants.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _pickedRestaurant = vm.pickRandomRestaurant();
                              });
                            },
                      icon: const Icon(Icons.casino),
                      label: const Text('隨機選餐廳'),
                    ),
                    if (_pickedRestaurant != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '🎲 ${_pickedRestaurant!.name}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),

                // Probability list
                Text('各餐廳機率', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Expanded(
                  child: sortedRestaurants.isEmpty
                      ? const Center(child: Text('沒有餐廳資料'))
                      : ListView.builder(
                          itemCount: sortedRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = sortedRestaurants[index];
                            final probability =
                                probabilities[restaurant.id] ?? 0.0;
                            final percent =
                                (probability * 100).toStringAsFixed(1);

                            return ListTile(
                              dense: true,
                              leading: SizedBox(
                                width: 55,
                                child: Text(
                                  '$percent%',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(restaurant.name),
                              subtitle: LinearProgressIndicator(
                                value: probability,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
