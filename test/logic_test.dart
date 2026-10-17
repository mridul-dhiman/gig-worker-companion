import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saathi_ai/data/professions.dart';
import 'package:saathi_ai/models/models.dart';
import 'package:saathi_ai/services/fallback_engine.dart';
import 'package:saathi_ai/services/gemini_client.dart';

void main() {
  const engine = FallbackEngine();
  final delivery = professions['delivery']!;
  final driver = professions['driver']!;
  final daily = professions['daily_wage']!;

  test('inr uses Indian grouping', () {
    expect(inr(730), '₹730');
    expect(inr(18980), '₹18,980');
    expect(inr(1234567), '₹12,34,567');
  });

  test('parses a custom shift log', () {
    final r = engine.parseLog(
        'Earned ₹900 today. Spent ₹100 on petrol. Platform deducted ₹50 penalty even though I was on time.', delivery);
    expect((r.gross, r.expense, r.deduction), (900, 100, 50));
    expect(r.deductionWhy, isNotEmpty);
  });

  test('SMS: tip is a payment, petrol is a duplicate, payout cut is flagged', () {
    final s = delivery.sampleSms.map((t) => engine.parseSms(t, delivery, delivery.sample, delivery.defaultLog)!).toList();
    expect(s[0].kind, SmsKind.payment);
    expect(s[0].dir, EntryDir.gotMoney);
    expect(s[0].amount, 60);
    expect(s[1].kind, SmsKind.payout);
    expect(s[1].flagAmount, 180);
    expect(s[2].kind, SmsKind.duplicate);
  });

  test('SMS: unpaid toll and short wages are flagged', () {
    final toll = engine.parseSms(driver.sampleSms[1], driver, driver.sample, driver.defaultLog)!;
    expect(toll.flagAmount, 120);
    final wages = engine.parseSms(daily.sampleSms[0], daily, daily.sample, daily.defaultLog)!;
    expect(wages.flagAmount, 600);
    final grocery = engine.parseSms(daily.sampleSms[1], daily, daily.sample, daily.defaultLog)!;
    expect(grocery.kind, SmsKind.personal);
  });

  test('scheme matching follows age and income rules', () {
    const p = Profile(name: 'Test', age: 29, state: 'Delhi', phone: '9876504410', professionId: 'delivery');
    final high = matchSchemes(p, 18980).firstWhere((s) => s.name.startsWith('PM Shram'));
    expect(high.status, SchemeStatus.notEligible);
    final low = matchSchemes(p, 12000).firstWhere((s) => s.name.startsWith('PM Shram'));
    expect(low.status, SchemeStatus.eligible);
  });

  test('Gemini client retries 503 then succeeds', () async {
    var calls = 0;
    final client = GeminiClient(
      httpClient: MockClient((req) async {
        calls++;
        if (calls == 1) return http.Response('busy', 503);
        final inner = jsonEncode({'advice': 'ok'});
        return http.Response(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': inner}
                    ]
                  }
                }
              ]
            }),
            200);
      }),
    )..apiKey = 'test';
    final retries = <int>[];
    final out = await client.generateJson(
        systemInstruction: 's', prompt: 'p', schema: obj({'advice': str}), onRetry: retries.add);
    expect(out, {'advice': 'ok'});
    expect(calls, 2);
    expect(retries, [2]);
  });

  test('Gemini client gives up after 3 attempts and returns null', () async {
    var calls = 0;
    final client = GeminiClient(httpClient: MockClient((_) async {
      calls++;
      return http.Response('down', 500);
    }))
      ..apiKey = 'test';
    final out = await client.generateJson(systemInstruction: 's', prompt: 'p', schema: obj({'a': str}));
    expect(out, isNull);
    expect(calls, GeminiClient.maxAttempts);
  });
}
