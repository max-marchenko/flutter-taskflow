# TaskFlow

TaskFlow is a polished Flutter demo of a collaborative project and task management app for small teams. It is designed as a Junior Flutter Developer portfolio project: easy to run, visually intentional, role-aware, tested, and honest about what is demo-ready versus roadmap.

## First 30 Seconds

- Runs immediately in demo mode with no Supabase account or API keys.
- Shows a realistic workspace with projects, tasks, members, labels, comments, and activity.
- Demonstrates adaptive Flutter UI across mobile, tablet, and desktop/web layouts.
- Includes role-aware UI for Owner, Admin, Member, and Viewer.
- Includes a Supabase/PostgreSQL schema as the planned production backend foundation.

## Screenshots

Real screenshots have not been captured in this environment. Placeholder paths are reserved so screenshots can be added before a portfolio release:

- `docs/screenshots/dashboard.png`
- `docs/screenshots/kanban.png`
- `docs/screenshots/task-detail.png`
- `docs/screenshots/admin-roles.png`

Suggested local capture flow:

1. Run `flutter run -d chrome`.
2. Use demo mode.
3. Capture Dashboard, Tasks/Kanban, Task detail, and Settings role switcher.
4. Save PNGs to the paths above.

## Features

- Demo login and seeded demo users.
- Dashboard metrics for active projects, due soon tasks, overdue tasks, and completed work.
- Workspace members with role badges and demo invite/settings feedback.
- Project list with status, progress, and direct task-board navigation.
- Task workspace with list, Kanban columns, search, status filter, priority filter, sorting, status updates, and detail panel.
- Task detail surface with assignee, labels, comments, and activity.
- Role switcher for reviewing RBAC behavior without separate accounts.
- Light, dark, and system theme modes.
- Mobile bottom navigation, tablet navigation rail, and desktop side navigation.
- Supabase migration for the production data model.
- Unit and widget tests for permissions, demo data, filters, navigation, and role-aware UI.

## Demo Mode

TaskFlow is intentionally runnable without Supabase credentials:

```bash
flutter pub get
flutter run
```

Use **Continue in demo mode** on the login screen.

Seeded users:

| Role | Email |
| --- | --- |
| Owner | `olivia@taskflow.demo` |
| Admin | `alex@taskflow.demo` |
| Member | `mia@taskflow.demo` |
| Viewer | `victor@taskflow.demo` |

Any password with six or more characters works for seeded demo emails. The Settings screen lets reviewers preview the app as each seeded user/role.

## Architecture Overview

```text
lib/
  app/                 App composition, adaptive shell, theme
  core/                Permissions, responsive helpers, reusable widgets
  data/demo/           In-memory seeded demo data source
  features/            Auth, dashboard, projects, tasks, workspaces, settings
  models/              Domain models and enums
supabase/migrations/   PostgreSQL schema and RLS intent
test/                  Unit and widget coverage
docs/                  Release checklist and screenshot slots
```

The current implementation keeps dependencies intentionally lean. Demo data is first-class and isolated in `DemoStore`, while the domain model and Supabase schema make the future backend path clear without pretending runtime Supabase integration is already complete.

## Tech Stack

- Flutter and Material 3
- Dart null safety
- InheritedNotifier/ChangeNotifier for lightweight demo state
- Flutter test for unit and widget coverage
- Supabase/PostgreSQL schema for planned production persistence
- GitHub Actions quality workflow

## Roles And Permissions

| Capability | Owner | Admin | Member | Viewer |
| --- | --- | --- | --- | --- |
| View workspace | Yes | Yes | Yes | Yes |
| Manage workspace settings | Yes | No | No | No |
| Manage members | Yes | Yes | No | No |
| Create projects | Yes | Yes | No | No |
| Edit projects | Yes | Yes | No | No |
| Delete projects | Yes | No | No | No |
| Create tasks | Yes | Yes | Yes | No |
| Edit any task | Yes | Yes | No | No |
| Edit assigned/unassigned task | Yes | Yes | Yes | No |
| Comment | Yes | Yes | Yes | No |

The Flutter UI uses `WorkspacePolicy` to hide or disable actions. In production, these rules must also be enforced by Supabase Row Level Security.

## Supabase Setup

Runtime Supabase integration is not wired yet. The repository currently includes the schema foundation:

1. Create a Supabase project.
2. Run `supabase/migrations/0001_initial_schema.sql`.
3. Copy `.env.example` to `.env` when runtime integration is added.

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
TASKFLOW_FORCE_DEMO=true
```

The migration defines profiles, workspaces, workspace members, projects, tasks, labels, task labels, task comments, and activity events. It enables RLS and documents the intended role model. Full production policies and Flutter repository adapters remain roadmap work.

## Quality Commands

```bash
dart format .
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

See `docs/release-checklist.md` for manual QA before merging to `main`.

## Architecture Decisions

- Keep demo mode dependency-light so recruiters can run the app quickly.
- Use a central `WorkspacePolicy` so role behavior is visible, testable, and easy to map to backend RLS.
- Prefer adaptive layout helpers and reusable TaskFlow components over one-off screen styling.
- Keep Supabase honest as a schema/backend plan until runtime repositories are implemented.

## Known Limitations

- Demo data is in memory and resets when the app restarts.
- Theme and selected demo role are not persisted yet; plugin-based persistence was deferred to avoid platform setup friction.
- Supabase runtime auth/CRUD adapters are not implemented.
- Kanban uses status dropdowns and selectable cards rather than drag and drop.
- Real screenshots still need to be captured locally.

## Roadmap

- Add Supabase repository implementations for auth and CRUD.
- Add production RLS helper functions and concrete policies.
- Persist theme, selected role, and selected workspace locally.
- Add drag-and-drop Kanban interactions.
- Add comment creation and richer task editing.
- Capture real screenshots and add them to the README.

## Recruiter Note

TaskFlow demonstrates product thinking, Flutter UI composition, responsive design, role-aware behavior, test discipline, and honest documentation. It is intentionally scoped as a portfolio demo with a clear path toward a production backend.
