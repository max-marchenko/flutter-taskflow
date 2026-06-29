enum WorkspaceRole { owner, admin, member, viewer }

enum ProjectStatus { planned, active, paused, completed, archived }

enum TaskStatus { backlog, todo, inProgress, review, done, archived }

enum TaskPriority { low, medium, high, urgent }

enum TaskSort { dueDate, priority, updated }

extension WorkspaceRoleLabel on WorkspaceRole {
  String get label => switch (this) {
    WorkspaceRole.owner => 'Owner',
    WorkspaceRole.admin => 'Admin',
    WorkspaceRole.member => 'Member',
    WorkspaceRole.viewer => 'Viewer',
  };
}

extension ProjectStatusLabel on ProjectStatus {
  String get label => switch (this) {
    ProjectStatus.planned => 'Planned',
    ProjectStatus.active => 'Active',
    ProjectStatus.paused => 'Paused',
    ProjectStatus.completed => 'Completed',
    ProjectStatus.archived => 'Archived',
  };
}

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.backlog => 'Backlog',
    TaskStatus.todo => 'To do',
    TaskStatus.inProgress => 'In progress',
    TaskStatus.review => 'Review',
    TaskStatus.done => 'Done',
    TaskStatus.archived => 'Archived',
  };
}

extension TaskPriorityLabel on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
    TaskPriority.urgent => 'Urgent',
  };
}

extension TaskSortLabel on TaskSort {
  String get label => switch (this) {
    TaskSort.dueDate => 'Due date',
    TaskSort.priority => 'Priority',
    TaskSort.updated => 'Recently updated',
  };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
  });

  final String id;
  final String name;
  final String email;
  final String initials;
}

class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;
}

class WorkspaceMember {
  const WorkspaceMember({
    required this.user,
    required this.role,
    required this.title,
  });

  final AppUser user;
  final WorkspaceRole role;
  final String title;
}

class Project {
  const Project({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.description,
    required this.status,
    required this.ownerId,
    required this.dueDate,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String description;
  final ProjectStatus status;
  final String ownerId;
  final DateTime dueDate;
}

class TaskLabel {
  const TaskLabel({
    required this.id,
    required this.name,
    required this.hexColor,
  });

  final String id;
  final String name;
  final int hexColor;
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assigneeId,
    required this.dueDate,
    required this.labelIds,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assigneeId;
  final DateTime dueDate;
  final List<String> labelIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskItem copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? assigneeId,
    DateTime? dueDate,
    List<String>? labelIds,
  }) {
    return TaskItem(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assigneeId: assigneeId ?? this.assigneeId,
      dueDate: dueDate ?? this.dueDate,
      labelIds: labelIds ?? this.labelIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class TaskComment {
  const TaskComment({
    required this.id,
    required this.taskId,
    required this.authorId,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String taskId;
  final String authorId;
  final String body;
  final DateTime createdAt;
}

class ActivityEvent {
  const ActivityEvent({
    required this.id,
    required this.message,
    required this.actorId,
    required this.createdAt,
  });

  final String id;
  final String message;
  final String actorId;
  final DateTime createdAt;
}
