import 'package:flutter/material.dart';

import '../../../core/widgets/taskflow_components.dart';
import '../../../data/demo/demo_store.dart';
import '../../../models/taskflow_models.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PersonAvatar(
                  initials: store.currentUser.initials,
                  tooltip: store.currentUser.name,
                ),
                title: Text(store.currentUser.name),
                subtitle: Text(store.currentUser.email),
                trailing: RoleBadge(store.currentRole),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demo role switcher',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Switch roles to verify RBAC controls without separate accounts.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final role in WorkspaceRole.values)
                    ChoiceChip(
                      label: Text(role.label),
                      selected: store.currentRole == role,
                      onSelected: (_) => store.switchRole(role),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {store.themeMode},
                onSelectionChanged: (value) => store.setThemeMode(value.first),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About TaskFlow',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'TaskFlow is a demo-first Flutter portfolio app with clean architecture boundaries, role-aware UI, seeded local data, and Supabase-ready database design.',
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: store.logout,
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
