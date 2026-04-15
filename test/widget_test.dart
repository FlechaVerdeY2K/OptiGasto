import 'package:flutter_test/flutter_test.dart';
import 'package:optigasto/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OptiGastoApp());

    // Verify that splash screen is shown
    expect(find.text('OptiGasto'), findsOneWidget);
    expect(find.text('Encuentra ofertas y promociones cerca de ti'),
        findsOneWidget);
  });
}

// Made with Bob
