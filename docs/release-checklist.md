# TaskFlow Release Checklist

Use this checklist before merging the feature branch into `main`.

## Automated Gates

- Run `dart format .`.
- Run `flutter analyze`.
- Run `flutter test`.
- Run `flutter build web`.
- Run `flutter build apk --debug` when Android tooling is available.

## Manual Product QA

- Launch the app with no Supabase credentials and confirm demo login works.
- Verify login validation for invalid email and short password.
- Confirm mobile width uses bottom navigation.
- Confirm tablet width uses `NavigationRail`.
- Confirm desktop/web width uses the side navigation.
- Open Dashboard and verify metrics, my tasks, and activity render.
- Open Projects and confirm project cards show progress and open the task board.
- Create a demo project as Owner or Admin.
- Open Tasks and verify search, status filter, priority filter, sort, and clear filters.
- Select a task and confirm comments, labels, assignee, status, and activity show in the detail panel.
- Switch to Viewer in Settings and confirm create/edit controls are hidden or disabled.
- Switch theme between system, light, and dark.
- Check Workspace invite/settings controls show honest demo feedback.

## Documentation QA

- Confirm README does not claim runtime Supabase integration is complete.
- Confirm screenshot section is honest if real screenshots have not been captured.
- Confirm `.env.example` contains no real secrets.
- Confirm known limitations and roadmap match the actual implementation.

## Release Decision

- Merge only when automated gates pass and screenshots or placeholder instructions are accurate.
- Do not merge if demo mode is broken, README overclaims features, or role-aware behavior is not visible.
