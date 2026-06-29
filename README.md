# TaskFlow

TaskFlow is a demo-first Flutter project management app for small teams. It is built as a portfolio-grade project that demonstrates adaptive Flutter UI, clean domain boundaries, role-aware workflows, seeded local data, and a Supabase-ready database design.

## Preview

Screenshot placeholders are reserved for:

- `docs/screenshots/dashboard.png`
- `docs/screenshots/kanban.png`
- `docs/screenshots/task-detail.png`
- `docs/screenshots/admin-roles.png`

## Features

- Demo login that runs without external services or secrets.
- Authentication screens for login, registration, profile, and logout flow.
- Dashboard metrics for active projects, due soon, overdue, and completed work.
- Workspace view with members, titles, role badges, invite UI, and settings.
- Project list with progress, status, create flow, and responsive cards.
- Task list and Kanban-style board with status, priority, assignee, labels, due dates, comments-ready data, search, filters, and status updates.
- Demo role switcher for Owner, Admin, Member, and Viewer.
- Light, dark, and system theme modes.
- Mobile bottom navigation, tablet navigation rail, and desktop side navigation.
- Supabase/PostgreSQL migration with workspace, project, task, label, comment, and activity tables.
- Tests for permission policy, demo data, and app smoke flow.

## Demo Mode

TaskFlow is intentionally runnable without Supabase credentials.

```bash
flutter pub get
flutter run
```

Use **Continue in demo mode** on the login screen.

Seeded demo users:

| Role | Email |
| --- | --- |
| Owner | `olivia@taskflow.demo` |
| Admin | `alex@taskflow.demo` |
| Member | `mia@taskflow.demo` |
| Viewer | `victor@taskflow.demo` |

Password validation accepts six or more characters for seeded demo emails. The settings screen includes a role switcher so reviewers can verify RBAC behavior without managing multiple accounts.

## Architecture

The project uses a feature-first shape with shared core utilities:

```text
lib/
  app/                 App composition, shell, theme
  core/                Permissions, responsive helpers, reusable widgets
  data/demo/           Seeded local demo data source
  features/            Auth, dashboard, projects, tasks, workspaces, settings
  models/              Domain models and enums
supabase/migrations/   PostgreSQL schema
test/                  Unit and widget coverage
```

The current implementation keeps dependencies intentionally lean so the portfolio demo stays easy to run. The app is organized so Supabase repositories can be added behind the same domain concepts without changing presentation code.

## Role Matrix

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

The Flutter UI hides or disables actions through `WorkspacePolicy`. In production, the same rules must also be enforced by Supabase Row Level Security.

## Supabase Setup

1. Create a Supabase project.
2. Run `supabase/migrations/0001_initial_schema.sql`.
3. Copy `.env.example` to `.env` and fill in:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
TASKFLOW_FORCE_DEMO=false
```

The migration defines:

- `profiles`
- `workspaces`
- `workspace_members`
- `projects`
- `tasks`
- `labels`
- `task_labels`
- `task_comments`
- `activity_events`

It enables RLS and documents the intended policy model. Helper functions and complete production policies should be added before deploying with real users.

## Quality Commands

```bash
dart format .
flutter analyze
flutter test
flutter build web
flutter build apk --debug
```

## What This Demonstrates

- Flutter adaptive layouts across mobile, tablet, and desktop/web.
- Domain modeling for collaborative project/task management.
- Role-based UI and tested permission behavior.
- Demo-first product thinking for recruiter-friendly evaluation.
- Supabase-ready backend planning without committing secrets.
- Professional documentation and CI quality gates.

## Known Limitations

- Demo data is in memory and resets when the app restarts.
- Supabase repositories are not fully wired to runtime UI yet; the schema and boundaries are prepared.
- Kanban status changes use dropdown controls rather than drag and drop.
- Screenshot files are placeholders until captured from a running build.

## Roadmap

- Add Supabase repository implementations for auth and CRUD.
- Add drag-and-drop Kanban interactions.
- Persist demo theme and selected role with local storage.
- Add richer task detail pages with comment creation.
- Capture real screenshots for the README preview section.
