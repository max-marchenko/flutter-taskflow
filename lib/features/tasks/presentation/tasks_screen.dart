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
        AppPageHeader(
          title: store.selectedProject.name,
          subtitle:
              'Review tasks, update status, inspect details, and switch roles to verify access.',
          action: PermissionGate(
            allowed: canCreate,
            fallback: Semantics(
              label: 'Task creation unavailable for viewer role',
              child: const Tooltip(
                message: 'Viewers have read-only access',
                child: Icon(Icons.lock_outline),
              ),
            ),
            child: FilledButton.icon(
              onPressed: () => _showTaskDialog(context),
              icon: const Icon(Icons.add_task),
              label: const Text('New task'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _TaskFilters(store: store),
        const SizedBox(height: 16),
        if (tasks.isEmpty)
          EmptyState(
            title: 'No tasks found',
            message: store.currentRole == WorkspaceRole.viewer
                ? 'This workspace is read-only for your current demo role.'
                : 'Create a task or clear filters to keep the project moving.',
            action: TextButton.icon(
              onPressed: store.clearTaskFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear filters'),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    for (final task in tasks)
                      TaskCard(
                        task: task,
                        selected: store.selectedTask?.id == task.id,
                        onTap: () => _showTaskDetailSheet(context, task),
                      ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 420,
                    child: Column(
                      children: [
                        for (final task in tasks)
                          TaskCard(
                            task: task,
                            selected: store.selectedTask?.id == task.id,
                            onTap: () => store.selectTask(task.id),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _KanbanBoard(tasks: tasks),
                        const SizedBox(height: 16),
                        TaskDetailPanel(task: store.selectedTask),
                      ],
                    ),
                  ),
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
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
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

  void _showTaskDetailSheet(BuildContext context, TaskItem task) {
    final store = DemoScope.of(context);
    store.selectTask(task.id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(child: TaskDetailPanel(task: task)),
      ),
    );
  }
}

class _TaskFilters extends StatelessWidget {
  const _TaskFilters({required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final fullWidth = constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: compact ? fullWidth : 300,
              child: TextField(
                onChanged: store.setTaskQuery,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search tasks',
                ),
              ),
            ),
            SizedBox(
              width: compact ? fullWidth : 190,
              child: DropdownButtonFormField<TaskStatus?>(
                initialValue: store.statusFilter,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem<TaskStatus?>(
                    child: Text('All statuses'),
                  ),
                  for (final status in TaskStatus.values)
                    DropdownMenuItem(value: status, child: Text(status.label)),
                ],
                onChanged: store.setStatusFilter,
              ),
            ),
            SizedBox(
              width: compact ? fullWidth : 190,
              child: DropdownButtonFormField<TaskPriority?>(
                initialValue: store.priorityFilter,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  const DropdownMenuItem<TaskPriority?>(
                    child: Text('All priorities'),
                  ),
                  for (final priority in TaskPriority.values)
                    DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                ],
                onChanged: store.setPriorityFilter,
              ),
            ),
            SizedBox(
              width: compact ? fullWidth : 210,
              child: DropdownButtonFormField<TaskSort>(
                initialValue: store.taskSort,
                decoration: const InputDecoration(labelText: 'Sort by'),
                items: [
                  for (final sort in TaskSort.values)
                    DropdownMenuItem(value: sort, child: Text(sort.label)),
                ],
                onChanged: (value) {
                  if (value != null) store.setTaskSort(value);
                },
              ),
            ),
            TextButton.icon(
              onPressed: store.clearTaskFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final TaskItem task;
  final bool selected;
  final VoidCallback? onTap;

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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AppSectionCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selected)
                Container(
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
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
                  Icon(Icons.event, size: 16, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(_dateLabel(task.dueDate)),
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
                        if (status != null) {
                          store.updateTaskStatus(task, status);
                        }
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
      ),
    );
  }

  String _dateLabel(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
                      '${status.label} (${tasks.where((task) => task.status == status).length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (tasks.where((task) => task.status == status).isEmpty)
                      Text(
                        'No tasks',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      for (final task in tasks.where(
                        (task) => task.status == status,
                      ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _KanbanTaskTile(task: task),
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

class _KanbanTaskTile extends StatelessWidget {
  const _KanbanTaskTile({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    return InkWell(
      onTap: () => store.selectTask(task.id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            PriorityChip(task.priority),
          ],
        ),
      ),
    );
  }
}

class TaskDetailPanel extends StatelessWidget {
  const TaskDetailPanel({required this.task, super.key});

  final TaskItem? task;

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return const EmptyState(
        title: 'No task selected',
        message: 'Select a task to inspect its comments, labels, and activity.',
      );
    }
    final store = DemoScope.of(context);
    final assignee = task!.assigneeId == null
        ? null
        : store.users.firstWhere((user) => user.id == task!.assigneeId);
    final canEdit = PolicyScope.policy.canEditTask(
      role: store.currentRole,
      task: task!,
      userId: store.currentUserId,
    );
    final comments = store.commentsFor(task!.id);
    return AppSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task!.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (canEdit)
                DropdownButton<TaskStatus>(
                  value: task!.status,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final status in TaskStatus.values)
                      DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                  ],
                  onChanged: (status) {
                    if (status != null) store.updateTaskStatus(task!, status);
                  },
                )
              else
                const Tooltip(
                  message: 'Read-only for this role',
                  child: Icon(Icons.lock_outline),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(task!.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip.task(task!.status),
              PriorityChip(task!.priority),
              if (assignee != null)
                Chip(
                  avatar: PersonAvatar(
                    initials: assignee.initials,
                    tooltip: assignee.name,
                  ),
                  label: Text(assignee.name),
                ),
              for (final labelId in task!.labelIds)
                Chip(
                  label: Text(
                    store.labels
                        .firstWhere((label) => label.id == labelId)
                        .name,
                  ),
                ),
            ],
          ),
          const Divider(height: 28),
          Text('Comments', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (comments.isEmpty)
            const Text('No comments yet.')
          else
            for (final comment in comments)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PersonAvatar(
                  initials: store.users
                      .firstWhere((user) => user.id == comment.authorId)
                      .initials,
                ),
                title: Text(comment.body),
                subtitle: Text(
                  store.users
                      .firstWhere((user) => user.id == comment.authorId)
                      .name,
                ),
              ),
          const Divider(height: 28),
          Text('Activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final event in store.activity.take(3))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(event.message),
              subtitle: Text(
                store.users.firstWhere((user) => user.id == event.actorId).name,
              ),
            ),
        ],
      ),
    );
  }
}
