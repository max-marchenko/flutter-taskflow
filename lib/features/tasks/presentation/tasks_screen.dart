import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../core/widgets/taskflow_components.dart';
import '../../../data/demo/demo_store.dart';
import '../../../models/taskflow_models.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final canCreate = PolicyScope.policy.canCreateTask(store.currentRole);
    final tasks = store.visibleTasks;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.selectedProject.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text('List and board views for project tasks'),
                ],
              ),
            ),
            PermissionGate(
              allowed: canCreate,
              fallback: const Tooltip(
                message: 'Viewers have read-only access',
                child: Icon(Icons.lock_outline),
              ),
              child: FilledButton.icon(
                onPressed: () => _showTaskDialog(context),
                icon: const Icon(Icons.add_task),
                label: const Text('New task'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: store.setTaskQuery,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search tasks',
                ),
              ),
            ),
            DropdownButton<TaskStatus?>(
              value: store.statusFilter,
              hint: const Text('All statuses'),
              items: [
                const DropdownMenuItem<TaskStatus?>(
                  child: Text('All statuses'),
                ),
                for (final status in TaskStatus.values)
                  DropdownMenuItem(value: status, child: Text(status.label)),
              ],
              onChanged: store.setStatusFilter,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (tasks.isEmpty)
          EmptyState(
            title: 'No tasks found',
            message: store.currentRole == WorkspaceRole.viewer
                ? 'This workspace is read-only for your current demo role.'
                : 'Create a task or clear filters to keep the project moving.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [for (final task in tasks) TaskCard(task: task)],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 420,
                    child: Column(
                      children: [
                        for (final task in tasks) TaskCard(task: task),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _KanbanBoard(tasks: tasks)),
                ],
              );
            },
          ),
      ],
    );
  }

  void _showTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final store = DemoScope.of(context);
        return AlertDialog(
          title: const Text('Create task'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                store.addTask(
                  titleController.text.trim(),
                  descriptionController.text.trim(),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({required this.task, super.key});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final assignee = task.assigneeId == null
        ? null
        : store.users.firstWhere((user) => user.id == task.assigneeId);
    final canEdit = PolicyScope.policy.canEditTask(
      role: store.currentRole,
      task: task,
      userId: store.currentUserId,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (assignee != null)
                  PersonAvatar(
                    initials: assignee.initials,
                    tooltip: assignee.name,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip.task(task.status),
                PriorityChip(task.priority),
                for (final labelId in task.labelIds)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      store.labels
                          .firstWhere((label) => label.id == labelId)
                          .name,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.dueDate.month}/${task.dueDate.day}/${task.dueDate.year}',
                ),
                const Spacer(),
                if (canEdit)
                  DropdownButton<TaskStatus>(
                    value: task.status,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final status in TaskStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                    onChanged: (status) {
                      if (status != null) store.updateTaskStatus(task, status);
                    },
                  )
                else
                  const Tooltip(
                    message: 'Read-only for this role',
                    child: Icon(Icons.lock_outline, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _KanbanBoard extends StatelessWidget {
  const _KanbanBoard({required this.tasks});

  final List<TaskItem> tasks;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final status in TaskStatus.values.where(
            (status) => status != TaskStatus.archived,
          ))
            Container(
              width: 250,
              margin: const EdgeInsets.only(right: 12),
              child: AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final task in tasks.where(
                      (task) => task.status == status,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• ${task.title}'),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
