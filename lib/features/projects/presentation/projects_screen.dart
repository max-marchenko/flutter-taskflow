import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../core/widgets/taskflow_components.dart';
import '../../../data/demo/demo_store.dart';
import '../../../models/taskflow_models.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final canCreate = PolicyScope.policy.canCreateProject(store.currentRole);
    final isCompact = MediaQuery.sizeOf(context).width < 700;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, isCompact ? 96 : 20),
      children: [
        AppPageHeader(
          title: 'Projects',
          subtitle:
              '${store.projects.length} project spaces in ${store.workspace.name}. Open a project to review its task board.',
          action: PermissionGate(
            allowed: canCreate,
            fallback: Semantics(
              label: 'Project creation unavailable for viewer role',
              child: const Tooltip(
                message: 'Viewers cannot create projects',
                child: Icon(Icons.lock_outline),
              ),
            ),
            child: FilledButton.icon(
              onPressed: () => _showProjectDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New project'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 1000
                ? 3
                : constraints.maxWidth > 620
                ? 2
                : 1;
            final cardWidth = columns == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (12 * (columns - 1))) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final project in store.projects)
                  SizedBox(
                    width: cardWidth,
                    child: _ProjectCard(
                      project: project,
                      taskCount: _taskCount(store, project.id),
                      doneCount: _doneCount(store, project.id),
                      progress: _progressFor(store, project.id),
                      onOpen: () => store.selectProject(project.id),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  int _taskCount(DemoStore store, String projectId) {
    return store.tasks.where((task) => task.projectId == projectId).length;
  }

  int _doneCount(DemoStore store, String projectId) {
    return store.tasks
        .where(
          (task) =>
              task.projectId == projectId && task.status == TaskStatus.done,
        )
        .length;
  }

  double _progressFor(DemoStore store, String projectId) {
    final total = _taskCount(store, projectId);
    if (total == 0) return 0;
    return _doneCount(store, projectId) / total;
  }

  void _showProjectDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final store = DemoScope.of(context);
        return AlertDialog(
          title: const Text('Create project'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
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
                if (nameController.text.trim().isEmpty) return;
                store.addProject(
                  nameController.text.trim(),
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

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.taskCount,
    required this.doneCount,
    required this.progress,
    required this.onOpen,
  });

  final Project project;
  final int taskCount;
  final int doneCount;
  final double progress;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: AppSectionCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 160,
                    maxWidth: 340,
                  ),
                  child: Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    softWrap: true,
                  ),
                ),
                StatusChip.project(project.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 18),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text('$doneCount of $taskCount tasks complete'),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Open task board'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
