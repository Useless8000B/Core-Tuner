import 'package:flutter_test/flutter_test.dart';
import 'package:core_tuner/main.dart';

void main() {
  testWidgets('Smoke test - App simple boot', (WidgetTester tester) async {
    await tester.pumpWidget(const CoreTuner(hasRoot: false));
    expect(find.byType(CoreTuner), findsOneWidget);
  });
}