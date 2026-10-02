import 'package:finder/features/admin/admin_console_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the server status and falls back to the built-in provider list', () {
    final info = AiSettingsInfo.fromApi({
      'configured': true,
      'enabled': true,
      'provider': 'custom',
      'providerLabel': 'OpenAI-compatible',
      'model': 'llama3',
      'baseUrl': 'http://localhost:11434/v1',
      'source': 'db',
      'keyHint': '…0001',
      'pendingTranslations': 7,
      'unscoredPending': '2',
      'providers': [
        {'id': 'google', 'label': 'Google AI Studio', 'defaultModel': 'gemini-2.5-flash-lite'},
        {'id': 'custom', 'label': 'OpenAI-compatible', 'defaultModel': ''},
      ],
    });
    expect(info.configured, isTrue);
    expect(info.provider, 'custom');
    expect(info.pendingTranslations, 7);
    expect(info.unscoredPending, 2);
    expect(info.providers.length, 2);
    expect(info.defaultModelFor('google'), 'gemini-2.5-flash-lite');
    expect(info.defaultModelFor('nope'), '');

    final bare = AiSettingsInfo.fromApi({'configured': false});
    expect(bare.source, 'none');
    expect(bare.providers.length, 4);
    expect(bare.defaultModelFor('anthropic'), 'claude-haiku-4-5-20251001');
  });
}
