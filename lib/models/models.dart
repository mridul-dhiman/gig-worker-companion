import 'dart:typed_data';

/// Where an answer came from: Gemini, or the built-in rule engine.
enum Source { gemini, fallback }

class Profile {
  const Profile({
    required this.name,
    required this.age,
    required this.state,
    required this.phone,
    required this.professionId,
  });

  final String name;
  final int age;
  final String state;
  final String phone;
  final String professionId;

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map((w) => w[0])
      .take(2)
      .join()
      .toUpperCase();
  String get maskedPhone =>
      phone.length == 10 ? '${phone.substring(0, 2)}xxxx${phone.substring(6)}' : phone;

  Profile copyWith({String? professionId, String? name, int? age, String? state}) => Profile(
        name: name ?? this.name,
        age: age ?? this.age,
        state: state ?? this.state,
        phone: phone,
        professionId: professionId ?? this.professionId,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'age': age, 'state': state, 'phone': phone, 'professionId': professionId};

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] as String,
        age: j['age'] as int,
        state: j['state'] as String,
        phone: j['phone'] as String,
        professionId: j['professionId'] as String,
      );
}

class EarnResult {
  const EarnResult({
    required this.gross,
    required this.expense,
    required this.deduction,
    this.deductionWhy = '',
    this.summary = '',
  });

  final int gross;
  final int expense;
  final int deduction;

  /// Non-empty when the deduction looks unfair; explains why in plain words.
  final String deductionWhy;
  final String summary;
}

class DocResult {
  const DocResult({
    required this.type,
    required this.summary,
    required this.terms,
    required this.steps,
    this.deadline = '',
  });

  final String type;
  final String summary;
  final List<(String, String)> terms;
  final List<String> steps;
  final String deadline;
}

class GrievanceResult {
  const GrievanceResult({
    required this.explanation,
    required this.to,
    required this.subject,
    required this.body,
  });

  final String explanation;
  final String to;
  final String subject;
  final String body;

  String get fullText => 'To: $to\nSubject: $subject\n\n$body';
}

class ProofResult {
  const ProofResult({
    required this.fileName,
    required this.kind,
    required this.facts,
    required this.sentence,
    this.bytes,
    this.readOk = true,
  });

  final String fileName;
  final String kind;
  final List<(String, String)> facts;

  /// One sentence ready to append to the complaint.
  final String sentence;
  final Uint8List? bytes;
  final bool readOk;
}

enum EntryDir { gotMoney, spentMoney }

class CashEntry {
  const CashEntry({required this.dir, required this.amount, required this.label, required this.at});

  final EntryDir dir;
  final int amount;
  final String label;
  final DateTime at;

  Map<String, dynamic> toJson() =>
      {'dir': dir.name, 'amount': amount, 'label': label, 'at': at.toIso8601String()};

  factory CashEntry.fromJson(Map<String, dynamic> j) => CashEntry(
        dir: EntryDir.values.byName(j['dir'] as String),
        amount: j['amount'] as int,
        label: j['label'] as String,
        at: DateTime.parse(j['at'] as String),
      );
}

enum SmsKind { payment, payout, duplicate, personal }

enum SmsStatus { pending, added, ignored }

class SmsEntry {
  SmsEntry({
    required this.text,
    required this.sender,
    required this.kind,
    required this.amount,
    required this.label,
    required this.at,
    this.dir,
    this.flagAmount = 0,
    this.flagReason = '',
    this.status = SmsStatus.pending,
  });

  final String text;
  final String sender;
  final SmsKind kind;
  final EntryDir? dir;
  final int amount;
  final String label;
  final int flagAmount;
  final String flagReason;
  final DateTime at;
  SmsStatus status;

  Map<String, dynamic> toJson() => {
        'text': text,
        'sender': sender,
        'kind': kind.name,
        'dir': dir?.name,
        'amount': amount,
        'label': label,
        'flagAmount': flagAmount,
        'flagReason': flagReason,
        'at': at.toIso8601String(),
        'status': status.name,
      };

  factory SmsEntry.fromJson(Map<String, dynamic> j) => SmsEntry(
        text: j['text'] as String,
        sender: j['sender'] as String,
        kind: SmsKind.values.byName(j['kind'] as String),
        dir: j['dir'] == null ? null : EntryDir.values.byName(j['dir'] as String),
        amount: j['amount'] as int,
        label: j['label'] as String,
        flagAmount: j['flagAmount'] as int,
        flagReason: j['flagReason'] as String,
        at: DateTime.parse(j['at'] as String),
        status: SmsStatus.values.byName(j['status'] as String),
      );
}

enum SchemeStatus { eligible, check, notEligible }

class Scheme {
  const Scheme({
    required this.name,
    required this.status,
    required this.why,
    required this.benefit,
    required this.kyc,
  });

  final String name;
  final SchemeStatus status;
  final String why;
  final String benefit;
  final List<String> kyc;
}

class Hazard {
  const Hazard({required this.id, required this.label, required this.whatToDo, required this.fix});

  final String id;
  final String label;
  final List<String> whatToDo;

  /// What the worker asks for when reporting this hazard.
  final String fix;
}
