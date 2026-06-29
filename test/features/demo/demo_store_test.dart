import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/demo/demo_store.dart';
import 'package:taskflow/models/taskflow_models.dart';

void main() {
  test('demo login works without external credentials', () {
    final store = DemoStore();

    store.demoLogin();

    expect(store.isAuthenticated, isTrue);
    expect(store.workspace.name, 'Acme Product Studio');
    expect(store.projects.length, greaterThanOrEqualTo(4));
    expect(store.tasks.length, greaterThanOrEqualTo(12));
  });

  test('role switcher updates current role and user', () {
    final store = DemoStore()..demoLogin();

    store.switchRole(WorkspaceRole.viewer);

    expect(store.currentRole, WorkspaceRole.viewer);
    expect(store.currentUser.email, 'victor@taskflow.demo');
  });

  test('selecting a project opens the task workspace', () {
    final store = DemoStore()..demoLogin();

    store.selectProject('launch-checklist');

    expect(store.selectedProject.id, 'launch-checklist');
    expect(store.selectedIndex, 2);
    expect(
      store.visibleTasks.every((task) => task.projectId == 'launch-checklist'),
      isTrue,
    );
  });

  test('task filters and sort narrow visible tasks', () {
    final store = DemoStore()..demoLogin();

    store.setPriorityFilter(TaskPriority.high);
    store.setStatusFilter(TaskStatus.inProgress);

    expect(store.visibleTasks, isNotEmpty);
    expect(
      store.visibleTasks.every((task) => task.priority == TaskPriority.high),
      isTrue,
    );
    expect(
      store.visibleTasks.every((task) => task.status == TaskStatus.inProgress),
      isTrue,
    );

    store.setTaskSort(TaskSort.priority);
    expect(store.taskSort, TaskSort.priority);

    store.clearTaskFilters();
    expect(store.statusFilter, isNull);
    expect(store.priorityFilter, isNull);
  });
}
