import '../data/professions.dart';
import '../l10n/strings.dart';
import '../models/models.dart';

/// Deterministic answers used when Gemini is unreachable, so every flow
/// still completes. Nothing here touches the network.
class FallbackEngine {
  const FallbackEngine();

  static final _amount = RegExp(r'(?:₹|rs\.?|inr)\s?([\d,]+(?:\.\d{1,2})?)', caseSensitive: false);

  static int _toInt(String s) => double.parse(s.replaceAll(',', '')).round();

  EarnResult parseLog(String text, Profession prof) {
    if (text.trim() == prof.defaultLog) return prof.sample;
    var gross = 0, expense = 0, deduction = 0;
    // Classify each amount by the clause it sits in. Split on sentence ends
    // and ", " but not inside numbers like ₹1,150 or 180.00.
    for (final clause in text.split(RegExp(r'\.(?=\s|$)|[;\n]|,\s'))) {
      final ctx = clause.toLowerCase();
      for (final m in _amount.allMatches(clause)) {
        final amt = _toInt(m.group(1)!);
        if (RegExp(r'penalt|deduct|held back|withh|toll|commission|cut|fine').hasMatch(ctx)) {
          deduction += amt;
        } else if (RegExp(r'petrol|cng|fuel|diesel|bus|spent|repair|food').hasMatch(ctx)) {
          expense += amt;
        } else if (gross == 0) {
          gross = amt;
        }
      }
    }
    if (gross == 0) return prof.sample;
    final unfair = deduction > 0 &&
        RegExp(r'even though|despite|without|not added|withh|wrong', caseSensitive: false).hasMatch(text);
    return EarnResult(
      gross: gross,
      expense: expense,
      deduction: deduction,
      deductionWhy: unfair ? 'Your note says the cut was not your fault. Keep screenshots or receipts as proof.' : '',
    );
  }

  DocResult decodeDocument(String text, Profession prof) {
    if (text.trim() == prof.defaultDoc) return prof.doc;
    if (text.startsWith('Documents needed for')) {
      final scheme = RegExp(r'for (.+?):').firstMatch(text)?.group(1) ?? 'this scheme';
      final items = text.split('\n').where((l) => l.startsWith('• ')).map((l) => l.substring(2)).toList();
      return DocResult(
        type: 'Scheme checklist',
        summary: 'To apply for $scheme, you need ${items.length} documents. Get them ready before you go to a CSC centre.',
        terms: const [
          ('KYC', 'Proof of who you are: Aadhaar, bank details, photo'),
          ('CSC centre', 'Common Service Centre, a local shop that fills government forms for a small fee'),
        ],
        steps: [
          'Collect: ${items.take(2).join(' and ')}.',
          items.length > 2 ? 'Also arrange: ${items.skip(2).join(', ')}.' : 'Make one photocopy of each document.',
          'Visit the nearest CSC centre or the official portal to register.',
        ],
      );
    }
    final lower = text.toLowerCase();
    final type = lower.contains('challan')
        ? 'Traffic e-challan'
        : lower.contains('penalt') || lower.contains('debited')
            ? 'Penalty notice'
            : lower.contains('kyc') || lower.contains('aadhaar') || lower.contains('registration')
                ? 'Registration notice'
                : 'Notice';
    final first = text.split(RegExp(r'[.:]')).firstWhere((s) => s.trim().length > 12, orElse: () => text).trim();
    final deadline = RegExp(r'(\d+)\s*(hours|days)', caseSensitive: false).firstMatch(text)?.group(0) ?? '';
    return DocResult(
      type: type,
      summary: 'This paper says: $first. Below are the steps to take.',
      terms: const [],
      steps: const [
        'Keep the original paper or a clear photo of it.',
        'Note any date or amount written on it.',
        'Reply in writing and keep a copy of your reply.',
      ],
      deadline: deadline,
    );
  }

