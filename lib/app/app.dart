import 'package:flutter/material.dart';

import '../core/permissions/workspace_policy.dart';
import '../core/responsive/adaptive_breakpoints.dart';
import '../core/widgets/taskflow_components.dart';
import '../data/demo/demo_store.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/projects/presentation/projects_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import '../features/workspaces/presentation/workspace_screen.dart';
import 'theme/app_theme.dart';

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  final DemoStore store = DemoStore();

  @override
  Widget build(BuildContext context) {
    return DemoScope(
      store: store,
      child: AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          return MaterialApp(
            title: 'TaskFlow',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: store.themeMode,
            home: store.isAuthenticated
                ? const TaskFlowShell()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}

class TaskFlowShell extends StatelessWidget {
  const TaskFlowShell({super.key});

  static const _destinations = [
    _Destination('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    _Destination('Projects', Icons.folder_copy_outlined, Icons.folder_copy),
    _Destination('Tasks', Icons.view_kanban_outlined, Icons.view_kanban),
    _Destination('Workspace', Icons.groups_outlined, Icons.groups),
    _Destination('Settings', Icons.settings_outlined, Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final layout = AdaptiveBreakpoints.of(context);
    final screens = [
      const DashboardScreen(),
      const ProjectsScreen(),
      const TasksScreen(),
      const WorkspaceScreen(),
      const SettingsScreen(),
    ];

    if (layout == LayoutClass.compact) {
      return Scaffold(
        appBar: AppBar(title: const Text('TaskFlow')),
        body: screens[store.selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: store.selectedIndex,
          onDestinationSelected: store.setSelectedIndex,
          destinations: [
            for (final item in _destinations)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      );
    }

    final navRail = NavigationRail(
      selectedIndex: store.selectedIndex,
      onDestinationSelected: store.setSelectedIndex,
      labelType: NavigationRailLabelType.all,
      destinations: [
        for (final item in _destinations)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          ),
      ],
    );

    if (layout == LayoutClass.medium) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              navRail,
              const VerticalDivider(width: 1),
              Expanded(child: screens[store.selectedIndex]),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 272,
              child: _SideNavigation(
                destinations: _destinations,
                selectedIndex: store.selectedIndex,
                onSelected: store.setSelectedIndex,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: screens[store.selectedIndex]),
          ],
        ),
      ),
    );
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_Destination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: const Text('TF'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TaskFlow',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        store.workspace.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            RoleBadge(store.currentRole),
            const SizedBox(height: 16),
            for (var index = 0; index < destinations.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ListTile(
                  selected: index == selectedIndex,
                  leading: Icon(destinations[index].icon),
                  title: Text(destinations[index].label),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onTap: () => onSelected(index),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              store.currentUser.name,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(store.currentUser.email, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: store.logout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionGate extends StatelessWidget {
  const PermissionGate({
    required this.allowed,
    required this.child,
    this.fallback,
    super.key,
  });

  final bool allowed;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}

class PolicyScope {
  const PolicyScope._();

  static const WorkspacePolicy policy = WorkspacePolicy();
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
