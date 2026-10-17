import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/professions.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../services/gemini_client.dart';
import '../services/saathi_ai.dart';

/// Single source of truth for the signed-in worker. Every "Next Step" CTA is
/// a method here that writes the target tab's input and switches tab.
class AppState extends ChangeNotifier {
  AppState({SaathiAi? ai}) : ai = ai ?? SaathiAi(GeminiClient());

  final SaathiAi ai;
  SharedPreferences? _prefs;

  AppLang lang = AppLang.en;
  Profile? profile;
  int tab = 0;
  bool loaded = false;

  final logCtrl = TextEditingController();
  final disputeCtrl = TextEditingController();
  final docCtrl = TextEditingController();

  /// Which AI task is running ('earn', 'draft', 'doc', 'welfare', 'proof').
  String? busy;
  int retryN = 0;
  final Map<String, Source> sources = {};

  EarnResult earn = const EarnResult(gross: 0, expense: 0, deduction: 0);
  GrievanceResult? letter;
  Recipient recipient = Recipient.platform;
  DocResult? doc;
  String welfareAdvice = '';
  int? monthlyOverride;
  String hazardId = '';
  List<bool> checks = [];
  List<CashEntry> cash = [];
  List<SmsEntry> sms = [];
  Map<String, int> history = {};
  ProofResult? proof;
  bool proofUsed = false;
  String? toast;

  Profession get prof => professions[profile?.professionId ?? 'delivery']!;
  bool get aiLive => ai.gemini.hasKey && !ai.gemini.simulateOffline;

