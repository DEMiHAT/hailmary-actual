import 'package:flutter_test/flutter_test.dart';
import 'package:hailmary_health/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HailMaryApp());
    expect(find.text('HAILMARY'), findsOneWidget);
  });
}