  GrievanceResult draftGrievance({
    required String dispute,
    required Recipient recipient,
    required Profile profile,
    required Profession prof,
    required AppLang lang,
    ProofResult? proof,
  }) {
    final found = _amount.firstMatch(dispute);
    final amt = found == null ? 'the money' : inr(_toInt(found.group(1)!));
    final recName = tr(lang, switch (recipient) {
      Recipient.platform => 'recPlatform',
      Recipient.contractor => 'recContractor',
      Recipient.labour => 'recLabour',
      Recipient.court => 'recCourt',
    });
    final to = switch (recipient) {
      Recipient.platform => 'Partner Support Team',
      Recipient.contractor => prof.id == 'daily_wage' ? 'Site Contractor, Sector 42 site' : 'Fleet owner',
      Recipient.labour => 'Labour Officer, ${profile.state}',
      Recipient.court => 'Virtual Traffic Court',
    };
    final subject = switch (recipient) {
      Recipient.platform => 'Request to reverse wrong deduction – Partner ${prof.partnerId}',
      Recipient.contractor => 'Request for full payment of promised wages',
      Recipient.labour => 'Complaint about unpaid wages – ${profile.name}',
      Recipient.court => 'Request to contest challan – ${prof.partnerId}',
    };
    final proofLine = proof != null
        ? 'Proof attached: ${proof.fileName}.'
        : 'Proof is attached: screenshots and receipts with date and time.';
    final body = 'Dear Sir/Madam,\n\n'
        'I, ${profile.name}, work as a ${prof.role} (ID: ${prof.partnerId}). I am writing about the following issue:\n\n'
        '$dispute\n\n'
        'I request you to (a) review this within 7 days, (b) return $amt or cancel the penalty, and (c) send me your reply in writing.\n\n'
        '$proofLine\n\n'
        'Thank you,\n${profile.name}\nPhone: +91 ${profile.maskedPhone}';
    final explanation = switch (lang) {
      AppLang.en =>
        'You are asking the $recName to give back $amt and explain the cut in writing. Send this letter, take a screenshot after sending, and wait 7 days. If nobody replies, Saathi will help you write to the Labour Officer next.',
      AppLang.hi =>
        'आप $recName से $amt वापस माँग रहे हैं और कटौती का कारण लिखित में माँग रहे हैं। यह पत्र भेजें, भेजने के बाद स्क्रीनशॉट लें, और 7 दिन इंतज़ार करें। जवाब न आए तो साथी आगे श्रम अधिकारी को पत्र लिखने में मदद करेगा।',
      AppLang.pa =>
        'ਤੁਸੀਂ $recName ਤੋਂ $amt ਵਾਪਸ ਮੰਗ ਰਹੇ ਹੋ ਅਤੇ ਕਟੌਤੀ ਦਾ ਕਾਰਨ ਲਿਖਤ ਵਿੱਚ ਮੰਗ ਰਹੇ ਹੋ। ਇਹ ਚਿੱਠੀ ਭੇਜੋ, ਭੇਜਣ ਤੋਂ ਬਾਅਦ ਸਕ੍ਰੀਨਸ਼ਾਟ ਲਓ, ਅਤੇ 7 ਦਿਨ ਉਡੀਕ ਕਰੋ। ਜਵਾਬ ਨਾ ਆਵੇ ਤਾਂ ਸਾਥੀ ਅੱਗੇ ਲੇਬਰ ਅਫ਼ਸਰ ਨੂੰ ਚਿੱਠੀ ਲਿਖਣ ਵਿੱਚ ਮਦਦ ਕਰੇਗਾ।',
      AppLang.hl =>
        'Aap $recName se $amt wapas maang rahe ho aur katauti ka reason likhit mein maang rahe ho. Yeh letter bhejo, bhejne ke baad screenshot lo, aur 7 din wait karo. Jawab na aaye toh Saathi aage Labour Officer ko likhne mein madad karega.',
    };
    return GrievanceResult(explanation: explanation, to: to, subject: subject, body: body);
  }

