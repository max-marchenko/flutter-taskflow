import 'package:flutter/material.dart';

import '../../../app/app.dart';
import '../../../core/widgets/taskflow_components.dart';
import '../../../data/demo/demo_store.dart';
import '../../../models/taskflow_models.dart';

class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = DemoScope.of(context);
    final canManageMembers = PolicyScope.policy.canManageMembers(
      store.currentRole,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Workspace', style: Theme.of(context).textTheme.headlineMedium),
        Text(store.workspace.description),
        const SizedBox(height: 16),
        AppSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Members',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (canManageMembers)
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.person_add_alt),
                      label: const Text('Invite'),
                    )
                  else
                    const Tooltip(
                      message: 'Only owners and admins can invite members',
                      child: Icon(Icons.lock_outline),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              for (final member in store.members)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: PersonAvatar(
                    initials: member.user.initials,
                    tooltip: member.user.name,
                  ),
                  title: Text(member.user.name),
                  subtitle: Text(member.title),
                  trailing: RoleBadge(member.role),
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
                'Workspace settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Current role: ${store.currentRole.label}. Production role enforcement belongs in Supabase RLS.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed:
                    PolicyScope.policy.canManageWorkspace(store.currentRole)
                    ? () {}
                    : null,
                icon: const Icon(Icons.tune),
                label: const Text('Manage workspace'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
