import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/permissions/workspace_policy.dart';
import 'package:taskflow/models/taskflow_models.dart';

void main() {
  const policy = WorkspacePolicy();
  final assignedTask = TaskItem(
    id: 'task-1',
    projectId: 'project-1',
    title: 'Assigned task',
    description: 'A task assigned to the member',
    status: TaskStatus.todo,
    priority: TaskPriority.medium,
    assigneeId: 'member-1',
    dueDate: DateTime(2026, 7),
    labelIds: const [],
    createdAt: DateTime(2026, 6),
    updatedAt: DateTime(2026, 6),
  );

  test('owner can manage workspace, members, projects, and tasks', () {
    expect(policy.canManageWorkspace(WorkspaceRole.owner), isTrue);
    expect(policy.canManageMembers(WorkspaceRole.owner), isTrue);
    expect(policy.canCreateProject(WorkspaceRole.owner), isTrue);
    expect(policy.canDeleteProject(WorkspaceRole.owner), isTrue);
    expect(
      policy.canEditTask(
        role: WorkspaceRole.owner,
        task: assignedTask,
        userId: 'owner',
      ),
      isTrue,
    );
  });

  test('admin can manage projects and members but not owner-only actions', () {
    expect(policy.canManageWorkspace(WorkspaceRole.admin), isFalse);
    expect(policy.canManageMembers(WorkspaceRole.admin), isTrue);
    expect(policy.canCreateProject(WorkspaceRole.admin), isTrue);
    expect(policy.canDeleteProject(WorkspaceRole.admin), isFalse);
  });

  test('member can create tasks and edit assigned tasks only', () {
    expect(policy.canCreateTask(WorkspaceRole.member), isTrue);
    expect(
      policy.canEditTask(
        role: WorkspaceRole.member,
        task: assignedTask,
        userId: 'member-1',
      ),
      isTrue,
    );
    expect(
      policy.canEditTask(
        role: WorkspaceRole.member,
        task: assignedTask,
        userId: 'someone-else',
      ),
      isFalse,
    );
  });

  test('viewer has read-only permissions', () {
    expect(policy.canView(WorkspaceRole.viewer), isTrue);
    expect(policy.canCreateTask(WorkspaceRole.viewer), isFalse);
    expect(policy.canCreateProject(WorkspaceRole.viewer), isFalse);
    expect(
      policy.canEditTask(
        role: WorkspaceRole.viewer,
        task: assignedTask,
        userId: 'viewer',
      ),
      isFalse,
    );
  });
}
