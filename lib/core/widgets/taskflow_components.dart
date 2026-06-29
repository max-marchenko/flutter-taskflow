import 'package:flutter/material.dart';

import '../../models/taskflow_models.dart';

class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: padding, child: child),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    required this.subtitle,
    this.action,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 2),
              Text(subtitle),
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppSectionCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primaryContainer,
            foregroundColor: colors.onPrimaryContainer,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.headlineSmall),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip.project(this.status, {super.key}) : taskStatus = null;

  const StatusChip.task(this.taskStatus, {super.key}) : status = null;

  final ProjectStatus? status;
  final TaskStatus? taskStatus;

  @override
  Widget build(BuildContext context) {
    final label = status?.label ?? taskStatus!.label;
    final color = switch (status) {
      ProjectStatus.active => Colors.teal,
      ProjectStatus.planned => Colors.blue,
      ProjectStatus.paused => Colors.amber,
      ProjectStatus.completed => Colors.green,
      ProjectStatus.archived => Colors.blueGrey,
      null => switch (taskStatus!) {
        TaskStatus.backlog => Colors.blueGrey,
        TaskStatus.todo => Colors.blue,
        TaskStatus.inProgress => Colors.teal,
        TaskStatus.review => Colors.purple,
        TaskStatus.done => Colors.green,
        TaskStatus.archived => Colors.blueGrey,
      },
    };
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.circle, color: color, size: 12),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip(this.priority, {super.key});

  final TaskPriority priority;

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      TaskPriority.low => Colors.blueGrey,
      TaskPriority.medium => Colors.teal,
      TaskPriority.high => Colors.orange,
      TaskPriority.urgent => Colors.red,
    };
    return Chip(
      label: Text(priority.label),
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.flag, color: color, size: 16),
    );
  }
}

class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});

  final WorkspaceRole role;

  @override
  Widget build(BuildContext context) {
    final color = switch (role) {
      WorkspaceRole.owner => Colors.teal,
      WorkspaceRole.admin => Colors.indigo,
      WorkspaceRole.member => Colors.green,
      WorkspaceRole.viewer => Colors.blueGrey,
    };
    return Chip(
      label: Text(role.label),
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.verified_user_outlined, color: color, size: 16),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    required this.message,
    this.action,
    super.key,
  });

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({required this.initials, this.tooltip, super.key});

  final String initials;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 16,
      child: Text(initials, style: Theme.of(context).textTheme.labelSmall),
    );
    return tooltip == null ? avatar : Tooltip(message: tooltip!, child: avatar);
  }
}
