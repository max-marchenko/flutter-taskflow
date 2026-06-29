import 'package:flutter/material.dart';

import '../../models/taskflow_models.dart';

class DemoStore extends ChangeNotifier {
  DemoStore() {
    _seed();
  }

  final Workspace workspace = const Workspace(
    id: 'workspace-acme',
    name: 'Acme Product Studio',
    description: 'A demo workspace for shipping focused product work.',
  );

  late final List<AppUser> users;
  late final List<WorkspaceMember> members;
  late final List<TaskLabel> labels;
  late List<Project> projects;
  late final List<TaskComment> comments;
  late List<ActivityEvent> activity;
  late List<TaskItem> tasks;

  bool isAuthenticated = false;
  String currentUserId = 'olivia';
  WorkspaceRole currentRole = WorkspaceRole.owner;
  ThemeMode themeMode = ThemeMode.system;
  int selectedIndex = 0;
  String? selectedProjectId;
  String taskQuery = '';
  TaskStatus? statusFilter;

  AppUser get currentUser =>
      users.firstWhere((user) => user.id == currentUserId);

  Project get selectedProject => projects.firstWhere(
    (project) => project.id == (selectedProjectId ?? projects.first.id),
  );

  List<TaskItem> get myTasks {
    return tasks
        .where((task) => task.assigneeId == currentUserId)
        .where((task) => task.status != TaskStatus.done)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<TaskItem> get visibleTasks {
    final query = taskQuery.toLowerCase().trim();
    return tasks.where((task) {
      final matchesProject = task.projectId == selectedProject.id;
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query) ||
          task.description.toLowerCase().contains(query);
      final matchesStatus = statusFilter == null || task.status == statusFilter;
      return matchesProject && matchesQuery && matchesStatus;
    }).toList();
  }

  int get activeProjectCount {
    return projects
        .where((project) => project.status == ProjectStatus.active)
        .length;
  }

  int get dueSoonCount {
    final now = DateTime.now();
    final soon = now.add(const Duration(days: 7));
    return tasks
        .where((task) => task.status != TaskStatus.done)
        .where(
          (task) => task.dueDate.isAfter(now) && task.dueDate.isBefore(soon),
        )
        .length;
  }

  int get overdueCount {
    final now = DateTime.now();
    return tasks
        .where((task) => task.status != TaskStatus.done)
        .where((task) => task.dueDate.isBefore(now))
        .length;
  }

  int get completedThisWeekCount {
    final weekStart = DateTime.now().subtract(const Duration(days: 7));
    return tasks
        .where((task) => task.status == TaskStatus.done)
        .where((task) => task.updatedAt.isAfter(weekStart))
        .length;
  }

  void demoLogin() {
    isAuthenticated = true;
    currentUserId = 'olivia';
    currentRole = WorkspaceRole.owner;
    notifyListeners();
  }

  String? login(String email, String password) {
    if (!email.contains('@')) return 'Enter a valid email address.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    final match = users.where((user) => user.email == email.trim()).toList();
    if (match.isEmpty) return 'Use demo mode or a seeded demo email.';
    currentUserId = match.first.id;
    currentRole = members
        .firstWhere((member) => member.user.id == currentUserId)
        .role;
    isAuthenticated = true;
    notifyListeners();
    return null;
  }

  void logout() {
    isAuthenticated = false;
    selectedIndex = 0;
    notifyListeners();
  }

