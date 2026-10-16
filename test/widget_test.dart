
import 'package:flutter_test/flutter_test.dart';
import 'package:skillbytes_app/main.dart';

void main() {
  testWidgets('SkillBytes Program Listing screen loads',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SkillBytesApp());

    expect(find.text('Learning Programs'), findsOneWidget);
    expect(find.text('Flutter Development'), findsOneWidget);
    expect(find.text('Python Programming'), findsOneWidget);
    expect(find.text('Networking Basics'), findsOneWidget);
  });
}
