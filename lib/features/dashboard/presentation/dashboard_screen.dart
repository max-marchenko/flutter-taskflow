import 'package:flutter/material.dart';

import '../../../core/widgets/taskflow_components.dart';
import '../../../data/demo/demo_store.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const AppPageHeader(
          title: 'Dashboard',
          subtitle:
              'Demo mode is active. Supabase can be connected with environment variables.',
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 4
                : constraints.maxWidth > 560
                ? 2
                : 1;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: columns == 1 ? 4 : 2.5,
              children: [
                MetricCard(
                  label: 'Active projects',
                  value: '${store.activeProjectCount}',
                  icon: Icons.folder_open,
                ),
                MetricCard(
                  label: 'Tasks due soon',
                  value: '${store.dueSoonCount}',
                  icon: Icons.event_available,
                ),
                MetricCard(
                  label: 'Overdue tasks',
                  value: '${store.overdueCount}',
                  icon: Icons.warning_amber,
                ),
                MetricCard(
                  label: 'Completed this week',
                  value: '${store.completedThisWeekCount}',
                  icon: Icons.check_circle_outline,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= 880;
            final panelWidth = twoColumns
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: panelWidth,
                  child: AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My tasks',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        for (final task in store.myTasks.take(5))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(task.title),
                            subtitle: Text(
                              store.projects
                                  .firstWhere(
                                    (project) => project.id == task.projectId,
                                  )
                                  .name,
                            ),
                            trailing: PriorityChip(task.priority),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: panelWidth,
                  child: AppSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent activity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        for (final event in store.activity.take(5))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.bolt_outlined),
                            title: Text(event.message),
                            subtitle: Text(
                              '${store.users.firstWhere((user) => user.id == event.actorId).name} - ${_relativeTime(event.createdAt)}',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays >= 1) return '${difference.inDays}d ago';
    if (difference.inHours >= 1) return '${difference.inHours}h ago';
    return '${difference.inMinutes.clamp(1, 59)}m ago';
  }
}
