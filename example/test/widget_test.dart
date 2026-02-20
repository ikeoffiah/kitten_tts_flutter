import 'package:flutter_test/flutter_test.dart';
import 'package:kitten_tts_flutter_example/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const KittenTTSDemo());
    expect(find.text('KittenTTS Demo'), findsOneWidget);
  });
}