  // ---------- persistence ----------

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final p = _prefs!;
    lang = AppLang.values.asNameMap()[p.getString('lang')] ?? AppLang.en;
    final key = p.getString('apiKey');
    if (key != null && key.isNotEmpty) ai.gemini.apiKey = key;
    final prof = p.getString('profile');
    if (prof != null) {
      profile = Profile.fromJson(jsonDecode(prof) as Map<String, dynamic>);
      _setupProfession();
      cash = _readList(p.getString('cash'), CashEntry.fromJson);
      sms = _readList(p.getString('sms'), SmsEntry.fromJson);
      history = (jsonDecode(p.getString('history') ?? '{}') as Map<String, dynamic>).cast<String, int>();
      final saved = (jsonDecode(p.getString('checks') ?? '[]') as List).cast<bool>();
      if (saved.length == checks.length) checks = saved;
    }
    loaded = true;
    notifyListeners();
  }

  static List<T> _readList<T>(String? raw, T Function(Map<String, dynamic>) f) =>
      raw == null ? [] : [for (final e in jsonDecode(raw) as List) f(e as Map<String, dynamic>)];

  void _save() {
    final p = _prefs;
    if (p == null) return;
    p.setString('lang', lang.name);
    if (profile == null) return;
    p.setString('profile', jsonEncode(profile!.toJson()));
    p.setString('cash', jsonEncode([for (final c in cash) c.toJson()]));
    p.setString('sms', jsonEncode([for (final s in sms) s.toJson()]));
    p.setString('history', jsonEncode(history));
    p.setString('checks', jsonEncode(checks));
  }

  // ---------- account ----------

  void setLang(AppLang l) {
    lang = l;
    if (profile != null && sources['draft'] != Source.gemini) _fallbackLetter();
    _save();
    notifyListeners();
  }

  void completeOnboarding(Profile p) {
    final changedWork = profile?.professionId != p.professionId;
    profile = p;
    if (changedWork) {
      cash = [];
      sms = [];
      _setupProfession();
    } else {
      _fallbackLetter();
    }
    tab = 0;
    _save();
    notifyListeners();
  }

  Future<void> logout() async {
    final keep = lang;
    await _prefs?.clear();
    profile = null;
    cash = [];
    sms = [];
    history = {};
    sources.clear();
    tab = 0;
    lang = keep;
    _save();
    notifyListeners();
  }

  void setApiKey(String key) {
    ai.gemini.apiKey = key.trim();
    _prefs?.setString('apiKey', key.trim());
    notifyListeners();
  }

  void setSimulateOffline(bool v) {
    ai.gemini.simulateOffline = v;
    notifyListeners();
  }

  /// Pre-fills every module for the chosen work so each tab is useful at once.
  void _setupProfession() {
    final pr = prof;
    logCtrl.text = pr.defaultLog;
    disputeCtrl.text = pr.defaultIssue;
    docCtrl.text = pr.defaultDoc;
    earn = pr.sample;
    recipient = pr.recipient;
    doc = pr.doc;
    hazardId = pr.hazards.first.id;
    checks = List.filled(pr.safetyChecklist.length, false);
    monthlyOverride = null;
    proof = null;
    proofUsed = false;
    sources.clear();
    _fallbackLetter();
    welfareAdvice = ai.fallback.welfareFirstStep(schemes);
  }

  void _fallbackLetter() {
    letter = ai.fallback.draftGrievance(
        dispute: disputeCtrl.text, recipient: recipient, profile: profile!, prof: prof, lang: lang, proof: proof);
  }

  // ---------- money ----------

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  List<CashEntry> get todayCash => cash.where((c) => _isToday(c.at)).toList();

  ({int gross, int expense, int deduction, int cashIn, int smsIn, int net}) get totals {
    int sum(Iterable<({EntryDir? dir, int amount})> xs, EntryDir d) =>
        xs.where((x) => x.dir == d).fold(0, (a, x) => a + x.amount);
    final c = todayCash.map((e) => (dir: e.dir as EntryDir?, amount: e.amount));
    final s = sms
        .where((e) => e.status == SmsStatus.added && e.kind != SmsKind.payout && _isToday(e.at))
        .map((e) => (dir: e.dir, amount: e.amount));
    final cashIn = sum(c, EntryDir.gotMoney), smsIn = sum(s, EntryDir.gotMoney);
    final gross = earn.gross + cashIn + smsIn;
    final expense = earn.expense + sum(c, EntryDir.spentMoney) + sum(s, EntryDir.spentMoney);
    return (
      gross: gross,
      expense: expense,
      deduction: earn.deduction,
      cashIn: cashIn,
      smsIn: smsIn,
      net: gross - expense - earn.deduction,
    );
  }

  int get monthlyEstimate => totals.net * 26;
  int get monthly => monthlyOverride ?? monthlyEstimate;
  List<Scheme> get schemes => matchSchemes(profile!, monthly);

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _recordToday() {
    history[dayKey(DateTime.now())] = totals.net;
    _save();
  }

  void addCash(EntryDir dir, int amount, String label) {
    cash.insert(0, CashEntry(dir: dir, amount: amount, label: label, at: DateTime.now()));
    _recordToday();
    notifyListeners();
  }

  void removeCash(CashEntry e) {
    cash.remove(e);
    _recordToday();
    notifyListeners();
  }

  /// Returns false when no amount could be read from [text].
  bool readSms(String text) {
    final e = ai.fallback.parseSms(text, prof, earn, logCtrl.text);
    if (e == null) return false;
    sms.removeWhere((s) => s.text == e.text);
    sms.insert(0, e);
    _save();
    notifyListeners();
    return true;
  }

  void loadSampleSms() {
    for (final s in prof.sampleSms.reversed) {
      readSms(s);
    }
  }

  void setSmsStatus(SmsEntry e, SmsStatus st) {
    e.status = st;
    _recordToday();
    notifyListeners();
  }

  // ---------- AI runs ----------

  Future<void> _run<T>(String key, Future<Answer<T>> Function(void Function(int)) call, void Function(T) apply) async {
    busy = key;
    retryN = 0;
    notifyListeners();
    final (value, src) = await call((n) {
      retryN = n;
      notifyListeners();
    });
    apply(value);
    sources[key] = src;
    busy = null;
    retryN = 0;
    _save();
    notifyListeners();
  }

  Future<void> calculate() => _run('earn', (r) => ai.analyzeEarnings(logCtrl.text, lang, prof, profile!, onRetry: r),
          (v) {
        earn = v;
        monthlyOverride = null;
        _recordToday();
      });

  Future<void> draft() => _run(
      'draft',
      (r) => ai.draftGrievance(
          dispute: disputeCtrl.text,
          recipient: recipient,
          lang: lang,
          prof: prof,
          profile: profile!,
          proof: proof,
          onRetry: r),
      (v) => letter = v);

  Future<void> decode() =>
      _run('doc', (r) => ai.decodeDocument(docCtrl.text, lang, prof, profile!, onRetry: r), (v) => doc = v);

  Future<void> runWelfare() => _run('welfare',
      (r) => ai.welfareFirstStep(schemes, monthly, lang, prof, profile!, onRetry: r), (v) => welfareAdvice = v);

  Future<void> attachProof(Uint8List bytes, String mime, String name) async {
    busy = 'proof';
    proof = null;
    proofUsed = false;
    notifyListeners();
    final r = await ai.readProof(bytes, mime, name, lang, prof, profile!, disputeCtrl.text, onRetry: (n) {
      retryN = n;
      notifyListeners();
    });
    proof = r ??
        ProofResult(fileName: name, kind: 'Photo', facts: const [], sentence: '', bytes: bytes, readOk: false);
    busy = null;
    retryN = 0;
    notifyListeners();
  }

  void useSampleProof() {
    proof = prof.sampleProof;
    proofUsed = false;
    notifyListeners();
  }

  void useProofFacts() {
    final p = proof;
    if (p == null || p.sentence.isEmpty) return;
    disputeCtrl.text = '${disputeCtrl.text.trim()} ${p.sentence}';
    proofUsed = true;
    draft();
  }

  // ---------- navigation & hand-offs ----------

  void goTab(int i, {bool filled = false}) {
    tab = i;
    if (filled) toast = tr(lang, 'filled', {'tab': tabNames(lang)[i]});
    notifyListeners();
  }

  String? takeToast() {
    final t = toast;
    toast = null;
    return t;
  }

  void setRecipient(Recipient r) {
    recipient = r;
    notifyListeners();
  }

  void _toComplaint(String text, Recipient r) {
    disputeCtrl.text = text;
    recipient = r;
    goTab(1, filled: true);
    draft();
  }

  /// Earnings → Complaint
  void contestDeduction() {
    final note = logCtrl.text.trim() == prof.defaultLog ? prof.defaultIssue : 'My shift note: "${logCtrl.text.trim()}"';
    _toComplaint('${inr(earn.deduction)} was cut from my pay. ${earn.deductionWhy} $note'.replaceAll(RegExp(r'\s+'), ' ').trim(),
        prof.recipient);
  }

  /// Earnings → Schemes
  void checkSchemes() {
    monthlyOverride = monthlyEstimate;
    goTab(2, filled: true);
    runWelfare();
  }

  /// Schemes → Papers
  void docHelpFor(Scheme s) {
    docCtrl.text = 'Documents needed for ${s.name}:\n${s.kyc.map((k) => '• $k').join('\n')}';
    goTab(3, filled: true);
    decode();
  }

  /// Papers → Complaint
  void replyToNotice() {
    final d = doc!;
    final r = d.type.toLowerCase().contains('challan')
        ? Recipient.court
        : prof.id == 'daily_wage'
            ? Recipient.labour
            : Recipient.platform;
    _toComplaint(
        'About the ${d.type.toLowerCase()} I received: ${d.summary} I believe this is wrong and want to contest it. '
        'Notice text: "${docCtrl.text.trim()}"',
        r);
  }

  /// Safety → Complaint
  void reportHazard() {
    final h = prof.hazards.firstWhere((h) => h.id == hazardId);
    final d = DateTime.now();
    _toComplaint(
        'Unsafe work condition: ${h.label}. On ${d.day}/${d.month}/${d.year} I paused work for my safety. '
        'I request that my account is not blocked, rated down or penalised for this pause, and that ${h.fix}.',
        prof.id == 'daily_wage' ? Recipient.labour : Recipient.platform);
  }

  /// SMS payout cut → Complaint
  void disputeSms(SmsEntry e) {
    _toComplaint('My bank SMS shows money missing: "${e.text}" ${e.flagReason}.', prof.recipient);
  }

  void setHazard(String id) {
    hazardId = id;
    notifyListeners();
  }

  void toggleCheck(int i, bool v) {
    checks[i] = v;
    _save();
    notifyListeners();
  }

  @override
  void dispose() {
    logCtrl.dispose();
    disputeCtrl.dispose();
    docCtrl.dispose();
    super.dispose();
  }
}
