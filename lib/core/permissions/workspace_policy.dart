import '../../models/taskflow_models.dart';

class WorkspacePolicy {
  const WorkspacePolicy();

  bool canView(WorkspaceRole role) => true;

  bool canManageWorkspace(WorkspaceRole role) => role == WorkspaceRole.owner;

  bool canManageMembers(WorkspaceRole role) {
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  bool canCreateProject(WorkspaceRole role) {
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  bool canEditProject(WorkspaceRole role) {
    return role == WorkspaceRole.owner || role == WorkspaceRole.admin;
  }

  bool canDeleteProject(WorkspaceRole role) => role == WorkspaceRole.owner;

  bool canCreateTask(WorkspaceRole role) {
    return role != WorkspaceRole.viewer;
  }

  bool canEditTask({
    required WorkspaceRole role,
    required TaskItem task,
    required String userId,
  }) {
    return switch (role) {
      WorkspaceRole.owner || WorkspaceRole.admin => true,
      WorkspaceRole.member =>
        task.assigneeId == null || task.assigneeId == userId,
      WorkspaceRole.viewer => false,
    };
  }

  bool canComment(WorkspaceRole role) => role != WorkspaceRole.viewer;
}
