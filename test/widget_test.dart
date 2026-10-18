
import 'package:flutter_test/flutter_test.dart';
import 'package:skillbytes_app/main.dart';

void main() {
  testWidgets('SkillBytes starts at login and navigates to home',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SkillBytesApp());

    expect(find.text('SkillBytes'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    await tester.enterText(
      find.byType(TextFormField).first,
      'learner@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).last,
      'password',
    );
    await tester.tap(find.text('Log In'));
    await tester.pump(const Duration(milliseconds: 950));
    await tester.pumpAndSettle();

    expect(find.text('Hello, learner!'), findsOneWidget);
  });
}