  void switchRole(WorkspaceRole role) {
    currentRole = role;
    currentUserId = members.firstWhere((member) => member.role == role).user.id;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void selectProject(String id) {
    selectedProjectId = id;
    selectedIndex = 1;
    notifyListeners();
  }

  void setTaskQuery(String value) {
    taskQuery = value;
    notifyListeners();
  }

  void setStatusFilter(TaskStatus? value) {
    statusFilter = value;
    notifyListeners();
  }

  void setThemeMode(ThemeMode value) {
    themeMode = value;
    notifyListeners();
  }

  void addProject(String name, String description) {
    final id = 'project-${projects.length + 1}';
    projects = [
      ...projects,
      Project(
        id: id,
        workspaceId: workspace.id,
        name: name,
        description: description,
        status: ProjectStatus.active,
        ownerId: currentUserId,
        dueDate: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
    selectedProjectId = id;
    _addActivity('Created project "$name"');
    notifyListeners();
  }

  void addTask(String title, String description) {
    final task = TaskItem(
      id: 'task-${tasks.length + 1}',
      projectId: selectedProject.id,
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: TaskPriority.medium,
      assigneeId: currentUserId,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      labelIds: const ['mobile'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    tasks = [task, ...tasks];
    _addActivity('Created task "$title"');
    notifyListeners();
  }

  void updateTaskStatus(TaskItem task, TaskStatus status) {
    tasks = [
      for (final item in tasks)
        if (item.id == task.id) item.copyWith(status: status) else item,
    ];
    _addActivity('Moved "${task.title}" to ${status.label}');
    notifyListeners();
  }

  void _addActivity(String message) {
    activity = [
      ActivityEvent(
        id: 'activity-${activity.length + 1}',
        message: message,
        actorId: currentUserId,
        createdAt: DateTime.now(),
      ),
      ...activity,
    ];
  }

  void _seed() {
    users = const [
      AppUser(
        id: 'olivia',
        name: 'Olivia Owner',
        email: 'olivia@taskflow.demo',
        initials: 'OO',
      ),
      AppUser(
        id: 'alex',
        name: 'Alex Admin',
        email: 'alex@taskflow.demo',
        initials: 'AA',
      ),
      AppUser(
        id: 'mia',
        name: 'Mia Member',
        email: 'mia@taskflow.demo',
        initials: 'MM',
      ),
      AppUser(
        id: 'victor',
        name: 'Victor Viewer',
        email: 'victor@taskflow.demo',
        initials: 'VV',
      ),
    ];
    members = [
      WorkspaceMember(
        user: users[0],
        role: WorkspaceRole.owner,
        title: 'Founder',
      ),
      WorkspaceMember(
        user: users[1],
        role: WorkspaceRole.admin,
        title: 'Product Lead',
      ),
      WorkspaceMember(
        user: users[2],
        role: WorkspaceRole.member,
        title: 'Flutter Developer',
      ),
      WorkspaceMember(
        user: users[3],
        role: WorkspaceRole.viewer,
        title: 'Stakeholder',
      ),
    ];
    labels = const [
      TaskLabel(id: 'design', name: 'Design', hexColor: 0xff2563eb),
      TaskLabel(id: 'mobile', name: 'Mobile', hexColor: 0xff0f766e),
      TaskLabel(id: 'backend', name: 'Backend', hexColor: 0xff7c3aed),
      TaskLabel(id: 'bug', name: 'Bug', hexColor: 0xffdc2626),
      TaskLabel(id: 'docs', name: 'Docs', hexColor: 0xffca8a04),
      TaskLabel(id: 'qa', name: 'QA', hexColor: 0xff16a34a),
    ];
    projects = [
      Project(
        id: 'mobile-redesign',
        workspaceId: workspace.id,
        name: 'Mobile Redesign',
        description: 'Refresh task workflows, navigation, and mobile density.',
        status: ProjectStatus.active,
        ownerId: 'alex',
        dueDate: DateTime.now().add(const Duration(days: 21)),
      ),
      Project(
        id: 'launch-checklist',
        workspaceId: workspace.id,
        name: 'Launch Checklist',
        description:
            'Coordinate release readiness across product, QA, and docs.',
        status: ProjectStatus.active,
        ownerId: 'olivia',
        dueDate: DateTime.now().add(const Duration(days: 12)),
      ),
      Project(
        id: 'website-refresh',
        workspaceId: workspace.id,
        name: 'Website Refresh',
        description:
            'Improve the marketing site and recruiter-facing portfolio pages.',
        status: ProjectStatus.planned,
        ownerId: 'mia',
        dueDate: DateTime.now().add(const Duration(days: 45)),
      ),
      Project(
        id: 'internal-ops',
        workspaceId: workspace.id,
        name: 'Internal Ops',
        description: 'Clean up recurring operations and team rituals.',
        status: ProjectStatus.paused,
        ownerId: 'olivia',
        dueDate: DateTime.now().add(const Duration(days: 60)),
      ),
    ];
    selectedProjectId = projects.first.id;
    tasks = _seedTasks();
    comments = [
      TaskComment(
        id: 'comment-1',
        taskId: 'task-1',
        authorId: 'alex',
        body: 'Keep this flow crisp. It is the first thing reviewers will see.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TaskComment(
        id: 'comment-2',
        taskId: 'task-4',
        authorId: 'mia',
        body: 'I added the edge cases to the QA checklist.',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
    activity = [
      ActivityEvent(
        id: 'a1',
        message: 'Mia moved "Kanban drag states" to Review',
        actorId: 'mia',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ActivityEvent(
        id: 'a2',
        message: 'Alex commented on "Demo login polish"',
        actorId: 'alex',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ActivityEvent(
        id: 'a3',
        message: 'Olivia created "Launch readiness board"',
        actorId: 'olivia',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  List<TaskItem> _seedTasks() {
    final now = DateTime.now();
    final specs = [
      (
        'task-1',
        'mobile-redesign',
        'Demo login polish',
        TaskStatus.inProgress,
        TaskPriority.high,
        'mia',
        2,
        ['mobile', 'design'],
      ),
      (
        'task-2',
        'mobile-redesign',
        'Adaptive shell breakpoints',
        TaskStatus.done,
        TaskPriority.high,
        'mia',
        -1,
        ['mobile'],
      ),
      (
        'task-3',
        'mobile-redesign',
        'Workspace role switcher',
        TaskStatus.todo,
        TaskPriority.medium,
        'alex',
        4,
        ['mobile', 'qa'],
      ),
      (
        'task-4',
        'mobile-redesign',
        'Kanban drag states',
        TaskStatus.review,
        TaskPriority.medium,
        'mia',
        3,
        ['mobile', 'qa'],
      ),
      (
        'task-5',
        'mobile-redesign',
        'Task detail comment layout',
        TaskStatus.backlog,
        TaskPriority.low,
        null,
        8,
        ['design'],
      ),
      (
        'task-6',
        'launch-checklist',
        'Release checklist template',
        TaskStatus.todo,
        TaskPriority.urgent,
        'alex',
        -2,
        ['docs'],
      ),
      (
        'task-7',
        'launch-checklist',
        'QA smoke test pass',
        TaskStatus.inProgress,
        TaskPriority.urgent,
        'mia',
        1,
        ['qa', 'bug'],
      ),
      (
        'task-8',
        'launch-checklist',
        'Supabase RLS notes',
        TaskStatus.done,
        TaskPriority.medium,
        'olivia',
        -3,
        ['backend', 'docs'],
      ),
      (
        'task-9',
        'launch-checklist',
        'Invite copy review',
        TaskStatus.todo,
        TaskPriority.low,
        'victor',
        6,
        ['docs'],
      ),
      (
        'task-10',
        'website-refresh',
        'Portfolio screenshot slots',
        TaskStatus.backlog,
        TaskPriority.medium,
        'alex',
        10,
        ['design', 'docs'],
      ),
      (
        'task-11',
        'website-refresh',
        'Landing page performance audit',
        TaskStatus.todo,
        TaskPriority.high,
        null,
        -1,
        ['qa'],
      ),
      (
        'task-12',
        'internal-ops',
        'Weekly planning notes cleanup',
        TaskStatus.done,
        TaskPriority.low,
        'olivia',
        -5,
        ['docs'],
      ),
    ];
    return [
      for (final spec in specs)
        TaskItem(
          id: spec.$1,
          projectId: spec.$2,
          title: spec.$3,
          description:
              'Demo task for ${spec.$3.toLowerCase()} with role-aware actions and activity history.',
          status: spec.$4,
          priority: spec.$5,
          assigneeId: spec.$6,
          dueDate: now.add(Duration(days: spec.$7)),
          labelIds: spec.$8,
          createdAt: now.subtract(Duration(days: spec.$7.abs() + 2)),
          updatedAt: spec.$4 == TaskStatus.done
              ? now.subtract(const Duration(days: 2))
              : now,
        ),
    ];
  }
}

class DemoScope extends InheritedNotifier<DemoStore> {
  const DemoScope({required DemoStore store, required super.child, super.key})
    : super(notifier: store);

  static DemoStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DemoScope>();
    assert(scope != null, 'DemoScope not found in widget tree.');
    return scope!.notifier!;
  }
}
