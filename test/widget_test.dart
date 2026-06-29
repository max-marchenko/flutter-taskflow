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
}
