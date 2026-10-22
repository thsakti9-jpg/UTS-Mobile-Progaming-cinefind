import 'package:flutter_test/flutter_test.dart';
import 'package:cinefind/main.dart';

void main() {
  testWidgets('CineFind app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CineFindApp());

    // Verify that the app title header is rendered.
    expect(find.text('CINEFIND'), findsOneWidget);
  });
}
