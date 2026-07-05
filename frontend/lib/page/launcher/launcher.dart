import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../developer_page.dart';
import '../event_detail/event_detail_page.dart';
import '../add_restaurant/add_restaurant_page.dart';
import 'launcher_view_model.dart';

part 'launcher_restaurants_tab.dart';
part 'launcher_events_tab.dart';
part 'launcher_create_event_tab.dart';

class LauncherPage extends HookWidget {
  const LauncherPage({required this.initialUserId, super.key});

  final int initialUserId;

  @override
  Widget build(BuildContext context) {
    final vm = useMemoized(
      () => LauncherViewModel(initialUserId: initialUserId),
      [initialUserId],
    );
    useListenable(vm);
    useEffect(() => vm.dispose, [vm]);

    final titleController = useTextEditingController();
    final eventDateController = useTextEditingController(
      text: _formatDate(DateTime.now()),
    );
    final participantUserIds = useState<List<int>>([]);
    final participantInputController = useTextEditingController();

    useListenable(titleController);
    useListenable(eventDateController);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restaurant Launcher'),
          actions: [
            IconButton(
              onPressed: () => _openDeveloperPage(context, vm),
              icon: const Icon(Icons.developer_mode),
              tooltip: 'Developer Page',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_circle_outline), text: '開新活動'),
              Tab(icon: Icon(Icons.restaurant), text: '餐廳總覽'),
              Tab(icon: Icon(Icons.history), text: '活動紀錄'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CreateEventTab(
              vm: vm,
              titleController: titleController,
              eventDateController: eventDateController,
              participantUserIds: participantUserIds,
              participantInputController: participantInputController,
            ),
            _RestaurantsTab(vm: vm),
            _EventsTab(vm: vm),
          ],
        ),
      ),
    );
  }

  void _openDeveloperPage(BuildContext context, LauncherViewModel vm) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DeveloperPage(initialBaseUrl: vm.baseUrlController.text),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
