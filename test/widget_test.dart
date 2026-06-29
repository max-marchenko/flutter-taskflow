import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app/app.dart';
import 'package:taskflow/data/demo/demo_store.dart';
import 'package:taskflow/features/projects/presentation/projects_screen.dart';

void main() {
  testWidgets('app launches to polished demo login', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('Welcome to TaskFlow'), findsOneWidget);
    expect(find.text('Continue in demo mode'), findsOneWidget);
  });

  testWidgets('demo login shows dashboard and role-aware settings', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    await tester.tap(find.text('Continue in demo mode'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Active projects'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Demo role switcher'), findsOneWidget);
    expect(find.text('Viewer'), findsWidgets);
  });

  testWidgets('viewer role hides task creation in the task workspace', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    await tester.tap(find.text('Continue in demo mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Viewer').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();

    expect(find.text('New task'), findsNothing);
    expect(
      find.text(
        'Review tasks, update status, inspect details, and switch roles to verify access.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mobile projects layout does not overflow', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final store = DemoStore()
      ..demoLogin()
      ..setThemeMode(ThemeMode.dark)
      ..setSelectedIndex(1);

    await tester.pumpWidget(
      DemoScope(
        store: store,
        child: MaterialApp(
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: const ProjectsScreen(),
            bottomNavigationBar: NavigationBar(
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.folder_copy_outlined),
                  label: 'Projects',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Mobile Redesign'), findsOneWidget);
    expect(find.text('Launch Checklist'), findsOneWidget);
    expect(find.text('Website Refresh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
