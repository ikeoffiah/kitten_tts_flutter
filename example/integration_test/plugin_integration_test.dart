import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_kitten_tts/flutter_kitten_tts.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('KittenTTS can be created', (WidgetTester tester) async {
    final tts = KittenTTS();
    expect(tts.isInitialized, false);
    expect(tts.availableVoices.length, 8);
  });
}
