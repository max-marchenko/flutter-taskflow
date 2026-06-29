import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/app/app.dart';

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
}
