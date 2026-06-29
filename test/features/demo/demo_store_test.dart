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
}