  String welfareFirstStep(List<Scheme> schemes) {
    final first = schemes.firstWhere((s) => s.status == SchemeStatus.eligible, orElse: () => schemes.first);
    return 'Start with ${first.name}. Carry ${first.kyc.first} to a CSC centre. It is free to register.';
  }

  /// Reads one bank/UPI SMS on the device. Compares it with today's log so
  /// money already counted is not counted twice.
  SmsEntry? parseSms(String raw, Profession prof, EarnResult today, String todayLog) {
    final text = raw.trim();
    final m = _amount.firstMatch(text);
    if (m == null) return null;
    final amount = _toInt(m.group(1)!);
    final lower = text.toLowerCase();
    final isIn = RegExp(r'credited|received|deposited').hasMatch(lower);
    final isOut = !isIn && RegExp(r'debited|sent|paid|withdrawn|spent').hasMatch(lower);
    final sender = RegExp(r'-\s*([A-Za-z][A-Za-z ]{2,30})\s*$').firstMatch(text)?.group(1)?.trim() ?? 'Bank SMS';
    final party = RegExp(r'(?:from|to|at)\s+([A-Z][A-Z .]{2,40}?)(?=\s+via|\s+by|\.|$)').firstMatch(text)?.group(1);
    final partyLabel = party == null ? null : _title(party);

    final looksPayout = isIn && RegExp(r'payout|earnings|settlement|wages|salary').hasMatch(lower);
    if (looksPayout) {
      var flag = 0;
      var reason = '';
      final adj = RegExp(r'adj\w*:?\s*-\s*([\d,]+(?:\.\d+)?)', caseSensitive: false).firstMatch(text);
      final days = RegExp(r'wages\s+(\d{1,2})\s*-\s*(\d{1,2})', caseSensitive: false).firstMatch(text);
      if (adj != null) {
        flag = _toInt(adj.group(1)!);
        reason = 'This payout has a ${inr(flag)} cut';
      } else if (RegExp(r'(toll|reimburs\w*)[^.]*:\s*0(\.0+)?\b', caseSensitive: false).hasMatch(text) &&
          today.deduction > 0) {
        flag = today.deduction;
        reason = 'Toll was not repaid (${inr(flag)})';
      } else if (days != null && prof.id == 'daily_wage') {
        final n = int.parse(days.group(2)!) - int.parse(days.group(1)!) + 1;
        final promised = n * prof.sample.gross;
        if (n > 0 && amount < promised) {
          flag = promised - amount;
          reason = '$n days of wages: ${inr(flag)} less than the ${inr(promised)} promised';
        }
      }
      return SmsEntry(
        text: text,
        sender: sender,
        kind: SmsKind.payout,
        amount: amount,
        label: reason.isEmpty ? 'Payout' : reason,
        flagAmount: flag,
        flagReason: reason,
        at: DateTime.now(),
      );
    }

    final dir = isIn ? EntryDir.gotMoney : (isOut ? EntryDir.spentMoney : null);
    if (dir == null) return null;
    final inLog = RegExp('₹\\s?${_withCommas(amount)}\\b').hasMatch(todayLog) ||
        RegExp('₹\\s?$amount\\b').hasMatch(todayLog);
    final personal = RegExp(r'kirana|store|recharge|mart|grocery|bazaar').hasMatch(lower);
    final label = isIn
        ? 'From ${partyLabel ?? 'UPI'}'
        : (partyLabel ?? 'Payment');
    return SmsEntry(
      text: text,
      sender: sender,
      kind: inLog ? SmsKind.duplicate : (personal ? SmsKind.personal : SmsKind.payment),
      dir: dir,
      amount: amount,
      label: label,
      at: DateTime.now(),
    );
  }

  static String _withCommas(int n) => inr(n).substring(1);

  static String _title(String s) => s
      .trim()
      .split(RegExp(r'\s+'))
      .map((w) => w.length <= 2 ? w : '${w[0]}${w.substring(1).toLowerCase()}')
      .join(' ');
}
