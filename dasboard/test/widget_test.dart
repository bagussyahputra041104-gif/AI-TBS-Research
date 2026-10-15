import 'package:flutter_test/flutter_test.dart';
import 'package:dasboard/app.dart';

void main() {
  testWidgets('PalmVision app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const PalmVisionApp());

    expect(find.text('PalmVision'), findsOneWidget);
  });
}
