import 'package:flutter_test/flutter_test.dart';
import 'package:kalasaathi/main.dart';

void main() {
  testWidgets('KalaSaathi app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const KalaSaathiApp());

    // Allow splash screen animations and delayed timers to complete
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Verify that KalaSaathi app is running
    expect(find.byType(KalaSaathiApp), findsOneWidget);
  });
}
