part of 'launcher.dart';

class _CreateEventTab extends StatelessWidget {
  const _CreateEventTab({
    required this.vm,
    required this.titleController,
    required this.eventDateController,
    required this.participantUserIds,
    required this.participantInputController,
  });

  final LauncherViewModel vm;
  final TextEditingController titleController;
  final TextEditingController eventDateController;
  final ValueNotifier<List<int>> participantUserIds;
  final TextEditingController participantInputController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vm.eventErrorMessage != null) ...[
            Text(
              vm.eventErrorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: '活動標題',
              border: OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: eventDateController,
            decoration: InputDecoration(
              labelText: '活動日期',
              border: const OutlineInputBorder(),
              hintText: 'yyyy-MM-dd',
              suffixIcon: IconButton(
                onPressed: () => _pickEventDate(context),
                icon: const Icon(Icons.calendar_today),
                tooltip: '選擇日期',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('參加者', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: participantInputController,
                  decoration: const InputDecoration(
                    labelText: 'User ID',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _addParticipant(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addParticipant,
                icon: const Icon(Icons.person_add),
                tooltip: '加入參加者',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: participantUserIds.value
                .map(
                  (uid) => Chip(
                    label: Text('User $uid'),
                    onDeleted: () {
                      participantUserIds.value = [
                        ...participantUserIds.value.where((id) => id != uid),
                      ];
                    },
                  ),
                )
                .toList(),
          ),
          if (participantUserIds.value.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '尚未加入任何參加者',
                style: theme.textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: vm.isSubmitting ||
                    titleController.text.trim().isEmpty ||
                    eventDateController.text.trim().isEmpty
                ? null
                : () async {
                    await vm.createEvent(
                      title: titleController.text.trim(),
                      eventDate: eventDateController.text.trim(),
                      participantUserIds: participantUserIds.value,
                    );
                    if (!context.mounted || vm.eventErrorMessage != null) {
                      return;
                    }
                    titleController.clear();
                    eventDateController.text = LauncherPage._formatDate(DateTime.now());
                    participantUserIds.value = [];
                    DefaultTabController.of(context).animateTo(2);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('活動已建立')),
                    );
                  },
            icon: const Icon(Icons.add),
            label: Text(vm.isSubmitting ? '建立中...' : '建立活動'),
          ),
        ],
      ),
    );
  }

  void _addParticipant() {
    final userId = int.tryParse(participantInputController.text.trim());
    if (userId == null) return;
    if (!participantUserIds.value.contains(userId)) {
      participantUserIds.value = [...participantUserIds.value, userId];
    }
    participantInputController.clear();
  }

  Future<void> _pickEventDate(BuildContext context) async {
    final initialDate = DateTime.tryParse(eventDateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      eventDateController.text = LauncherPage._formatDate(picked);
    }
  }
}
