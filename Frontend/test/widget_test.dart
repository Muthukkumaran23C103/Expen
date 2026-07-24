import 'package:flutter_test/flutter_test.dart';
import 'package:expensr_frontend/main.dart';

void main() {
  testWidgets('App load test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenSRApp());
    expect(find.byType(ExpenSRApp), findsOneWidget);
  });
}
