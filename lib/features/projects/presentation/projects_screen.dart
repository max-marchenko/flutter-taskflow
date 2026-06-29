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
    return ListView(
      padding: const EdgeInsets.all(20),
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
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: columns == 1 ? 2.1 : 1.35,
              children: [
                for (final project in store.projects)
                  InkWell(
                    onTap: () => store.selectProject(project.id),
                    borderRadius: BorderRadius.circular(8),
                    child: AppSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              StatusChip.project(project.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            project.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          LinearProgressIndicator(
                            value: _progressFor(store, project.id),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_doneCount(store, project.id)} of ${_taskCount(store, project.id)} tasks complete',
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () => store.selectProject(project.id),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Open task board'),
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
