part of 'launcher.dart';

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.vm});

  final LauncherViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restaurantNames = {
      for (final restaurant in vm.restaurants) restaurant.id: restaurant.name,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('共 ${vm.events.length} 筆活動', style: theme.textTheme.titleSmall),
              const Spacer(),
              IconButton(
                onPressed: vm.loadEvents,
                icon: const Icon(Icons.refresh),
                tooltip: '重新整理活動',
              ),
            ],
          ),
          if (vm.eventErrorMessage != null) ...[
            Text(
              vm.eventErrorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Expanded(
            child: vm.events.isEmpty
                ? const Center(child: Text('目前沒有活動資料'))
                : ListView.separated(
                    itemCount: vm.events.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final event = vm.events[index];
                      final restaurantName = restaurantNames[event.restaurantId];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 4),
                              Text('日期：${event.eventDate}'),
                              if (event.restaurantId != null)
                                Text(
                                  restaurantName != null
                                      ? '餐廳：$restaurantName (#${event.restaurantId})'
                                      : '餐廳 ID：${event.restaurantId}',
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => EventDetailPage(
                                  event: event,
                                  vm: vm,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
