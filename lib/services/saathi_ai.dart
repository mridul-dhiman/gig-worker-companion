import 'dart:typed_data';

import '../data/professions.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import 'fallback_engine.dart';
import 'gemini_client.dart';

typedef Answer<T> = (T, Source);

/// One method per pillar. Each tries Gemini first and falls back to the
/// deterministic engine, so callers always get a usable answer.
class SaathiAi {
  SaathiAi(this.gemini, [this.fallback = const FallbackEngine()]);

  final GeminiClient gemini;
  final FallbackEngine fallback;

  String _system(AppLang lang, Profession prof, Profile profile) => '''
You are Saathi, a kind helper for Indian gig and informal workers.
The worker is ${profile.firstName}, a ${prof.role}, age ${profile.age}, in ${profile.state}.
Write every user-facing string in ${lang.promptName}. For Hinglish, use Hindi words in Latin letters.
Rules:
- Use words a 5th-grade student understands. Short sentences.
- Be warm and on the worker's side, but stay factual. Never invent numbers that are not in the input.
- Give clear actions the worker can take today.
- Never use a legal or technical term without a plain-language meaning next to it.
- Formal letters stay in English so platforms and officers can read them.''';

  Future<Answer<EarnResult>> analyzeEarnings(String log, AppLang lang, Profession prof, Profile profile,
      {void Function(int)? onRetry}) async {
    final json = await gemini.generateJson(
      systemInstruction: _system(lang, prof, profile),
      prompt: 'Read this shift note and split the money into gross earned, work expenses, and deductions '
          'taken by the platform or employer. Use whole rupees. If a deduction looks unfair from the note, '
          'set unfair to true and explain why in one or two simple sentences.\n\nShift note: """$log"""',
      schema: obj({
        'gross': integer,
        'expenses': integer,
        'deductions': integer,
        'unfair': boolean,
        'whyUnfair': str,
        'summary': str,
      }),
      onRetry: onRetry,
    );
    try {
      if (json != null) {
        return (
          EarnResult(
            gross: (json['gross'] as num).round(),
            expense: (json['expenses'] as num).round(),
            deduction: (json['deductions'] as num).round(),
            deductionWhy: json['unfair'] == true ? json['whyUnfair'] as String : '',
            summary: json['summary'] as String? ?? '',
          ),
          Source.gemini,
        );
      }
    } catch (_) {}
    return (fallback.parseLog(log, prof), Source.fallback);
  }

  Future<Answer<GrievanceResult>> draftGrievance({
    required String dispute,
    required Recipient recipient,
    required AppLang lang,
    required Profession prof,
    required Profile profile,
    ProofResult? proof,
    void Function(int)? onRetry,
  }) async {
    final base = fallback.draftGrievance(
        dispute: dispute, recipient: recipient, profile: profile, prof: prof, lang: lang, proof: proof);
    final json = await gemini.generateJson(
      systemInstruction: _system(lang, prof, profile),
      prompt: 'Write a complaint for this worker.\n'
          'Send to: ${base.to}\n'
          'Worker ID: ${prof.partnerId}. Phone: +91 ${profile.maskedPhone}\n'
          'What happened: """$dispute"""\n'
          '${proof != null ? 'Proof attached: ${proof.fileName}. ${proof.sentence}\n' : ''}'
          'Return: explanation = 2-3 sentences in the worker language saying what this letter asks for and what to do after sending. '
          'subject = short English subject line. body = polite formal English letter, starting "Dear Sir/Madam," '
          'with a clear request, a 7-day deadline, and the worker name and phone at the end.',
      schema: obj({'explanation': str, 'subject': str, 'body': str}),
      onRetry: onRetry,
    );
    try {
      if (json != null && (json['body'] as String).length > 40) {
        return (
          GrievanceResult(
            explanation: json['explanation'] as String,
            to: base.to,
            subject: json['subject'] as String,
            body: json['body'] as String,
          ),
          Source.gemini,
        );
      }
    } catch (_) {}
    return (base, Source.fallback);
  }

  Future<Answer<DocResult>> decodeDocument(String text, AppLang lang, Profession prof, Profile profile,
      {void Function(int)? onRetry}) async {
    final json = await gemini.generateJson(
      systemInstruction: _system(lang, prof, profile),
      prompt: 'Explain this notice or document for the worker. Give: type (2-4 words), summary (2-3 simple sentences), '
          'terms (hard words from the notice with plain meanings), exactly 3 steps to do next, and the deadline '
          'if the notice states one (else empty string).\n\nNotice: """$text"""',
      schema: obj({
        'type': str,
        'summary': str,
        'terms': arr(obj({'term': str, 'meaning': str})),
        'steps': arr(str),
        'deadline': str,
      }),
      onRetry: onRetry,
    );
    try {
      if (json != null) {
        final steps = (json['steps'] as List).cast<String>();
        if (steps.isNotEmpty) {
          return (
            DocResult(
              type: json['type'] as String,
              summary: json['summary'] as String,
              terms: [
                for (final t in json['terms'] as List) ((t as Map)['term'] as String, t['meaning'] as String)
              ],
              steps: steps.take(3).toList(),
              deadline: json['deadline'] as String? ?? '',
            ),
            Source.gemini,
          );
        }
      }
    } catch (_) {}
    return (fallback.decodeDocument(text, prof), Source.fallback);
  }

  Future<Answer<String>> welfareFirstStep(List<Scheme> schemes, int monthly, AppLang lang, Profession prof,
      Profile profile, {void Function(int)? onRetry}) async {
    final list = schemes.map((s) => '- ${s.name}: ${s.status.name}. ${s.why}').join('\n');
    final json = await gemini.generateJson(
      systemInstruction: _system(lang, prof, profile),
      prompt: 'Monthly take-home is about ₹$monthly. These scheme results come from official rules; do not change them:\n'
          '$list\n\nIn 2-3 short sentences, tell the worker which one to start with today and the first thing to carry.',
      schema: obj({'advice': str}),
      onRetry: onRetry,
    );
    final advice = json?['advice'];
    if (advice is String && advice.isNotEmpty) return (advice, Source.gemini);
    return (fallback.welfareFirstStep(schemes), Source.fallback);
  }

  /// Reads a screenshot or photo for facts that support a complaint.
  /// Returns null when the picture could not be read.
  Future<ProofResult?> readProof(Uint8List bytes, String mime, String fileName, AppLang lang, Profession prof,
      Profile profile, String dispute,
      {void Function(int)? onRetry}) async {
    final json = await gemini.generateJson(
      systemInstruction: _system(lang, prof, profile),
      prompt: 'This image is proof for a worker complaint about: """$dispute"""\n'
          'Read only what is visible. Return kind (e.g. "App screenshot", "Wage slip"), up to 5 facts as label/value '
          'pairs (times, amounts, IDs), and one English sentence that states what the image proves, starting "My".',
      schema: obj({
        'kind': str,
        'facts': arr(obj({'label': str, 'value': str})),
        'sentence': str,
      }),
      imageBytes: bytes,
      imageMime: mime,
      onRetry: onRetry,
    );
    try {
      if (json != null) {
        final facts = [
          for (final f in json['facts'] as List) ((f as Map)['label'] as String, f['value'] as String)
        ];
        if (facts.isNotEmpty) {
          return ProofResult(
            fileName: fileName,
            kind: json['kind'] as String,
            facts: facts,
            sentence: json['sentence'] as String,
            bytes: bytes,
          );
        }
      }
    } catch (_) {}
    return null;
  }
}
